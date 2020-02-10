module converter(bin, bcd1, bcd0);
	input [4:0] bin;
	output [3:0] bcd1, bcd0;
	reg [3:0] bcd1, bcd0;	
	
        always @(bin) begin
           if (bin < 10) begin bcd1 = 10; bcd0 = bin; end
           else if (bin < 20) begin bcd1 = 1; bcd0 = bin + 6; end
           else begin bcd1 = 2; bcd0 = bin + 12; end
        end
endmodule