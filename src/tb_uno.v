`timescale 1ns / 1ps

module tb_uno;

    reg clk;
    reg rst;
    reg btn_next, btn_play, btn_draw; // ativos em baixo (1 = solto)
    reg [3:0] color_selector;

    wire [9:0] top_card;
    wire player_turn, cpu_turn;
    wire invalid_move, skip_action, draw_action_disp, choosing_color;
    wire win, lose;
    wire [6:0] n_player, n_cpu;

    integer acoes; // quantas vezes o player agiu
    integer reset_hold; // ns extras de reset (varia a semente do shuffle)

    top_uno #(.HAND_SIZE(7)) uut (
        .clk(clk), .rst(rst),
        .btn_next(btn_next), .btn_play(btn_play), .btn_draw(btn_draw),
        .color_selector(color_selector),
        .top_card(top_card), .player_turn(player_turn), .cpu_turn(cpu_turn),
        .invalid_move(invalid_move), .skip_action(skip_action),
        .draw_action_disp(draw_action_disp), .choosing_color(choosing_color),
        .win(win), .lose(lose), .n_player(n_player), .n_cpu(n_cpu)
    );

    always #10 clk = ~clk; // clock de 50MHz

    // pressiona o botao DRAW por 1 ciclo (borda de descida = pressao)
    task aperta_draw;
        begin
            @(posedge clk); btn_draw = 1'b0;
            @(posedge clk); btn_draw = 1'b1;
        end
    endtask

    // pressiona o botao PLAY por 1 ciclo (usado p/ confirmar a cor do coringa)
    task aperta_play;
        begin
            @(posedge clk); btn_play = 1'b0;
            @(posedge clk); btn_play = 1'b1;
        end
    endtask

    initial begin
        clk = 0; rst = 1;
        btn_next = 1'b1; btn_play = 1'b1; btn_draw = 1'b1;
        color_selector = 4'b1000; // vermelho
        acoes = 0;
        if (!$value$plusargs("RESET_HOLD=%d", reset_hold)) reset_hold = 0;

        $display("=================================================");
        $display("   PARTIDA DE UNO - player sempre compra         ");
        $display("=================================================");

        // reset sincrono
        repeat (4) @(posedge clk);
        #(reset_hold);
        rst = 0;

        // espera a distribuicao e a carta inicial (vez do player)
        wait (player_turn == 1'b1);
        #1;
        $display("[%0t] distribuicao: n_player=%0d n_cpu=%0d topo=%b", $time, n_player, n_cpu, top_card);
        if (n_player !== 7'd7 || n_cpu !== 7'd7) $display("  [FALHA] distribuicao incorreta");
        else $display("  [OK] 7 cartas para cada");
        if (top_card[9:8] !== 2'b00) $display("  [FALHA] carta inicial nao e numero");
        else $display("  [OK] carta inicial e numero");

        // o player so compra; a cpu joga sozinha. confirma a cor quando pedir coringa
        while (!win && !lose && acoes < 400) begin
            #4000; // tempo p/ o controlador processar a acao anterior (e o turno da cpu)
            if (choosing_color) begin
                color_selector = 4'b1000;
                aperta_play(); // confirma a cor do coringa comprado
            end else if (player_turn) begin
                aperta_draw();
                acoes = acoes + 1;
            end
        end

        $display("=================================================");
        if (win)  $display("   RESULTADO: WIN  (player venceu)  - %0d acoes", acoes);
        if (lose) $display("   RESULTADO: LOSE (cpu venceu)    - %0d acoes", acoes);
        if (!win && !lose) $display("   [TIMEOUT] jogo nao terminou em %0d acoes", acoes);
        $display("   n_player=%0d  n_cpu=%0d", n_player, n_cpu);
        $display("=================================================");
        $finish;
    end

endmodule
