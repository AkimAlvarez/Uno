`timescale 1ns / 1ps

// cenario: player joga +2; a CPU nao tem +2 -> compra 2 cartas e e pulada.
module tb_penalidade;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000));    // topo: vermelho 5
        set_carta(8'd0,  mk(2'b01, 4'b1100, 4'b1000)); // mao[0] player: +2 vermelho (casa cor)
        // mao da CPU fica default (vermelho 0) -> sem +2 para empilhar

        wait (player_turn == 1'b1);
        #1;
        aperta_play();           // joga o +2
        wait (n_player == 7'd6); // player jogou o +2

        wait (n_cpu == 7'd9);    // CPU comprou 2 (7 -> 9)
        wait (player_turn == 1'b1); // aguarda o timer de 2s liberar o controlador
        if (player_turn) $display("[OK] penalidade: CPU comprou 2 e foi pulada (n_cpu=%0d)", n_cpu);
        else $display("[FALHA] penalidade: player_turn=%b n_cpu=%0d", player_turn, n_cpu);
        $finish;
    end

endmodule
