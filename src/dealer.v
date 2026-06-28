`timescale 1ns / 1ps

module dealer_fsm (
    input wire clk,
    input wire rst,
    input wire draw, // pulso: pede uma carta
    input wire [9:0] discard_in, // carta a descartar
    input wire discard_we, // pulso: empurra discard_in pro descarte

    // interface com a RAM (instanciada no top)
    output reg [6:0] ram_addr,
    output reg ram_we,
    output reg [9:0] ram_data,
    input wire [9:0] ram_q,

    // status / saidas do jogo
    output reg ready, // embaralhamento inicial concluido
    output wire busy, // ocupado: nao aceita draw/discard agora
    output reg draw_action, // ativo: carta distribuida
    output reg [9:0] carta_sorteada, // conteudo da carta distribuida
    output reg [6:0] carta_ponteiro, // posicao (head) de onde saiu a carta
    output wire [7:0] deck_count // cartas no baralho de compra
);

    localparam [7:0] DECK0 = 8'd108; // baralho completo (indices 0..107)

    // LFSR + semente vinda da entropia do tempo de reset
    wire [7:0] lfsr_out;
    wire lfsr_done;
    reg  [7:0] entropy_counter = 8'd0; // contador livre, nao zerado pelo rst
    reg  rst_d;
    wire reset_release = rst_d & ~rst;
    wire [7:0] seed_value = (entropy_counter == 8'hFF) ? 8'h01 : entropy_counter;

    always @(posedge clk) begin
        entropy_counter <= entropy_counter + 8'd1;
        rst_d <= rst;
    end

    LFSR #(.NUM_BITS(8)) embaralhador (
        .i_Clk      (clk),
        .i_Enable   (1'b1),
        .i_Seed_DV  (reset_release),
        .i_Seed_Data(seed_value),
        .o_LFSR_Data(lfsr_out),
        .o_LFSR_Done(lfsr_done)
    );

    localparam [3:0] S_RESET=4'd0,
                     S_PICK=4'd1,      // sorteia jrand (0..shuf_n-1)
                     S_RDA_INIT=4'd2,  // apresenta o endereco da posicao i
                     S_RDA_CAP=4'd3,   // captura a = mem[i], pede mem[j]
                     S_RDB_CAP=4'd4,   // captura b = mem[j]
                     S_WRA=4'd5,       // mem[i] <= b
                     S_WRB=4'd6,       // mem[j] <= a (fim da troca)
                     S_READY=4'd7,     // fecha o lote embaralhado
                     S_DWAIT=4'd8,     // livre: espera draw / discard / reshuffle
                     S_DEAL=4'd9,      // entrega mem[head]
                     S_DISCARD=4'd10;  // grava descarte em mem[tail]

    reg [3:0] state;

    // buffer circular
    reg [6:0] head; // proxima carta a distribuir
    reg [7:0] count; // cartas no baralho de compra
    reg [7:0] shuf_left; // cartas embaralhadas restantes a partir de head
    wire [6:0] tail = head + count[6:0]; // mod 128 (wrap natural de 7 bits)

    // embaralhamento (Fisher-Yates sobre [head, head+shuf_n))
    reg [7:0] shuf_n; // tamanho do lote a embaralhar
    reg [7:0] idx; // indice corrente 0..shuf_n-1
    reg [6:0] jrand; // posicao relativa sorteada
    reg [9:0] aval, bval; // valores trocados

    wire [6:0] addr_i = head + idx[6:0]; // posicao absoluta i (mod 128)
    wire [6:0] addr_j = head + jrand; // posicao absoluta j (mod 128)

    assign busy = (state != S_DWAIT);
    assign deck_count = count;

    // controles combinacionais da RAM
    always @(*) begin
        ram_addr = 7'd0;
        ram_we   = 1'b0;
        ram_data = 10'd0;
        case (state)
        S_PICK, S_RDA_INIT: ram_addr = addr_i;
        S_RDA_CAP, S_RDB_CAP: ram_addr = addr_j;
        S_WRA: begin ram_addr = addr_i; ram_we = 1'b1; ram_data = bval; end
        S_WRB: begin ram_addr = addr_j; ram_we = 1'b1; ram_data = aval; end
        S_DISCARD: begin ram_addr = tail; ram_we = 1'b1; ram_data = discard_in; end
        default: ram_addr = head; // S_READY/S_DWAIT/S_DEAL: le mem[head]
        endcase
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= S_RESET;
            head <= 7'd0;
            count <= 8'd0;
            shuf_left <= 8'd0;
            idx <= 8'd0;
            ready <= 1'b0;
            draw_action <= 1'b0;
            carta_sorteada <= 10'd0;
            carta_ponteiro <= 7'd0;
        end else begin
            case (state)
            // prepara o embaralhamento inicial
            S_RESET: begin
                head <= 7'd0;
                count <= 8'd0; // sinaliza "embaralhamento inicial" p/ o S_READY
                ready <= 1'b0;
                shuf_n <= DECK0; // embaralha as 108 cartas
                idx <= 8'd0;
                state <= S_PICK;
            end

            // Fisher-Yates sobre (head, head+shuf_n)
            S_PICK: begin
                if (lfsr_out < shuf_n) begin // rejeita >= tamanho do lote
                    jrand <= lfsr_out[6:0];
                    state <= S_RDA_INIT;
                end
            end

            S_RDA_INIT: state <= S_RDA_CAP;

            S_RDA_CAP: begin // a = mem[i]
                aval <= ram_q;
                state <= S_RDB_CAP;
            end

            S_RDB_CAP: begin // b = mem[j]
                bval <= ram_q;
                state <= S_WRA;
            end

            S_WRA: state <= S_WRB; // mem[i] <= b

            S_WRB: begin // mem[j] <= a
                if (idx == shuf_n - 8'd1) state <= S_READY;
                else begin
                    idx <= idx + 8'd1;
                    state <= S_PICK;
                end
            end

            // fecha o lote embaralhado
            S_READY: begin
                ready <= 1'b1;
                shuf_left <= shuf_n; // todo o lote esta embaralhado
                if (count == 8'd0) count <= shuf_n; // so no embaralhamento inicial
                state <= S_DWAIT;
            end

            // livre (busy=0): atende os pedidos
            S_DWAIT: begin
                if (discard_we) begin
                    state <= S_DISCARD;
                end else if (shuf_left == 8'd0 && count != 8'd0) begin // esgotou: reembaralha o descarte
                    shuf_n <= count;
                    idx <= 8'd0;
                    state <= S_PICK;
                end else if (draw && count != 8'd0) begin
                    draw_action <= 1'b0; // 1 borda por carta
                    state <= S_DEAL;
                end
            end

            // entrega uma carta
            S_DEAL: begin
                carta_sorteada <= ram_q; // mem[head]
                carta_ponteiro <= head;
                draw_action <= 1'b1;
                head <= head + 7'd1; // mod 128
                count <= count - 8'd1;
                shuf_left <= shuf_left - 8'd1;
                state <= S_DWAIT;
            end

            // recebe um descarte (grava em mem[tail])
            S_DISCARD: begin
                count <= count + 8'd1;
                state <= S_DWAIT;
            end

            default: state <= S_RESET;
            endcase
        end
    end

endmodule
