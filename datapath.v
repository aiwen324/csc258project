module datapath(
	input clk,
	input resetn,
	input [4:0] char, guess// char, guess from keyboard
	input ld, writeorread, timecount, compare, fill, draw, over, ld_g, wren, rden// from control
	output reg [2:0] color,
	output reg word, match, finish, graph_loaded, timeout,// to control
	// output reg [6:0] timecounter, // to vga / hex
	output reg [14:0] qout, // to vga
	output [6:0] HEX0, HEX1, HEX3, HEX4, HEX5
	);

	wire hour, minute, second;
	reg count;
	reg dash;
	reg [4:0] rdaddress; // The address we will read from
	reg [4:0] wraddress; // The address we will write data to
	reg [4:0] guesschar; // The register to save the char that guesser guess
	reg [4:0] matchaddress; // The address that 
	reg [4:0] length
	// timecounter
	always@(posedge timecount) begin
		if (resetn) begin
			HEX3 <= 0;
			HEX4 <= 0;
			HEX5 <= 0;
		end
		else begin
		displaytime d0(.clk(clk), .reset_n(resetn) .outm(minute), .outh(hour), outs(second).fail(timeout));
		Hexdecoder h3(hour[3], hour[2], hour[1], hour[0], .HEX(HEX5));
		Hexdecoder h4(minute[3], minute[2], minute[1], minute[0], .HEX(HEX4));
		Hexdecoder h5(second[3], second[2], second[1], second[0], .HEX(HEX3));
		end
	end
	// registers char
	// This block will write and read the memory
	
	
	always @ (posedge clk) begin
		if (resetn) begin
			dash <= 1'b0; // dash is the underscore below every char
		end
		else if (writeorread) begin
			dualportram d0(.clock(clk), .data(inputs), .rdaddress(rdaddress), 
			.rden(rden), .wraddress(wraddress), .wren(wren), .q(word));
			// rden is the signal to enable read
			// wren is the signal to enable write
			dash <= 1'b1;
			end
	end
	
	
	reg [4:0] inputs;
	always @ (posedge clk) begin
		if (resetn) begin
			inputs <= 0;
		end
		else if (ld) begin
			inputs <= char;
		end
		else if (compare) begin
			inputs <= position;
		end
	end
	
		
	
	always @(posedge clk) begin
		if (ld) begin
			wraddress <= wraddress1;
		end
		else if (compare) begin
			wraddress <= wraddress2;
		end
	end
	
	reg [4:0] wraddress1;	// This also can be treated as the length of the words
							// since we write the chars to memory start from 1
	always @ (posedge ld)
		begin
			if (resetn) begin
				wraddress1 <= 5'd0;
			else begin
				wraddress1 <= wraddress1 + 1; // wordlength
			end
		end
			

	reg loopend;
	always @ (posedge clk) begin
		if (resetn) begin
			rdaddress <= 5'b0;
			loopend <= 1'b0;
		end
		else if (compare) begin
			if (rdaddress >= length) begin
				rdaddress <= 5'b00000;
				loopend <= 1'b1;
			end
			else begin
				rdaddress <= rdaddress + 1;
				loopend <= 1'b0;
			end
		end
		else if (fill) begin
				rdaddress <= wraddress2 + count;
		end
	end
	
	
	reg [4:0] position;
	always @ (posedge clk) begin
		if (resetn) begin
			guesschar <= 5'b0;
			count <= 0; // The number of chars in the word; 
			wraddress2 <= 5'b11111; // We save the memory address to the wraddress2
			position <= 5'b00000;
		end
		else if (compare) begin
			
			match <= 1'b0;
			guesschar <= guess;
			if (guesschar == word) begin
				count <= count + 1;
				position <= rdaddress;
				wraddress2 <= wraddress2 - 5'b00001; 
				if (loopend == 1'b1) begin
					if (count != 0) begin
						match <= 1'b1;
					end
				end
			end
			else begin
				match <= 1'b0;
			end
		end
		else if (fill) begin
			if (count != 0) begin
				count <= count -1;
				filled <= 1'b0;
				fillblank f0(.resetn(resetn), .clk(clk), .fill(1'b0), .position(word), .char(guess), .qout(qout)); 
				fillblank f1(.resetn(resetn), .clk(clk), .fill(fill), .position(word), .char(guess), .qout(qout)); 
			end
//fill blank
			else begin
			wraddress2 <= 5'b11111;
			filled <= 1'b1;
			end
		end
		
	end

	
	reg [4:0] length;
	always @(posedge clk) begin
		if (ld_g = 1'b1) begin
			length <= wraddress1;
			remain <= length;
		end
		else if(loopend == 1'b1) begin
			remain <= remain - count;
	end
		
	// compare guesschar with registered char; ouput match and count and match position and draw
	
	// reg qout
	always @(posedge clk) begin
		if (resetn) begin
			color <= 0;
			qout <= 0;
		end
		else begin
		if (ld) begin
			color <= 3'b111;// white
		end
		if (dash) begin// draw dashes
		drawdash d1(.resetn(resetn), .clk(clk), .qout(qout)); 
		end
	// load graph
		else if (ld_g) begin
		color <= 3'b001; // blue
		load_graph l0(.clk(clk), .resetn(resetn), .qout(qout)); 
		end
		else if (fill) begin
			color <= 3'b010;// green
		end
	// draw parts
		else if (draw) begin
			color <= 3'b100;// red
			drawparts d0(.part(part), .out(qout));
		end
	// wipe all the images
		else if (over) begin
		color <= 3'b000;// black
		clear c0(.resetn(resetn), .clk(clk),.clearout(qout)); 
		end
		end
	end
	
	// draw parts/endgame and register scores
	reg [2:0] part;
	always@(posedge clk) begin
		if (resetn) begin
			part <= 0; 
			complete <= 1'b0;
			p1score <= 0;
		end
		else begin
			if (part == 3'b101) begin
				complete <= 1'b1;
				p1score <= p1score + 1;
			end
			else if (draw) begin
				part <= part + 1;
				complete <= 1'b0;
			end
		end
	end
	end
	// determine whether to continue or end game; win-lose state
	always@(posedge clk) begin
		if (resetn) begin
			continuous <= 1'b0;
			p2score <= 0;
		end
		else begin
			if (remain == 0) begin
				continuous <= 1'b0;
				p2score <= p2score + 1;
			end
			else begin
				continuous <= 1'b1;
			end
		end
	end
	
	always@(posedge clk) begin
		if (resetn) begin
			p1score <= 0;
		else if (timeout == 1'b1) begin
				p1score <= p1score + 1;		
		end
	end

	// display
	always @(*) begin
		if (resetn) begin
			HEX0 <= 0;
			HEX1 <= 0;
		end
		else begin
			Hexdecoder h2(p2score[3], p2score[2], p2score[1], p2score[0], .HEX(HEX0));
			Hexdecoder h1(p1score[3], p1score[2], p1score[1], p1score[0], .HEX(HEX1));
		end
	end
endmodule
module drawdash(
	input resetn, clk,
	output reg [14:0] qout
	);
	assign counter4_clear = (counter4 == 4'b1010); //+10
	// draw dashes	
	always @(posedge clk) begin
		if (resetn) begin
			counter4 <= 0;
		//	finish <= 1’b0;
		end
		else if (counter4_clear) begin
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
endmodule
module load_graph(
	input clk, resetn, 
	output reg graph_loaded,
	output reg [14:0] qout);
	
	reg [1:0] counter1; reg [5:0] counter2; reg[4:0] counter3; reg [3:0] counter4; reg [6:0] counter5;
	wire counter1_clear, counter2_clear, counter3_clear, counter4_clear, counter5_clear, en0, en1, en2, en3;
	localparam x1 = 8'd100, y1 = 7'd20, x2 = 8'd80, x3 = 8'd30, y2 = 7'd78;
	
	assign counter1_clear = (counter1 == 2'b10); // +2
	assign counter2_clear = (counter2 == 6'b111100); //+60
	assign counter3_clear = (counter3 == 5'b10110); //+22
	assign counter4_clear = (counter4 == 4'b1010); //+10
	assign counter5_clear = (counter5 == 7'b1010000); //+80
	assign en0 = ld_g ? 1'b1 : 1'b0;
	always @(posedge clk) begin
		if (resetn) begin
			counter5 <= 0;
			counter1 <= 0;
			counter2 <= 0;
			counter3 <= 0;
			counter4 <= 0;
			qout <= 0;
			graph_loaded <= 0;
		end
		else if (en0) begin
			if (counter5_clear) begin
				qout <= {x3+counter5, y2+counter1};
				counter5 <= 0;
				counter1 <= counter1+1;
			end
		 	else if (counter1_clear && counter5_clear) begin
		 		qout <= {x3+counter5, y2+counter1};
				counter5 <= 0;
				counter1 <= 0;
				en1<= 1;
			end
			else begin
				qout <= {x3+counter5, y2+counter1};
				counter5 <= counter5+1;
			end
		else if (en1) begin
				if (counter2_clear) begin
				qout<= {x1+counter1,y1+counter2};
				counter2 <= 0;
				counter1 <= counter1+1;
				end
			else if (counter1_clear && counter2_clear) begin
				qout<= {x1+counter1,y1+counter2};
				counter2 <= 0;
				counter1 <= 0;
				en2 <= 1;
				en1 <= 0;
			end
			else begin
				qout<= {x1+counter1,y1+counter2};
				counter2 <= counter2+1;
			end
			
		end
		else if (en2) begin
			if (counter3_clear) begin
				qout<= {x2+counter3,y1+counter1};
				counter3 <= 0;
				counter1 <= counter1+1;
				end
			else if (counter3_clear && counter1_clear) begin
				qout<= {x2+counter3,y1+counter1};
				counter3 <= 0;
				counter1 <= 0;
				en3 <= 1;
				en2 <= 0;
			end
			else begin
				qout<= {x2+counter3,y1+counter1};
				counter3 <= counter3+1;
			end
		else if (en3) begin
			if (counter4_clear) begin
				qout<= {x2+counter1,y1+counter4};
				counter4 <= 0;
				counter1 <= counter1+1;
				end
			else if (counter4_clear && counter1_clear) begin
				qout<= {x2+counter1,y1+counter4};
				counter4 <= 0;
				counter1 <= 0;
				en3 <= 0;
				graph_loaded <= 1;
			end
			else begin
				qout<= {x2+counter1,y1+counter4};
				counter4 <= counter4+1;
			end
		end
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

module clear(
	input clk, resetn,
	output reg [15:0] clearout
	);
	reg [7:0] xCounter; reg [6:0] yCounter;
	wire xCounter_clear, yCounter_clear;
	assign xCounter_clear = (xCounter == 8'b10011111);
	assign yCounter_clear = (yCounter == 7'b1110111); 
	
	always @(posedge clk, negedge resetn)
	begin
		if (!resetn)
			xCounter <= 10'd0;
		else if (xCounter_clear) begin
				xCounter <= 10'd0;
			end
		else begin
			xCounter <= xCounter + 1'b1;
			end
		end
	end
	
	always @(posedge vga_clock or negedge resetn)
	begin
		if (!resetn)
			yCounter <= 10'd0;
		else if (xCounter_clear && yCounter_clear)
			yCounter <= 10'd0;
		else if (xCounter_clear)		//Increment when x counter resets
			yCounter <= yCounter + 1'b1;
	end
	
	always @(*) begin
		clearout =	{xCounter, yCounter};
	end
endmodule

module drawparts(
	input resetn, clk,
	input [2:0] part,
	output reg finish,
	output reg [15:0] drawout
	);
	
	wire counter2_clear, counter1_clear, counter3_clear, counter4_clear, counter5_clear, counter6_clear;
	reg en1, en2, en3, en4, en5, en6, en7;
	reg [1:0] counter1;
	reg [2:0] counter4, counter5;
	reg [3:0] counter3, counter6;
	reg [4:0] counter2;
	
	localparam x1 = 8'd80, y1 = 7'd30, x2 = 8'd81， y2 = 7'd40, y3 = 7'd60, 
	x3 = 8'd79, x4 = 8'd78, x5 = 8'd77, x6 = 8'd76, y4 = 7'd31, y5 = 7'd32, y6 = 7'd33;
	assign counter1_clear = (counter1 == 2'b10); // +2
	assign counter2_clear = (counter2 == 5'b10100); //+20
	assign counter3_clear = (counter3 == 4'b1010); //+10
	assign counter4_clear = (counter4 == 3'b100);//+4
	assign counter5_clear = (counter5 == 3'b111);//+6
	assign counter6_clear = (counter6 == 4'b1000);//+8
	
	// cases of every parts.
	always @(posedge clk) 
		if (resetn) begin
			drawout <= 0;
			finish <= 0;
		else begin
			case(part) begin
				3'b0000: 
					en4 <= 1'b1;
					drawout<= circle;// circle
				3'b0001: begin
					en2 <= 1'b1;
					en1 <= 1'b1;
					drawout <= {x1+counter1, y2+counter2}; // body (x1, y2)
					end
				3'b0010: begin
					en3 <= 1'b1;
					drawout <= {x1-counter3, y2-counter3};// left hand
					end
				3'b0011: begin
					en3 <= 1'b1;
					drawout <= {x2+counter3, y2-counter3};// right hand
					end
				3'b0100: begin
					en3<= 1'b1; 
					drawout <= {x1-counter3, y3+counter3};// left leg
					end
				3'b0101: begin
					en3<= 1'b1;
					drawout <= {x2+counter3, y3+counter3};// right leg
					end
				default: drawout <= 0;
			endcase
		end
	end
	reg [15:0] circle; // head
	always @(posedge clk) begin
		if (resetn) begin
			counter3 <= 0;
			counter4<= 0;
			counter5<= 0;
			counter6<= 0;
			end
		else if (en4) begin
			if (counter3_clear) begin
				circle<= {x3+counter4, y1+counter3};
				counter3 <= 0;
				counter4 <= counter4+1;
				end
			else if (counter3_clear && counter4_clear) begin
				circle<= {x3+counter4, y1+counter3};
				counter4 <= 0;
				counter3 <= 0;
				en4<= 0;
				en5<=1;
			end
			else begin
				circle<= {x3+counter4, y1+counter3};
				counter3 <= counter3+1;
			end
		end
		else if (en5) begin
			if (counter6_clear) begin
				circle<= {x4+counter5, y4+counter6};
				counter6 <= 0;
				counter5 <= counter5+1;
				end
			else if (counter5_clear && counter6_clear) begin
				circle<= {x4+counter5, y4+counter6};
				counter5 <= 0;
				counter6 <= 0;
				en5 <= 0;
				en6 <=1;
			end
			else begin
				circle<= {x4+counter5, y4+counter6};
				counter6 <= counter6+1;
			end
		end
		else if (en6) begin
			if (counter6_clear) begin
				circle<= {x5+counter6, y5+counter5};
				counter6 <= 0;
				counter5 <= counter5+1;
				end
			else if (counter5_clear && counter6_clear) begin
				circle<= {x5+counter6, y5+counter5};
				counter5 <= 0;
				counter6 <= 0;
				en6 <= 0;
				en7 <= 1;
			end
			else begin
				circle<= {x5+counter6, y5+counter5};
				counter6 <= counter6+1;
			end
		end
		else if (en7) begin
			if (counter3_clear) begin
				circle<= {x6+counter3, y6+counter4};
				counter3 <= 0;
				counter4 <= counter4+1;
				end
			else if (counter3_clear && counter4_clear) begin
				circle<= {x6+counter3, y6+counter4};
				counter4 <= 0;
				counter3 <= 0;
				en7 <= 0;
				finish <= 1;
			end
			else begin
				circle<= {x6+counter3, y6+counter4};
				counter3 <= counter3+1;
			end
		end
	end
	// counter1+2 = body(+2, +20)
	always @(posedge clk) begin
		if (resetn) begin
			counter1<= 0;
			end
		else if (en1) begin
			if (counter2_clear) begin
				counter1 <= counter1+1;
				end
			else if (counter2_clear && counter1_clear) begin
				counter1 <= 0;
			end
		end
	end
	always @(posedge clk) begin
		if (resetn) begin
			counter2 <= 0;
			finish <= 1'b0;
		end
		else if (en2) begin
			if (counter2_clear) begin
				counter2 <= 0;
				finish <= 1'b1;
			end
		 	else begin
				counter2 <= counter2 + 1;
			end
		end
	end
	// +10 diagonal(+10, +10)
	always @(posedge clk) begin
		if (resetn) begin
			counter3 <= 0;
			finish <= 1’b0;
		end
		else if (en3) begin
			if (counter3_clear) begin
				counter3 <= 0;
				finish <= 1’b1;
			end
		 	else begin
				counter3 <= counter3 + 1;
			end
		end
	end
endmodule
