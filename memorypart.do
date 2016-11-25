# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ps/1ps memorypart.v
# Load simulation using mux as the top level simulation module.
vsim memorypart

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


#input clk, resetn, ld, compare, fill, wren, rden, writeorread;
	#input [4:0] char;
	#input [4:0] guess;

# write char process
force {clk} 0 0, 1 2 -r 4
# 2, 4, 6, 8, 10, 12, 14, 16........
force {resetn} 1 0, 0 3
force {ld} 1 0, 0 6, 1 8, 0 10, 1 12, 0 14
force {writeorread} 1 0, 0 6, 1 8, 0 10, 1 12, 0 14, 1 22, 0 56
# S_LOAD_GRAPH 14, S_WAIT_GRAPH 16, S_LOAD_G 22
force {wren} 1 0, 0 6, 1 8, 0 10, 1 12, 0 14, 1 22, 0 34, 1 44, 0 56
# wren 
force {rden} 0 0, 1 22, 0 58
# rden 
force {compare} 0 0, 1 22, 0 34, 1 44, 0 56
force {fill} 0 0, 1 34, 1 56
force {char} 5'b00001 0, 5'b00001 7, 5'b00010 9, 5'b00001 11, 5'b00001 13, 5'b00001 15
force {guess} 5'b00001 20, 5'b00010 36
run 100ps





