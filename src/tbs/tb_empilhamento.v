`timescale 1ns / 1ps

// cenario: player joga +2, a CPU empilha outro +2; o player (sem +2) come 4 cartas.
module tb_empilhamento;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000));    // topo: vermelho 5
        set_carta(8'd0,  mk(2'b01, 4'b1100, 4'b1000)); // mao[0] player: +2 vermelho
        set_carta(8'd7,  mk(2'b01, 4'b1100, 4'b0100)); // mao[0] CPU: +2 verde (empilha)
        // resto das maos default (vermelho 0): player nao tem outro +2

        wait (player_turn == 1'b1);
        #1;
        aperta_play();           // player joga +2
        wait (n_cpu == 7'd6);    // CPU empilhou um +2
        $display("[OK] CPU empilhou +2 (n_cpu=%0d)", n_cpu);

        wait (player_turn == 1'b1); // volta pro player, agora com penalidade 4
        #1;
        aperta_draw();           // player nao tem +2 -> come a penalidade
        wait (n_player >= 7'd10); // 6 -> 10 (comprou 4)
        $display("[OK] player comeu 4 cartas acumuladas (n_player=%0d)", n_player);
        $finish;
    end

endmodule
