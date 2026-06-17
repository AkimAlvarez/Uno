`timescale 1ns / 1ps

module top (
    input  wire        clk,
    input  wire        rst,
    input  wire        draw,
    output wire        ready,           // baralho embaralhado e pronto
    output wire        busy,            // ocupado: nao aceita draw agora
    output wire        draw_action,     // ativo: carta distribuida
    output wire [7:0]  carta_ponteiro,  // indice distribuido (0..107)
    output wire [9:0]  carta_sorteada   // conteudo da carta distribuida
);

    // Interconexao dealer <-> RAM
    wire [6:0] ram_addr;
    wire       ram_we;
    wire [9:0] ram_data;
    wire [9:0] ram_q;

    dealer_fsm dealer (
        .clk            (clk),
        .rst            (rst),
        .draw           (draw),
        .ram_addr       (ram_addr),
        .ram_we         (ram_we),
        .ram_data       (ram_data),
        .ram_q          (ram_q),
        .ready          (ready),
        .busy           (busy),
        .draw_action    (draw_action),
        .carta_sorteada (carta_sorteada),
        .carta_ponteiro (carta_ponteiro)
    );

    card_ram #(
        .DATA_BITS (10),
        .ADDR_BITS (7),
        .DEPTH     (128),
        .INIT_FILE ("uno_deck.mif")
    ) baralho_ram (
        .clock   (clk),
        .we      (ram_we),
        .address (ram_addr),
        .data_in (ram_data),
        .q       (ram_q)
    );

endmodule
