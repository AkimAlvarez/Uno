module tigrinho(input clk, draw, rst,
				output reg draw_action.
				output reg [6:0] carta_sorteada);



		reg[126:0] cartas_disponiveis, cartas_usadas;
		reg[6:0] contador;	

		reg[1:0] current_state, next_state;
		parameter 	n_cavar = 2'b00,
					cavar = 2'b01,
					esperar_soltar = 2'b10;
					 
		always @(posedge clk)
			begin
				if(rst) 
					contador <= 7'd0;
				else if(contador == 7'd126)
					contador <=7'd0;
				else
					contador <= contador + 7'd1;
			end
		
		always @(posedge clk)
			begin
				if (rst) begin
					current_state <= n_cavar;
					cartas_usadas <= 127'd0;
				end
				else begin
					current_state <= next_state;

					if (current_state == cavar && cartas_usadas[contador] == 1'b0) begin
						cartas_usadas[contador] <= 1'b1;
						carta_sorteada <= contador;
					end
				end
			end




		// FSM para rodar o botão Draw
		always @ (posedge clk) 
			begin
				if(rst)
					current_state <= n_cavar;
				else
					current_state <= next_state;
			end
					 
		
		always @ (*)
			begin: DRAW_LOGIC_STATE
				case (current_state)
					n_cavar: if(!draw)
									next_state = cavar;
								else
									next_state = n_cavar;
					
					cavar: begin
						if (cartas_usadas[contador] == 1'b0)
							next_state = esperar_soltar;
						else
							next_state = cavar;
						end
					esperar_soltar:
						if(!draw)
							next_state = esperar_soltar;
						else
							next_state = n_cavar;
								
					default:next_state = n_cavar;
				endcase
			end
			
		always @(*)
			begin
				case(current_state)
					n_cavar: draw_action = 1'b0;
					cavar: draw_action = 1'b0;
					esperar_soltar: draw_action = 1'b1;
					default: draw_action = 1'b0;
				endcase
			end


endmodule