// controlador geral para a visualização do jogo

module ViewController (
    // entradas do sistema
    input clk,
    input reset,

    // entrada da carta do jogador e da mesa
    input [9:0] player_card,
    input [9:0] top_card,

    // controles do menu de cores
    input choosing_color,
    input [3:0] color_selector,

    // contadores de cartas
    input [6:0] n_player,
    input [6:0] n_cpu,

    // entradas de status do jogo (comandos da fsm)
    input player_turn,
    input cpu_turn,
    input invalid_move,
    input win_game,
    input lose_game,
    input start_game,

    // saídas (pinagem física da placa)
    output [6:0] out_cor_player,
    output [6:0] out_val_player,
    output [6:0] out_cor_top,
    output [6:0] out_val_top,
    output [6:0] out_player_unid,
    output [6:0] out_player_dez,
    output [6:0] out_cpu_unid,
    output [6:0] out_cpu_dez,
    output [17:0] ledr,
    output [8:0] ledg
);

    wire w_reset_sync; // fio que vai receber o reset limpo

    ResetSynchronizer #(
        .STAGES(4) // 4 flip-flops de proteção
    ) sync_reset (
        .clk(clk),
        .reset(reset),
        .reset_sync(w_reset_sync)
    );

    // gera o clk para as animações

    wire w_tick_animacao;

    ClockDiv redutor_freq(
        .clk(clk),
        .reset(w_reset_sync),
        .tick_out(w_tick_animacao)
    );


    // animação dos leds
    LedAnimator animador_leds (
        .clk(clk),
        .reset(w_reset_sync),
        .tick_rapido(w_tick_animacao),
        .player_turn(player_turn),
        .cpu_turn(cpu_turn),
        .invalid_move(invalid_move),
        .win_game(win_game),
        .lose_game(lose_game),
        .start_game(start_game),
        .ledr(ledr),
        .ledg(ledg)
    );

    // animação dos displays
    wire [6:0] w_dec_cor_p; // fio interno p cor decodificada
    wire [6:0] w_dec_val_p; // fio interno p valor decodificado

    // dedodificação da cor e do binário p display (player)
    DecoderCor dec_cor_p (
        .cor_input(player_card[3:0]),
        .display_out(w_dec_cor_p)
    );
    DecoderValor dec_val_p (
        .valor_input(player_card[7:4]),
        .display_out(w_dec_val_p)
    );

    // injeta os sinais no animador pra tratar a lógica de piscar
    DisplayAnimator animador_displays (
        .clk(clk),
        .reset(w_reset_sync),
        .tick_rapido(w_tick_animacao),
        .choosing_color(choosing_color),
        .game_start(start_game),
        .color_selector(color_selector),
        .decoded_p_color(w_dec_cor_p),
        .decoded_p_valor(w_dec_val_p),
        .left_p_display(out_cor_player),
        .right_p_display(out_val_player)
    );

    // displays mesa (top card)
    DecoderCor dec_cor_t (
        .cor_input(top_card[3:0]),
        .display_out(out_cor_top)
    );
    DecoderValor dec_val_t (
        .valor_input(top_card[7:4]),
        .display_out(out_val_top)
    );

    // contadores de cartas
    wire [3:0] w_player_dez, w_player_unid;
    wire [3:0] w_cpu_dez, w_cpu_unid;

    // conversor e displays do jogador
    QuantityConversor conv_player (
        .qtd_cards(n_player),
        .display_out_dez(w_player_dez),
        .display_out_unid(w_player_unid)
    );
    DecoderValor disp_p_dez (
        .valor_input(w_player_dez),
        .display_out(out_player_dez)
    );
    DecoderValor disp_p_unid (
        .valor_input(w_player_unid),
        .display_out(out_player_unid)
    );

    // conversor e displays da cpu
    QuantityConversor conv_cpu (
        .qtd_cards(n_cpu),
        .display_out_dez(w_cpu_dez),
        .display_out_unid(w_cpu_unid)
    );
    DecoderValor disp_c_dez (
        .valor_input(w_cpu_dez),
        .display_out(out_cpu_dez)
    );
    DecoderValor disp_c_unid (
        .valor_input(w_cpu_unid),
        .display_out(out_cpu_unid)
    );

endmodule