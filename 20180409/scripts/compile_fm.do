set SRC_PATH "/homes/simili/dig_sys/ds-2018/20180409/vhdl"
set TMP_PATH "/tmp/simili/20180409/sim/"

# Compile the vhdl files (in order!)
vcom $SRC_PATH/sm.vhd
vcom $SRC_PATH/sm_sim.vhd

# Start the simulation of the lb_eval entity (testbench)

# vsim sm_eval
vsim sm_sim


# Add the wavingform for all the signals
add wave * 

# Format the s_led signal to be binary (and not unsigned as default)
# radix signal sim:/ct_sim/s_led binary

# Run the simulation entirely
run -all
