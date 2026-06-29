`timescale 1ns / 1ps

module tb_led_animator();

    reg clk;
    reg reset;
    reg player_turn;
    reg cpu_turn;
    reg invalid_move;
    reg win_game;
    reg lose_game;
    reg start_game;

    wire tick_rapido;

    wire [17:0] ledr;
    wire [8:0] ledg;

    LedAnimator dut (
        .clk(clk),
        .reset(reset),
        .player_turn(player_turn),
        .tick_rapido(tick_rapido),
        .cpu_turn(cpu_turn),
        .invalid_move(invalid_move),
        .win_game(win_game),
        .lose_game(lose_game),
        .start_game(start_game),
        .ledr(ledr),
        .ledg(ledg)
    );

    ClockDiv dut_tick (
        .clk(clk),
        .reset(reset),
        .tick_out(tick_rapido)
    );

    defparam dut_tick.BIT_ALVO = 2;

    always #5 clk = ~clk;

    initial begin
        $monitor("Tempo: %0t | Tick: %b | Leds Verdes: %b | Leds Vermelhos: %b",
                 $time, tick_rapido, ledg, ledr);
    end

    task wait_ticks;
        input integer num_ticks;
        integer i;
        begin
            for (i = 0; i < num_ticks; i = i + 1) begin
                @(posedge tick_rapido);
            end
        end
    endtask

    task pulse_signal;
        output sig;
        begin
            @(posedge clk);
            sig = 1;
            @(posedge clk);
            sig = 0;
        end
    endtask

    initial begin
        clk = 0; reset = 1;
        player_turn = 0; cpu_turn = 0;
        invalid_move = 0; win_game = 0; lose_game = 0; start_game = 0;

        #20;
        reset = 0;

        $display("TESTANDO START GAME");
        pulse_signal(start_game);
        wait_ticks(5); // Espera as 4 viradas de LED do estado IDLE acabarem

        $display("--- TESTANDO TURNOS ---");
        player_turn = 1;
        #50; // Dá tempo para os LEDs verdes acenderem

        $display("--- TESTANDO MOVIMENTO INVÁLIDO ---");
        pulse_signal(invalid_move);
        // O LedAnimator leva 4 ticks para piscar o erro. Temos que esperar!
        wait_ticks(5);

        $display("--- TROCANDO TURNO PARA CPU ---");
        player_turn = 0;
        cpu_turn = 1;
        #50;

        $display("--- TESTANDO VITÓRIA ---");
        pulse_signal(win_game);
        // A animação de vitória leva 62 ticks. O testbench TEM que aguardar.
        wait_ticks(65);

        $display("--- TESTANDO DERROTA ---");
        // Dá um pulso rápido de start para tirar do IDLE
        pulse_signal(start_game);
        wait_ticks(5);

        pulse_signal(lose_game);
        wait_ticks(65);

        $display("--- FIM DO TESTE ---");
        $stop;
    end

endmodule