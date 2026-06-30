`timescale 1ns / 1ps

// cenario: player joga um coringa; entra o menu de cor (choosing_color) e ele
// confirma a cor pelo seletor (PLAY). O topo assume a cor escolhida.
module tb_coringa;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b0100; // vai escolher verde
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b1000));    // topo: vermelho 5
        set_carta(8'd0,  mk(2'b10, 4'b1101, 4'b0000)); // mao[0] player: coringa muda cor

        wait (player_turn == 1'b1);
        #1;
        aperta_play();                 // joga o coringa
        wait (choosing_color == 1'b1); // controlador pede a cor
        $display("[OK] entrou no menu de escolha de cor");
        color_selector = 4'b0100;      // verde
        aperta_play();                 // confirma a cor

        wait (n_player == 7'd6);
        #1;
        if (top_card == mk(2'b10, 4'b1101, 4'b0100)) $display("[OK] coringa assumiu verde (topo=%b)", top_card);
        else $display("[FALHA] topo do coringa: %b", top_card);
        $finish;
    end

endmodule
