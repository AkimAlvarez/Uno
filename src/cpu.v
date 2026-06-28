`timescale 1ns / 1ps

module cpu #(
    parameter MAX_CARDS = 104
)(
    input wire clk,
    input wire reset,

    input wire meu_turno,
    input wire carta_valida,

    input wire deal,
    input wire [9:0] card_in,
    input wire remove,

    output reg sinal_jogar,
    output reg sinal_comprar,
    output reg fim_turno,
    output wire [9:0] carta_escolhida,
    output wire [3:0] cor_escolhida,
    output wire [6:0] n_cpu,
    output wire vazio
);

    localparam [2:0] S_IDLE=3'd0,
                     S_WAIT=3'd1,
                     S_AVALIAR=3'd2,
                     S_PROXIMA=3'd3,
                     S_JOGAR=3'd4,
                     S_COMPRAR=3'd5,
                     S_FIM=3'd6;

    reg [9:0] mao [0:MAX_CARDS-1];
    reg [6:0] n_cartas; // quantidade de cartas na mão
    reg [6:0] p_carta; // ponteiro da selecao
    reg [2:0] current_state, next_state;
    integer i;

    // cor da 1a carta colorida da mao (vermelho por padrao se so houver coringa)
    reg [3:0] cor_r;
    always @(*) begin
        cor_r = 4'b1000; // Vermelho (Peguei qlq cor)
        for (i = MAX_CARDS-1; i >= 0; i = i - 1)
            if (i < n_cartas && mao[i][3:0] != 4'b0000) // a ideia é pegar a cor da primeira carta da mão na lógica de selecionar cores
                cor_r = mao[i][3:0];
    end

    always @(posedge clk) begin
        if (reset) begin
            n_cartas <= 7'd0;
            p_carta <= 7'd0;
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
            if (deal) begin
                mao[n_cartas] <= card_in;
                n_cartas      <= n_cartas + 7'd1;
            end
            else if (remove && n_cartas > 7'd0) begin
                for (i = 0; i < MAX_CARDS-1; i = i + 1)
                    if (i >= p_carta && i < n_cartas-1)
                        mao[i] <= mao[i+1];
                n_cartas <= n_cartas - 7'd1;
            end
            else if (current_state == S_WAIT && meu_turno) begin
                p_carta <= 7'd0;  // recomeca a varredura a cada turno
            end
            else if (current_state == S_PROXIMA) begin
                p_carta <= p_carta + 7'd1; // a ideia é ir verificando se a carta é valida a cada ciclo
            end
        end
    end

    always @(*) begin
        next_state = current_state;
        sinal_jogar   = 1'b0;
        sinal_comprar = 1'b0;
        fim_turno     = 1'b0;
        case (current_state)
            S_IDLE: next_state = S_WAIT;
            S_WAIT: if (meu_turno) next_state = (n_cartas > 7'd0) ? S_AVALIAR : S_FIM;
            S_AVALIAR: if (carta_valida)            next_state = S_JOGAR;
                       else if (p_carta == n_cartas-1) next_state = S_COMPRAR;
                       else                          next_state = S_PROXIMA;
            S_PROXIMA: next_state = S_AVALIAR;
            S_JOGAR:   begin sinal_jogar   = 1'b1; if (!meu_turno) next_state = S_FIM; end
            S_COMPRAR: begin sinal_comprar = 1'b1; if (!meu_turno) next_state = S_FIM; end
            S_FIM:     begin fim_turno     = 1'b1; next_state = S_WAIT; end
            default:   next_state = S_IDLE;
        endcase
    end

    assign carta_escolhida = (n_cartas > 7'd0) ? mao[p_carta] : 10'd0;
    assign cor_escolhida = cor_r;
    assign n_cpu = n_cartas;
    assign vazio = (n_cartas == 7'd0);

endmodule
