`timescale 1ns / 1ps

module card_ram #(
    parameter DATA_BITS = 10,
    parameter ADDR_BITS = 7,
    parameter DEPTH     = 128,
    parameter INIT_FILE = "uno_deck.mif"
)(
    input  wire                 clock,
    input  wire                 we,
    input  wire [ADDR_BITS-1:0] address,
    input  wire [DATA_BITS-1:0] data_in,
    output wire [DATA_BITS-1:0] q
);

    altsyncram #(
        .operation_mode         ("SINGLE_PORT"),
        .intended_device_family ("Cyclone IV E"),
        .width_a                (DATA_BITS),
        .widthad_a              (ADDR_BITS),
        .numwords_a             (DEPTH),
        .outdata_reg_a          ("UNREGISTERED"),
        .address_aclr_a         ("NONE"),
        .outdata_aclr_a         ("NONE"),
        .init_file              (INIT_FILE),
        .read_during_write_mode_port_a ("OLD_DATA"),
        .lpm_type               ("altsyncram")
    ) altsyncram_component (
        .clock0    (clock),
        .address_a (address),
        .data_a    (data_in),
        .wren_a    (we),
        .q_a       (q)
    );

endmodule
