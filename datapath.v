module datapath(
	input clk,
	input resetn,
	input char, guess// char, guess
	input ld, ld_g, // enter
	input compare, part, p2score, p1score, timecount, 
	output reg word, match, finish,
	output reg draw, // underscore
	output reg [6:0] timecounter
	output reg [15:0] qout, q1out, q2out, q3out, q4out,
	output [6:0] HEX0, HEX1
	);
	
	// timecounter
	always@(posedge timecount) begin
		displaytime d0(.clk(clk), .reset_n(resetn) .out(timecounter), .fail(timeout));
	end
		// change 2 for another test

	// registers char
	reg dash;
	reg [4：0] char;
	reg [4:0] wordcount, remain;
	reg [3:0] counter4;
	wire counter4_clear;
	localparam x1 = 8'd100, y2 = 7'd78;
	
	always @ (posedge clk) begin
		if (resetn) begin
			char <= 0; // the input we will put, it's a single character, it's 5 bits
			dash <= 1'b0; // dash is the underscore below the every chars
		end
		else if (ld == 1) begin
			ram32v5 r0(.address(address), .clk(clk), .data(char), .wren(ld), .q(word));
			dash <= 1'b1;
			/*
			remain <= wordlength;*/
			end
		end
		
	
	reg [4:0] address;	// This is also can be treated as the length of the words
						// since we write the chars to memory start from 1
	always @ (posedge ld, posedge resetn)
		begin
			if (resetn == 1'b1) begin
				address <= 5'd0;
				remain <= 0;
			else begin
				address <= address + 1; // wordlength
				remain <= address
			end
		end
	// draw dashes	
	always @(posedge clk) begin
		if (resetn) begin
			counter4 <= 0;
		//	finish <= 1’b0;
		end
		else if (dash) begin
			if (counter4_clear) begin
				counter4 <= 0;
		//		finish <= 1’b1;
			end
		 	else begin
				counter4 <= counter4 + 1;
			end
	end

	always @(posedge clk) begin
		if (resetn) begin
			y2 <= y1;
			qout <= 0;
		else begin
			y2 <= y2+counter4;
			qout <= {y2, x1}; 
			y2 <= y2+5;
		end
	end
	
	// load graph
	load_graph l0(.clk(clk), .resetn(resetn), .ld_g(ld_g), .q1out(q1out), .q2out(q2out), .q3out(q3out), .q4out(q4out));
	// compare guesschar with registered char; ouput match and count and match position
	wire count, position;
	
	always@(posedge clk) begin
		
		if (fill) begin
			if (count != 0) begin
				count <= count -1;
				filled <= 1'b0;
				fillblank f0(.position(position), draw the character);
			end
			else  begin
				filled <= 1'b1;
				end
	end
	// draw parts
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
			else if (draw) begin
				drawparts d0(.part(part), .out(out to vga));
				part <= part + 1;
				complete <= 1'b0;
			end
		end
	end
	end
	// determine whether to continue; win-lose state
	always@(posedge clk, negedge resetn) begin
		if (resetn) begin
			continue <= 1'b0;
			p2score <= 0;
		end
		else begin
			if (remain == 0) begin
				continue <= 1'b0;
				p2score <= p2score + 1;
			end
			else if (match) begin
				remain <= wordcount - count;
				continue <= 1'b1;
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
	// display
	Hexdecoder h2(p2score[3], p2score[2], p2score[1], p2score[0], .HEX(HEX0));
	Hexdecoder h1(p1score[3], p1score[2], p1score[1], p1score[0], .HEX(HEX1));
	
endmodule

module load_graph(
	input clk, resetn, ld_g, 
	output reg [15:0] q1out, q2out, q3out, q4out);
	
	reg [1:0] counter1; reg [5:0] counter2; reg[4:0] counter3; reg [3:0] counter4; reg [6:0] counter5;
	wire counter1_clear, counter2_clear, counter3_clear, counter4_clear, counter5_clear;
	localparam x1 = 8'd100, y1 = 7'd20, x2 = 8'd80, x3 = 8'd30, y2 = 7'd78;
	
	assign counter1_clear = (counter1 == 2'b10); // +2
	assign counter2_clear = (counter2 == 6'b111100); //+60
	assign counter3_clear = (counter3 == 5'b10110); //+22
	assign counter4_clear = (counter4 == 4'b1010); //+10
	assign counter5_clear = (counter5 == 7'b1010000); //+80
	
	always @(posedge clk) begin
		if (resetn) begin
			counter2 <= 0;
		//	finish <= 1’b0;
		end
		else if (ld_g) begin
			if (counter2_clear) begin
				counter2 <= 0;
		//		finish <= 1’b1;
			end
		 	else begin
				counter2 <= counter2 + 1;
			end
	end
	
	always @(posedge clk) begin
		if (resetn) begin
			counter1<= 0;
			end
		else if (ld_g) begin
			if ((counter2_clear || counter3_clear || counter4_clear) && counter1_clear)  begin
				counter1 <= 0;
				end
			else if (counter2_clear) begin
				counter1 <= counter1+1;
				end
			else if (counter3_clear) begin
				counter1 <= counter1+1;
			else if (counter4_clear) begin
				counter1 <= counter1+1;
			else if (counter5_clear) begin
				counter1 <= counter1+1;
		end
	end
	
	always @(posedge clk) begin
		if (resetn) begin
			counter3 <= 0;
		//	finish <= 1’b0;
		end
		else if (ld_g) begin
			if (counter3_clear) begin
				counter3 <= 0;
		//		finish <= 1’b1;
			end
		 	else begin
				counter3 <= counter3 + 1;
			end
	end
	
	always @(posedge clk) begin
		if (resetn) begin
			counter4 <= 0;
		//	finish <= 1’b0;
		end
		else if (ld_g) begin
			if (counter4_clear) begin
				counter4 <= 0;
		//		finish <= 1’b1;
			end
		 	else begin
				counter4 <= counter4 + 1;
			end
	end
	
	always @(posedge clk) begin
		if (resetn) begin
			counter5 <= 0;
		//	finish <= 1’b0;
		end
		else if (ld_g) begin
			if (counter5_clear) begin
				counter5 <= 0;
		//		finish <= 1’b1;
			end
		 	else begin
				counter5 <= counter5 + 1;
			end
	end
	
	always @(*) begin
		q1out <= {x1+counter1,y1+counter2};
		//x1out <= x1+counter1[];
		//y1out <= y1+counter2[];
		q2out <= {x2+counter3,y1+counter1};
		//x2out <= x2+counter2[];
		//y2out <= y2+counter2[];
		q3out <= {x2+counter1,y1+counter4};
		//x3out <= x3+counter3[];
		//y3out <= y3+counter3[];
		q4out <= {x3+counter5, y2+counter1};
	end
endmodule



module HexDecoder(d, c, b, a, HEX);

	//  d      c      b      a
	//SW[3]  SW[2]  SW[1]  SW[0]

	input a; // LSB
	input b; 
	input c;
	input d; // MSB

	output [6:0] HEX;
	assign HEX[0] = (~d & ~c & ~b & a) | (~d & c & ~b & ~a) | (d & c & ~b & a) | (d & ~c & b & a);
	assign HEX[1] = (d & b & a) | (d & c & ~a) | (c & b & ~a) | (~d & c & ~b & a);
	assign HEX[2] = (d & c & b) | (d & c & ~a) | (~d & ~c & b & ~a);
	assign HEX[3] = (c & b & a) | (~c & ~b & a) | (~d & c & ~b & ~a) | (d & ~c & b & ~a);
	assign HEX[4] = (~d & a) | (~d & c & ~b) | (~c & ~b & a);
	assign HEX[5] = (~d & ~c & a) | (~d & ~c & b) | (~d & b & a) | (d & c & ~b & a);
	assign HEX[6] = (~d & ~c & ~b) | (~d & c & b & a) | (d & c & ~b & ~a);

endmodule

module fillblank(
	input position,
	output [15:0] out)
	
	

