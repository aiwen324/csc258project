module displaytime(clk, reset_n, out, fail);
	input clk, reset_n;
	output [0:6] out;
	output fail;
	wire enb;
	RateDivider R0(.enb(enb), .clk(clk), .reset_n(reset_n));
	timecounter t0(.clk(clk), .reset_n(reset_n), .enb(enb), .out(out), .fail(fail);


module timecounter(clk, reset_n, enb, out, fail);
	input clk;
	input reset_n;
	input enb;
	output reg [0:6]out;
	output reg fail
	
	always @(posedge clk)
		if (reset_n == 0)
			begin
				out <= 6'd59;
				fail <= 1'b0;
			end
		else if (out = 1'b0)
			begin
				fail = 1'b1;
				out <= 6'd59;
			end
		else if((enb == 1)
			begin
				out = out - 1'b1;
				fail = 1'b0;
			end




module RateDivider(enb, clk, reset_n);
	output enb;
	input clk;
	input reset_n;
	reg [27:0] count;
	reg enb;
	
	always @(*)
		begin
		count = ‭0010111110101111000001111111‬;
		end
	reg q
	always@(posedge CLOCK_50)
		begin
		if (reset_n == 1’b0)
		begin
		q <= 0;
		enb <= 1’b0;
		end
		else if (q == 0)
		begin
		q <= count;
		enb <= 1’b1;
		end
		else
		begin
		q <= q - 1’b1; 
		enb <= 1’b0; 
		end
		
endmodule

