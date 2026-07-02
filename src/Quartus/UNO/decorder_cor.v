// módulo decodificador de cor (4 bits one-hot para 7 segmentos)

module DecoderCor (
    input [3:0] cor_input,          // 4 bits de cor
    output reg [6:0] display_out    // 7 bits do display
);

    // códigos de cor da padronização
    localparam VERMELHO = 4'b1000;
    localparam VERDE    = 4'b0100;
    localparam AZUL     = 4'b0010;
    localparam AMARELO  = 4'b0001;
    localparam PRETO    = 4'b0000;

    // mapa do display de 7 segmentos
    localparam LETRA_A = 7'b0001000; // verde
    localparam LETRA_B = 7'b0000011; // azul
    localparam LETRA_C = 7'b1000110; // amarelo
    localparam LETRA_D = 7'b0100001; // vermelho
    localparam LETRA_E = 7'b0000110; // preto
    localparam APAGADO = 7'b1111111; // proteção / vazio

    always @(*) begin
        case (cor_input)
            VERDE:    display_out = LETRA_A;
            AZUL:     display_out = LETRA_B;
            AMARELO:  display_out = LETRA_C;
            VERMELHO: display_out = LETRA_D;
            PRETO:    display_out = LETRA_E;

            default:  display_out = APAGADO;
        endcase
    end

endmodule