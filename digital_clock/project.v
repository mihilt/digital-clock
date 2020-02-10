module project(clk, reset, button1, button0, led5, led4, led3, led2, led1, led0, alarmon, what);
	input clk, reset, button1, button0;
	output [6:0] led5, led4, led3, led2, led1, led0, alarmon, what;
		
	reg [3:0] num0, num1, num2, num3, num4, num5;
	reg [6:0] alarmon, what;

	wire B1, B0, inc_hour, inc_min, stop, stop_start, stop_reset;
	wire [3:0] h1, h10;
	wire [4:0] hour_out;

	wire en_clock, en_sec, en_sec10, en_min, en_min10, en_hour;
	wire tc, tc_sec, tc_sec10, tc_min, tc_min10;
	wire [3:0] sec, min, hour1, hour10;
	wire [2:0] sec10, min10;
	wire [4:0] hour;


	button_pulse b0 (clk, ~reset, button0, B0);		
	button_pulse b1 (clk, ~reset, button1, B1);		
	
	statemachine st (set_clock, alarm_set_clock, inc_hour, inc_min, stop, stop_start, stop_reset, B0, B1, clk, ~reset);
	
	counterN #(50000000,26) u0 (clk, ~reset, en_clock,  , tc);   
	counterN #(10,4) u1 (clk, ~reset, en_sec, sec, tc_sec);
    counterN #(6,3)  u2 (clk, ~reset, en_sec10, sec10, tc_sec10);
    counterN #(10,4) u3 (clk, ~reset, en_min, min, tc_min);
    counterN #(6,3)  u4 (clk, ~reset, en_min10, min10, tc_min10);
    counterN #(24,5) u5 (clk, ~reset, en_hour, hour, );
	
	assign en_clock = (set_clock) ? 1'b0 : 1;
	assign en_sec = (set_clock) ? 1'b0 : tc;             
	assign en_sec10 = tc_sec;
	assign en_min = (set_clock) ? inc_min : tc_sec10;       
	assign en_min10 = tc_min;
	assign en_hour = (set_clock) ? inc_hour : tc_min10;     
	
	wire  alarm_en_clock, alarm_en_sec, alarm_en_sec10, alarm_en_min, alarm_en_min10, alarm_en_hour;
	wire  alarm_tc, alarm_tc_sec, alarm_tc_sec10, alarm_tc_min, alarm_tc_min10;
	wire  [3:0] alarm_sec, alarm_min;
	wire  [2:0] alarm_sec10, alarm_min10;
	wire  [4:0] alarm_hour;

    counterN #(10,4) u6 (clk, ~reset, alarm_en_min, alarm_min, alarm_tc_min);
    counterN #(6,3)  u7 (clk, ~reset, alarm_en_min10, alarm_min10, alarm_tc_min10);
    counterN #(24,5) u8 (clk, ~reset, alarm_en_hour, alarm_hour, );
	
	assign alarm_en_clock = (alarm_set_clock) ? 1'b0 : 1;
	assign alarm_en_sec = (alarm_set_clock) ? 1'b0 : alarm_tc;
	assign alarm_en_sec10 = alarm_tc_sec;
	assign alarm_en_min = (alarm_set_clock) ? inc_min : alarm_tc_sec10;
	assign alarm_en_min10 = alarm_tc_min;
	assign alarm_en_hour = (alarm_set_clock) ? inc_hour : alarm_tc_min10;

	wire stop_en_clock, stop_en_msec, stop_en_msec10, stop_en_sec, stop_en_sec10, stop_en_min, stop_en_min10;
	wire stop_tc, stop_tc_msec, stop_tc_msec10, stop_tc_sec, stop_tc_sec10, stop_tc_min, stop_tc_min10;
	wire [3:0] stop_msec, stop_msec10, stop_sec, stop_min;
	wire [2:0] stop_sec10, stop_min10;
	
	 counterN #(500000,26) u10 (clk, stop_reset, stop_en_clock,  , stop_tc);
	 counterN #(10,4) u11 (clk, stop_reset, stop_en_msec, stop_msec, stop_tc_msec);
	 counterN #(10,4) u12 (clk, stop_reset, stop_en_msec10, stop_msec10, stop_tc_msec10);
	 counterN #(10,4) u13 (clk, stop_reset, stop_en_sec, stop_sec, stop_tc_sec);
    counterN #(6,3)  u14 (clk, stop_reset, stop_en_sec10, stop_sec10, stop_tc_sec10);
    counterN #(10,4) u15 (clk, stop_reset, stop_en_min, stop_min, stop_tc_min);
    counterN #(6,3)  u16 (clk, stop_reset, stop_en_min10, stop_min10, stop_tc_min10);

	assign stop_en_clock = (stop) ? 1 : 1'b0;
	assign stop_en_msec = (stop_start) ? stop_tc : 1'b0;
	assign stop_en_msec10 = stop_tc_msec;
	assign stop_en_sec = stop_tc_msec10;
	assign stop_en_sec10 = stop_tc_sec;
	assign stop_en_min = stop_tc_sec10;
	assign stop_en_min10 = stop_tc_min;



	assign hour_out = (alarm_set_clock) ? alarm_hour : hour;	
	
	converter h0 (hour_out, h10, h1);


	always @* begin
		if (alarm_set_clock) begin	
			num5 = h10;
			num4 = h1;
			num3 = {1'b0, alarm_min10};
			num2 = alarm_min;
			num1 = 1'b0;
			num0 = 1'b0;
			what =7'b000_1000;
		end
		else if (stop) begin
			num5 = stop_min10;
			num4 = stop_min;
			num3 = stop_sec10;
			num2 = stop_sec;
			num1 = stop_msec10;
			num0 = stop_msec;
		end
		else begin
			num5 = h10;
			num4 = h1;
			num3 = {1'b0, min10};
			num2 = min;
			num1 = {1'b0, sec10};
			num0 = sec;
			what =7'b111_1111;
		end
	end
	
	
	led u31 (num0, led0);
	led u32 (num1, led1);
	led u33 (num2, led2);
	led u34 (num3, led3);
	led u35 (num4, led4);
	led u36 (num5, led5);


	always@ * begin
		if(alarm_hour == hour && alarm_min10 == min10 && alarm_min == min)
		alarmon =7'b000_1000;
		else
		alarmon =7'b111_1111; 
		
	end                                 
	
endmodule
