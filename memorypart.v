module memorypart(clk, resetn, ld, compare, ld_g, fill, wren, rden, char, guess, loadguessvalue,
					filled, remain);
	input clk, resetn, ld;
	input ld_g;
	input loadguessvalue, compare, fill, wren, rden;
	input [4:0] char;
	input [4:0] guess;
	reg [4:0] rdaddress; // The address we will read from
	reg [4:0] wraddress; // The write address we will write to memory
	reg [4:0] guesschar; // The guesser's guess char
	reg [4:0] inputs; // the input we will write to memory(char and position in different stage)
	wire [4:0] word; // The output of memory
	reg [4:0] length; // length of the word we will guess
	reg [4:0] count; // The duplicated numbers of char in one guess
	reg [4:0] wraddress2; // The write address of position(start from 31th, 5'b00001)
	reg [4:0] wraddress1; // The write address of the chars we will guess
	reg [4:0] position; // We will write position(memory address of matching chars) 
						// to memory(we will write start from 31th words)
	reg match; // The signal to tell the guess chars does match one of the chars save in memory
	output reg filled; // The signal to tell the blank need to fill has been filled and goes to the next status
	output reg [4:0] remain; // The output signal we have on how much chars left the guesser doesn't guess correctly
	reg loopend; // The signal to tell the end of loop when we find the same chars as guesser's input
	// TODO: Change the loopend timing, let threshold be len + 2 or 1 or something
	// TODO: Change the position value, let it minus 1 or minus 2
	// TODO: Don't forget to merge the fucking file
	
	dualportram d0(.clock(clk), .data(inputs), .rdaddress(rdaddress), 
			.rden(rden), .wraddress(wraddress), .wren(wren), .q(word));
	// The memory we will save and read data
	
	
	// This is the block to change the input we write to memory
	// 1. resetn should let inputs to be 0;
	// 2. ld should let inputs to be the char;
	// 3. compare should let the inputs to be the memory address(position).
	//always @ (posedge clk) begin
	always @ (*) begin
		if (resetn) begin
			inputs = 0;
		end
		else if (ld) begin
			inputs = char;
		end
		else if (compare) begin
			if (position == 5'b00001) begin
				inputs = length - 5'b00001;
			end
			else if (position == 5'b00010) begin
				inputs = length;
			end
			else if (position == 0) begin
				inputs = 0;
			end
			else begin
			inputs = position - 5'b00010;
			end
		end
	end
	
	// This block change the wraddress1 
	// where we will write chars to by listening the posedge of ld signal.
	// This also can be treated as the length of the words
	// since we write the chars to memory start from 1
	always @ (posedge ld, negedge resetn)
		begin
			if (resetn == 1'b1) begin
				wraddress1 <= 5'd0;
			end
			else begin
				wraddress1 <= wraddress1 + 1;
			end
		end
			

	
	// This block changes the rdaddress
	// 1. in the compare it will read from 1 to the length of the word
	// 2. in the fill part it will be wraddress2 + count which is the memory address we have for position
	reg flag;
	reg [4:0] rdaddress2;
	always @ (posedge clk) begin
		if (resetn) begin
			rdaddress2 <= 5'b00001;
			loopend <= 1'b0;
			
		end
		if (loadguessvalue) begin
			rdaddress2 <= 5'b00001;
			loopend <= 1'b0;
		end
		else if (compare == 1'b1) begin
			if (rdaddress2 >= length) begin
				rdaddress2 <= 5'b00001;
				loopend <= 1'b1;
			end
			else begin
				rdaddress2 <= rdaddress2 + 1;
				loopend <= 1'b0;
			end
		end
		else if (fill == 1'b1) begin
			if (count > 0) begin
				rdaddress2 <= wraddress2 + count;
			end
		end
	end
	
	always @(posedge clk) begin
		if (resetn) begin
			flag <= 1'b0;
		end
		else if (loadguessvalue) begin
			flag <= 1'b0;
		end
		else if (loopend) begin
			flag <= 1'b1;
		end
	end
	
	
	always @ (*) begin
		if (resetn) begin
			rdaddress = 5'b0;
		end
		else if (compare || fill) begin
			rdaddress = rdaddress2;
		end
		else begin
			rdaddress = wraddress1;
		end
	end
	
	// This is the block we load guess value to the register guesschar.
	// This fix some problem so maybe it's helpful to change the initial
	// value of rdaddress to 1 instead 0, since looks like we won't miss a loop
	always @ (*) begin
		if (resetn) begin
			guesschar = 0;
		end
		else if (loadguessvalue) begin
			guesschar = guess;
		end
	end
	
	
	
	always @ (posedge clk) begin
		if (resetn) begin
			guesschar <= 5'b0;
			count <= 0; // The number of chars in the word
			wraddress2 <= 5'b11111; // We save the memory address to the wraddress2
			position <= 5'b00000;
		end
		else if (compare == 1'b1) begin
			match <= 1'b0;
			//guesschar <= guess These 2 lines will be implemented in the same cycle, so we decide to 
			if (guesschar == word && flag != 1) begin // change the start of rdaddress to 0 instead of 1
				count <= count + 1;
				position <= rdaddress;
				wraddress2 <= wraddress2 - 5'b00001; 
			end
			if (loopend == 1'b1) begin
					if (count != 0) begin
						match <= 1'b1;
					end
					else begin
						match <= 1'b0;
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

	// This block let the length be given value as wraddress1
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
		else if (loadguessvalue) begin
			wraddress = 0;
		end
		else if (compare) begin
			if (wraddress2 < 5'b11111) begin
				wraddress = wraddress2 + 1;
			end
		end
	end
endmodule
// megafunction wizard: %RAM: 2-PORT%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: altsyncram 

// ============================================================
// File Name: dualportram.v
// Megafunction Name(s):
// 			altsyncram
//
// Simulation Library Files(s):
// 			altera_mf
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 16.0.0 Build 211 04/27/2016 SJ Lite Edition
// ************************************************************


//Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, the Altera Quartus Prime License Agreement,
//the Altera MegaCore Function License Agreement, or other 
//applicable license agreement, including, without limitation, 
//that your use is for the sole purpose of programming logic 
//devices manufactured by Altera and sold by Altera or its 
//authorized distributors.  Please refer to the applicable 
//agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module dualportram (
	clock,
	data,
	rdaddress,
	rden,
	wraddress,
	wren,
	q);

	input	  clock;
	input	[4:0]  data;
	input	[4:0]  rdaddress;
	input	  rden;
	input	[4:0]  wraddress;
	input	  wren;
	output	[4:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock;
	tri1	  rden;
	tri0	  wren;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [4:0] sub_wire0;
	wire [4:0] q = sub_wire0[4:0];

	altsyncram	altsyncram_component (
				.address_a (wraddress),
				.address_b (rdaddress),
				.clock0 (clock),
				.data_a (data),
				.rden_b (rden),
				.wren_a (wren),
				.q_b (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b ({5{1'b1}}),
				.eccstatus (),
				.q_a (),
				.rden_a (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_b = "NONE",
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 32,
		altsyncram_component.numwords_b = 32,
		altsyncram_component.operation_mode = "DUAL_PORT",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_b = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.rdcontrol_reg_b = "CLOCK0",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = 5,
		altsyncram_component.widthad_b = 5,
		altsyncram_component.width_a = 5,
		altsyncram_component.width_b = 5,
		altsyncram_component.width_byteena_a = 1;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: ADDRESSSTALL_A NUMERIC "0"
// Retrieval info: PRIVATE: ADDRESSSTALL_B NUMERIC "0"
// Retrieval info: PRIVATE: BYTEENA_ACLR_A NUMERIC "0"
// Retrieval info: PRIVATE: BYTEENA_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_ENABLE_A NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_ENABLE_B NUMERIC "0"
// Retrieval info: PRIVATE: BYTE_SIZE NUMERIC "8"
// Retrieval info: PRIVATE: BlankMemory NUMERIC "1"
// Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_A NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_INPUT_B NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_A NUMERIC "0"
// Retrieval info: PRIVATE: CLOCK_ENABLE_OUTPUT_B NUMERIC "0"
// Retrieval info: PRIVATE: CLRdata NUMERIC "0"
// Retrieval info: PRIVATE: CLRq NUMERIC "0"
// Retrieval info: PRIVATE: CLRrdaddress NUMERIC "0"
// Retrieval info: PRIVATE: CLRrren NUMERIC "0"
// Retrieval info: PRIVATE: CLRwraddress NUMERIC "0"
// Retrieval info: PRIVATE: CLRwren NUMERIC "0"
// Retrieval info: PRIVATE: Clock NUMERIC "0"
// Retrieval info: PRIVATE: Clock_A NUMERIC "0"
// Retrieval info: PRIVATE: Clock_B NUMERIC "0"
// Retrieval info: PRIVATE: IMPLEMENT_IN_LES NUMERIC "0"
// Retrieval info: PRIVATE: INDATA_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: INDATA_REG_B NUMERIC "0"
// Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_B"
// Retrieval info: PRIVATE: INIT_TO_SIM_X NUMERIC "0"
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: PRIVATE: JTAG_ENABLED NUMERIC "0"
// Retrieval info: PRIVATE: JTAG_ID STRING "NONE"
// Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
// Retrieval info: PRIVATE: MEMSIZE NUMERIC "160"
// Retrieval info: PRIVATE: MEM_IN_BITS NUMERIC "0"
// Retrieval info: PRIVATE: MIFfilename STRING ""
// Retrieval info: PRIVATE: OPERATION_MODE NUMERIC "2"
// Retrieval info: PRIVATE: OUTDATA_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: OUTDATA_REG_B NUMERIC "1"
// Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "0"
// Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_MIXED_PORTS NUMERIC "2"
// Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_PORT_A NUMERIC "3"
// Retrieval info: PRIVATE: READ_DURING_WRITE_MODE_PORT_B NUMERIC "3"
// Retrieval info: PRIVATE: REGdata NUMERIC "1"
// Retrieval info: PRIVATE: REGq NUMERIC "1"
// Retrieval info: PRIVATE: REGrdaddress NUMERIC "1"
// Retrieval info: PRIVATE: REGrren NUMERIC "1"
// Retrieval info: PRIVATE: REGwraddress NUMERIC "1"
// Retrieval info: PRIVATE: REGwren NUMERIC "1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: USE_DIFF_CLKEN NUMERIC "0"
// Retrieval info: PRIVATE: UseDPRAM NUMERIC "1"
// Retrieval info: PRIVATE: VarWidth NUMERIC "0"
// Retrieval info: PRIVATE: WIDTH_READ_A NUMERIC "5"
// Retrieval info: PRIVATE: WIDTH_READ_B NUMERIC "5"
// Retrieval info: PRIVATE: WIDTH_WRITE_A NUMERIC "5"
// Retrieval info: PRIVATE: WIDTH_WRITE_B NUMERIC "5"
// Retrieval info: PRIVATE: WRADDR_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: WRADDR_REG_B NUMERIC "0"
// Retrieval info: PRIVATE: WRCTRL_ACLR_B NUMERIC "0"
// Retrieval info: PRIVATE: enable NUMERIC "0"
// Retrieval info: PRIVATE: rden NUMERIC "1"
// Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
// Retrieval info: CONSTANT: ADDRESS_ACLR_B STRING "NONE"
// Retrieval info: CONSTANT: ADDRESS_REG_B STRING "CLOCK0"
// Retrieval info: CONSTANT: CLOCK_ENABLE_INPUT_A STRING "BYPASS"
// Retrieval info: CONSTANT: CLOCK_ENABLE_INPUT_B STRING "BYPASS"
// Retrieval info: CONSTANT: CLOCK_ENABLE_OUTPUT_B STRING "BYPASS"
// Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: CONSTANT: LPM_TYPE STRING "altsyncram"
// Retrieval info: CONSTANT: NUMWORDS_A NUMERIC "32"
// Retrieval info: CONSTANT: NUMWORDS_B NUMERIC "32"
// Retrieval info: CONSTANT: OPERATION_MODE STRING "DUAL_PORT"
// Retrieval info: CONSTANT: OUTDATA_ACLR_B STRING "NONE"
// Retrieval info: CONSTANT: OUTDATA_REG_B STRING "CLOCK0"
// Retrieval info: CONSTANT: POWER_UP_UNINITIALIZED STRING "FALSE"
// Retrieval info: CONSTANT: RDCONTROL_REG_B STRING "CLOCK0"
// Retrieval info: CONSTANT: READ_DURING_WRITE_MODE_MIXED_PORTS STRING "DONT_CARE"
// Retrieval info: CONSTANT: WIDTHAD_A NUMERIC "5"
// Retrieval info: CONSTANT: WIDTHAD_B NUMERIC "5"
// Retrieval info: CONSTANT: WIDTH_A NUMERIC "5"
// Retrieval info: CONSTANT: WIDTH_B NUMERIC "5"
// Retrieval info: CONSTANT: WIDTH_BYTEENA_A NUMERIC "1"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT VCC "clock"
// Retrieval info: USED_PORT: data 0 0 5 0 INPUT NODEFVAL "data[4..0]"
// Retrieval info: USED_PORT: q 0 0 5 0 OUTPUT NODEFVAL "q[4..0]"
// Retrieval info: USED_PORT: rdaddress 0 0 5 0 INPUT NODEFVAL "rdaddress[4..0]"
// Retrieval info: USED_PORT: rden 0 0 0 0 INPUT VCC "rden"
// Retrieval info: USED_PORT: wraddress 0 0 5 0 INPUT NODEFVAL "wraddress[4..0]"
// Retrieval info: USED_PORT: wren 0 0 0 0 INPUT GND "wren"
// Retrieval info: CONNECT: @address_a 0 0 5 0 wraddress 0 0 5 0
// Retrieval info: CONNECT: @address_b 0 0 5 0 rdaddress 0 0 5 0
// Retrieval info: CONNECT: @clock0 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @data_a 0 0 5 0 data 0 0 5 0
// Retrieval info: CONNECT: @rden_b 0 0 0 0 rden 0 0 0 0
// Retrieval info: CONNECT: @wren_a 0 0 0 0 wren 0 0 0 0
// Retrieval info: CONNECT: q 0 0 5 0 @q_b 0 0 5 0
// Retrieval info: GEN_FILE: TYPE_NORMAL dualportram.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL dualportram.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dualportram.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dualportram.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dualportram_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL dualportram_bb.v TRUE
// Retrieval info: LIB_FILE: altera_mf
