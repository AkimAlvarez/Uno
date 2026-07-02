// módulo que faz a redução de frequência do clock

module ClockDiv #(
    parameter BIT_ALVO = 22 // 22 para a placa real (12.5Hz)
)(
    input clk,
    input reset,
    output tick_out
);

    reg [BIT_ALVO:0] contador;

    // extrai o pulso do bit parametrizado
    assign tick_out = contador[BIT_ALVO];

    always @(posedge clk) begin
        if(reset) begin
            contador <= 0; // reseta o contador
        end
        else begin
            contador <= contador + 1; // incrementa o contador em um bit mantendo a largura do barramento
        end
    end

endmodule