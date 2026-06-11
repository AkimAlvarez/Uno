module tigrinho(
    input clk, draw, rst,
    output reg draw_action,
    output reg [6:0] carta_sorteada_id
);

    reg [107:0] cartas_usadas;
    reg [6:0] contador;    

    reg [1:0] current_state, next_state;

    localparam idle          = 2'b00;
    localparam validar_carta = 2'b01;
    localparam cavar         = 2'b10;
    localparam waiting       = 2'b11;

    reg carta_valida;
    
    always @(posedge clk) begin
        if (rst) begin
            current_state <= idle;
            cartas_usadas <= 108'd0;
            carta_sorteada_id <= 7'd0;
            carta_valida <= 0;
            contador <= 7'd0;
        end else begin
            current_state <= next_state;

            if(contador == 7'd107)
                contador <= 7'd0;
            else
                contador <= contador + 7'd1;

            case(current_state)
                waiting: begin
                    carta_valida <= 0;
                end
                
                validar_carta: begin
                    if (!cartas_usadas[contador]) begin
                        cartas_usadas[contador] <= 1'b1;
                        carta_sorteada_id <= contador;
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