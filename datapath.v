module datapath(
	input clk,
	input resetn,
	input char, // char
	input ld, // enter
	input compare, part, p2score, p1score, timecount, 
	input [4:0] wordcount,
	output reg word, match, count, dash
	output reg draw, // underscore
	output reg [6:0] timecounter
	);
	
	// timecounter
	always@(timecount) begin
		displaytime d0(.clk(clk), .reset_n(resetn) .out(timecounter), .fail(timeout));
	end
	// registers char and draw dashes
	reg dash;
	reg [] char;

	always @ (posedge clk) begin
		if (resetn) begin
			char<= 0;
			dash <= 1'b0;
			wordcount <= 0;
		end
		else begin
			word <= ld ? char : word;
			dash <= ld && word ? 1'b1 : 1'b0;
			wordcount <= wordcount + 1;
			remain <= wordcount;
			end
		end
	end
	// load graph
	always @(posedge clk) begin
		if (resetn) begin
			counter <= 4'b0;
			finish <= 1’b0;
		end
		if (draw) begin
			if (counter == 4'b1111) begin
				counter <= 4'd0;
				finish <= 1’b1;
			end
		 	else begin
				counter <= counter + 1'b1;
			end
		end
	end
	
	
	
	
	
	always@(posedge clk, negedge resetn) begin
		if (resetn)
			wordcount <= 0;
		else if (ld) begin
			wordcount <= wordcount + 1;
			remain <= wordcount;
		end
	end
	
	always@(posedge clk, negedge resetn) begin
		if (resetn) begin
			remain <= 0;
			continue <= 1'b0;
			p2score <= 0;
		end
		else begin
			if (remain == 0) begin
				continue <= 1'b0;
				p2score <= p2score + 1;
			end
			if (match) begin
				remain <= wordcount - count;
				continue <= 1'b1;
			end
			if (fill == 1'b1) begin
				if (count != 0) begin
					count <= count -1;
					filled <= 1'b0;
				end
				else  begin
					filled <= 1'b1;
				end
			end
		end
	end
	
	always@(posedge clk, negedge resetn) begin
		if (resetn) begin
			part <= 0;
			complete <= 1'b0;
			p1score <= 0;
		end
		else begin
			if (part == 4'b1001) begin
				complete <= 1'b1;
				p1score <= p1score + 1;
			end
			if (draw) begin
				part <= part + 1;
				complete <= 1'b0;
			end
		end
	end
	
	always@(posedge clk, negedge resetn) begin
		if (resetn) begin
			p1score <= 0;
		else if (timeout == 1'b1) begin
				p1score <= p1score + 1;			
		end
	end
	
endmodule

