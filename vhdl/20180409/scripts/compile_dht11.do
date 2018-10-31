set SRC_PATH "/homes/simili/dig_sys/ds-2018/20180409/vhdl"
set TMP_PATH "/tmp/simili/20180409/sim/"

# Compile the vhdl files (in order!)
vcom $SRC_PATH/edge.vhd
vcom $SRC_PATH/timer2.vhd
vcom $SRC_PATH/counter.vhd
vcom $SRC_PATH/sr2.vhd
vcom $SRC_PATH/sm2.vhd
vcom $SRC_PATH/dht11_ctrl.vhd
vcom $SRC_PATH/dht11_ctrl_sim.vhd   

# Start the simulation of the lb_eval entity (testbench)

# vsim sm_eval
vsim dht11_ctrl_sim


# Add the wavingform for all the signals
add wave * 
add wave sim:/dht11_ctrl_sim/u_dht11_ctrl/sm2_0/*


# Format the s_led signal to be binary (and not unsigned as default)
# radix signal sim:/ct_sim/s_led binary

# Run the simulation entirely
run 10000 us
