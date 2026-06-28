`timescale 1ns / 1ps

// cenario: o player esvazia a mao primeiro -> WIN. Como tudo e "vermelho 0",
// toda carta casa, entao o player so joga em todo turno e acaba antes.
module tb_win;

    `include "uno_bancada.vh"

    integer guard;

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        // fila default tudo vermelho 0 (todas casam entre si)

        wait (player_turn == 1'b1);
        guard = 0;
        while (!win && !lose && guard < 100) begin
            if (player_turn) begin
                aperta_play();              // joga a carta selecionada (sempre valida)
                @(posedge clk);
                wait (!player_turn || win || lose); // turno passou
                guard = guard + 1;
            end else begin
                @(posedge clk);             // espera a CPU jogar sozinha
            end
        end

        if (win) $display("[OK] WIN: player esvaziou a mao (n_player=%0d)", n_player);
        else $display("[FALHA] resultado inesperado: win=%b lose=%b", win, lose);
        $finish;
    end

endmodule
