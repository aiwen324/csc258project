module control(
	input clk,
	input resetn,
	input load, endinput, start, wipe, try // from keyboard
	input timeout, finish, complete, continuous, graph_loaded, match,// from datapath
	output reg writeorread, timecount, compare, fill, draw, over, ld_g, wren // to datapath
	output reg plot, // writeEn to vga to change color
	output reg[3:0] part, p2score, p1score
	);
	
	reg [4:0] remain;
	reg [3:0] current_state, next_state;
	reg continuous, complete;

	localparam S_LOAD_C = 4'b0000, // load
		  S_WAIT_C = 4'b0001,   // end, inside counter
		  S_LOAD_GRAPH = 4'b0010,  // start
		  S_WAIT_GRAPH = 4'b0011,	//wait for input, try
	          S_LOAD_G = 4'b0100, // match
	          S_LOAD_G_WAIT = 4'b0101
	          S_FILL_BLANK = 4'b0110,
	          S_FILL_BLANK_WAIT = 4'b0111,
		  	  S_DRAW = 4'b1000, // inside counter
		  	  S_DRAW_WAIT = 4'b1001,
		  S_WIN = 4'b1010,
		  S_GRAPHOUT = 4'b1011,
		  S_TIMEOUT = 4'b1100;

	always@(*)
	begin: state_table
		case(current_state)
			S_LOAD_C:
				if (load == 1) begin
					next_state = S_WAIT_C;
				end
				else if(endinput == 1) begin
					next_state = S_LOAD_GRAPH;  // use 'End' on keyboard to control the endinput
				end
				else if(load == 0 || endinput == 0) begin
					next_state = S_LOAD_C;
				end
			S_WAIT_C: next_state = load ? S_WAIT_C : S_LOAD_C; 
			S_LOAD_GRAPH: next_state = start ? S_WAIT_GRAPH : S_LOAD_GRAPH; // timecounter
			S_WAIT_GRAPH: next_state = graph_loaded ? S_LOAD_G : S_WAIT_GRAPH; // register misses???   // use "Insert" to control the endinput
			S_LOAD_G: next_state = try ? S_LOAD_G_WAIT : S_LOAD_G;  // some key
			S_LOAD_G_WAIT: 
				if (timeout) begin
					next_state = S_TIMEOUT;
				end
				else begin
					next_state = match ? S_FILL_BLANK : S_DRAW ; // comparator; output match and count (misses)
				end
			S_FILL_BLANK: next_state = filled ? S_FILL_BLANK_WAIT: S_FILL_BLANK; //output cont; fill char
			S_FILL_BLANK_WAIT: next_state = continuous? S_LOAD_G : S_WIN;  //
			S_DRAW: next_state = finish ? S_DRAW_WAIT : S_DRAW; // draw parts
			S_DRAW_WAIT: next_state = complete ? S_GRAPHOUT : S_LOAD_G; // finish drawing
			S_WIN: next_state = wipe? S_LOAD_C : S_WIN; // Use "Delete" to control the restart of game
			//S_WIN: next_state = S_LOAD_C; // flash
			S_GRAPHOUT: next_state = wipe ? S_LOAD_C : S_GRAPHOUT; // flash 
			S_TIMEOUT: next_state = wipe? S_LOAD_C : S_GRAPHOUT; // ASYNC, flash
			default: next_state = S_LOAD_C;
		endcase
	end
	always @(*)
	begin: enable_signals
		// By default make all out signals 0
		writeorread = 1'b0;
		timecount = 1'b0;
		compare = 1'b0;
		fill = 1'b0;
		draw = 1'b0;
		over = 1'b0;
		ld_g = 1'b0;
		rden = 1'b0;
		wren = 1'b0;
		plot = 1'b0;

		case(current_state)
			S_LOAD_C: begin
				writeorread = 1'b1; 
				wren = 1'b1;
				ld = 1'b1; 
				plot = 1'b1;
			end	
	        S_LOAD_GRAPH: begin
				ld_g = 1'b1;
				plot = 1'b1;
			end
		  	S_WAIT_GRAPH: begin
				timecount = 1'b1;
			end
			S_LOAD_G: begin
				compare = 1'b1;
				timecount = 1'b1;
				writeorread = 1'b1;
				wren = 1'b1;
				rden = 1'b1;
			end
      		S_FILL_BLANK: begin
				fill = 1'b1;
				timecount = 1'b1;
				plot = 1'b1;
				writeorread = 1'b1;
				rden = 1'b1;
			end
		  	S_DRAW: begin
				draw = 1'b1;
				timecount = 1'b1;
				plot = 1'b1;
			end
			S_WIN: begin
				timecount = 1'b0;
				over = wipe ? 1'b1 : 1'b0;
				plot = 1'b1;
			end
			S_GRAPHOUT: begin
				timecount = 1'b0;
				over = wipe ? 1'b1 : 1'b0;
				plot = 1'b1;
			end
			S_TIMEOUT: begin
				timecount = 1'b0;
				over = wipe ? 1'b1 : 1'b0;
				plot = 1'b1;
			end
		endcase
	end
		
	
	// current_state registers
	always@(posedge clk, negedge resetn) begin
		if(resetn)
			current_state <= S_LOAD_C;
		else 
			current_state <= next_state;
	end
endmodule