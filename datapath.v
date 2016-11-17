module datapath(
	input clk,
	input resetn,
	input char, // char need to give several bits
	input load, // enter
	input compare, part, p2score, p1score, timecount, 
	input [4:0] wordlength,
	output reg [31:0] word, // The length of word shouload smaller or equal to 6;
	output reg match, count, dash,
	output reg draw, // underscore
	wire [6:0] timecounter,
	wire timecount
	);
	
	// timecounter
	displaytime d0(.clk(clk), .reset_n(resetn) .out(timecounter), .fail(timeout));
	// registers char and draw dashes
	reg dash;   
	reg [] char;
	reg i;

	always @ (posedge clk) begin
		if (resetn) begin
			char <= 0; // the input we will put, it's a single character, it's 5 bits
			dash <= 1'b0; // dash is the underscore below the every chars
		end
		else if (load == 1) begin
			ram32v5 r0(.address(address), .clk(clk), .data(char), .wren(load), .q(address));
			dash <= 1'b1;
			/*
			remain <= wordlength;*/
			end
		end
		
	
	reg [4:0] address;	// This is also can be treated as the length of the words
						// since we write the chars to memory start from 1
	always @ (posedge load, posedge resetn)
		begin
			if (resetn == 1'b1) begin
				address <= 5'd0;
			else begin
				address <= address + 1;
				
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
	
	
	
	
	
	/*always@(posedge clk, negedge resetn) begin
		if (resetn)
			wordlength <= 0;
		else if (load) begin
			wordlength <= wordlength + 1;
			remain <= wordlength;
		end
	end*/
	
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
				remain <= wordlength - count;
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

