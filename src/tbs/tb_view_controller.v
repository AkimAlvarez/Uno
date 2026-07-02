`timescale 1ns / 1ps

module tb_view_controller();

    // sinais de controle
    reg clk;
    reg reset;

    // sinais gerados localmente (externalizados do src/view_controller.v)
    wire reset_sync;
    wire tick_animacao;

    reg [9:0] player_card;
    reg [9:0] top_card;
    reg [6:0] n_player;
    reg [6:0] n_cpu;

    reg player_turn;
    reg cpu_turn;
    reg invalid_move;
    reg win_game;
    reg lose_game;
    reg start_game;

    reg choosing_color;
    reg [3:0] color_selector;

    wire [6:0] out_cor_player;
    wire [6:0] out_val_player;
    wire [6:0] out_cor_top;
    wire [6:0] out_val_top;
    wire [6:0] out_player_unid;
    wire [6:0] out_player_dez;
    wire [6:0] out_cpu_unid;
    wire [6:0] out_cpu_dez;
    wire [17:0] ledr;
    wire [8:0] ledg;

    // Sincronizador de reset
    ResetSynchronizer #(.STAGES(4)) sync_reset (
        .clk       (clk),
        .reset     (reset),
        .reset_sync(reset_sync)
    );

    // Divisor de clock acelerado para simulacao (BIT_ALVO=2 -> tick a cada 4 ciclos)
    ClockDiv #(.BIT_ALVO(2)) redutor_freq (
        .clk     (clk),
        .reset   (reset_sync),
        .tick_out(tick_animacao)
    );

    // instanciacao do view controller
    view_controller dut (
        .clk           (clk),
        .reset_sync    (reset_sync),
        .tick_animacao (tick_animacao),
        .player_card   (player_card),
        .top_card      (top_card),
        .choosing_color(choosing_color),
        .color_selector(color_selector),
        .n_player      (n_player),
        .n_cpu         (n_cpu),
        .player_turn   (player_turn),
        .cpu_turn      (cpu_turn),
        .invalid_move  (invalid_move),
        .win_game      (win_game),
        .lose_game     (lose_game),
        .start_game    (start_game),
        .out_cor_player(out_cor_player),
        .out_val_player(out_val_player),
        .out_cor_top   (out_cor_top),
        .out_val_top   (out_val_top),
        .out_player_unid(out_player_unid),
        .out_player_dez(out_player_dez),
        .out_cpu_unid  (out_cpu_unid),
        .out_cpu_dez   (out_cpu_dez),
        .ledr          (ledr),
        .ledg          (ledg)
    );

    // Gerador de clock (50MHz = 20ns de periodo)
    always #10 clk = ~clk;

    // ----------------------------------------------------------------
    // Tasks de teste
    // ----------------------------------------------------------------

    task apply_reset;
        begin
            $display("[%0t] [SYSTEM] Aplicando Reset...", $time);
            reset = 1;
            #100; // espera os 4 estagios do ResetSynchronizer
            reset = 0;
            #40;
        end
    endtask

    task test_cards;
        input [9:0] p_card;
        input [9:0] t_card;
        input [8*30:1] description;
        begin
            $display("[%0t] [DECODERS] Cartas: %s", $time, description);
            player_card = p_card;
            top_card    = t_card;
            #100;
        end
    endtask

    task test_quantities;
        input [6:0] p_qtd;
        input [6:0] c_qtd;
        begin
            $display("[%0t] [CONVERSOR] Testando BCD: Player=%d, CPU=%d", $time, p_qtd, c_qtd);
            n_player = p_qtd;
            n_cpu    = c_qtd;
            #100;
        end
    endtask

    // ----------------------------------------------------------------
    // Roteiro
    // ----------------------------------------------------------------
    initial begin
        clk = 0; reset = 0;
        player_card = 0; top_card = 0;
        n_player = 0; n_cpu = 0;
        player_turn = 0; cpu_turn = 0; choosing_color = 0; color_selector = 0;
        invalid_move = 0; win_game = 0; lose_game = 0; start_game = 0;

        $display("iniciando testes:");

        apply_reset();
        #100;

        // ----------------------------------------------------------------
        // INICIO DO JOGO
        // ----------------------------------------------------------------
        $display("[%0t] [START] Segurando start_game ate as FSMs sairem do IDLE", $time);
        @(posedge clk); start_game = 1;
        #1000;                              // ~6 periodos de tick (BIT_ALVO=2)
        @(posedge clk); start_game = 0;
        #100;

        // ----------------------------------------------------------------
        // DECODERS: carta do player e do topo
        // ----------------------------------------------------------------
        test_cards(10'b00_0001_1000, 10'b00_1001_0100, "Player: Vermelho 1 | Top: Verde 9");
        test_cards(10'b01_1010_0010, 10'b01_1011_0001, "Player: Azul Bloqueio | Top: Amarelo Inverso");
        test_cards(10'b01_1100_1000, 10'b10_1101_0000, "Player: Vermelho +2 | Top: Coringa sem cor");
        test_cards(10'b10_1110_0000, 10'b10_1110_0000, "Player: Coringa +4  | Top: Coringa +4");

        // ----------------------------------------------------------------
        // CONVERSOR BCD da quantidade de cartas
        // ----------------------------------------------------------------
        test_quantities(7'd0,  7'd0);    // limite inferior
        test_quantities(7'd9,  7'd5);    // apenas unidades
        test_quantities(7'd10, 7'd19);   // virada da dezena
        test_quantities(7'd55, 7'd42);   // numeros intermediarios
        test_quantities(7'd99, 7'd108);  // acima do limite -> trava em 99

        // ----------------------------------------------------------------
        // TURNOS
        // ----------------------------------------------------------------
        $display("[%0t] [LED_ANIM] Turno do PLAYER (verdes)", $time);
        player_turn = 1; cpu_turn = 0; #400;
        $display("[%0t] [LED_ANIM] Turno da CPU (vermelhos)", $time);
        player_turn = 0; cpu_turn = 1; #400;

        // ----------------------------------------------------------------
        // JOGADA INVALIDA
        // ----------------------------------------------------------------
        $display("[%0t] [LED_ANIM] Jogada invalida (piscada dupla)", $time);
        player_turn = 1; cpu_turn = 0;
        @(posedge clk); invalid_move = 1;
        @(posedge clk); invalid_move = 0;
        #2000;

        // ----------------------------------------------------------------
        // MENU DE COR
        // ----------------------------------------------------------------
        $display("[%0t] [DISP_ANIM] Menu de escolha de cor (blink)", $time);
        choosing_color = 1;
        color_selector = 4'b1000; #800; // vermelho
        color_selector = 4'b0100; #800; // verde
        color_selector = 4'b0010; #800; // azul
        color_selector = 4'b0001; #800; // amarelo
        choosing_color = 0; #400;

        // ----------------------------------------------------------------
        // VITORIA
        // ----------------------------------------------------------------
        $display("[%0t] [LED_ANIM] Vitoria do PLAYER (cobrinha verde)", $time);
        @(posedge clk); win_game = 1;
        @(posedge clk); win_game = 0;
        #12000;

        // ----------------------------------------------------------------
        // DERROTA (reinicia e dispara lose_game)
        // ----------------------------------------------------------------
        apply_reset();
        @(posedge clk); start_game = 1; #1000; @(posedge clk); start_game = 0; #100;
        player_turn = 1; cpu_turn = 0; #200;

        $display("[%0t] [LED_ANIM] Derrota do PLAYER (cobrinha vermelha)", $time);
        @(posedge clk); lose_game = 1;
        @(posedge clk); lose_game = 0;
        #12000;

        $display("fim do teste");
        $stop;
    end

    initial begin
        $monitor("-> OUT_COR_P: %b | OUT_VAL_P: %b | N_PLAYER: %b%b",
                 out_cor_player, out_val_player, out_player_dez, out_player_unid);
    end

endmodule
