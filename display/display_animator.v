// módulo de animação dos displays do jogador

module DisplayAnimator (
    input clk,
    input reset,
    input choosing_color,
    input game_start,
    input [3:0] color_selector,
    input [6:0] decoded_p_valor, // valor normal da carta do jogador decodificado
    input [6:0] decoded_p_color, // cor normal da carta do jogador decodificada

    output reg [6:0] right_p_display, // display da direita (valor / letra da cor)
    output reg [6:0] left_p_display   // display da esquerda (cor / menu)
);

    wire tick_rapido;

    ClockDiv redutor_freq(
        .clk(clk),
        .reset(reset),
        .tick_out(tick_rapido)
    );

    // codificação one-hot dos estados
    localparam IDLE = 3'b001, NORMAL_GAME = 3'b010, CHOOSING_COLOR = 3'b100;

    // dicionário 7-segmentos para o menu
    localparam APAGADO = 7'b1111111;
    localparam LETRA_E = 7'b0000110; // preto (menu de decisão de cores)
    localparam LETRA_A = 7'b0001000; // verde
    localparam LETRA_B = 7'b0000011; // azul
    localparam LETRA_C = 7'b1000110; // amarelo
    localparam LETRA_D = 7'b0100001; // vermelho

    // variáveis de estado e tempo
    reg [2:0] estado_atual;
    reg pisca_status;
    reg tick_rapido_ant;

    initial begin
        estado_atual = IDLE;
        pisca_status = 1'b0;
        tick_rapido_ant = 1'b0;
    end

    always @(posedge clk) begin
        if(reset) begin
            estado_atual <= IDLE;
            right_p_display <= APAGADO;
            left_p_display <= APAGADO;
            pisca_status <= 1'b0;
            tick_rapido_ant <= 1'b0;
        end
        else begin
            case (estado_atual)

                IDLE: begin
                    right_p_display <= APAGADO;
                    left_p_display <= APAGADO;

                    if(game_start) begin
                        estado_atual <= NORMAL_GAME;
                    end
                end

                NORMAL_GAME: begin
                    // repassa os valores decodificados direto para a saída
                    right_p_display <= decoded_p_valor;
                    left_p_display <= decoded_p_color;

                    if(choosing_color) begin
                        estado_atual <= CHOOSING_COLOR;
                        pisca_status <= 1'b1; // garante que o menu comece aceso
                    end
                end

                CHOOSING_COLOR: begin
                    // detecta a borda de subida do tick para alternar o pisca
                    if (tick_rapido == 1'b1 && tick_rapido_ant == 1'b0) begin
                        pisca_status <= ~pisca_status;
                    end

                    // lógica visual do pisca-pisca
                    if (pisca_status) begin
                        // mostra a cor preta ('e') na esquerda e a letra da cor escolhida na direita
                        left_p_display <= LETRA_E;

                        case (color_selector)
                            4'b0100: right_p_display <= LETRA_A; // verde
                            4'b0010: right_p_display <= LETRA_B; // azul
                            4'b0001: right_p_display <= LETRA_C; // amarelo
                            4'b1000: right_p_display <= LETRA_D; // vermelho
                            default: right_p_display <= APAGADO;
                        endcase
                    end else begin
                        // desliga os dois displays do jogador para fzr a piscada
                        left_p_display <= APAGADO;
                        right_p_display <= APAGADO;
                    end

                    // se o sinal de escolha cair (jogador confirmou) volta pro jogo
                    if (!choosing_color) begin
                        estado_atual <= NORMAL_GAME;
                    end
                end

                default: begin
                    estado_atual <= IDLE;
                end
            endcase

            // registra o último estado do tick para a detecção de borda funcionar
            tick_rapido_ant <= tick_rapido;
        end
    end

endmodule