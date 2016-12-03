module datapath(
	input clk,
	input resetn,
	input [4:0] char, guess// char, guess from keyboard
	input ld, writeorread, timecount, compare, fill, draw, over, ld_g, wren, rden, dash// from control
	output reg [2:0] color,
	output reg loaded, match, finish, graph_loaded, timeout,// to control
	// output reg [6:0] timecounter, // to vga / hex
	output reg [7:0] x,
	output reg [6:0] y, // to vga
	output [6:0] HEX0, HEX1, HEX3, HEX4, HEX5
	);
	 
	wire hour, minute, second, counter3_clear;
	reg count;
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
		
		end
	end

	displaytime d0(.clk(clk), .reset_n(timecount) .outm(minute), .outh(hour), outs(second).fail(timeout));
	Hexdecoder h3(hour[3], hour[2], hour[1], hour[0], .HEX(HEX5));
	Hexdecoder h4(minute[3], minute[2], minute[1], minute[0], .HEX(HEX4));
	Hexdecoder h5(second[3], second[2], second[1], second[0], .HEX(HEX3));
	
	// registers char
	// This block will write and read the memory

	always @ (posedge clk) begin
		if (writeorread) begin
			dualportram d0(.clock(clk), .data(inputs), .rdaddress(rdaddress), 
			.rden(rden), .wraddress(wraddress), .wren(wren), .q(word));
			// rden is the signal to enable read
			// wren is the signal to enable write
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
		if (!resetn) begin
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
			if (count != 0 && done) begin
				count <= count -1;
				filled <= 1'b0;
				resetchar <= 1'b0;
			end
			else if (!resetchar) begin
				resetchar <= 1;
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
	assign counter3_clear = (counter3 == 4'b1010); //+9
	wire [7:0] dashx, graphx, drawx, overx;
	wire [6:0] dashy, graphy, drawy, overy;
	wire s, done;
	always @(posedge ld, posedge clk) begin
		if (resetn) begin
			counter3 <= 4'd0;		
		end
		else if (counter3_clear) begin
				counter3 <= 0;
			end
		else begin
				counter3 <= counter3 + 1;
			end
		end
	end
	always @(posedge clk) begin
		if (!resetn) begin
			s <= 0;
		end
		else if (fill) begin
			s <= 1;
		end
		else begin
			s <= 0;
		end
	end
	drawdash d1(.resetn(resetn), .clk(clk), .dash(dash), .dashcoord(counter3), .x(dashx), .y(dashy),.done(loaded)); 
	load_graph l0(.clk(clk), .resetn(resetn), .ld_g(ld_g), .x(graphx), .y(graphy), .ld_g(ld_g), .graph_loaded(graph_loaded), .x(x), .y(y)); 
	
	fillblank f0(.char(guess), .clk(clk), .resetn(resetn), .position(word), .fi(fill), .shift(s), .x(fillx), .y(filly), .done(done));
	
	drawparts d2(.part(part), .x(drawx), .y(drawy), .draw(draw), .finish(finish), .resetn(resetn), .clk(clk));
	clear c0(.resetn(resetn), .clk(clk),.xCounter(overx), .yCounter(overy)); 
	
	// reg color and (x, y)
	always @(posedge clk) begin
		if (resetn) begin
			color <= 0;
			x <= 0;
			y <= 0;
		end
		else begin
		if (ld) begin
			color <= 3'b111;// white
		end
		if (dash) begin// draw dashes
			color <= 3'b001;
			x <= dashx;
			y <= dashy;
		end
		else if (ld_g) begin
			color <= 3'b001; // blue
			x <= graphx;
			y <= graphy;
		end
		else if (fill) begin
			color <= 3'b010;// green
			x <= fillx;
			y <= filly;
		end
	// draw parts
		else if (draw) begin
			color <= 3'b100;// red
			x <= drawx;
			y <= drawy;
		end
	// wipe all the images
		else if (over) begin
			color <= 3'b000;// black
			x <= overx;
			y <= overy;
		end
	end
	reg [3:0] p1score, p2score;
	reg win, complete;
	// draw parts/endgame and register scores
	reg [2:0] part;
	always@(posedge clk) begin
		if (resetn) begin
			part <= 0; 
			complete <= 1'b0;
			p1score <= 0;
			win1 <= 0
		end
		else begin
			if (part == 3'b101) begin
				complete <= 1'b1;
				p1score <= p1score + 1;
				win1 <= 0
			end
			else if (draw) begin
				part <= part + 1;
				complete <= 1'b0;
				win1 <= 0
			end
			else if (timeout == 1'b1) begin
				p1score <= p1score + 1;		
			end
			else if (p1score == 4'b1001) begin
				p1score <= 0;
				win1 <= 1; //LEDR0
			end
			else begin
				win1 <= 0;
			end
		end
	end
	end
	// determine whether to continue or end game; win-lose state
	reg win2, continuous;
	always@(posedge clk) begin
		if (resetn) begin
			continuous <= 1'b0;
			p2score <= 0;
			win2 <= 0
		end
		else begin
			if (remain == 0) begin
				continuous <= 1'b0;
				p2score <= p2score + 1;
				win2 <= 0;
			end
			else if (p2score == 4'b1001) begin
				p2score <= 0;
				win2 <= 1;
			else begin
				continuous <= 1'b1;
				win2 <= 0;
			end
		end
	end

	Hexdecoder h2(p2score[3], p2score[2], p2score[1], p2score[0], .HEX(HEX0));
	Hexdecoder h1(p1score[3], p1score[2], p1score[1], p1score[0], .HEX(HEX1));
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
	output reg [7:0] xCounter,
	output reg [6:0] yCounter,
	);
	wire xCounter_clear, yCounter_clear;
	assign xCounter_clear = (xCounter == 8'b10011111);
	assign yCounter_clear = (yCounter == 7'b1110111); 
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			xCounter <= 10'd0;
			end
		else if (over) begin
			if (xCounter_clear) begin
				xCounter <= 10'd0;
			end
			else begin
				xCounter <= xCounter + 1'b1;
			end
		end
	end
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			yCounter <= 10'd0;
			end
		else if (over) begin
			if (xCounter_clear && yCounter_clear) begin
				yCounter <= 10'd0;
			end
			else if (xCounter_clear)	begin	//Increment when x counter resets
			yCounter <= yCounter + 1'b1;
			end
		end
	end
endmodule

