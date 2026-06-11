`timescale 1ns / 1ps

module tb_view_controller();

    // controles
    reg clk;
    reg reset;

    // dados do jogo
    reg [9:0] player_card;
    reg [9:0] top_card;
    reg [6:0] n_player;
    reg [6:0] n_cpu;

    // status
    reg player_turn;
    reg cpu_turn;
    reg invalid_move;
    reg win_game;
    reg lose_game;
    reg start_game;

    // novas entradas do menu de cores
    reg choosing_color;
    reg [3:0] color_selector;

    // saídas
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

    // instanciação do dut
    ViewController dut (
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

    // força os redutores de frequência internos a baterem a cada 4 clocks (bit 2)
    // em vez de esperar milhões de ciclos. evita que o pc trave.
    defparam dut.animador_leds.redutor_freq.BIT_ALVO = 2;
    defparam dut.animador_displays.redutor_freq.BIT_ALVO = 2;

    // gerador de clock (frequência de 50mhz = período de 20ns)
    // inverte o sinal a cada 10ns (metade do período)
    always #10 clk = ~clk;

    // imprime no console sempre que o estado dos displays do jogador mudar
    initial begin
        $monitor("Tempo: %0t | Turno P/C: %b/%b | Menu: %b | Disp_Esq: %b | Disp_Dir: %b",
                 $time, player_turn, cpu_turn, choosing_color, out_cor_player, out_val_player);
    end

    // inicio dos testes
    initial begin
        // inicialização
        clk = 0;
        reset = 1;
        player_card = 10'b0;
        top_card = 10'b0;
        choosing_color = 0;
        color_selector = 4'b0000;
        n_player = 7'd0;
        n_cpu = 7'd0;
        player_turn = 0;
        cpu_turn = 0;
        invalid_move = 0;
        win_game = 0;
        lose_game = 0;
        start_game = 0;

        // dá tempo suficiente (100ns = 5 clocks) para o sinal passar pelo shift register de 4 bits
        #100;
        reset = 0;

        // testar display das cartas
        #20;
        player_card = 10'b1010_0011; // ex: valor 10, cor 3
        top_card = 10'b1110_0000;    // ex: curinga recém jogado na mesa (cor preta 0000)
        n_player = 7'd12;            // testa o conversor de unidades (12 cartas)

        // testa as máquinas de estado do led
        #50;
        start_game = 1; // dá um pulso no start
        #20;
        start_game = 0; // solta o botão

        #100;
        player_turn = 1; // inicia o turno do jogador

        // teste menu de mudar de cor

        #100;
        choosing_color = 1;         // ativa o menu de seleção
        color_selector = 4'b0100;   // jogador olha a cor verde

        // tempo longo o suficiente para ver o display do jogador piscar

        #400;
        color_selector = 4'b0010;   // jogador olha a cor azul

        #400;
        color_selector = 4'b1000;   // jogador confirma a cor vermelha

        #20;
        choosing_color = 0;         // desativa o menu (volta pro jogo)
        top_card = 10'b1110_1000;   // atualiza a carta da mesa pro curinga assumir a cor vermelha

        // deixa a simulação rodar por um tempo longo e depois para
        #1000;
        $stop;
    end

endmodule