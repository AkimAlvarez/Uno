`timescale 1ns / 1ps

module timer_2s (
    input wire clk,
    input wire reset,
    input wire tick,
    input wire inicia_2s,
    output wire tempo_2s
);

    // 2 segundos = 25 ticks limpos (pulsos) de 12.5 Hz
    reg [4:0] contador;
    reg contando;
    reg tempo_2s_reg;

    assign tempo_2s = tempo_2s_reg;

    always @(posedge clk) begin
        if (reset) begin
            contador     <= 5'd0;
            contando     <= 1'b0;
            tempo_2s_reg <= 1'b0;
        end else if (inicia_2s) begin
            contador     <= 5'd0;
            contando     <= 1'b1;
            tempo_2s_reg <= 1'b0; // Limpa o estado anterior imediatamente
        end else if (contando && tick) begin
            if (contador < 5'd24) begin
                contador <= contador + 5'd1;
            end else begin
                contando     <= 1'b0;
                contador     <= 5'd0;
                tempo_2s_reg <= 1'b1; // Dispara os 2 segundos cravados
            end
        end else begin
            tempo_2s_reg <= 1'b0; // Garante que o sinal atua como um pulso síncrono para a FSM
        end
    end

endmodule