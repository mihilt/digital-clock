module statemachine(set_clock, alarm_set_clock, inc_hour, inc_min, stop, stop_start, stop_reset, B0, B1, clk, reset);
	input	B0, B1, clk, reset;
	output	set_clock, alarm_set_clock, inc_hour, inc_min, stop, stop_start, stop_reset;
	reg		[3:0] state;
	
	parameter  S0 = 0, S10 = 1, S11 = 3, S12 = 2, S20 = 6, S21 = 4, S22 = 5, S30 = 7, S31 = 15, S32 = 14;
	
	always @(posedge clk or posedge reset)begin
		if(reset) state <= S0;
		else begin
			case (state)
				S0: if (B0) state <= S10;			
					else if (B1) state <= S30;
				
				S10: if (B0) state <= S20;		
			  	     else if (B1) state <= S11;
				S11: if (B1) state <= S12;			
				S12: if (B1) state <= S10;			
					 
				S20: if (B0) state <= S0;			
				     else if (B1) state <= S21;
				S21: if (B1) state <= S22;		
				S22: if (B1) state <= S20;	
				
				S30: if (B0) state <= S31;		
					 else if (B1) state <= S0;
				S31: if (B0) state <= S32;
				S32: if (B0) state <= S30;
					 else if (B1) state <= S0;
					 
				default: state <= S0;
			endcase
		end
	end
	
	assign set_clock = (state == S10 || state == S11 || state == S12);
	assign alarm_set_clock = (state == S20 || state == S21 || state == S22);
	assign inc_hour = (state == S11 || state == S21) && B0;
	assign inc_min = (state == S12 || state == S22) && B0;
	assign stop = (state == S30 || state == S31 || state == S32);
	assign stop_start = (state == S31);
	assign stop_reset = (state == S30);

endmodule