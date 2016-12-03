module displaytime(clk, reset_n, out, fail);
	input clk, reset_n;
	output [3:0] outh, outm, outs;
	output fail;
	wire enb;
	RateDivider R0(.enb(enb), .clk(clk), .reset_n(reset_n));
	timecounter t0(.clk(clk), .reset_n(reset_n), .enb(enb), .outs(outs), .outm(outm), .outh(outh), .fail(fail);


module timecounter(clk, reset_n, enb, outm, outs, outh, fail);
	input clk;
	input reset_n;
	input enb;
	output reg [3:0]outm, outs, outh;
	output reg fail

	always@(posedge enb,posedge clk) begin
    	if(reset) begin
        		outm<=0;
        		outs<=0;
        		fail <= 0;
    	end
		else if (enb) begin
            if (outm == 4'd0 && outs == 4'd0 && outh != 4'd0) begin // 100, 200, 300, 400, 500
           		fail <= 1'b0;
           		outh <= outh -1;
            	outm <= 4'd5;
            	outs <= 4'd9; // 459, 359, 259, 159, 059;
           	end
           	else if(outs!=4'd0)
            begin
                outs<=outs-1; // 9876543210
                fail <= 1'b0;
            end
            else if(outs==4'd0 && outm != 4'd0) begin
                outs<=9; 		
                outm<=outm-1; //59,49,39,29,19, 09
                fail <= 1'b0;
            end
           	else if (outm == 4'd0 && outs == 4'd0 && outh == 4'd0) begin
           		fail <= 1'b1;
           	end
    	else begin
    		(outh != 4'd5) 
    			outm <= 4'd0;
    			outs <= 4'd0;
    			fail <= 1'b0;
    		end
    	end
	end


module RateDivider(enb, clk, reset_n);
	output enb;
	input clk;
	input reset_n;
	reg [27:0] count;
	reg enb;
	
	always @(*)
		begin
		count = ‭26‘b10111110101111000001111111‬;
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

