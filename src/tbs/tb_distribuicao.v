`timescale 1ns / 1ps

// cenario: distribuicao inicial (7 cartas p/ cada) e carta inicial numero.
module tb_distribuicao;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        // fila default e tudo "vermelho 0" (numero): distribui 7+7 e topo numero

        wait (player_turn == 1'b1);
        #1;
        $display("distribuicao: n_player=%0d n_cpu=%0d topo=%b", n_player, n_cpu, top_card);
        if (n_player == 7'd7 && n_cpu == 7'd7) $display("[OK] 7 cartas para cada");
        else $display("[FALHA] distribuicao incorreta");
        if (top_card[9:8] == 2'b00) $display("[OK] carta inicial e numero");
        else $display("[FALHA] carta inicial nao e numero");
        $finish;
    end

endmodule
