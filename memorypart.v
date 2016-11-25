module memorypart(clk, resetn, ld, compare, ld_g, fill, wren, rden, char, guess);
	input clk, resetn, ld, compare, fill, wren, rden;
	input [4:0] char;
	input [4:0] guess;
	input ld_g;
	reg [4:0] rdaddress; // The address we will read from
	reg [4:0] wraddress;
	reg [4:0] guesschar;
	reg dash;
	reg [4:0] inputs;
	reg [4:0] word;
	reg [4:0] length;
	reg [4:0] count;
	reg [4:0] wraddress2;
	reg [4:0] wraddress1;
	reg [4:0] position;
	reg match;
	reg filled;
	reg qout;
	reg [4:0] remain;
	always @ (posedge clk) begin
		if (resetn) begin
			dash <= 1'b0; // dash is the underscore below every char
		end
		else if (ld == 1) begin
			// rden is the signal to enable read
			// wren is the signal to enable write
			dash <= 1'b1;
			end
	end
	
	dualportram d0(.clock(clk), .data(inputs), .rdaddress(rdaddress), 
			.rden(rden), .wraddress(wraddress), .wren(wren), .q(word));
	fillblank f1(.resetn(resetn), .clk(clk), .fill(fill), .position(word), .char(guess), .qout(qout));
	
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
	
		// This also can be treated as the length of the words
							// since we write the chars to memory start from 1
	always @ (posedge ld, negedge resetn)
		begin
			if (resetn == 1'b0) begin
				wraddress1 <= 5'd0;
			end
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
		else if (compare == 1'b1) begin
			if (rdaddress >= length) begin
				rdaddress <= 5'b00000;
				loopend <= 1'b1;
			end
			else begin
				rdaddress <= rdaddress + 1;
				loopend <= 1'b0;
			end
		end
		else if (fill == 1'b1) begin
				rdaddress <= wraddress2 + count;
		end
	end
	
	
	always @ (posedge clk) begin
		if (resetn) begin
			guesschar <= 5'b0;
			count <= 0; // The number of chars in the word; 
			wraddress2 <= 5'b11111; // We save the memory address to the wraddress2
			position <= 5'b00000;
		end
		else if (compare == 1'b1) begin
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
					else begin
						match <= 1'b0;
					end
				end
			end
		end
		else if (fill) begin
			if (count != 0) begin
				count <= count -1;
				filled <= 1'b0; 
			end
//fill blank
			else begin
			wraddress2 <= 5'b11111;
			filled <= 1'b1;
			end
		end
	end

	
	always @(posedge clk) begin
		if (ld_g == 1'b1) begin
			length <= wraddress1;
			remain <= length;
		end
		else if(loopend == 1'b1) begin
			remain <= remain - count;
		end
	end
		
	
	
	always @(*) begin
		if (ld) begin
			wraddress = wraddress1;
		end
		else if (compare) begin
			wraddress = wraddress2;
		end
	end
endmodule