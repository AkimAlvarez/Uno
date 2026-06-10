/* módulo pra decodificar o binário da qtd de cartas para
    separar oq é unidade e oq é dezena
*/

module QuantityConversor (
    input [6:0] qtd_cards,            // qtd max de cartas possível é de 100, ent 127 cobre;
    output reg [3:0] display_out_dez, // o max seria 9 ent 12 cobre
    output reg [3:0] display_out_unid // o max seria 9 ent 12 cobre
);

    // o limite visual de 2 displays de 7-segmentos é 99 (decimal)
    localparam MAX_CARDS = 7'd99;
    localparam TRAVA_DEZ = 4'd9;
    localparam TRAVA_UNID = 4'd9;

    always @(*) begin
        if (qtd_cards > MAX_CARDS) begin
            // se por algum motivo passar de 99, trava o display em 99
            display_out_dez = TRAVA_DEZ;
            display_out_unid = TRAVA_UNID;
        end else begin
            // o quartus vai sintetizar um bloco divisor no hardware para resolver isso
            display_out_dez = qtd_cards / 10;
            display_out_unid = qtd_cards % 10;
        end
    end

endmodule