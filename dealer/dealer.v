`timescale 1ns / 1ps

module dealer_fsm (
    input  wire        clk,
    input  wire        rst,
    input  wire        draw,

    // interface com a RAM (instanciada no top)
    output reg  [6:0]  ram_addr,
    output reg         ram_we,
    output reg  [9:0]  ram_data,
    input  wire [9:0]  ram_q,

    output reg         ready,            // embaralhamento concluido
    output wire        busy,             // ocupado: nao aceita draw agora
    output reg         draw_action,      // ativo: carta distribuida
    output reg  [9:0]  carta_sorteada,   // conteudo da carta distribuida
    output reg  [7:0]  carta_ponteiro    // indice distribuido (0..107)
);

    wire [7:0] lfsr_out;
    wire       lfsr_done;

    reg  [7:0] entropy_counter = 8'd0;
    reg        rst_d;
    wire       reset_release = rst_d & ~rst;             // borda de descida do rst
    wire [7:0] seed_value    = (entropy_counter == 8'hFF) ? 8'h01 : entropy_counter;

    always @(posedge clk) begin
        entropy_counter <= entropy_counter + 8'd1;
        rst_d           <= rst;
    end

    LFSR #(.NUM_BITS(8)) embaralhador (
        .i_Clk      (clk),
        .i_Enable   (1'b1),
        .i_Seed_DV  (reset_release),
        .i_Seed_Data(seed_value),
        .o_LFSR_Data(lfsr_out),
        .o_LFSR_Done(lfsr_done)
    );

    localparam N_CARTAS = 8'd108;

    localparam S_RESET     = 4'd0,
               S_PICK      = 4'd1,   // sorteia jrand (0..107)
               S_RDA_INIT   = 4'd2,  // pede leitura de mem[idx]
               S_RDA_CAP   = 4'd3,   // captura a=mem[idx], pede leitura de mem[jrand]
               S_RDB_CAP   = 4'd4,   // captura b=mem[jrand]
               S_WRA       = 4'd5,   // mem[idx]  <= b
               S_WRB       = 4'd6,   // mem[jrand]<= a
               S_READY     = 4'd7,
               S_DWAIT     = 4'd8,   // livre: espera um pulso de draw
               S_DEAL      = 4'd9,   // entrega mem[ptr]
               S_EMPTY     = 4'd10;  // baralho vazio

    reg [3:0] state;
    reg [7:0] idx;       // indice corrente do embaralhamento (0..107)
    reg [6:0] jrand;     // posicao sorteada para a troca
    reg [9:0] aval;      // mem[idx] guardado
    reg [9:0] bval;      // mem[jrand] guardado
    reg [7:0] ptr;       // ponteiro de distribuicao

    // ocupado sempre que nao esta livre esperando um draw
    assign busy = (state != S_DWAIT);

    always @(*) begin
        ram_addr = 7'd0;
        ram_we   = 1'b0;
        ram_data = 10'd0;
        case (state)
            S_PICK,
            S_RDA_INIT:  ram_addr = idx[6:0];
            S_RDA_CAP,
            S_RDB_CAP:  ram_addr = jrand;
            S_WRA: begin ram_addr = idx[6:0]; ram_we = 1'b1; ram_data = bval; end
            S_WRB: begin ram_addr = jrand;    ram_we = 1'b1; ram_data = aval; end
            S_READY,
            S_DWAIT,
            S_DEAL:     ram_addr = ptr[6:0];
            default:    ram_addr = 7'd0;
        endcase
    end


    always @(posedge clk) begin
        if (rst) begin
            state          <= S_RESET;
            idx            <= 8'd0;
            ptr            <= 8'd0;
            ready          <= 1'b0;
            draw_action    <= 1'b0;
            carta_sorteada <= 10'd0;
            carta_ponteiro <= 8'd0;
        end else begin
            case (state)
                S_RESET: begin
                    idx         <= 8'd0;
                    ptr         <= 8'd0;
                    ready       <= 1'b0;
                    draw_action <= 1'b0;
                    state       <= S_PICK;
                end

                S_PICK: begin
                    // rejeita valores >=108 ate cair em uma posicao valida
                    if (lfsr_out < N_CARTAS) begin
                        jrand <= lfsr_out[6:0];
                        state <= S_RDA_INIT;
                    end
                end

                S_RDA_INIT: state <= S_RDA_CAP;            // endereco idx apresentado

                S_RDA_CAP: begin
                    aval  <= ram_q;                        // ram_q = mem[idx]
                    state <= S_RDB_CAP;                    // endereco jrand apresentado
                end

                S_RDB_CAP: begin
                    bval  <= ram_q;                        // ram_q = mem[jrand]
                    state <= S_WRA;
                end

                S_WRA: state <= S_WRB;                     // mem[idx] <= bval

                S_WRB: begin                               // mem[jrand] <= aval
                    if (idx == N_CARTAS - 8'd1) begin
                        state <= S_READY;
                    end else begin
                        idx   <= idx + 8'd1;
                        state <= S_PICK;
                    end
                end

                S_READY: begin
                    ready <= 1'b1;
                    ptr   <= 8'd0;
                    state <= S_DWAIT;
                end

                S_DWAIT: begin
                    // livre para uma nova compra (busy=0)
                    if (ptr >= N_CARTAS)
                        state <= S_EMPTY;
                    else if (draw) begin
                        draw_action <= 1'b0;   // baixa antes de reentregar (1 borda por carta)
                        state       <= S_DEAL;
                    end
                end

                S_DEAL: begin
                    carta_sorteada <= ram_q;               // ram_q = mem[ptr]
                    carta_ponteiro <= ptr;
                    draw_action    <= 1'b1;                // carta entregue; segue ativo
                    ptr            <= ptr + 8'd1;
                    state          <= S_DWAIT;
                end

                S_EMPTY: begin
                    draw_action <= 1'b0;
                end

                default: state <= S_RESET;
            endcase
        end
    end

endmodule
