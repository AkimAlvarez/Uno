`timescale 1ns / 1ps // Escala de tempo para a simulacao

module tb_dealer;
    reg clk;
    reg rst;
    reg draw;
    wire draw_action;
    wire [6:0] carta_sorteada_id;
    wire [9:0] carta_sorteada;

    integer cartas_compradas;

    // Quantas cartas o teste vai comprar de forma encadeada
    localparam TOTAL_CARTAS = 5;

    top uut (
        .clk(clk),
        .rst(rst),
        .draw(draw),
        .draw_action(draw_action),
        .carta_sorteada_id(carta_sorteada_id),
        .carta_sorteada(carta_sorteada)
    );

    always #10 clk = ~clk; // Clock de 50MHz

    initial begin
        clk  = 0;
        rst  = 1;
        draw = 0;
        cartas_compradas = 0;

        $display("=================================================");
        $display("   INICIANDO SIMULACAO DO BARALHO DE UNO         ");
        $display("=================================================");

        // Reset sincrono
        repeat (2) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Dispara a primeira compra; o restante encadeia sozinho
        $display("\n---> Solicitando primeira compra");
        solicitar_compra();
    end

    // A descida de draw_action marca o "final da geracao" de uma carta pelo dealer.

    always @(negedge draw_action) begin
        if (!rst) begin
            // 1 ciclo de latencia da LUT sincrona para
            // garantir 'carta_sorteada' estavel na saida do TOP
            @(posedge clk);

            cartas_compradas = cartas_compradas + 1;

            $display("\n   [SUCESSO] Carta %0d comprada!", cartas_compradas);
            $display("   > Posicao Fisica (ID): %0d", carta_sorteada_id);
            $display("   > Bits Crus da Carta : %b", carta_sorteada);
            $display("   > Interpretacao      : Categoria [%b] | Valor [%b] | Cor [%b]",
                      carta_sorteada[9:8], carta_sorteada[7:4], carta_sorteada[3:0]);

            if (cartas_compradas < TOTAL_CARTAS) begin
                // Encadeia a proxima compra a partir da borda atual
                solicitar_compra();
            end else begin
                #40;
                $display("\n=================================================");
                $display("               TESTE FINALIZADO                  ");
                $display("=================================================");
                $finish;
            end
        end
    end


    task solicitar_compra;
        begin
            @(posedge clk);
            draw = 1'b1;
            @(posedge clk);
            draw = 1'b0;
        end
    endtask

endmodule
