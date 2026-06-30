`timescale 1ns / 1ps

// cenario: player joga skip (bloqueio) -> a vez volta para o player (CPU pulada).
module tb_skip;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000));    // topo: vermelho 5
        set_carta(8'd0,  mk(2'b01, 4'b1010, 4'b1000)); // mao[0] player: bloqueio vermelho (casa cor)

        wait (player_turn == 1'b1);
        #1;
        aperta_play();          // joga o skip
        wait (n_player == 7'd6); // player jogou
        repeat (30) @(posedge clk);
        if (player_turn && n_cpu == 7'd7 && viu_skip)
            $display("[OK] skip: a vez voltou pro player, CPU nao jogou (n_cpu=%0d)", n_cpu);
        else
            $display("[FALHA] skip: player_turn=%b n_cpu=%0d viu_skip=%b", player_turn, n_cpu, viu_skip);
        $finish;
    end

endmodule
