`timescale 1ns / 1ps

// cenario: a CPU nao tem carta valida -> compra automaticamente e passa a vez.
module tb_cpu_compra;

    `include "uno_bancada.vh"

    integer i;

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000));        // topo: vermelho 5
        for (i = 7; i <= 13; i = i + 1)
            set_carta(i[7:0], mk(2'b00, 4'd2, 4'b0010));   // toda a mao da CPU: azul 2 (invalida)
        set_carta(8'd15, mk(2'b00, 4'd3, 4'b0010));        // compra do player: azul 3 (invalida) -> passa
        set_carta(8'd16, mk(2'b00, 4'd1, 4'b0010));        // compra da CPU: azul 1 (invalida) -> guarda e passa

        wait (player_turn == 1'b1);
        #1;
        aperta_draw(); // player passa a vez para a CPU

        wait (n_cpu == 7'd8); // CPU comprou 1 carta (7 -> 8)
        #1;
        if (top_card == mk(2'b00, 4'd5, 4'b1000)) $display("[OK] CPU sem jogada comprou e passou (n_cpu=%0d, topo intacto)", n_cpu);
        else $display("[FALHA] topo mudou: %b", top_card);
        $finish;
    end

endmodule
