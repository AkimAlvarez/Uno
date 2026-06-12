module tigrinho(
    input clk, draw, rst,
    output reg draw_action,
    output reg [6:0] carta_sorteada_id
);

    wire[7:0] lfsr_out;
    wire lfsr_done;

    reg [107:0] cartas_usadas;   

    reg [1:0] current_state, next_state;

    localparam idle          = 2'b00;
    localparam validar_carta = 2'b01;
    localparam cavar         = 2'b10;
    localparam waiting       = 2'b11;

    reg carta_valida;

    LFSR #(.NUM_BITS(8)) embaralhador(
        .i_Clk(clk),
        .i_Enable(1'b1),
        .i_Seed_DV(1'd0),
        .i_Seed_Data(8'b0),
        .o_LFSR_Data(lfsr_out),
        .o_LFSR_Done(lfsr_done)
    );
    
    always @(posedge clk) begin
        if (rst) begin
            current_state <= idle;
            cartas_usadas <= 108'd0;
            carta_sorteada_id <= 7'd0;
            carta_valida <= 0;
        end else begin
            current_state <= next_state;

            case(current_state)
                waiting: begin
                    carta_valida <= 0;
                end
                
                validar_carta: begin
                    if (lfsr_out < 8'd108 && !cartas_usadas[lfsr_out]) begin
                        cartas_usadas[lfsr_out] <= 1'b1;
                        carta_sorteada_id <= lfsr_out[6:0];
                        carta_valida <= 1;
                    end
                end
            endcase
        end
    end

    always @(*) begin
        next_state = current_state;
        draw_action = 1'b0;

        case (current_state)
            idle: begin
                if(draw)
                    next_state = validar_carta;
            end
            
            validar_carta: begin
                draw_action = 1'b1;
                if(carta_valida)
                    next_state = cavar;
            end

            cavar: begin
                draw_action = 1'b1;
                next_state = waiting;
            end

            waiting: begin
                if (draw) begin
                    next_state = validar_carta;
                end
            end
                
            default: next_state = idle;
        endcase
    end

endmodule