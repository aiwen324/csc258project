# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ps/1ps tmptopmod.v
# Load simulation using mux as the top level simulation module.
vsim tmptopmod

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}


#input input clk, resetn, ld, compare, fill, wren, rden, writeorread;
	#input [4:0] char;
	#input [4:0] guess;

# write char process
force {clk} 0 0, 1 2 -r 4
force {resetn} 1 0, 0 3
force {ld} 0 0, 1 4, 0 7, 1 10
force {writeorread}
force {wren}
force {rden}
force {compare}
force {fill}
force {char}
force {guess} 





