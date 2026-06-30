`timescale 1ns / 1ps

module top #(
    parameter HAND_SIZE = 7
)(
    // Clock principal
    input wire CLOCK_50,

    // Chaves (Switches)
    // SW[0]    -> Reset
    // SW[4:1]  -> Seletor de cor (one-hot)
    input wire [17:0] SW,

    // Botoes (Keys - ativos em baixo)
    // KEY[0] -> Next
    // KEY[1] -> Play
    // KEY[2] -> Draw
    input wire [3:0] KEY,

    // Displays de 7 Segmentos
    output wire [6:0] HEX7, // Cor Player
    output wire [6:0] HEX6, // Valor Player
    output wire [6:0] HEX5, // Cor Topo
    output wire [6:0] HEX4, // Valor Topo
    output wire [6:0] HEX3, // Qtd Cartas Player (Dez)
    output wire [6:0] HEX2, // Qtd Cartas Player (Unid)
    output wire [6:0] HEX1, // Qtd Cartas CPU (Dez)
    output wire [6:0] HEX0, // Qtd Cartas CPU (Unid)

    // LEDs
    output wire [17:0] LEDR,
    output wire [8:0] LEDG
);

    // Mapeamento dos botoes e chaves para fios internos
    wire clk            = CLOCK_50;
    wire rst            = SW[0];
    wire [3:0] color_selector = SW[4:1];
    wire btn_next       = KEY[0];
    wire btn_play       = KEY[1];
    wire btn_draw       = KEY[2];

    // Sinais internos temporizacao e reset
    wire rst_sync;
    wire tick_animacao;
    wire inicia_2s;
    wire tempo_2s;

    // Instanciar sincronizador de reset
    ResetSynchronizer #(.STAGES(4)) sync_reset (
        .clk(clk),
        .reset(rst),
        .reset_sync(rst_sync)
    );

    // Instanciar divisor de clock para o temporizador e display
    ClockDiv #(.BIT_ALVO(22)) div_clk (
        .clk(clk),
        .reset(rst_sync),
        .tick_out(tick_animacao)
    );

    // Instanciar o temporizador de 2 segundos
    timer_2s temporizador (
        .clk(clk),
        .reset(rst_sync),
        .tick(tick_animacao),
        .inicia_2s(inicia_2s),
        .tempo_2s(tempo_2s)
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

    // veredito de validade e estados do display
    wire       carta_valida;
    wire [9:0] top_card;
    wire       player_turn, cpu_turn, invalid_move, skip_action;
    wire       draw_action_disp, choosing_color, win, lose;
    wire [6:0] n_player, n_cpu;

    dealer_fsm dealer (
        .clk(clk), .rst(rst_sync), .draw(draw),
        .discard_in(discard_in), .discard_we(discard_we),
        .ram_addr(ram_addr), .ram_we(ram_we), .ram_data(ram_data), .ram_q(ram_q),
        .ready(ready), .busy(busy), .draw_action(draw_action),
        .carta_sorteada(carta_sorteada), .carta_ponteiro(carta_ponteiro), .deck_count(deck_count)
    );

    card_ram baralho (
        .clock(clk), .we(ram_we), .address(ram_addr), .data_in(ram_data), .q(ram_q)
    );

    player jogador (
        .clk(clk), .reset(rst_sync),
        .meu_turno(p_meu_turno),
        .next_pulse(p_next_pulse), .play_pulse(p_play_pulse), .draw_pulse(p_draw_pulse),
        .carta_valida(carta_valida),
        .deal(p_deal), .card_in(carta_sorteada), .remove(p_remove),
        .sinal_jogar(p_jogar), .sinal_comprar(p_comprar), .sinal_invalido(p_invalido),
        .fim_turno(p_fim), .carta_escolhida(player_card), .n_player(n_player), .vazio(p_vazio)
    );

    cpu maquina (
        .clk(clk), .reset(rst_sync),
        .meu_turno(c_meu_turno), .carta_valida(carta_valida),
        .deal(c_deal), .card_in(carta_sorteada), .remove(c_remove),
        .sinal_jogar(c_jogar), .sinal_comprar(c_comprar), .fim_turno(c_fim),
        .carta_escolhida(cpu_card), .cor_escolhida(cpu_cor), .n_cpu(n_cpu), .vazio(c_vazio)
    );

    controlador #(.HAND_SIZE(HAND_SIZE)) ctrl (
        .clk(clk), .reset(rst_sync),
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
        
        // Timer injetado
        .tempo_2s(tempo_2s),
        .inicia_2s(inicia_2s),
        
        // Display signals
        .top_card(top_card), .player_turn(player_turn), .cpu_turn(cpu_turn),
        .invalid_move(invalid_move), .skip_action(skip_action), .draw_action_disp(draw_action_disp),
        .choosing_color(choosing_color), .win(win), .lose(lose)
    );

    // modulo view_controller integrado ao top
    view_controller v_ctrl (
        .clk(clk),
        .reset_sync(rst_sync),
        .tick_animacao(tick_animacao),
        .player_card(player_card),
        .top_card(top_card),
        .choosing_color(choosing_color),
        .color_selector(color_selector),
        .n_player(n_player),
        .n_cpu(n_cpu),
        .player_turn(player_turn),
        .cpu_turn(cpu_turn),
        .invalid_move(invalid_move),
        .win_game(win),
        .lose_game(lose),
        .start_game(ready), // start da animacao de inicio associada ao baralho pronto
        
        // Saidas mapeadas diretamente para as portas da placa DE2-115
        .out_cor_player(HEX7),
        .out_val_player(HEX6),
        .out_cor_top(HEX5),
        .out_val_top(HEX4),
        .out_player_dez(HEX3),
        .out_player_unid(HEX2),
        .out_cpu_dez(HEX1),
        .out_cpu_unid(HEX0),
        .ledr(LEDR),
        .ledg(LEDG)
    );

endmodule