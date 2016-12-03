module character
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	assign writeEn = 1'b1;
	
	wire [5:0] bus;
	wire [1:0] data;
	wire go, dash;
	wire [14:0] q;
	assign fill = ~KEY[1];
	
	fillblank f0(.clk(CLOCK_50), .resetn(resetn),  .fill(fill),.char(SW[4:0]), .position(SW[9:5]), .qout(q), .color(colour), .done(go));
	assign x = q[14:7];
	assign y = q[6:0];
endmodule

module fillblank(
	input [4:0] char,
	input clk, resetn,
	input [4:0] position, 
	input fill,// read
	output [14:0] qout,
	output done
	);
	wire p;
	shiftr s0(.resetn(resetn), .clk(clk), .fill(fill), .char(char), .p(p), .shift(shift));
	cells c0(.resetn(resetn), .clk(clk), .fill(shift), .position(position), .done(done));
	always @(posedge clk) begin
		if (resetn) begin
			qout <= 0;
			color <= 3'b000;
		end
		else if (p) begin
			qout <= cells;
			color <= 3'b010;
		end
	end			

endmodule
module shiftr(
	input resetn, clk, 
	input [4:0] char, 
	output p);
	
	reg [29:0] pixel;
	localparam a = 5'b00001,
	b = 5'b00010,
	c = 5'b00011,
	d = 5'b00100,
	e = 5'b00101,
	f = 5'b00110,
	g = 5'b00111,
	h = 5'b01000,
	i = 5'b01001,
	j = 5'b01010,
	k = 5'b01011,
	l = 5'b01100,
	m = 5'b01101,
	n = 5'b01110,
	o = 5'b01111,
	p = 5'b10000,
	q = 5'b10001,
	r = 5'b10010,
	s = 5'b10011,
	t = 5'b10100,
	u = 5'b10101,
	v = 5'b10110,
	w = 5'b10111,
	x = 5'b11000,
	y = 5'b11001,
	z = 5'b11010;

	always @(*) begin
			case(char)
			a: pixel = 30'b011101000110001111111000110001;
			b: pixel = 30'b111101000111110100011000111110;
			c: pixel = 30'b011101000110000100001000101110;
			d: pixel = 30'b111101000110001100011000111110;
			e: pixel = 30'b111111000011100100001000011111;
			f: pixel = 30'b111111000010000111001000010000;
			g: pixel = 30'b011101000110000101111000101110;
			h: pixel = 30'b100011000111111100011000110001;
			i: pixel = 30'b011100010000100001000010001110;
			j: pixel = 30'b001110001000010000101001001100;
			k: pixel = 30'b100011001010100101001001010001;
			l: pixel = 30'b100001000010000100001000011111;
			m: pixel = 30'b100011101110101100011000110001;
			n: pixel = 30'b100011100110101100111000110001;
			o: pixel = 30'b011101000110001100011000101110;
			p: pixel = 30'b111101000110001111101000010000;
			q: pixel = 30'b011101000110001101011001001101;
			r: pixel = 30'b111101000111110101001001010001;
			s: pixel = 30'b011111000001110000010000111110;
			t: pixel = 30'b111110010000100001000010000100;
			u: pixel = 30'b100011000110001100011000101110;
			v: pixel = 30'b100011000110001100010101000100;
			w: pixel = 30'b100011000110001101011010101010;
			x: pixel = 30'b100010101000100010101000110001;
			y: pixel = 30'b100011000101010001000010000100;
			z: pixel = 30'b111110001000100010001000011111;
		endcase
	end
	reg [29:0] pout;
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			pout <= 0;
		end
		else if (fill)
		begin
			pout <= pixel;
			shift <= 1;
		end
		else if (fill && shift) 
		begin
			pout <= pout << 1'b1;
		end
	end
	assign p = pout[29];

endmodule 
module cells(
	input resetn, clk,
	input [4:0] position,
	output [14:0] cells,
	output done)

	wire counter2_clear, counter1_clear, p;
	assign counter1_clear = (counter1 == 3'b100);//+5
	assign counter2_clear = (counter2 == 3'b100); //+5
	
	always @(*) begin
		case(position)
			5'd1: coord = {8'd17, 7'd95};
			5'd2: coord = {8'd31, 7'd95};
			5'd3: coord = {8'd45, 7'd95};
			5'd4: coord = {8'd59, 7'd95};
			5'd5: coord = {8'd73, 7'd95};
			5'd6: coord = {8'd87, 7'd95};
			5'd7: coord = {8'd101, 7'd95};
			5'd8: coord = {8'd115, 7'd95};
			5'd9: coord = {8'd129, 7'd95};
			5'd10: coord = {8'd129, 7'd95};
		endcase
	end

	reg [14:0] cells;
	// cell 1
	always @(posedge clk) begin
		if (resetn) begin
			cells <= 0;
		end
		else if (fill)begin
		cells <= {coord[14:7]+counter1, coord[6:0]+counter2};
		end
	end

	
	always @(posedge clk) begin
		if (resetn) begin
			counter2 <= 0;
			done <= 0;
			counter1 <= 0;
		end
		else if (fill) begin
			if (!counter2_clear && counter1_clear) begin
				counter2 <= counter2 + 1;
				counter1 <= 0;
				done <= 0;
			end
			else if (counter2_clear && counter1_clear) begin
				counter2 <= 0;
				counter1 <= 0;
				done <= 1;
			end
			else begin
			counter1 <= counter1 +1;
			end
		end
	end
endmodule
	
	
	
	
	
	