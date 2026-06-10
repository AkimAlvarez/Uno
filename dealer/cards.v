module cartas (input [9:0] nipes_jogada, input [9:0] nipes_topo,
                output jogada_valida, cavar_2,cavar_4,reverse,skip)

    reg [126:0] cartas;
    reg [9:0] nipes;

    // nipes[3:0]cor
    // nipes[7:4]padrao
    // nipes[9:8]sinalizador

    wire mesma_cor = (nipes_jogada[3:0] == nipes_topo[3:0]);
    wire mesmo_valor = (nipes_jogada[7:4] == nipes_topo[7:4]);
    wire coringa = (nipes_jogada[9:8] == 2'b10);

    assign jogada_valida = mesma_cor || mesmo_valor || coringa;
    assign cavar_2 = (nipes_jogada[7:4] == 4'd12 && mesma_cor);
    assign cavar_4 = (nipes_jogada[7:4] == 4'd14);
    assign mudar_cor = (nipes_jogada[7:4] == 4'd13);
    assign reverse = (nipes_jogada[7:4]==4'd11);
    assign skip = (nipes_jogada[7:4]==4'd10);





endmodule