module datapath(
	input clk,
	input resetn,
	input [4:0] char, guess// char, guess from keyboard
	input ld, timecount, compare, fill, draw, over, ld_g,// from control
	output reg [2:0] color,
	output reg word, match, finish, graph_loaded, timeout,// to control
	// output reg [6:0] timecounter, // to vga / hex
	output reg [14:0] qout, // to vga
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4
	);
	wire timecounter;
	// timecounter
	always@(posedge timecount) begin
		displaytime d0(.clk(clk), .reset_n(resetn) .out(timecounter), .fail(timeout));
	end
	// color to vga
	always@(*) begin
		if (ld) begin
			assign color = 3'b111;// white
		end
		else if (ld_g) begin
			assign color = 3'b001; // blue
		end
		else if (draw) begin
			assign color = 3'b100;// red
		end
		else if (fill) begin
			assign color = 3'b010;// green
		end
		else if (over) begin
			assign color = 3'b000;// black
		end
	end
		
	
	// registers char
	reg dash;
	reg [39：0] word;
	reg [4:0] wordcount, remain;
	
	
	
	// This block will write and read the memory
	always @ (posedge clk) begin
		if (resetn) begin
			char <= 0; // the input we will put, it's a single character, it's 5 bits
			dash <= 1'b0; // dash is the underscore below the every chars
		end
		else if (writeorread == 1) begin
			dualportram d0(.clock(clk), .data(char), .rdaddress(rdaddress), 
			.rden(compare), .wraddress(wraddress), .wren(wren), .q(word));
			// compare is the signal to enable read
			// wren is the signal to enable write
			dash <= 1'b1;
			/*
			remain <= wordlength;*/
			end
			
	reg [4:0] rdaddress; // The address we will read from, it will be a loop
	
	always @ (posedge clk) begin
		if (resetn) begin
			rdaddress <= 5'b0;
			loopend <= 1'b0;
		end
		else if (compare == 1'b1) begin
			if (rdaddress == length) begin
				rdaddress <= 5'b00001;
				loopend <= 1'b1;
			end
			else begin
				rdaddress <= rdaddress + 1;
			end
		end
	end
	
	reg [4:0] guesschar; // The register to save the char that guesser guess
	reg [4:0] matchaddress; // The address that 
	always @ (posedge clk) begin
		if (resetn) begin
			guesschar <= 5'b0;
			count <= 0; // The number of chars in the word; 
		end
		else if (compare == 1'b1) begin
			match <= 1'b0;
			wraddress <= 5'b11111;
			char <= 5'b00000;
			guesschar <= guess; // The 
			if (guesschar == word) begin
				count <= count + 1;
				char <= rdaddress;
				wraddress <= wraddress - 5'b00001;
				if (loopend == 1'b1) begin
					if (count != 0) begin
						match = 1'b1;
						char = 5'b00000;
					end
					else begin
						match = 1'b0;
					end
				end
			end
		end
	end
	
	reg [4:0] length
	always @(*) begin
		if (ld_g = 1'b1) begin
			length = wraddress;
		end
	end
	
	reg [4:0] wraddress;	// This also can be treated as the length of the words
						// since we write the chars to memory start from 1
	always @ (posedge writeorread, posedge resetn)
		begin
			if (resetn == 1'b1) begin
				wraddress <= 5'd0;
				remain <= 0;
			else begin
				wraddress <= wraddress + 1; // wordlength
				remain <= wraddress;
			end
		end
	// need a mux here
	// draw dashes
	always @(*) begin
		if (dash) begin
		drawdash d1(.resetn(resetn), .clk(clk), .qout(qout)); end
	// load graph
		else if (ld_g) begin
		load_graph l0(.clk(clk), .resetn(resetn), .qout(qout)); end
	// compare guesschar with registered char; ouput match and count and match position and draw
	
	// wipe all the images
		else if (over) begin
		clear c0(.resetn(resetn), .clk(clk),.clearout(qout)); end
		else if (fill) begin
			
	end
	wire count, position, w1;
	// fill blank
	always@(posedge clk) begin
		
		if (fill) begin
			if (count != 0) begin
				count <= count -1;
				filled <= 1'b0;
				fillblank f0(.position(position), .qout(w1).char(char),.clk(clk), .resetn(resetn)// read
	input ld, // write(shift register)
	output match, filled,
	output [15:0] qout;);
			end
			else  begin
				filled <= 1'b1;
				end
	end
	// draw parts/endgame and register scores
	reg [2:0] part;
	always@(posedge clk, negedge resetn) begin
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
				drawparts d0(.part(part), .out(qout));
				part <= part + 1;
				complete <= 1'b0;
			end
		end
	end
	end
	// determine whether to continue or end game; win-lose state

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
	output reg [14:0] qout;
	
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
	assign xCounter_clear = (xCounter == 8'b10100000);
	assign yCounter_clear = (yCounter == 7'b1111000); 
	
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
endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	