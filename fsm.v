module tmptopmod(clk, resetn, load, finish, endinput, start, timeout, match, wipe, filled, continuous, complete, try, fill, draw, over,
				ld, timecount, ldguessinput, compare, ldgraph, address);
	input clk;
	input resetn; // a key
	input load; // the key to load the input
	input finish; // the key to start the input from guesser
	input endinput; // the key end the input
	input start;  // the key to start the game, it will make state initialize the timecounter
	input timeout; // the ffedback timeout signal from datapath(this will be the fake signal in demo1)
	input match; // the match feedback from datapath(this will be the fake signal in demo1)
	input wipe; // Command from player, it will be some keys
	input try; // let ldguessinput signal be 1
	input complete; // feedback from datapath, (it will be the fake signal in this demo1)
	input filled; // fake signal
	input continuous; //fake signal
	output reg ldguessinput;
	output reg fill; 
	output reg draw;
	output reg over;
	output reg ld;  // output signal to let datapath make memory load the value
	output reg timecount; // let timecounter to start count
	output reg compare;  // let datapath to start compare the value
	output reg ldgraph; // let datapath to load the graph
	output reg [4:0] address; // it should be in datapath, but to make it easier for test, this time is in the fsm
	
	
	reg [3:0] current_state, next_state;
	
	
	localparam S_LOAD_C = 4'b0000, // load
		  S_WAIT_C = 4'b0001,   // end, inside counter
		  S_LOAD_GRAPH = 4'b0010,  // start
		  S_WAIT_GRAPH = 4'b0011,	//wait for input, finish
	      S_LOAD_G = 4'b0100, // match
		  S_LOAD_G_WAIT = 4'b1000,
	      S_FILL_BLANK = 4'b0101,
	      S_FILL_BLANK_WAIT = 4'b0110,
		  S_DRAW = 4'b0111, // inside counter
		  S_WIN = 4'b1001,
		  S_GRAPHOUT = 4'b1010,
		  S_TIMEOUT = 4'b1011;


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
				else if(load == 0) begin
					next_state = S_LOAD_C;
				end
			S_WAIT_C: next_state = load ? S_WAIT_C : S_LOAD_C; 
			S_LOAD_GRAPH: next_state = start ? S_WAIT_GRAPH : S_LOAD_GRAPH; // timecounter
			S_WAIT_GRAPH: next_state = finish ? S_LOAD_G : S_WAIT_GRAPH; // register misses???   // use "Insert" to control the endinput
			S_LOAD_G: next_state = try ? S_LOAD_G_WAIT: S_LOAD_G;
			S_LOAD_G_WAIT:
				if (timeout) begin
					next_state = S_TIMEOUT;
				end
				else begin
					next_state = match ? S_FILL_BLANK : S_DRAW ; // comparator; output match and count (misses)
				end
			S_FILL_BLANK: next_state = filled ? S_FILL_BLANK_WAIT: S_FILL_BLANK; //output continuous; fill char
			S_FILL_BLANK_WAIT: next_state = continuous? S_LOAD_G : S_WIN;  //
			S_DRAW: next_state = complete ? S_GRAPHOUT : S_LOAD_G; // draw parts
			S_WIN: next_state = wipe? S_LOAD_C : S_WIN; // Use "Delete" to control the restart of game
			S_GRAPHOUT: next_state = wipe ? S_LOAD_C : S_GRAPHOUT; // flash 
			S_TIMEOUT: next_state = wipe? S_LOAD_C : S_GRAPHOUT; // ASYNC, flash
			default: next_state = S_LOAD_C;
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
		ldguessinput = 1'b0;
		ldgraph = 1'b0;

		case(current_state) 
		S_LOAD_C: begin
				ld = 1'b1; 
			end
		/*S_WAIT_C: begin
				wordcount = wordcount +1;
			end*/
	    S_LOAD_GRAPH: begin
				ldgraph = 1'b1; // it will load the graph of basic things
			end
		S_WAIT_GRAPH: begin
				timecount = 1'b1; // it will let the display time to 
			end
		S_LOAD_G: begin
				ldguessinput = 1'b1; // it will let the reg in datapath to load the input
				timecount = 1'b1;
			end
		S_LOAD_G_WAIT: begin
				compare = 1'b1; // it will compare the value of register and the input
				timecount = 1'b1;
			end
      	S_FILL_BLANK: begin
				fill = 1'b1;
				timecount = 1'b1;
			end
		S_DRAW: begin
				draw = 1'b1;
				timecount = 1'b1;
			end
		S_WIN: begin
				over = 1'b1;
				timecount = 1'b0;
			end
		S_FILL_BLANK_WAIT: begin
				timecount = 1'b1;
			end
		S_GRAPHOUT: begin
				over = 1'b1;
				timecount = 1'b0;
			end
		S_TIMEOUT: begin 
				over = 1'b1;
				timecount = 1'b0;
			end
		endcase
	end
	
	always @ (posedge ld, posedge resetn)
		begin
			if (resetn == 1'b1) begin
				address <= 5'd0;
			end
			else begin
				address <= address + 1;
			end
		end
	

		
	// current_state registers
	always@(posedge clk) begin
		if(resetn)
			current_state <= S_LOAD_C;
		else 
			current_state <= next_state;
	end
endmodule