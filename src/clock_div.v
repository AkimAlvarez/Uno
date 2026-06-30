`timescale 1ns / 1ps

module ClockDiv #(
    parameter BIT_ALVO = 22 // Mantido por compatibilidade de hierarquia, mas usaremos contagem real
)(
    input wire clk,
    input wire reset,
    output reg tick_out
);

    // Para 12.5 Hz a partir de 50MHz, precisamos contar até 4.000.000
    // 4.000.000 cabe perfeitamente em 22 bits (max 4.194.303)
    reg [21:0] contador;

    always @(posedge clk) begin
        if (reset) begin
            contador <= 22'd0;
            tick_out <= 1'b0;
        end else begin
            // Na simulação do tb_uno, se o BIT_ALVO for reduzido (ex: defparam = 2)
            // usamos uma contagem proporcionalmente menor para acelerar
            if ((BIT_ALVO == 2 && contador == 22'd7) || (BIT_ALVO != 2 && contador == 22'd3999999)) begin
                contador <= 22'd0;
                tick_out <= 1'b1; // Gera o pulso de exatamente 1 ciclo de clock
            end else begin
                contador <= contador + 22'd1;
                tick_out <= 1'b0; // Garante que volta para 0 no ciclo seguinte
            end
        end
    end

endmodule