module cpu (
    input wire clk, 
    input wire reset, 
    // Sinais do Controlador/Dealer
    input wire deal,
    input wire [9:0] card_in,
    input wire ready,
    input wire remove,
    input wire meu_turno, 
    input wire [9:0] carta_topo,
    // Saídas
    output wire sinal_comprar_carta, 
    output wire sinal_jogar_carta, 
    output wire fim_turno_out,
    output wire [9:0] carta_escolhida,
    output wire [6:0] num_cartas_mao
);

    localparam  S_IDLE        = 4'd0,
                S_PREPARE     = 4'd1,
                S_WAIT        = 4'd2,
                S_AVALIAR     = 4'd3,
                S_PROXIMA     = 4'd4,
                COMPRAR_CARTA = 4'd5,
                JOGAR_CARTA   = 4'd6,
                FIM_TURNO     = 4'd7;
    
    reg [9:0] mao [0:127];
    reg [6:0] n_player;
    reg [6:0] ponteiro_sel;

    reg [3:0] estado_atual, proximo_estado;

    //VALIDAÇÃO
    wire[9:0] carta_atual = mao[ponteiro_sel];

    wire mesma_cor  = |(carta_atual[3:0] & carta_topo[3:0]);
    wire mesmo_valor    = (carta_atual[7:4] == carta_topo[7:4]);
    wire eh_coringa = (carta_atual[9:8]==2'b10);

    wire carta_valida = mesma_cor | mesmo_valor | eh_coringa;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            estado_atual <= S_IDLE;
            n_player     <= 7'd0;
            ponteiro_sel <= 7'd0;
        end
        else begin
            estado_atual <= proximo_estado; // Atualiza a FSM
            
            // 1. Receber Cartas
            if (deal) begin
                mao[n_player] <= card_in;
                n_player      <= n_player + 7'd1;    
            end

            // 2. Descartar e Reorganizar a Mão (Shift)
            if (remove && n_player > 0) begin
                n_player <= n_player - 7'd1;
                
                for (integer i = 0; i < 127; i = i + 1) begin
                    if (i >= ponteiro_sel && i < (n_player - 1)) begin
                        mao[i] <= mao[i + 1];
                    end
                end
                
                if (ponteiro_sel == n_player - 1 && ponteiro_sel > 0) begin
                    ponteiro_sel <= ponteiro_sel - 7'd1;
                end
            end

            // 3. Procurar a carta valida
            if (estado_atual == S_WAIT && meu_turno) begin
                    ponteiro_sel <= 7'd0;
            end
            else if (estado_atual == S_PROXIMA)begin
                    ponteiro_sel <= ponteiro_sel + 7'd1;
            end
        end
    end

    always @(*) begin
        proximo_estado = estado_atual; 

        case (estado_atual)
            S_IDLE: begin
                proximo_estado = S_PREPARE;
            end

            S_PREPARE: begin
                if (ready) begin
                    proximo_estado = S_WAIT;
                end
            end
            
            S_WAIT: begin
                if (meu_turno) begin
                    if (n_player>0)
                        proximo_estado = S_AVALIAR;
                    else
                        proximo_estado = FIM_TURNO;
                end
            end

            S_AVALIAR: begin
                if (carta_valida)
                    proximo_estado = JOGAR_CARTA;
                else begin
                    if(ponteiro_sel == n_player -1)
                        proximo_estado = COMPRAR_CARTA;
                    else
                        proximo_estado = S_PROXIMA;
                end
            end

            S_PROXIMA: begin
                    proximo_estado = S_AVALIAR;
            end

            COMPRAR_CARTA: begin
                proximo_estado = FIM_TURNO;
            end

            JOGAR_CARTA: begin
                proximo_estado = FIM_TURNO;
            end

            FIM_TURNO: begin
                proximo_estado = S_WAIT;
            end

            default: proximo_estado = S_IDLE;
        endcase
    end

    assign sinal_comprar_carta = (estado_atual == COMPRAR_CARTA);
    assign sinal_jogar_carta   = (estado_atual == JOGAR_CARTA);
    assign fim_turno_out       = (estado_atual == FIM_TURNO);
    assign carta_escolhida     = carta_atual;
    assign num_cartas_mao      = n_player;



endmodule