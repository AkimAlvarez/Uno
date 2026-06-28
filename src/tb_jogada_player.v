`timescale 1ns / 1ps

// cenario: player tenta jogar carta invalida (INVALID_MOVE) e depois rola com
// NEXT ate uma valida e joga (PLAY).
module tb_jogada_player;

    `include "uno_bancada.vh"

    initial begin
        color_selector = 4'b1000;
        aplica_reset();
        set_carta(8'd14, mk(2'b00, 4'd5, 4'b0100)); // topo: verde 5
        set_carta(8'd0,  mk(2'b00, 4'd3, 4'b0010)); // mao[0] player: azul 3 (nao casa)
        set_carta(8'd1,  mk(2'b00, 4'd7, 4'b0100)); // mao[1] player: verde 7 (casa cor)

        wait (player_turn == 1'b1);
        #1;

        // 1) carta selecionada (mao[0]=azul 3) e invalida sobre verde 5
        aperta_play();
        repeat (8) @(posedge clk);
        if (viu_invalido && n_player == 7'd7) $display("[OK] jogada invalida sinalizada, mao intacta");
        else $display("[FALHA] invalida: viu_invalido=%b n_player=%0d", viu_invalido, n_player);

        // 2) rola para mao[1]=verde 7 e joga (valida)
        aperta_next();
        repeat (4) @(posedge clk);
        aperta_play();
        wait (n_player == 7'd6);
        #1;
        if (top_card == mk(2'b00, 4'd7, 4'b0100)) $display("[OK] jogou verde 7 (topo=%b, n_player=%0d)", top_card, n_player);
        else $display("[FALHA] topo apos jogada valida: %b", top_card);
        $finish;
    end

endmodule
