module counterN(clk, reset, enable, qout, tc);
    parameter N=24, M=5;
    input clk, reset;
    input enable;
    output [M-1:0] qout;
    output tc;

    reg [M-1:0] qout;

    assign tc = (qout==N-1) & enable;
    always @(posedge clk or posedge reset) begin
        if (reset) qout <= 0;
        else if (enable) begin
            if (qout==N-1) qout = 0;
            else qout <= qout + 1;
        end
    end
endmodule