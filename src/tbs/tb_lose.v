`timescale 1ns / 1ps

// cenario: o player so compra cartas invalidas (nunca joga) -> a CPU esvazia
// a mao e o player perde (LOSE).
module tb_lose;

    `include "uno_bancada.vh"

    integer i;
    integer guard;

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000)); // topo: vermelho 5
        // todas as compras do player serao azul 2 (invalidas sobre vermelho) -> ele guarda e passa
        for (i = 15; i < 80; i = i + 1)
            set_carta(i[7:0], mk(2'b00, 4'd2, 4'b0010));
        // mao da CPU default (vermelho 0) casa com o topo -> joga sempre

        wait (player_turn == 1'b1);
        guard = 0;
        while (!win && !lose && guard < 100) begin
            if (player_turn) begin
                aperta_draw();              // player so compra (e passa)
                @(posedge clk);
                wait (!player_turn || win || lose);
                guard = guard + 1;
            end else begin
                @(posedge clk);
            end
        end

        if (lose) $display("[OK] LOSE: a CPU esvaziou a mao (n_cpu=%0d)", n_cpu);
        else $display("[FALHA] resultado inesperado: win=%b lose=%b", win, lose);
        $finish;
    end

endmodule
