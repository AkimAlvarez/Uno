module player (
    input wire clk, 
    input wire reset, 
    input wire meu_turno, 
    input wire ultima_carta,
    input wire [9:0] carta_lida_memoria,
    input wire [9:0] carta_topo,
    input wire carta_valida,
    output wire [8:0] ponteiro_leitura,
    output wire sinal_comprar_carta, 
    output wire sinal_jogar_carta, 
    output wire fim_turno_out,
    output wire [9:0] carta_escolhida
);

    localparam  IDLE          = 3'd0,
                LER_CARTA     = 3'd1,
                VALIDAR       = 3'd2,
                PROXIMA_CARTA = 3'd3,
                COMPRAR_CARTA = 3'd4,
                JOGAR_CARTA   = 3'd5,
                FIM_TURNO     = 3'd6;
    
    reg [2:0] estado_atual, proximo_estado;
    reg [8:0] ponteiro;

    always @(posedge clk or posedge reset)begin
        if (reset) begin
            estado_atual<= IDLE;
            ponteiro<=9'd0;
        end
        else begin
            estado_atual <= proximo_estado;
            if (estado_atual == IDLE)
                ponteiro <= 9'd0;    
            else if (estado_atual == PROXIMA_CARTA)
                ponteiro <= ponteiro + 1'b1;
        end
    end

    always @(*) begin
        case (estado_atual)
            IDLE: begin
                if(meu_turno)
                    proximo_estado = LER_CARTA;
                else
                    proximo_estado = IDLE;
            end

            LER_CARTA: begin
                proximo_estado = VALIDAR;
            end

            VALIDAR: begin
                if(carta_valida)
                    proximo_estado = JOGAR_CARTA;
                else
                    proximo_estado = PROXIMA_CARTA;
            end

            PROXIMA_CARTA: begin
                if(ultima_carta)
                    proximo_estado = COMPRAR_CARTA;
                else
                    proximo_estado = LER_CARTA;
            end

            COMPRAR_CARTA: begin
                proximo_estado = FIM_TURNO;
            end

            JOGAR_CARTA: begin
                proximo_estado = FIM_TURNO;
            end

            FIM_TURNO: begin
                proximo_estado = IDLE;
            end

            default: proximo_estado = IDLE;
        endcase

    end

    assign ponteiro_leitura = ponteiro;
    assign sinal_comprar_carta = (estado_atual == COMPRAR_CARTA);
    assign sinal_jogar_carta = (estado_atual == JOGAR_CARTA);
    assign fim_turno_out = (estado_atual == FIM_TURNO);
    assign carta_escolhida = carta_lida_memoria;



endmodule