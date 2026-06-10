// modulo decodificador (4 bits para 7 segmentos)

module DecoderValor (
    input [3:0] valor_input,
    output reg [6:0] display_out
);


    // 0 liga o segmento, 1 apaga.

    localparam NUM_0   = 7'b1000000;
    localparam NUM_1   = 7'b1111001;
    localparam NUM_2   = 7'b0100100;
    localparam NUM_3   = 7'b0110000;
    localparam NUM_4   = 7'b0011001;
    localparam NUM_5   = 7'b0010010;
    localparam NUM_6   = 7'b0000010;
    localparam NUM_7   = 7'b1111000;
    localparam NUM_8   = 7'b0000000;
    localparam NUM_9   = 7'b0010000;

    localparam LETRA_A = 7'b0001000;
    localparam LETRA_b = 7'b0000011;
    localparam LETRA_C = 7'b1000110;
    localparam LETRA_d = 7'b0100001;
    localparam LETRA_E = 7'b0000110;

    localparam APAGADO = 7'b1111111; // desliga todos os segmentos

    always @(*) begin
        case (valor_input)
            4'h0: display_out = NUM_0;
            4'h1: display_out = NUM_1;
            4'h2: display_out = NUM_2;
            4'h3: display_out = NUM_3;
            4'h4: display_out = NUM_4;
            4'h5: display_out = NUM_5;
            4'h6: display_out = NUM_6;
            4'h7: display_out = NUM_7;
            4'h8: display_out = NUM_8;
            4'h9: display_out = NUM_9;
            4'hA: display_out = LETRA_A;
            4'hB: display_out = LETRA_b;
            4'hC: display_out = LETRA_C;
            4'hD: display_out = LETRA_d;
            4'hE: display_out = LETRA_E;
            4'hF: display_out = APAGADO;

            default: display_out = APAGADO; 
        endcase
    end

endmodule