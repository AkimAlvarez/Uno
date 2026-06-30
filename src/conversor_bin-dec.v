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

    // vars intermediárias de 7 bits
    reg [6:0] calc_dez;
    reg [6:0] calc_unid;

    always @(*) begin
        if (qtd_cards > MAX_CARDS) begin
            // se por algum motivo passar de 99, trava o display em 99
            display_out_dez = TRAVA_DEZ;
            display_out_unid = TRAVA_UNID;

            // impede a criação de latch setando as variáveis que não são usadas aqui
            calc_dez = 7'd0;
            calc_unid = 7'd0;

        end else begin
            // Faz a divisão e o resto
            calc_dez = qtd_cards / 7'd10;
            calc_unid = qtd_cards % 7'd10;

            // envia os 4 LSB pros displays
            display_out_dez = calc_dez[3:0];
            display_out_unid = calc_unid[3:0];
        end
    end

endmodule