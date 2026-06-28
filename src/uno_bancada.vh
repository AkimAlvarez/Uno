// bancada compartilhada dos testbenches do UNO.
// instancia controlador + player + cpu + dealer_controlavel e oferece as tasks.
// usada dentro de cada modulo tb_<cenario> via `include "uno_bancada.vh".

    reg clk;
    reg rst;
    reg btn_next, btn_play, btn_draw; // ativos em baixo (1 = solto)
    reg [3:0] color_selector;

    // dealer <-> controlador
    wire ready, busy, draw_action;
    wire [9:0] carta_sorteada;
    wire draw, discard_we;
    wire [9:0] discard_in;

    // player <-> controlador
    wire p_jogar, p_comprar, p_invalido, p_fim;
    wire [9:0] player_card;
    wire [6:0] n_player;
    wire p_vazio;
    wire p_meu_turno, p_next_pulse, p_play_pulse, p_draw_pulse, p_deal, p_remove;

    // cpu <-> controlador
    wire c_jogar, c_comprar, c_fim;
    wire [9:0] cpu_card;
    wire [3:0] cpu_cor;
    wire [6:0] n_cpu;
    wire c_vazio;
    wire c_meu_turno, c_deal, c_remove;

    wire carta_valida;

    // display
    wire [9:0] top_card;
    wire player_turn, cpu_turn, invalid_move, skip_action, draw_action_disp;
    wire choosing_color, win, lose;

    dealer_controlavel dealer (
        .clk(clk), .rst(rst), .draw(draw),
        .discard_in(discard_in), .discard_we(discard_we),
        .ready(ready), .busy(busy), .draw_action(draw_action),
        .carta_sorteada(carta_sorteada)
    );

    player jogador (
        .clk(clk), .reset(rst),
        .meu_turno(p_meu_turno),
        .next_pulse(p_next_pulse), .play_pulse(p_play_pulse), .draw_pulse(p_draw_pulse),
        .carta_valida(carta_valida),
        .deal(p_deal), .card_in(carta_sorteada), .remove(p_remove),
        .sinal_jogar(p_jogar), .sinal_comprar(p_comprar), .sinal_invalido(p_invalido),
        .fim_turno(p_fim), .carta_escolhida(player_card), .n_player(n_player), .vazio(p_vazio)
    );

    cpu maquina (
        .clk(clk), .reset(rst),
        .meu_turno(c_meu_turno), .carta_valida(carta_valida),
        .deal(c_deal), .card_in(carta_sorteada), .remove(c_remove),
        .sinal_jogar(c_jogar), .sinal_comprar(c_comprar), .fim_turno(c_fim),
        .carta_escolhida(cpu_card), .cor_escolhida(cpu_cor), .n_cpu(n_cpu), .vazio(c_vazio)
    );

    controlador ctrl (
        .clk(clk), .reset(rst),
        .btn_next(btn_next), .btn_play(btn_play), .btn_draw(btn_draw),
        .color_selector(color_selector),
        .ready(ready), .busy(busy), .draw_action(draw_action), .carta_sorteada(carta_sorteada),
        .draw(draw), .discard_in(discard_in), .discard_we(discard_we),
        .p_jogar(p_jogar), .p_comprar(p_comprar), .p_invalido(p_invalido), .p_fim(p_fim),
        .player_card(player_card), .n_player(n_player), .p_vazio(p_vazio),
        .p_meu_turno(p_meu_turno), .p_next_pulse(p_next_pulse), .p_play_pulse(p_play_pulse),
        .p_draw_pulse(p_draw_pulse), .p_deal(p_deal), .p_remove(p_remove),
        .c_jogar(c_jogar), .c_comprar(c_comprar), .c_fim(c_fim),
        .cpu_card(cpu_card), .cpu_cor(cpu_cor), .n_cpu(n_cpu), .c_vazio(c_vazio),
        .c_meu_turno(c_meu_turno), .c_deal(c_deal), .c_remove(c_remove),
        .carta_valida(carta_valida),
        .anim_busy(1'b0),
        .top_card(top_card), .player_turn(player_turn), .cpu_turn(cpu_turn),
        .invalid_move(invalid_move), .skip_action(skip_action), .draw_action_disp(draw_action_disp),
        .choosing_color(choosing_color), .win(win), .lose(lose)
    );

    initial clk = 1'b0;
    always #10 clk = ~clk; // 50MHz

    // latches "ja vi este pulso" (limpos pelo reset) p/ checar eventos de 1 ciclo
    reg viu_invalido, viu_skip, viu_draw;
    always @(posedge clk) begin
        if (rst) begin
            viu_invalido <= 1'b0;
            viu_skip <= 1'b0;
            viu_draw <= 1'b0;
        end else begin
            if (invalid_move) viu_invalido <= 1'b1;
            if (skip_action) viu_skip <= 1'b1;
            if (draw_action_disp) viu_draw <= 1'b1;
        end
    end

    // monta o codigo de 10 bits de uma carta
    function [9:0] mk;
        input [1:0] cat;
        input [3:0] val;
        input [3:0] cor;
        mk = {cat, val, cor};
    endfunction

    // carrega uma carta na fila do dealer (ordem de saque)
    task set_carta;
        input [7:0] idx;
        input [9:0] val;
        begin
            dealer.fila[idx] = val;
        end
    endtask

    // reset sincrono + botoes soltos
    task aplica_reset;
        begin
            rst = 1'b1;
            btn_next = 1'b1; btn_play = 1'b1; btn_draw = 1'b1;
            repeat (4) @(posedge clk);
            rst = 1'b0;
        end
    endtask

    // pressiona um botao por 1 ciclo (borda de descida = pressao)
    task aperta_draw; begin @(posedge clk); btn_draw = 1'b0; @(posedge clk); btn_draw = 1'b1; end endtask
    task aperta_play; begin @(posedge clk); btn_play = 1'b0; @(posedge clk); btn_play = 1'b1; end endtask
    task aperta_next; begin @(posedge clk); btn_next = 1'b0; @(posedge clk); btn_next = 1'b1; end endtask
