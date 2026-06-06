module tigrinho(input clk, draw, rst
					 output reg draw_action);
			
		reg current_state, next_state;
		parameter n_cavar = 1`b0,
					 cavar = 1`b1;
					 
					 
		always @ (posedge clk or posedge rst) 
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
					
					cavar: if(!draw)
								next_state = cavar;
							 
							 else
								next_state = n_cavar;
								
					default:next_state = n_cavar;
				endcase
			end
			
		always @(*)
			begin
				case(current_state)
					n_cavar: draw_action = 1`b0;
					cavar: draw_action = 1`b1;
					default: draw_action = 1`b0;
				endcase
			end


endmodule