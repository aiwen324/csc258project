module control(
	input clk,
	input resetn,
	input load, try, endinput, start, timeout, 
	input match, count // feedback from datapath
	output reg ld, timecount, compare, 
	output reg [4:0] wordcount,
	output reg[3:0] part, p2score, p1score
	);
	
	reg [4:0] remain;
	reg [3:0] current_state, next_state;
	reg continue, complete;

	localparam S_LOAD_C = 4'b0000, // load
		  S_WAIT_C = 4'b0001,   // end, inside counter
		  S_LOAD_GRAPH = 4'b0010,  // start
		  S_WAIT_GRAPH = 4'b0011,	//wait for input, try
	          S_LOAD_G = 4'b0100, // match
	          S_FILL_BLANK = 4'b0101,
	          S_FILL_BLANK_WAIT = 4'b0110,
		  	  S_DRAW = 4'b0111, // inside counter
		  S_DRAW_WAIT = 4'b1000,
		  S_WIN = 4'b1001,
		  S_GRAPHOUT = 4'b1010,
		  S_TIMEOUT = 4'b1011;


	always@(*)
	begin: state_table
		case(current_state)
			S_LOAD_C:
				if (load) begin
					next_state = S_WAIT_C;
				end
				else if(endinput) begin
					next_state = S_LOAD_GRAPH;  // use 'End' on keyboard to control the endinput
				end
			S_WAIT_C: next_state = load ? S_WAIT_C : S_LOAD_C; 
			S_LOAD_GRAPH: next_state = start ? S_WAIT_GRAPH : S_LOAD_GRAPH; // timecounter
			S_WAIT_GRAPH: next_state = try ? S_LOAD_G : S_WAIT_GRAPH; // register misses???   // use "Insert" to control the endinput
			S_LOAD_G: 
				if (timeout) begin
					next_state = S_TIMEOUT;
				end
				else begin
					next_state = match ? S_FILL_BLANK : S_DRAW ; // comparator; output match and count (misses)
				end
			S_FILL_BLANK: next_state = filled ? S_FILL_BLANK_WAIT: S_FILL_BLANK; //output continue; fill char
			S_FILL_BLANK_WAIT: next_state = continue ? S_LOAD_G : S_WIN;  //
			S_DRAW: next_state = complete ? S_GRAPHOUT : S_LOAD_G; // draw parts
			S_WIN: next_state = wipe? S_LOAD_C : S_WIN; // Use "Delete" to control the restart of game
			//S_WIN: next_state = S_LOAD_C; // flash
			S_GRAPHOUT: next_state = wipe ? S_LOAD_C : S_GRAPHOUT; // flash 
			S_TIMEOUT: next_state = wipe? S_LOAD_C : S_GRAPHOUT; // ASYNC, flash
			default: next_state = S_LOAD_X;
		endcase
	end
	always @(*)
	begin: enable_signals
		// By default make all out signals 0
		ld = 1'b0;
		timecount = 1'b0;
		compare = 1'b0;
		fill = 1'b0;
		draw = 1'b0;
		over = 1'b0;

		case(current_state)
		S_LOAD_C: begin
				ld = 1'b1; 
			end	
		//	S_WAIT_C: begin
		//		wordcount <= wordcount +1;
		//		end	
	        S_LOAD_GRAPH: begin
				ldgraph = 1'b1; // it will load the graph of basic things
			end
		S_WAIT_GRAPH: begin
				timecount = 1'b1; // it will let the display time to 
			end
		S_LOAD_G: begin
				compare = 1'b1; // it will compare the value of register and the input
			end
      		S_FILL_BLANK: begin
				fill = 1'b1;
		//		count <= count -1;   // Probably don't need this
			end
		S_DRAW: begin
				draw = 1'b1;
		//		part <= part+1;
			end
			S_WIN: begin
		//		p2score <= p2score + 1;
				over = 1'b1;
			end
			S_GRAPHOUT: begin
		//		p1score <= p1score + 1;
				over = 1'b1;
			end
			S_TIMEOUT: begin
		//		p1score <= p1score + 1;
				over = 1'b1;
			end
		endcase
	end
	
	always@(posedge clk, negedge resetn) begin
		if (resetn)
			wordcount <= 0;
		else if (load) begin
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
				if (count == 0) begin
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
	
	
	// current_state registers
	always@(posedge clk, negedge resetn) begin
		if(resetn)
			current_state <= S_LOAD_C;
		else 
			current_state <= next_state;
	end
endmodule
