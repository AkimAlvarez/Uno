`timescale 1ns / 1ps

module tb_view_controller();

    //  sinais de controle
    reg clk;
    reg reset;

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

    // instanciação do view controller (top)

    view_controller dut (
        .clk(clk),
        .reset(reset),
        .player_card(player_card),
        .top_card(top_card),
        .choosing_color(choosing_color),
        .color_selector(color_selector),
        .n_player(n_player),
        .n_cpu(n_cpu),
        .player_turn(player_turn),
        .cpu_turn(cpu_turn),
        .invalid_move(invalid_move),
        .win_game(win_game),
        .lose_game(lose_game),
        .start_game(start_game),
        .out_cor_player(out_cor_player),
        .out_val_player(out_val_player),
        .out_cor_top(out_cor_top),
        .out_val_top(out_val_top),
        .out_player_unid(out_player_unid),
        .out_player_dez(out_player_dez),
        .out_cpu_unid(out_cpu_unid),
        .out_cpu_dez(out_cpu_dez),
        .ledr(ledr),
        .ledg(ledg)
    );

    // Acelera os animadores reduzindo o divisor de clock
    defparam dut.redutor_freq.BIT_ALVO = 2;

    // Gerador de clock (50MHz = 20ns de período)
    always #10 clk = ~clk;

    // tasks de teste

    // task pra aplicar o reset esperando o sincronizador
    task apply_reset;
        begin
            $display("[%0t] [SYSTEM] Aplicando Reset...", $time);
            reset = 1;
            #100; // espera os 4 estágios do shift register do ResetSynchronizer
            reset = 0;
            #40;
        end
    endtask

    // testa a decodificação de cartas (DecoderCor e DecoderValor)
    task test_cards;
        input [9:0] p_card;
        input [9:0] t_card;
        input [8*30:1] description;
        begin
            $display("[%0t] [DECODERS] Cartas: %s", $time, description);
            player_card = p_card;
            top_card = t_card;
            #100;
        end
    endtask

    // testa limites do conversor Binário para BCD (Quantidade de cartas)
    task test_quantities;
        input [6:0] p_qtd;
        input [6:0] c_qtd;
        begin
            $display("[%0t] [CONVERSOR] Testando BCD: Player=%d, CPU=%d", $time, p_qtd, c_qtd);
            n_player = p_qtd;
            n_cpu = c_qtd;
            #100;
        end
    endtask


    initial begin
        // inicialização de todas as variáveis
        clk = 0; reset = 0;
        player_card = 0; top_card = 0;
        n_player = 0; n_cpu = 0;
        player_turn = 0; cpu_turn = 0; choosing_color = 0; color_selector = 0;
        invalid_move = 0; win_game = 0; lose_game = 0; start_game = 0;

        $display("iniciando testes:");

        // aplica o idle geral (reset)
        apply_reset();
        #100;

        // ----------------------------------------------------------------
        // INICIO DO JOGO: start_game precisa ficar ALTO durante a animacao
        // de inicio (o LedAnimator conta piscadas em bordas do tick ate ir
        // para TURNOS; o DisplayAnimator vai para NORMAL_GAME).
        // ----------------------------------------------------------------
        $display("[%0t] [START] Segurando start_game ate as FSMs sairem do IDLE", $time);
        @(posedge clk); start_game = 1;
        #1000;                              // ~6 periodos de tick (BIT_ALVO=2)
        @(posedge clk); start_game = 0;
        #100;

        // ----------------------------------------------------------------
        // DECODERS: agora em NORMAL_GAME o display do jogador deve mostrar
        // a carta. A carta da mesa (top) nao depende da FSM.
        // ----------------------------------------------------------------
        test_cards(10'b00_0001_1000, 10'b00_1001_0100, "Player: Vermelho 1 | Top: Verde 9");
        test_cards(10'b01_1010_0010, 10'b01_1011_0001, "Player: Azul Bloqueio | Top: Amarelo Inverso");
        test_cards(10'b01_1100_1000, 10'b10_1101_0000, "Player: Vermelho +2 | Top: Coringa sem cor");
        test_cards(10'b10_1110_0000, 10'b10_1110_0000, "Player: Coringa +4  | Top: Coringa +4");

        // CONVERSOR (BCD da quantidade de cartas) - nao depende da FSM
        test_quantities(7'd0,  7'd0);   // limite inferior
        test_quantities(7'd9,  7'd5);   // apenas unidades
        test_quantities(7'd10, 7'd19);  // virada da dezena
        test_quantities(7'd55, 7'd42);  // números intermediários
        test_quantities(7'd99, 7'd108); // acima do limite -> trava em 99

        // ----------------------------------------------------------------
        // TURNOS: verde para o jogador, vermelho para a CPU
        // ----------------------------------------------------------------
        $display("[%0t] [LED_ANIM] Turno do PLAYER (verdes)", $time);
        player_turn = 1; cpu_turn = 0; #400;
        $display("[%0t] [LED_ANIM] Turno da CPU (vermelhos)", $time);
        player_turn = 0; cpu_turn = 1; #400;

        // ----------------------------------------------------------------
        // JOGADA INVALIDA: piscada dupla dos vermelhos e volta pra TURNOS
        // ----------------------------------------------------------------
        $display("[%0t] [LED_ANIM] Jogada invalida (piscada dupla)", $time);
        player_turn = 1; cpu_turn = 0;
        @(posedge clk); invalid_move = 1;
        @(posedge clk); invalid_move = 0;
        #2000;

        // ----------------------------------------------------------------
        // MENU DE COR: DisplayAnimator entra em CHOOSING_COLOR (pisca a cor)
        // ----------------------------------------------------------------
        $display("[%0t] [DISP_ANIM] Menu de escolha de cor (blink)", $time);
        choosing_color = 1;
        color_selector = 4'b1000; #800; // vermelho
        color_selector = 4'b0100; #800; // verde
        color_selector = 4'b0010; #800; // azul
        color_selector = 4'b0001; #800; // amarelo
        choosing_color = 0; #400;

        // ----------------------------------------------------------------
        // VITORIA: cobrinha verde por ~5s e volta para IDLE
        // ----------------------------------------------------------------
        $display("[%0t] [LED_ANIM] Vitoria do PLAYER (cobrinha verde)", $time);
        @(posedge clk); win_game = 1;
        @(posedge clk); win_game = 0;
        #12000;                             // tempo para a animacao concluir

        // ----------------------------------------------------------------
        // DERROTA: reinicia, recomeca o jogo e dispara lose_game
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

    // monitora o console

    initial begin
        $monitor("-> OUT_COR_P: %b | OUT_VAL_P: %b | N_PLAYER: %b%b",
                 out_cor_player, out_val_player, out_player_dez, out_player_unid);
    end

endmodule