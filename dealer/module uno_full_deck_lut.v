module uno_full_deck_lut (
    input wire clock,
    input wire [6:0] address,
    output reg [9:0] q
);
    always @(posedge clock) begin
        case(address)
            // =======================================================
            // CARTAS VERMELHAS (25 Cartas) - Cor One-Hot: 1000
            // =======================================================
            7'd0:   q <= 10'b00_0000_1000; // Numero 0 Vermelho
            7'd1:   q <= 10'b00_0001_1000; // Numero 1 Vermelho
            7'd2:   q <= 10'b00_0001_1000; // Numero 1 Vermelho
            7'd3:   q <= 10'b00_0010_1000; // Numero 2 Vermelho
            7'd4:   q <= 10'b00_0010_1000; // Numero 2 Vermelho
            7'd5:   q <= 10'b00_0011_1000; // Numero 3 Vermelho
            7'd6:   q <= 10'b00_0011_1000; // Numero 3 Vermelho
            7'd7:   q <= 10'b00_0100_1000; // Numero 4 Vermelho
            7'd8:   q <= 10'b00_0100_1000; // Numero 4 Vermelho
            7'd9:   q <= 10'b00_0101_1000; // Numero 5 Vermelho
            7'd10:  q <= 10'b00_0101_1000; // Numero 5 Vermelho
            7'd11:  q <= 10'b00_0110_1000; // Numero 6 Vermelho
            7'd12:  q <= 10'b00_0110_1000; // Numero 6 Vermelho
            7'd13:  q <= 10'b00_0111_1000; // Numero 7 Vermelho
            7'd14:  q <= 10'b00_0111_1000; // Numero 7 Vermelho
            7'd15:  q <= 10'b00_1000_1000; // Numero 8 Vermelho
            7'd16:  q <= 10'b00_1000_1000; // Numero 8 Vermelho
            7'd17:  q <= 10'b00_1001_1000; // Numero 9 Vermelho
            7'd18:  q <= 10'b00_1001_1000; // Numero 9 Vermelho
            7'd19:  q <= 10'b01_1010_1000; // Bloqueio Vermelho
            7'd20:  q <= 10'b01_1010_1000; // Bloqueio Vermelho
            7'd21:  q <= 10'b01_1011_1000; // Inversao Vermelho
            7'd22:  q <= 10'b01_1011_1000; // Inversao Vermelho
            7'd23:  q <= 10'b01_1100_1000; // Compra Duas (+2) Vermelho
            7'd24:  q <= 10'b01_1100_1000; // Compra Duas (+2) Vermelho

            // =======================================================
            // CARTAS VERDES (25 Cartas) - Cor One-Hot: 0100
            // =======================================================
            7'd25:  q <= 10'b00_0000_0100; // Numero 0 Verde
            7'd26:  q <= 10'b00_0001_0100; // Numero 1 Verde
            7'd27:  q <= 10'b00_0001_0100; // Numero 1 Verde
            7'd28:  q <= 10'b00_0010_0100; // Numero 2 Verde
            7'd29:  q <= 10'b00_0010_0100; // Numero 2 Verde
            7'd30:  q <= 10'b00_0011_0100; // Numero 3 Verde
            7'd31:  q <= 10'b00_0011_0100; // Numero 3 Verde
            7'd32:  q <= 10'b00_0100_0100; // Numero 4 Verde
            7'd33:  q <= 10'b00_0100_0100; // Numero 4 Verde
            7'd34:  q <= 10'b00_0101_0100; // Numero 5 Verde
            7'd35:  q <= 10'b00_0101_0100; // Numero 5 Verde
            7'd36:  q <= 10'b00_0110_0100; // Numero 6 Verde
            7'd37:  q <= 10'b00_0110_0100; // Numero 6 Verde
            7'd38:  q <= 10'b00_0111_0100; // Numero 7 Verde
            7'd39:  q <= 10'b00_0111_0100; // Numero 7 Verde
            7'd40:  q <= 10'b00_1000_0100; // Numero 8 Verde
            7'd41:  q <= 10'b00_1000_0100; // Numero 8 Verde
            7'd42:  q <= 10'b00_1001_0100; // Numero 9 Verde
            7'd43:  q <= 10'b00_1001_0100; // Numero 9 Verde
            7'd44:  q <= 10'b01_1010_0100; // Bloqueio Verde
            7'd45:  q <= 10'b01_1010_0100; // Bloqueio Verde
            7'd46:  q <= 10'b01_1011_0100; // Inversao Verde
            7'd47:  q <= 10'b01_1011_0100; // Inversao Verde
            7'd48:  q <= 10'b01_1100_0100; // Compra Duas (+2) Verde
            7'd49:  q <= 10'b01_1100_0100; // Compra Duas (+2) Verde

            // =======================================================
            // CARTAS AZUIS (25 Cartas) - Cor One-Hot: 0010
            // =======================================================
            7'd50:  q <= 10'b00_0000_0010; // Numero 0 Azul
            7'd51:  q <= 10'b00_0001_0010; // Numero 1 Azul
            7'd52:  q <= 10'b00_0001_0010; // Numero 1 Azul
            7'd53:  q <= 10'b00_0010_0010; // Numero 2 Azul
            7'd54:  q <= 10'b00_0010_0010; // Numero 2 Azul
            7'd55:  q <= 10'b00_0011_0010; // Numero 3 Azul
            7'd56:  q <= 10'b00_0011_0010; // Numero 3 Azul
            7'd57:  q <= 10'b00_0100_0010; // Numero 4 Azul
            7'd58:  q <= 10'b00_0100_0010; // Numero 4 Azul
            7'd59:  q <= 10'b00_0101_0010; // Numero 5 Azul
            7'd60:  q <= 10'b00_0101_0010; // Numero 5 Azul
            7'd61:  q <= 10'b00_0110_0010; // Numero 6 Azul
            7'd62:  q <= 10'b00_0110_0010; // Numero 6 Azul
            7'd63:  q <= 10'b00_0111_0010; // Numero 7 Azul
            7'd64:  q <= 10'b00_0111_0010; // Numero 7 Azul
            7'd65:  q <= 10'b00_1000_0010; // Numero 8 Azul
            7'd66:  q <= 10'b00_1000_0010; // Numero 8 Azul
            7'd67:  q <= 10'b00_1001_0010; // Numero 9 Azul
            7'd68:  q <= 10'b00_1001_0010; // Numero 9 Azul
            7'd69:  q <= 10'b01_1010_0010; // Bloqueio Azul
            7'd70:  q <= 10'b01_1010_0010; // Bloqueio Azul
            7'd71:  q <= 10'b01_1011_0010; // Inversao Azul
            7'd72:  q <= 10'b01_1011_0010; // Inversao Azul
            7'd73:  q <= 10'b01_1100_0010; // Compra Duas (+2) Azul
            7'd74:  q <= 10'b01_1100_0010; // Compra Duas (+2) Azul

            // =======================================================
            // CARTAS AMARELAS (25 Cartas) - Cor One-Hot: 0001
            // =======================================================
            7'd75:  q <= 10'b00_0000_0001; // Numero 0 Amarelo
            7'd76:  q <= 10'b00_0001_0001; // Numero 1 Amarelo
            7'd77:  q <= 10'b00_0001_0001; // Numero 1 Amarelo
            7'd78:  q <= 10'b00_0010_0001; // Numero 2 Amarelo
            7'd79:  q <= 10'b00_0010_0001; // Numero 2 Amarelo
            7'd80:  q <= 10'b00_0011_0001; // Numero 3 Amarelo
            7'd81:  q <= 10'b00_0011_0001; // Numero 3 Amarelo
            7'd82:  q <= 10'b00_0100_0001; // Numero 4 Amarelo
            7'd83:  q <= 10'b00_0100_0001; // Numero 4 Amarelo
            7'd84:  q <= 10'b00_0101_0001; // Numero 5 Amarelo
            7'd85:  q <= 10'b00_0101_0001; // Numero 5 Amarelo
            7'd86:  q <= 10'b00_0110_0001; // Numero 6 Amarelo
            7'd87:  q <= 10'b00_0110_0001; // Numero 6 Amarelo
            7'd88:  q <= 10'b00_0111_0001; // Numero 7 Amarelo
            7'd89:  q <= 10'b00_0111_0001; // Numero 7 Amarelo
            7'd90:  q <= 10'b00_1000_0001; // Numero 8 Amarelo
            7'd91:  q <= 10'b00_1000_0001; // Numero 8 Amarelo
            7'd92:  q <= 10'b00_1001_0001; // Numero 9 Amarelo
            7'd93:  q <= 10'b00_1001_0001; // Numero 9 Amarelo
            7'd94:  q <= 10'b01_1010_0001; // Bloqueio Amarelo
            7'd95:  q <= 10'b01_1010_0001; // Bloqueio Amarelo
            7'd96:  q <= 10'b01_1011_0001; // Inversao Amarelo
            7'd97:  q <= 10'b01_1011_0001; // Inversao Amarelo
            7'd98:  q <= 10'b01_1100_0001; // Compra Duas (+2) Amarelo
            7'd99:  q <= 10'b01_1100_0001; // Compra Duas (+2) Amarelo

            // =======================================================
            // CARTAS CORINGA (8 Cartas) - Sem Cor Inicial: 0000
            // =======================================================
            7'd100: q <= 10'b10_1101_0000; // Coringa Muda Cor
            7'd101: q <= 10'b10_1101_0000; // Coringa Muda Cor
            7'd102: q <= 10'b10_1101_0000; // Coringa Muda Cor
            7'd103: q <= 10'b10_1101_0000; // Coringa Muda Cor
            7'd104: q <= 10'b10_1110_0000; // Coringa Compra Quatro (+4)
            7'd105: q <= 10'b10_1110_0000; // Coringa Compra Quatro (+4)
            7'd106: q <= 10'b10_1110_0000; // Coringa Compra Quatro (+4)
            7'd107: q <= 10'b10_1110_0000; // Coringa Compra Quatro (+4)

            // Tratamento padrao para enderecos sobressalentes
            default: q <= 10'b00_0000_0000;
        endcase
    end
endmodule