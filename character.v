
module fillblank(
	input [4:0] char,
	input clk, resetn
	input [4:0] position, 
	input fill,// read
	output [13:0] qout;
	);
	
	wire counter2_clear, counter1_clear, ld_p, p;
	assign counter1_clear = (counter1 == 3'b101);//+5
	assign counter2_clear = (counter2 == 3'b101); //+5
	reg [29:0] pout, pixel;
	reg [14:0] cell1, cell2, cell3, cell4, cell5, cell6, cell7, cell8, cell9, cell10;
	localparam a = 5'b00001;
	b = 5'b00010;
	c = 5'b00011;
	d = 5'b00100;
	e = 5'b00101;
	f = 5'b00110;
	g = 5'b00111;
	h = 5'b01000;
	i = 5'b01001;
	j = 5'b01010;
	k = 5'b01011;
	l = 5'b01100;
	m = 5'b01101;
	n = 5'b01110;
	o = 5'b01111;
	p = 5'b10000;
	q = 5'b10001;
	r = 5'b10010;
	s = 5'b10011;
	t = 5'b10100;
	u = 5'b10101;
	v = 5'b10110;
	w = 5'b10111;
	x = 5'b11000;
	y = 5'b11001;
	z = 5'b11010;
	
	
	always @(posedge clk)
	begin
		if (resetn) begin
			pout <= 0;
		end
		else 
		begin
			pout <= pixel;
		end
		else if (fill) 
		begin
			pout <= pout << 1'b1;
		end
	end
	assign p = pout[29];
	always @(*) begin
		if (resetn) begin
			pixel <= 0;
		else begin
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
			u: pixel = 30'b100011000110001100011000101110
			v: pixel = 30'b100011000110001100010101000100
			w: pixel = 30'b100011000110001101011010101010
			x: pixel = 30'b100010101000100010101000110001
			y: pixel = 30'b100011000101010001000010000100
			z: pixel = 30'b111110001000100010001000011111
		
		default: pixel = 30'd0;
	
	// cell 1
	always @(posedge clk) begin
		if (resetn) begin
			cell1 <= 0;
			qout1 <= 0;
		end
		else if (fill)begin
		cell1 <= {8'd17+counter1, 7'd95+counter2};
		end
		else begin
		cell1 <= {8'd17, 7'd95};
		end
	end
	// cell 2
	always @(posedge clk) begin
		if (resetn) begin
			cell2 <= 0;
			qout2 <= 0;
		end
		else if (fill)begin
		cell2 <= {8'd31+counter1, 7'd95+counter2};
		end
		else begin
		cell2 <= {8'd31, 7'd95};
		end
		
	end
	// cell 3
	always @(posedge clk) begin
		if (resetn) begin
			cell3 <= 0;

		end
		else if (fill)begin
		cell3 <= {8'd45+counter1, 7'd95+counter2};
		end
		else begin
		cell3 <= {8'd45, 7'd95};
		end
		
	end
	// cell 4
	always @(posedge clk) begin
		if (resetn) begin
			cell4 <= 0;

		end
		else if (fill)begin
		cell4 <= {8'd59+counter1, 7'd95+counter2};
		end
		else begin
		cell4 <= {8'd59, 7'd95};
		end
		
	end
	// cell 5
	always @(posedge clk) begin
		if (resetn) begin
			cell5 <= 0;

		end
		else if (fill)begin
		cell5 <= {8'd73+counter1, 7'd95+counter2};
		end
		else begin
		cell5 <= {8'd73, 7'd95};
		end
	end
	// cell 6
	always @(posedge clk) begin
		if (resetn) begin
			cell6 <= 0;
		end
		else if (fill)begin
		cell6 <= {8'd87+counter1, 7'd95+counter2};
		end
		else begin
		cell6 <= {8'd87, 7'd95};
		end
	end
	// cell 7
	always @(posedge clk) begin
		if (resetn) begin
			cell7 <= 0;

		end
		else if (fill)begin
		cell7 <= {8'd101+counter1, 7'd95+counter2};
		end
		else begin
		cell7 <= {8'd101, 7'd95};
		end
	end
	// cell 8
	always @(posedge clk) begin
		if (resetn) begin
			cell8 <= 0;

		end
		else if (fill)begin
		cell8 <= {8'd115+counter1, 7'd95+counter2};
		end
		else begin
		cell8 <= {8'd115, 7'd95};
		end
	end
	// cell 9
	always @(posedge clk) begin
		if (resetn) begin
			cell9 <= 0;

		end
		else if (fill)begin
		cell9 <= {8'd129+counter1, 7'd95+counter2};
		end
		else begin
		cell9 <= {8'd129, 7'd95};
		end
	end
	// cell 10
	always @(posedge clk) begin
		if (resetn) begin
			cell10 <= 0;

		end
		else if (fill)begin
		cell10 <= {8'd143+counter1, 7'd95+counter2};
		end
		else begin
		cell10 <= {8'd143, 7'd95};
		end
	end

	
	always @(posedge clk) begin
		if (resetn) begin
			qout <= 0;
		end
		case(position) begin
			5'b00001: begin
				qout <= p ? cell1 : qout;
			end
			5'b00010: begin
				qout <= p ? cell2 : qout;
			end
			5'b00011: begin
				qout <= p ? cell3 : qout;
			end
			5'b00100: begin
				qout <= p ? cell4 : qout;
			end
			5'b00101: begin
				qout <= p ? cell5 : qout;
			end
			5'b00110: begin
				qout <= p ? cell6 : qout;
			end
			5'b00111: begin
				qout <= p ? cell7 : qout;
			end
			5'b01000: begin
				qout <= p ? cell8 : qout;
			end
			5'b01001:begin
				qout <= p ? cell9 : qout;
			end
			5'b01010: begin
				qout <= p ? cell10 : qout;
			end 
		endcase
		end
	end			
	
	always @(posedge clk) begin
		if (resetn) begin
			counter1 <= 0;
		end
		else if (counter1_clear) begin
				counter1 <= 0;
			end
		 	else if (fill) begin
				counter1 <= counter1 + 1;
			end
	end
	always @(posedge clk) begin
		if (resetn) begin
			counter2 <= 0;
		end
		else if (counter1_clear) begin
				counter2 <= counter2 + 1;
			end
		else if (counter2_clear && counter1_clear) begin
				counter2 <= 0
			end
	end
endmodule
	
	
	
	
	
	