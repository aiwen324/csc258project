# Set the working dir, where all compiled Verilog goes.
vlib work

# Compile all Verilog modules in mux.v to working dir;
# could also have multiple Verilog files.
# The timescale argument defines default time unit
# (used when no unit is specified), while the second number
# defines precision (all times are rounded to this value)
vlog -timescale 1ps/1ps fsm.v
# Load simulation using mux as the top level simulation module.
vsim control

# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}

#input clk,
#input resetn,
#input load, try, endinput, start, timeout, 
#input match, count

# input process
force {clock} 0 0, 1 1 -r 2
# clock has posedge in 1, 3, 5, 7, 9 ...
force {resetn} 1 0, 0 2
force {load} 0 0, 1 10, 0 20, 1 30, 0 40, 1 50, 0 60
# next state equals S_WAIT_C at 		10-20, 30-40, 50-60 ...
# current state will become S_WAIT_C at 11-21, 31-41, 51-61 ...
# ld will become 1 at 					11-21, 31-41, 51-61 ...
force {endinput} 0 0, 1 70
# next state equals S_LOAD_GRAPH at 	70
# current state becomes S_LOAD_GRAPH at 71
force {try} 0
force {start} 0
force {timeout} 0
force {match} 0
force {count} 0
run 80ps

# draw process
force {clock} 0 0, 1 1 -r 2
force {resetn} 0
force {load} 0
force {endinput} 0
force {start} 1 0, 0 2
# next state equals S_WAIT_GRAPH at 		0
# current state equals S_WAIT_GRAPH at 		1
force {try} 0 0, 1 4, 0 6
# next state equals S_LOAD_G at				4 - 6
# curent state equals S_LOAD_G at			5
# compare equals 1 at 						5
force {match} 0 0, 1 8
# curent state equals S_FILL_BLANK at		9
force {timeout} 0
force {count}  0 0, 1 8
# filled equals 0 at 						9
# count equals 0 at 						9.x
# filled equals 1 at						11.x
# current state equals S_FILL_BLANK_WAIT at	13







