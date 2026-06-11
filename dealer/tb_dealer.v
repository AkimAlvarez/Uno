`timescale 1ns / 1ps // Escala de tempo para a simulação

module tb_dealer;
    reg clk;
    reg rst;
    reg draw;
    wire draw_action;
    wire [6:0] carta_sorteada_id;
    wire [9:0] carta_sorteada;


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

        $display("=================================================");
        $display("   INICIANDO SIMULACAO DO BARALHO DE UNO         ");
        $display("=================================================");

        #10;
        
        @(posedge clk);

        rst = 0;
        
        #50;
        
        $display("\n---> Comprando Carta 1");
        apertar_botao_draw();

        #80;

        $display("\n---> Comprando Carta 2");
        apertar_botao_draw();

        #100;

        $display("\n---> Comprando Carta 3.");
        apertar_botao_draw();

        #20;

        $display("\n---> Comprando Carta 4");
        apertar_botao_draw();

        #120;

        $display("\n---> Comprando Carta 5");
        apertar_botao_draw();

        $display("\n=================================================");
        $display("               TESTE FINALIZADO                  ");
        $display("=================================================");
        $finish;
    end

    // ==========================================
    // Task: Simula o pulso do botao e le a carta
    // ==========================================
    task apertar_botao_draw;
        begin
            // Sincroniza com a subida do clock e aperta o botao por 1 ciclo
            @(posedge clk);
            draw = 1;
            @(posedge clk);
            draw = 0;
            
            // Espera a Maquina de Estados (FSM) terminar de cavar a carta
            // O sinal draw_action sobe em validar_carta/cavar e depois cai
            wait(draw_action == 1);
            wait(draw_action == 0);
            
            // Como a LUT tem 1 ciclo de latencia sincrona, esperamos mais 1 ciclo
            // para garantir que 'carta_sorteada' na saida do TOP esteja 100% atualizada
            @(posedge clk);
            
            // Imprime o resultado formatado no console
            $display("   [SUCESSO] Carta Comprada!");
            $display("   > Posicao Fisica (ID): %d", carta_sorteada_id);
            $display("   > Bits Crus da Carta : %b", carta_sorteada);
            $display("   > Interpretacao      : Categoria [%b] | Valor [%b] | Cor [%b]", 
                      carta_sorteada[9:8], carta_sorteada[7:4], carta_sorteada[3:0]);
        end
    endtask

endmodule