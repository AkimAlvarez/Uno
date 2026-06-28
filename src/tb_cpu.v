`timescale 1ns / 1ps

// cenario: na vez da CPU ela joga sozinha a primeira carta valida da mao.
module tb_cpu;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000)); // topo: vermelho 5
        set_carta(8'd7,  mk(2'b00, 4'd2, 4'b0010)); // cpu mao[0]: azul 2 (nao casa)
        set_carta(8'd8,  mk(2'b00, 4'd5, 4'b0100)); // cpu mao[1]: verde 5 (casa valor) -> 1a valida
        set_carta(8'd15, mk(2'b00, 4'd3, 4'b0010)); // compra do player: azul 3 (invalida) -> passa a vez

        wait (player_turn == 1'b1);
        #1;
        aperta_draw(); // player compra invalida e passa a vez para a CPU

        wait (n_cpu == 7'd6); // CPU jogou uma carta
        #1;
        if (top_card == mk(2'b00, 4'd5, 4'b0100)) $display("[OK] CPU jogou a 1a valida (verde 5), n_cpu=%0d", n_cpu);
        else $display("[FALHA] topo apos CPU: %b", top_card);
        $finish;
    end

endmodule
