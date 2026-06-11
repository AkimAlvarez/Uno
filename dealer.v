module tigrinho(input clk, draw, rst,
				output reg draw_action.
				output reg [9:0] carta_sorteada);



		reg[107:0] cartas_usadas;
		reg[6:0] contador;	

		reg[1:0] current_state, next_state;
		parameter 	init = 2'b00,
					validar_carta = 2'b01,
					cavar = 2'b10,
					waiting = 2'b11;

		//VALIDAR CARTA			 
		always @(posedge clk)
			begin
				if(rst) 
					contador <= 7'd0;
				else if(contador == 7'd107)
					contador <=7'd0;
				else
					contador <= contador + 7'd1;
			end
		
		always @(posedge clk)
			begin
				if (rst) begin
					current_state <= init;
					cartas_usadas <= 108'd0;
					carta_sorteada <= 7'd0;
				end
				else begin
					current_state <= next_state;

					if (current_state == validar_carta && cartas_usadas[contador] == 1'b0) begin
						cartas_usadas[contador] <= 1'b1;
						carta_sorteada <= contador;
					end
				end
			end



		// FMS's
		always @(*) begin
			next_state = current_state;
			draw_action = 1'b0;

			case (current_state)
				init:begin
					if(draw)
						next_state = validar_carta;
				end
				validar_carta:begin
					draw_action = 1'b1;
					if(cartas_usadas[contador] == 1'b0)
						next_state = cavar;
					else
						next_state = validar_carta;
				end

				cavar: begin
					draw_action = 1'b1;
					next_state = waiting;
				end

				waiting: begin
					draw_action = 0;
					if (draw) begin
						next_state = validar_carta;
					end
					else
						next_state = waiting;
				end
					
				default: next_state = waiting;
			endcase
		end


endmodule