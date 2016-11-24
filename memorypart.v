module memorypart(clk, resetn, ld, compare, fill, wren, rden, writeorread, char, guess);
	input clk, resetn, ld, compare, fill, wren, rden, writeorread;
	input [4:0] char;
	input [4:0] guess;
	reg [4:0] rdaddress; // The address we will read from
	reg [4:0] wraddress;
	reg [4:0] guesschar;
	
	always @ (posedge clk) begin
		if (resetn) begin
			dash <= 1'b0; // dash is the underscore below every char
		end
		else if (writeorread == 1) begin
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
	
	
	reg [4:0] wraddress1;	// This also can be treated as the length of the words
							// since we write the chars to memory start from 1
	always @ (posedge writeorread, posedge resetn)
		begin
			if (resetn == 1'b1) begin
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
	
	
	reg [4:0] position;
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
	always @(clk) begin
		if (ld_g = 1'b1) begin
			length <= wraddress1;
			remain <= length;
		end
		else if(loopend == 1'b1) begin
			remain <= remain - count;
	end
		
	
	
	always @(*) begin
		if (ld) begin
			wraddress = wraddress1;
		end
		else if (compare) begin
			wraddress = wraddress2;
		end
	end