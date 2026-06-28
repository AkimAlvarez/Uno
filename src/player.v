`timescale 1ns / 1ps

module player #(
    parameter MAX_CARDS = 104
)(
    input wire clk,
    input wire reset,

    input wire meu_turno,
    input wire next_pulse,
    input wire play_pulse,
    input wire draw_pulse,
    input wire carta_valida,

    input wire deal,
    input wire [9:0] card_in,
    input wire remove,

    output reg sinal_jogar,
    output reg sinal_comprar,
    output reg sinal_invalido,
    output reg fim_turno,
    output wire [9:0] carta_escolhida,
    output wire [6:0] n_player,
    output wire vazio
);

    localparam [2:0] S_IDLE=3'd0,
                     S_WAIT=3'd1,
                     S_VALIDAR=3'd2,
                     S_JOGAR=3'd3,
                     S_COMPRAR=3'd4,
                     S_FIM=3'd5;

    reg [9:0] mao [0:MAX_CARDS-1];
    reg [6:0] n_cartas; // quantidade de cartas na mão 
    reg [6:0] p_carta; // ponteiro da selecao
    reg [2:0] current_state, next_state;
    integer i;

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
                // 
                for (i = 0; i < MAX_CARDS-1; i = i + 1)
                    if (i >= p_carta && i < n_cartas-1) // reajusta o array para não ter um espaço sem cartas
                        mao[i] <= mao[i+1];
                n_cartas <= n_cartas - 7'd1;
                if (p_carta >= n_cartas-1 && p_carta > 7'd0) // conserta o caso do player jogar a carta que estava na ultima posição da array  
                    p_carta <= p_carta - 7'd1;
            end
            else if (next_pulse && current_state == S_WAIT && n_cartas > 7'd0) begin
                p_carta <= (p_carta == n_cartas-1) ? 7'd0 : p_carta + 7'd1; // movimenta a carta da mão, seguindo a lógica de uma array circular
            end
        end
    end

    always @(*) begin
        next_state = current_state;
        sinal_jogar    = 1'b0;
        sinal_comprar  = 1'b0;
        sinal_invalido = 1'b0;
        fim_turno      = 1'b0;
        case (current_state)
            S_IDLE: next_state = S_WAIT;
            S_WAIT: begin 
                if (meu_turno) begin
                    if (play_pulse)      next_state = S_VALIDAR;
                    else if (draw_pulse) next_state = S_COMPRAR;
                end
            end
            S_VALIDAR: begin
                if (carta_valida) next_state = S_JOGAR;
                else begin 
                    sinal_invalido = 1'b1;
                    next_state = S_WAIT;
                end
            end
            S_JOGAR:   begin
                sinal_jogar   = 1'b1;
                if (!meu_turno) next_state = S_FIM; 
            end
            S_COMPRAR: begin
                sinal_comprar = 1'b1;
                if (!meu_turno) next_state = S_FIM;
            end
            S_FIM: begin 
                fim_turno = 1'b1;
                next_state = S_WAIT; 
            end
            default: next_state = S_IDLE;
        endcase
    end

    assign carta_escolhida = (n_cartas > 7'd0) ? mao[p_carta] : 10'd0;
    assign n_player = n_cartas;
    assign vazio = (n_cartas == 7'd0);

endmodule
