set SRC_PATH "/homes/simili/dig_sys/ds-2018/20180409/vhdl"
set TMP_PATH "/tmp/simili/20180409/sim/"

# Compile the vhdl files (in order!)
vcom $SRC_PATH/sr2.vhd
vcom $SRC_PATH/sr2_sim.vhd

# Start the simulation of the lb_eval entity (testbench)

# vsim sr_eval
vsim sr2_sim


# Add the wavingform for all the signals
add wave * 

# Format the s_led signal to be binary (and not unsigned as default)
# radix signal sim:/ct_sim/s_led binary

# Run the simulation entirely
run -all
