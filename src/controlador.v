`timescale 1ns / 1ps

module controlador #(
    parameter HAND_SIZE = 7
)(
    input wire clk,
    input wire reset,

    // botoes
    input wire btn_next,
    input wire btn_play,
    input wire btn_draw,
    input wire [3:0] color_selector, // cor escolhida pelo player (one-hot)

    // dealer
    input wire ready,
    input wire busy,
    input wire draw_action,
    input wire [9:0] carta_sorteada,
    output reg draw,
    output reg [9:0] discard_in,
    output reg discard_we,

    // player
    input wire p_jogar,
    input wire p_comprar,
    input wire p_invalido,
    input wire p_fim,
    input wire [9:0] player_card,
    input wire [6:0] n_player,
    input wire p_vazio,
    output reg p_meu_turno,
    output wire p_next_pulse,
    output wire p_play_pulse,
    output wire p_draw_pulse,
    output reg p_deal,
    output reg p_remove,

    // cpu
    input wire c_jogar,
    input wire c_comprar,
    input wire c_fim,
    input wire [9:0] cpu_card,
    input wire [3:0] cpu_cor,
    input wire [6:0] n_cpu,
    input wire c_vazio,
    output reg c_meu_turno,
    output reg c_deal,
    output reg c_remove,

    // compartilhado p/ player e cpu
    output wire carta_valida,

    // display
    input wire anim_busy,
    output reg [9:0] top_card,
    output reg player_turn,
    output reg cpu_turn,
    output reg invalid_move,
    output reg skip_action,
    output reg draw_action_disp,
    output reg choosing_color,
    output reg win,
    output reg lose
);

    localparam P_PLAYER = 1'b0, P_CPU = 1'b1;
    localparam [1:0] D_PLAYER = 2'd0, D_CPU = 2'd1, D_CAP = 2'd2;

    localparam [4:0]
        S_IDLE=5'd0, S_PREPARE=5'd1, S_DEAL=5'd2, S_PICK=5'd3, S_PICK_EVAL=5'd4,
        S_GRANT=5'd5, S_WAIT_MOVE=5'd6, S_COMMIT=5'd7, S_COMMIT_TOP=5'd8,
        S_WAIT_COLOR=5'd9, S_APPLY=5'd10, S_NEXT=5'd11, S_DRAW1_EVAL=5'd12,
        S_PEN=5'd13, S_PEN_DEC=5'd14, S_WIN=5'd15, S_LOSE=5'd16,
        S_DRAW_REQ=5'd17, S_DRAW_PULSE=5'd18, S_DRAW_RX=5'd19,
        S_DISC_REQ=5'd20, S_DISC_PULSE=5'd21, S_WAIT_DISP=5'd22;

    reg [4:0] state;
    reg turn;
    reg [9:0] played_card;
    reg played_from_hand;
    reg pen_pending;
    reg pen_tipo; // 0=+2, 1=+4
    reg [6:0] pen_count;
    reg [6:0] dealt_p, dealt_c;
    reg [1:0] draw_dest;
    reg [4:0] draw_ret;
    reg [9:0] disc_card;
    reg [4:0] disc_ret;
    reg [4:0] disp_ret;

    // bordas dos botoes (ativos em baixo: pressao = descida)
    reg btn_next_d, btn_play_d, btn_draw_d, draw_action_d;
    wire next_press = btn_next_d & ~btn_next;
    wire play_press = btn_play_d & ~btn_play;
    wire draw_press = btn_draw_d & ~btn_draw;
    wire card_ready = draw_action & ~draw_action_d;

    assign p_next_pulse = next_press;
    assign p_play_pulse = play_press;
    assign p_draw_pulse = draw_press;

    // Funções para decodificar a carta
    function automatic is_num;  input [9:0] c; is_num  = (c[9:8]==2'b00); endfunction
    function automatic is_wild; input [9:0] c; is_wild = (c[9:8]==2'b10); endfunction
    function automatic is_p2;   input [9:0] c; is_p2   = (c[9:8]==2'b01) && (c[7:4]==4'b1100); endfunction
    function automatic is_p4;   input [9:0] c; is_p4   = (c[9:8]==2'b10) && (c[7:4]==4'b1110); endfunction
    function automatic is_skiprev; input [9:0] c;
        is_skiprev = (c[9:8]==2'b01)&&((c[7:4]==4'b1010)||(c[7:4]==4'b1011));
    endfunction
    function automatic valido; input [9:0] c; input [9:0] t;
        valido = (|(c[3:0] & t[3:0])) | ((c[7:4] == t[7:4]) && (c[9:8] == t[9:8])) | is_wild(c);
    endfunction

    // carta apontada pelo jogador da vez e seu veredito de validade
    wire [9:0] active_card = (turn==P_CPU) ? cpu_card : player_card;
    wire active_jogar = (turn==P_CPU) ? c_jogar : p_jogar;
    wire active_comprar = (turn==P_CPU) ? c_comprar : p_comprar;
    assign carta_valida = pen_pending ? (pen_tipo ? is_p4(active_card) : is_p2(active_card))
                                      : valido(active_card, top_card);
    always @(posedge clk) begin
        btn_next_d <= btn_next; 
        btn_play_d <= btn_play;
        btn_draw_d <= btn_draw;
        draw_action_d <= draw_action;

        // pulsos default 0
        draw <= 1'b0;
        discard_we <= 1'b0;
        p_deal <= 1'b0;
        p_remove <= 1'b0;
        c_deal <= 1'b0;
        c_remove <= 1'b0;
        invalid_move <= 1'b0;
        skip_action <= 1'b0;
        draw_action_disp <= 1'b0;

        if (reset) begin
            state<=S_IDLE; 
            turn<=P_PLAYER; 
            pen_pending<=1'b0; 
            pen_count<=7'd0;
            top_card<=10'd0; 
            player_turn<=1'b0; 
            cpu_turn<=1'b0; 
            choosing_color<=1'b0;
            win<=1'b0; 
            lose<=1'b0; 
            p_meu_turno<=1'b0; 
            c_meu_turno<=1'b0;
        end else begin
            case (state)
            S_IDLE:    state <= S_PREPARE;
            S_PREPARE: begin
                if (ready) begin 
                    dealt_p<=7'd0; 
                    dealt_c<=7'd0; 
                    state<=S_DEAL; 
                end
            end
            // distribuicao inicial
            S_DEAL: begin
                if (dealt_p < HAND_SIZE) begin
                    dealt_p <= dealt_p + 7'd1; 
                    draw_dest <= D_PLAYER; 
                    draw_ret <= S_DEAL; 
                    state <= S_DRAW_REQ;
                end else if (dealt_c < HAND_SIZE) begin
                    dealt_c <= dealt_c + 7'd1; 
                    draw_dest <= D_CPU; 
                    draw_ret <= S_DEAL; 
                    state <= S_DRAW_REQ;
                end else state <= S_PICK;
            end

            // carta inicial (numero)
            S_PICK: begin 
                draw_dest <= D_CAP; 
                draw_ret <= S_PICK_EVAL; 
                state <= S_DRAW_REQ; 
            end

            S_PICK_EVAL: begin
                if (is_num(carta_sorteada)) begin // Avalia se a carta é valida
                    top_card <= carta_sorteada; 
                    turn <= P_PLAYER; 
                    state <= S_GRANT;
                end else begin // Caso não seja, ela é descartada
                    disc_card <= carta_sorteada; 
                    disc_ret <= S_PICK; 
                    state <= S_DISC_REQ;
                end
            end

            // concede o turno
            S_GRANT: begin
                player_turn <= (turn == P_PLAYER);
                cpu_turn    <= (turn == P_CPU);
                if (turn == P_PLAYER) p_meu_turno <= 1'b1; 
                else c_meu_turno <= 1'b1;
                disp_ret <= S_WAIT_MOVE;
                state <= (turn == P_CPU) ? S_WAIT_DISP : S_WAIT_MOVE;
            end

            // espera a jogada/compra do jogador da vez
            S_WAIT_MOVE: begin
                if (turn==P_PLAYER && p_invalido) begin
                    invalid_move<=1'b1;
                    disp_ret <= S_WAIT_MOVE;
                    state <= S_WAIT_DISP;
                end else if (active_jogar) begin
                    played_card <= active_card; 
                    played_from_hand <= 1'b1;
                    p_meu_turno <= 1'b0; 
                    c_meu_turno <= 1'b0;
                    state <= S_COMMIT;
                end else if (active_comprar) begin // draw
                    p_meu_turno <= 1'b0; 
                    c_meu_turno <= 1'b0;
                    if (pen_pending) state <= S_PEN; // Subrotina de penalidade
                    else begin 
                        draw_dest <= D_CAP; 
                        draw_ret <= S_DRAW1_EVAL; 
                        state <= S_DRAW_REQ; 
                    end
                end
            end

            // efetiva a jogada: descarta topo antigo, define novo topo
            S_COMMIT: begin 
                disc_card <= top_card; 
                disc_ret <= S_COMMIT_TOP; 
                state <= S_DISC_REQ; 
            end

            S_COMMIT_TOP: begin // Avalia prox estado baseado na carta jogada
                if (is_wild(played_card)) begin // se for carta de escolha de escolher cor
                    if (turn == P_CPU) begin
                        top_card <= {played_card[9:4], cpu_cor}; // mantem a carta e altera apenas a cor
                        if (played_from_hand) c_remove <= 1'b1; // avalia se deve descartar a carta ou não
                        state <= S_APPLY;
                    end else begin
                        choosing_color <= 1'b1; 
                        state <= S_WAIT_COLOR;
                    end
                end else begin
                    top_card <= played_card;
                    if (played_from_hand) begin
                        if (turn == P_PLAYER) p_remove <= 1'b1; 
                        else c_remove <= 1'b1;
                    end
                    state <= S_APPLY;
                end
            end

            S_WAIT_COLOR: begin
                choosing_color <= 1'b1;
                if (play_press) begin
                    top_card <= {played_card[9:4], color_selector}; // mantem a carta e altera apenas a cor
                    if (played_from_hand) p_remove <= 1'b1;
                    choosing_color <= 1'b0;
                    state <= S_APPLY;
                end
            end

            // efeitos especiais
            S_APPLY: begin
                if (is_skiprev(played_card)) begin
                    skip_action <= 1'b1; 
                    disp_ret <= S_NEXT;
                    state <= S_WAIT_DISP; // a vez volta para quem jogou
                end else if (is_p2(played_card)) begin
                    pen_pending <= 1'b1; 
                    pen_tipo <= 1'b0; 
                    pen_count <= pen_count + 7'd2; 
                    turn <= ~turn; 
                    state <= S_NEXT;
                end else if (is_p4(played_card)) begin
                    pen_pending <= 1'b1; 
                    pen_tipo <= 1'b1; 
                    pen_count <= pen_count + 7'd4; 
                    turn <= ~turn; 
                    state <= S_NEXT;
                end else begin
                    turn <= ~turn; 
                    state <= S_NEXT;
                end
            end

            S_NEXT: begin
                if (p_vazio) state <= S_WIN;
                else if (c_vazio) state <= S_LOSE;
                else state <= S_GRANT;
            end

            // compra normal: avalia a carta comprada
            S_DRAW1_EVAL: begin
                if (valido(carta_sorteada, top_card)) begin
                    played_card <= carta_sorteada; 
                    played_from_hand <= 1'b0; 
                    state <= S_COMMIT;
                end else begin
                    if (turn == P_PLAYER) p_deal <= 1'b1; 
                    else c_deal <= 1'b1;
                    draw_action_disp <= 1'b1; 
                    turn <= ~turn;
                    disp_ret <= S_NEXT;
                    state <= S_WAIT_DISP;
                end
            end

            // penalidade: compra pen_count cartas e pula a vez
            S_PEN: begin
                if (pen_count == 7'd0) begin 
                    pen_pending <= 1'b0;
                    turn <= ~turn;
                    disp_ret <= S_NEXT;
                    state <= S_WAIT_DISP;
                end
                else begin
                    draw_dest <= (turn==P_PLAYER) ? D_PLAYER : D_CPU;
                    draw_ret <= S_PEN_DEC; 
                    draw_action_disp <= 1'b1; 
                    state <= S_DRAW_REQ;
                end
            end

            S_PEN_DEC: begin 
                pen_count <= pen_count - 7'd1; 
                state <= S_PEN; 
            end

            S_WIN:  begin win  <= 1'b1; player_turn <= 1'b0; cpu_turn <= 1'b0; end

            S_LOSE: begin lose <= 1'b1; player_turn <= 1'b0; cpu_turn <= 1'b0; end

            // sub-rotina: comprar uma carta do dealer
            S_DRAW_REQ: begin   // Verifica a disponibilidade do dealer
                if (!busy) begin 
                    draw <= 1'b1; 
                    state <= S_DRAW_PULSE; 
                end
            end

            S_DRAW_PULSE: begin // Envia o pulso para o dealer e espera a prox carta
                draw <= 1'b0; 
                state <= S_DRAW_RX; 
            end

            S_DRAW_RX: begin 
                if (card_ready) begin
                    case (draw_dest)
                        D_PLAYER: p_deal  <=  1'b1;
                        D_CPU: c_deal  <=  1'b1;
                        default:  ;
                    endcase
                    state  <=  draw_ret;
                end else if (!busy) state  <=  S_DRAW_REQ;
            end

            // sub-rotina: empurrar um descarte
            S_DISC_REQ: begin  
                if (!busy) begin 
                    discard_in <= disc_card; 
                    discard_we <= 1'b1; 
                    state <= S_DISC_PULSE; 
                end
            end

            S_DISC_PULSE: begin 
                discard_we <= 1'b0; 
                state <= disc_ret; 
            end

            S_WAIT_DISP: begin
                if (!anim_busy) state <= disp_ret;
            end

            default: state <= S_IDLE;
            endcase
        end
    end

endmodule
