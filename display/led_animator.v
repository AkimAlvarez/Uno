//esse modulo controla todos as animações dos leds

module LedAnimator (
    input clk,
    input reset,
    input player_turn,
    input tick_rapido,
    input cpu_turn,
    input invalid_move,
    input win_game,
    input lose_game,
    input start_game,
    output reg [17:0] ledr,
    output reg [8:0] ledg
);

    // estados da fsm
    localparam VITORIA = 5'b10000, DERROTA = 5'b00001, TURNOS = 5'b01000, INVALIDA = 5'b00100, IDLE = 5'b00010;

    // controle de leds
    localparam LEDR_OFF = 18'b0;
    localparam LEDG_OFF = 9'b0;
    localparam LEDR_ON  = 18'b111111111111111111;
    localparam LEDG_ON  = 9'b111111111;

    // org dos bits para a cobrinha
    localparam SEMENTE_VERDE    = 9'b000000001;
    localparam SEMENTE_VERMELHA = 18'b000000000000000001;

    // limites numéricos
    localparam MAX_PISCADAS = 3'd3;
    localparam MAX_TEMPO_5S = 6'd62; // 5seg/0,08 ≃ 62

    reg[5:0] contador_tempo;
    reg[4:0] estado_atual; //são 5 estados (Turnos, Vitória, Derrota, Jogada inválida e IDLE)
    reg[2:0] contador_piscadas;
    reg tick_rapido_ant;

    always @(posedge clk) begin
        if (reset) begin
            estado_atual <= IDLE;
            ledr <= LEDR_OFF;
            ledg <= LEDG_OFF;
            contador_tempo <= 6'b0;
            contador_piscadas <= 3'b0;
            tick_rapido_ant <= 1'b0;
        end else begin
            case (estado_atual)
                TURNOS: begin
                        if (win_game) begin
                            estado_atual <= VITORIA;
                            ledg <= SEMENTE_VERDE; // organiza os bits pra cobrinha
                            ledr <= LEDR_OFF;      // apaga os vemelhos
                            contador_tempo <= 6'd0;
                        end
                        else if (lose_game) begin
                            estado_atual <= DERROTA;
                            ledr <= SEMENTE_VERMELHA; // organiza os bits pra cobrinha
                            ledg <= LEDG_OFF;         // apaga os verdes
                            contador_tempo <= 6'd0;
                        end
                        else if (invalid_move) begin
                            estado_atual <= INVALIDA;
                            contador_piscadas <= 3'd0;
                        end
                    else begin
                        if (player_turn) begin
                            ledg <= LEDG_ON;  // liga todos os verdes
                            ledr <= LEDR_OFF; // desliga os vermelhos
                        end
                        else if (cpu_turn) begin
                            ledg <= LEDG_OFF; // desliga os verdes
                            ledr <= LEDR_ON;  // liga vermelhos
                        end
                    end
                end

                INVALIDA: begin
                    // só executa na subida do tick_rapido
                    if (tick_rapido == 1'b1 && tick_rapido_ant == 1'b0) begin

                        // inverte o estado atual dos 18 leds vermelhos
                        ledr <= ~ledr;

                        // registra que uma piscada aconteceu
                        contador_piscadas <= contador_piscadas + 3'd1;

                        // 2 piscadas completas precisam de 4 viradas (liga, desliga, liga, desliga)
                        if (contador_piscadas == MAX_PISCADAS) begin
                            contador_piscadas <= 3'd0; // zera o contador
                            estado_atual <= TURNOS;    // volta pro jogo
                        end
                    end
                end

                VITORIA: begin
                    // só executa na subida do tick_rapido
                    if (tick_rapido == 1'b1 && tick_rapido_ant == 1'b0) begin

                        // ring counter pro efeito da cobrinha
                        ledg <= { ledg[7:0], ledg[8] };

                        // cronômetro de 5 segundos
                        contador_tempo <= contador_tempo + 6'd1;

                        if (contador_tempo == MAX_TEMPO_5S) begin
                            contador_tempo <= 6'd0; // reseta o contador
                            ledg <= LEDG_OFF;       // apaga tudo no final
                            estado_atual <= IDLE;
                        end
                    end
                end

                DERROTA: begin
                    if (tick_rapido == 1'b1 && tick_rapido_ant == 1'b0) begin

                        // ring counter pro efeito da cobrinha
                        ledr <= { ledr[16:0], ledr[17] };

                        // cronômetro de 5 segundos
                        contador_tempo <= contador_tempo + 6'd1;

                        if (contador_tempo == MAX_TEMPO_5S) begin
                            contador_tempo <= 6'd0; // reseta o contador
                            ledr <= LEDR_OFF;       // apaga tudo no final
                            estado_atual <= IDLE;
                        end
                    end
                end

                IDLE: begin
                    if(start_game) begin
                        if (tick_rapido == 1'b1 && tick_rapido_ant == 1'b0) begin

                            // inverte o estado atual dos 18 leds vermelhos e 9 verdes
                            ledr <= ~ledr;
                            ledg <= ~ledg;

                            // registra que uma piscada aconteceu
                            contador_piscadas <= contador_piscadas + 3'd1;

                            // 2 piscadas completas precisam de 4 viradas (liga, desliga, liga, desliga)
                            if (contador_piscadas == MAX_PISCADAS) begin
                                contador_piscadas <= 3'd0; // zera o contador
                                estado_atual <= TURNOS;    // volta pro jogo
                            end
                        end
                    end
                end

                default: begin
                    estado_atual <= IDLE;
                    ledr <= LEDR_OFF;
                    ledg <= LEDG_OFF;
                end
            endcase

            tick_rapido_ant <= tick_rapido; //ultimo valor do tick rapido
        end
    end

endmodule