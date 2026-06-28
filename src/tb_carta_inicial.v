`timescale 1ns / 1ps

// cenario: a carta inicial sorteada e de acao -> deve ser descartada e o dealer
// saca outra ate sair um numero.
module tb_carta_inicial;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b01, 4'b1010, 4'b1000)); // mesa: bloqueio vermelho (acao)
        set_carta(8'd15, mk(2'b00, 4'd5, 4'b1000));    // proxima: vermelho 5 (numero)

        wait (player_turn == 1'b1);
        #1;
        $display("topo inicial = %b", top_card);
        if (top_card == mk(2'b00, 4'd5, 4'b1000)) $display("[OK] descartou a acao e pegou um numero");
        else $display("[FALHA] carta inicial inesperada");
        $finish;
    end

endmodule
