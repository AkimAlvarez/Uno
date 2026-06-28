`timescale 1ns / 1ps

// dealer dos testbenches: em vez de embaralhar a RAM, entrega as cartas de uma
// fila que o testbench carrega (via set_carta -> dealer.fila[i]). mantem a mesma
// interface de jogo do dealer real, entao o controlador nao muda.
module dealer_controlavel (
    input wire clk,
    input wire rst,
    input wire draw, // pulso: pede uma carta
    input wire [9:0] discard_in,
    input wire discard_we, // descarte: ignorado aqui

    output reg ready,
    output wire busy,
    output reg draw_action,
    output reg [9:0] carta_sorteada
);

    localparam [1:0] D_INIT=2'd0, D_IDLE=2'd1, D_DEAL=2'd2;

    reg [9:0] fila [0:255]; // cartas entregues em ordem (carregadas pelo testbench)
    reg [7:0] fptr; // proxima carta a entregar
    reg [2:0] espera; // pequeno atraso imitando o "embaralhar"
    reg [1:0] state;
    integer i;

    initial for (i = 0; i < 256; i = i + 1) fila[i] = 10'b00_0000_1000; // default: vermelho 0

    assign busy = (state != D_IDLE);

    always @(posedge clk) begin
        if (rst) begin
            ready <= 1'b0;
            draw_action <= 1'b0;
            carta_sorteada <= 10'd0;
            fptr <= 8'd0;
            espera <= 3'd0;
            state <= D_INIT;
        end else begin
            case (state)
            D_INIT: begin // espera um pouco e fica pronto
                espera <= espera + 3'd1;
                if (espera == 3'd4) begin
                    ready <= 1'b1;
                    state <= D_IDLE;
                end
            end
            D_IDLE: begin // livre; descarte e ignorado
                if (draw) begin
                    draw_action <= 1'b0; // 1 borda por carta
                    state <= D_DEAL;
                end
            end
            D_DEAL: begin // entrega a proxima carta da fila
                carta_sorteada <= fila[fptr];
                draw_action <= 1'b1;
                fptr <= fptr + 8'd1;
                state <= D_IDLE;
            end
            default: state <= D_INIT;
            endcase
        end
    end

endmodule
