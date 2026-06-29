`timescale 1ns / 1ps

module tb_display_animator();

    reg clk;
    reg reset;
    reg tick_rapido;
    reg choosing_color;
    reg game_start;
    reg [3:0] color_selector;
    reg [6:0] decoded_p_valor;
    reg [6:0] decoded_p_color;

    wire [6:0] right_p_display;
    wire [6:0] left_p_display;

    localparam APAGADO = 7'b1111111;
    localparam LETRA_E = 7'b0000110;
    localparam LETRA_A = 7'b0001000;

    DisplayAnimator dut (
        .clk(clk),
        .reset(reset),
        .tick_rapido(tick_rapido),
        .choosing_color(choosing_color),
        .game_start(game_start),
        .color_selector(color_selector),
        .decoded_p_valor(decoded_p_valor),
        .decoded_p_color(decoded_p_color),
        .right_p_display(right_p_display),
        .left_p_display(left_p_display)
    );

    // Clock de 50MHz (período de 20ns)
    always #10 clk = ~clk;

    // Gerador de tick_rapido síncrono (bate a cada 5 clocks para acelerar o teste)
    reg [2:0] tick_counter;
    always @(posedge clk) begin
        if (reset) begin
            tick_counter <= 0;
            tick_rapido <= 0;
        end else begin
            if (tick_counter == 3'd4) begin
                tick_rapido <= 1'b1;
                tick_counter <= 0;
            end else begin
                tick_rapido <= 1'b0;
                tick_counter <= tick_counter + 3'd1;
            end
        end
    end

    task apply_reset;
        begin
            reset = 1;
            #50;
            reset = 0;
        end
    endtask

    task wait_ticks;
        input integer num_ticks;
        integer i;
        begin
            for (i = 0; i < num_ticks; i = i + 1) begin
                @(posedge clk & tick_rapido);
            end
        end
    endtask

    initial begin
        clk = 0;
        choosing_color = 0;
        game_start = 0;
        color_selector = 4'b0000;
        decoded_p_valor = 7'b1000000; // Valor qualquer
        decoded_p_color = 7'b1111001; // Valor qualquer

        $display(" INICIANDO TESTE DO DISPLAY ANIMATOR");

        // RESET E ESTADO IDLE
        $display("[%0t] Verificando IDLE (Displays devem estar apagados)", $time);
        apply_reset();
        #100;

        // TRANSIÇÃO PARA NORMAL GAME
        $display("[%0t] Game Start (Displays devem mostrar decoded_p_*)", $time);
        @(posedge clk);
        game_start = 1;
        @(posedge clk);
        game_start = 0;

        // Simula o jogo rodando normalmente por alguns ciclos
        #200;

        // Atualiza a carta na mão do jogador
        @(posedge clk);
        decoded_p_valor = 7'b0100100; // Muda o valor decodificado da carta
        #200;

        // ESTADO DE MENU (CHOOSING COLOR)
        $display("[%0t] Entrando no Menu de Cores (Displays devem piscar)", $time);
        @(posedge clk);
        choosing_color = 1;

        // Testando a seleção da cor Verde
        color_selector = 4'b0100;
        $display("[%0t] Selecionando cor: VERDE", $time);
        wait_ticks(6); // Espera 6 ticks (suficiente para ver ligar, desligar e ligar de novo na forma de onda)

        // Testando a seleção da cor Azul
        color_selector = 4'b0010;
        $display("[%0t] Selecionando cor: AZUL", $time);
        wait_ticks(4);

        // Testando a seleção da cor Vermelha
        color_selector = 4'b1000;
        $display("[%0t] Selecionando cor: VERMELHA", $time);
        wait_ticks(4);

        // Testando a seleção da cor Amarela
        color_selector = 4'b0001;
        $display("[%0t] Selecionando cor: AMARELA", $time);
        wait_ticks(4);

        // SAÍDA DO MENU E VOLTA AO NORMAL
        $display("[%0t] Confirmando cor e voltando ao jogo", $time);
        @(posedge clk);
        choosing_color = 0; // Jogador confirmou

        // Muda as variáveis decodificadas simulando a atualização do controlador geral após a jogada
        decoded_p_valor = 7'b0011001;
        decoded_p_color = LETRA_A;

        #300;

        $display(" TESTES FINALIZADOS");
        $stop;
    end

    // Monitoramento reativo no console
    initial begin
        $monitor("Tempo: %0t | Estado Escolha: %b | Pisca: %b | Disp Esq: %b | Disp Dir: %b",
                 $time, choosing_color, dut.pisca_status, left_p_display, right_p_display);
    end

endmodule