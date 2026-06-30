`timescale 1ns / 1ps

module timer_2s (
    input wire clk,
    input wire reset,
    input wire tick,
    input wire inicia_2s,
    output wire tempo_2s
);

    // tick ocorre a ~12.5 Hz (com BIT_ALVO = 22 @ 50MHz)
    // 2 segundos = 25 ticks
    reg [4:0] contador;
    reg contando;

    assign tempo_2s = (contador == 5'd25);

    always @(posedge clk) begin
        if (reset) begin
            contador <= 5'd0;
            contando <= 1'b0;
        end else if (inicia_2s) begin
            contador <= 5'd0;
            contando <= 1'b1;
        end else if (contando && tick) begin
            if (contador < 5'd25) begin
                contador <= contador + 5'd1;
            end else begin
                contando <= 1'b0;
            end
        end
    end

endmodule