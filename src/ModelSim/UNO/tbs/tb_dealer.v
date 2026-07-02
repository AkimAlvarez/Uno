`timescale 1ns / 1ps

module tb_dealer;

    reg        clk;
    reg        rst;
    reg        draw;
    reg        discard_we;
    reg  [9:0] discard_in;

    wire        ready;
    wire        busy;
    wire        draw_action;
    wire [6:0]  carta_ponteiro;
    wire [9:0]  carta_sorteada;
    wire [7:0]  deck_count;

    // interconexao dealer_fsm <-> card_ram
    wire [6:0]  ram_addr;
    wire        ram_we;
    wire [9:0]  ram_data;
    wire [9:0]  ram_q;

    integer reset_hold;
    integer i, k, c, v;
    integer total;

    reg [7:0] exp_hist [0:1023];
    reg [7:0] act_hist [0:1023];
    reg [3:0] cor;

    dealer_fsm uut (
        .clk            (clk),
        .rst            (rst),
        .draw           (draw),
        .discard_in     (discard_in),
        .discard_we     (discard_we),
        .ram_addr       (ram_addr),
        .ram_we         (ram_we),
        .ram_data       (ram_data),
        .ram_q          (ram_q),
        .ready          (ready),
        .busy           (busy),
        .draw_action    (draw_action),
        .carta_sorteada (carta_sorteada),
        .carta_ponteiro (carta_ponteiro),
        .deck_count     (deck_count)
    );

    card_ram #(
        .DATA_BITS (10),
        .ADDR_BITS (7),
        .DEPTH     (128),
        .INIT_FILE ("uno_deck.mif")
    ) baralho (
        .clock   (clk),
        .we      (ram_we),
        .address (ram_addr),
        .data_in (ram_data),
        .q       (ram_q)
    );

    always #10 clk = ~clk; // 50 MHz

    // ============================================================
    // Monta o multiconjunto esperado (baralho completo de UNO)
    // ============================================================
    task montar_esperado;
        begin
            for (k = 0; k < 1024; k = k + 1) begin
                exp_hist[k] = 8'd0;
                act_hist[k] = 8'd0;
            end
            for (c = 0; c < 4; c = c + 1) begin
                case (c)
                    0: cor = 4'b1000; // vermelho
                    1: cor = 4'b0100; // verde
                    2: cor = 4'b0010; // azul
                    3: cor = 4'b0001; // amarelo
                endcase
                exp_hist[{2'b00, 4'd0, cor}] = exp_hist[{2'b00, 4'd0, cor}] + 8'd1;       // zero (1x)
                for (v = 1; v <= 9; v = v + 1)                                            // 1..9 (2x)
                    exp_hist[{2'b00, v[3:0], cor}] = exp_hist[{2'b00, v[3:0], cor}] + 8'd2;
                exp_hist[{2'b01, 4'b1010, cor}] = exp_hist[{2'b01, 4'b1010, cor}] + 8'd2; // bloqueio
                exp_hist[{2'b01, 4'b1011, cor}] = exp_hist[{2'b01, 4'b1011, cor}] + 8'd2; // inversao
                exp_hist[{2'b01, 4'b1100, cor}] = exp_hist[{2'b01, 4'b1100, cor}] + 8'd2; // +2
            end
            exp_hist[{2'b10, 4'b1101, 4'b0000}] = 8'd4; // coringa muda cor
            exp_hist[{2'b10, 4'b1110, 4'b0000}] = 8'd4; // coringa +4
        end
    endtask

    // ============================================================
    // Roteiro
    // ============================================================
    initial begin
        clk        = 0;
        rst        = 1;
        draw       = 0;
        discard_we = 0;
        discard_in = 10'd0;

        if (!$value$plusargs("RESET_HOLD=%d", reset_hold))
            reset_hold = 50;

        montar_esperado;

        $display("=================================================");
        $display("  DEALER UNO - EMBARALHA RAM + DISTRIBUI          ");
        $display("  RESET segurado por %0d ns (define a semente)    ", reset_hold);
        $display("=================================================");

        // Reset; o instante em que ele e solto define a semente do LFSR
        #(reset_hold);
        @(posedge clk);
        rst = 0;

        @(posedge ready);
        $display("[%0t] Embaralhamento concluido (ready=1). Distribuindo...\n", $time);

        // Distribui as 108 cartas. O "controlador" so dispara um PULSO de draw
        // quando o dealer esta livre (busy=0); cada pulso entrega uma carta.
        for (i = 0; i < 108; i = i + 1) begin
            wait (busy == 1'b0);                    // espera o dealer ficar livre
            @(posedge clk); draw = 1'b1;
            @(posedge clk); draw = 1'b0;            // pulso de 1 ciclo

            @(posedge draw_action);                 // carta entregue
            act_hist[carta_sorteada] = act_hist[carta_sorteada] + 8'd1;

            if (i < 12)
                $display("  carta %0d: ptr=%0d  bits=%b  (cat=%b val=%b cor=%b)",
                         i, carta_ponteiro, carta_sorteada,
                         carta_sorteada[9:8], carta_sorteada[7:4], carta_sorteada[3:0]);
            else if (i == 12)
                $display("  ... (demais cartas omitidas)");
        end

        // Confere que o baralho distribuido bate com o esperado
        total = 0;
        for (k = 0; k < 1024; k = k + 1) begin
            if (act_hist[k] !== exp_hist[k]) begin
                $display("  [FALHA] codigo %b: esperado=%0d distribuido=%0d",
                         k[9:0], exp_hist[k], act_hist[k]);
                total = total + 1;
            end
        end

        $display("\n=================================================");
        if (total == 0)
            $display("  [OK] 108 cartas distribuidas = baralho completo");
        else
            $display("  [ERRO] %0d divergencias no multiconjunto", total);
        $display("=================================================");
        $finish;
    end

endmodule
