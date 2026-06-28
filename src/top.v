`timescale 1ns / 1ps

module top_uno #(
    parameter HAND_SIZE = 7
)(
    input wire clk,
    input wire rst,

    // botoes
    input wire btn_next,
    input wire btn_play,
    input wire btn_draw,
    input wire [3:0] color_selector,

    // saidas de jogo (iriam para o display)
    output wire [9:0] top_card,
    output wire player_turn,
    output wire cpu_turn,
    output wire invalid_move,
    output wire skip_action,
    output wire draw_action_disp,
    output wire choosing_color,
    output wire win,
    output wire lose,
    output wire [6:0] n_player,
    output wire [6:0] n_cpu
);

    // dealer <-> ram
    wire [6:0] ram_addr;
    wire       ram_we;
    wire [9:0] ram_data;
    wire [9:0] ram_q;

    // dealer <-> controlador
    wire       ready, busy, draw_action;
    wire [9:0] carta_sorteada;
    wire [6:0] carta_ponteiro;
    wire [7:0] deck_count;
    wire       draw, discard_we;
    wire [9:0] discard_in;

    // controlador <-> player
    wire       p_jogar, p_comprar, p_invalido, p_fim;
    wire [9:0] player_card;
    wire       p_vazio;
    wire       p_meu_turno, p_next_pulse, p_play_pulse, p_draw_pulse, p_deal, p_remove;

    // controlador <-> cpu
    wire       c_jogar, c_comprar, c_fim;
    wire [9:0] cpu_card;
    wire [3:0] cpu_cor;
    wire       c_vazio;
    wire       c_meu_turno, c_deal, c_remove;

    // veredito de validade (controlador -> player/cpu)
    wire       carta_valida;

    dealer_fsm dealer (
        .clk(clk), .rst(rst), .draw(draw),
        .discard_in(discard_in), .discard_we(discard_we),
        .ram_addr(ram_addr), .ram_we(ram_we), .ram_data(ram_data), .ram_q(ram_q),
        .ready(ready), .busy(busy), .draw_action(draw_action),
        .carta_sorteada(carta_sorteada), .carta_ponteiro(carta_ponteiro), .deck_count(deck_count)
    );

    card_ram baralho (
        .clock(clk), .we(ram_we), .address(ram_addr), .data_in(ram_data), .q(ram_q)
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

    controlador #(.HAND_SIZE(HAND_SIZE)) ctrl (
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

endmodule
