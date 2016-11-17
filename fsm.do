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
force {load} 0 0, 1 10 -r 20
# next state equals S_WAIT_C at 		10-20, 30-40, 50-60 ...
# current state will become S_WAIT_C at 12-22, 32-42, 52-62 ...
# ld will become 1 at 					12-22, 32-42, 52-62 ...
force {