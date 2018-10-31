# Commands to be run from sim directory (source "setup.sh" first)

# Declare variables
set SRC_PATH "/homes/simili/dig_sys/ds-2018/20180312/vhdl/"
set TMP_PATH "/tmp/simili/20180312/sim/"

# Compile the vhdl files (in order!)
vcom $SRC_PATH\ct.vhd
vcom $SRC_PATH\ct_sim.vhd

# Start the simulation of the ct_sim entity (testbench)
vsim ct_sim

# Add the wavingform for all the signals
add wave * 

# Format the s_led signal to be binary (and not unsigned as default)
radix signal sim:/ct_sim/s_led binary

# Run the simulation for 200 ns (enough as the signals period is 20 ns)
run 200 ns
