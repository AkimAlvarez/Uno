`timescale 1ns / 1ps

// cenario: a CPU joga um coringa e adota automaticamente a cor da 1a carta
// colorida da mao (sem interacao).
module tb_coringa_cpu;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000));    // topo: vermelho 5
        set_carta(8'd7,  mk(2'b10, 4'b1101, 4'b0000)); // cpu mao[0]: coringa (1a valida)
        set_carta(8'd8,  mk(2'b00, 4'd3, 4'b0010));    // cpu mao[1]: azul 3 -> cor adotada = azul
        set_carta(8'd15, mk(2'b00, 4'd3, 4'b0100));    // compra do player: verde 3 (invalida) -> passa

        wait (player_turn == 1'b1);
        #1;
        aperta_draw(); // player passa a vez para a CPU

        wait (n_cpu == 7'd6); // CPU jogou o coringa
        #1;
        if (top_card == mk(2'b10, 4'b1101, 4'b0010)) $display("[OK] coringa da CPU assumiu azul (topo=%b)", top_card);
        else $display("[FALHA] cor do coringa da CPU: %b", top_card);
        $finish;
    end

endmodule
