module tigrinho(
    input clk, draw, rst,
    output reg draw_action,
    output reg [6:0] carta_sorteada_id
);

    wire[6:0] lfsr_out;
    wire lfsr_done;

    reg [6:0] baralho [0:107];
    reg [6:0] deck_ptr;
    reg [6:0] counter;

    reg [2:0] current_state, next_state;

    localparam idle          = 3'd0;
    localparam reset_deck    = 3'd1;
    localparam shuffle       = 3'd2;
    localparam distribute    = 3'd3;
    localparam ready         = 3'd4;
    localparam cavar         = 3'd5;
    localparam waiting       = 3'd6;

    reg carta_valida;

    LFSR #(.NUM_BITS(7)) embaralhador(
        .i_Clk(clk),
        .i_Enable(1'b1),
        .i_Seed_DV(1'd0),
        .i_Seed_Data(7'b0),
        .o_LFSR_Data(lfsr_out),
        .o_LFSR_Done(lfsr_done)
    );
    
    always @(posedge clk) begin
        if (rst) begin
            current_state <= reset_deck;
            counter <= 0;
            deck_ptr <= 0;
        end else begin
            current_state <= next_state;

            case (current_state)
                reset_deck: begin
                    baralho[counter] <= counter;
                    if (counter == 107) begin
                        counter <= 107;
                    end
                    else
                        counter <= counter + 1;
                end

                shuffle: begin
                    if(lfsr_out <= counter) begin
                        baralho[counter] <= baralho [lfsr_out[6:0]];
                        baralho[lfsr_out[6:0]] <= baralho[counter];
                        if(counter == 1)
                            counter <= 0;
                        else
                            counter <= counter -1;
                    end
                end

                distribute: begin
                    deck_ptr <= 15;
                end

                cavar: begin
                    carta_sorteada_id <= baralho[deck_ptr];
                    deck_ptr <= deck_ptr + 1;
                end
            endcase
        end
    end

    always @(*) begin
        next_state = current_state;
        draw_action = 1'b0;

        case (current_state)
            reset_deck: begin
                if (counter ==107) 
                    next_state = shuffle;
            end
            shuffle:begin
                if(counter == 0) 
                    next_state = distribute;
            end
            distribute: begin
                next_state = ready;
            end
            ready: begin
                if  (draw)
                    next_state = cavar;
            end
            cavar: begin
                draw_action = 1'b1;
                next_state = waiting;
            end
            waiting: begin
                if(!draw)
                    next_state = ready;
            end
            default: next_state = idle;
        endcase
    end

endmodule