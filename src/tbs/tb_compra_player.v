`timescale 1ns / 1ps

// cenario: player compra (DRAW); a carta comprada e valida -> o controlador
// joga automaticamente (sem entrar na mao).
module tb_compra_player;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000)); // topo: vermelho 5
        set_carta(8'd15, mk(2'b00, 4'd9, 4'b1000)); // 1a compra do player: vermelho 9 (casa cor)

        wait (player_turn == 1'b1);
        #1;
        aperta_draw();
        wait (top_card == mk(2'b00, 4'd9, 4'b1000)); // auto-jogou a carta comprada
        if (n_player == 7'd7) $display("[OK] comprou vermelho 9 e auto-jogou (mao continua 7)");
        else $display("[FALHA] mao mudou inesperadamente: n_player=%0d", n_player);
        $finish;
    end

endmodule
