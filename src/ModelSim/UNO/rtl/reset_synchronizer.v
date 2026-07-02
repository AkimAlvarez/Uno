// módulo que estabiliza e sincroniza o sinal de reset contra metaestabilidade

module ResetSynchronizer #(
    parameter STAGES = 4 // define a profundidade da fila
)(
    input clk,
    input reset,
    output reset_sync
);

    // cria o registrador usando o num de estágios
    reg [STAGES-1:0] shift_register;

    initial begin
        // operador de replicação pra zerar o shift_register independente do tamanho
        shift_register = {STAGES{1'b0}};
    end

    // a saída sempre tira o valor do último bit da fila (o MSB)
    assign reset_sync = shift_register[STAGES-1];

    always @(posedge clk) begin
        // desloca a fila: pega de [STAGES-2 até 0] e injeta o reset no final (LSB)
        shift_register <= { shift_register[STAGES-2:0], reset };
    end

endmodule