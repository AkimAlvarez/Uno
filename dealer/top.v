module top (
    input wire clk,
    input wire rst,
    input wire draw,                 
    
    output wire draw_action,       
    output wire [6:0] carta_sorteada_id, 
    output wire [9:0] carta_sorteada    
);

    tigrinho dealer (
        .clk(clk),
        .rst(rst),
        .draw(draw),
        .draw_action(draw_action),
        .carta_sorteada_id(carta_sorteada_id)
    );

    uno_full_deck_lut baralho_lut (
        .clock(clk),
        .address(carta_sorteada_id),
        .q(carta_sorteada)
    );

endmodule