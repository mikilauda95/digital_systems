# Commands to be run from sim directory (source "setup.sh" first)

# Declare variables
set SRC_PATH "/homes/simili/dig_sys/ds-2018/20180326/vhdl"
set TMP_PATH "/tmp/simili/20180326/sim/"

# Compile the vhdl files (in order!)
vcom $SRC_PATH/sr.vhd
vcom $SRC_PATH/timer.vhd
vcom $SRC_PATH/lb.vhd
vcom $SRC_PATH/sr_eval.vhd
vcom $SRC_PATH/timer_eval.vhd
vcom $SRC_PATH/lb_eval.vhd

# Start the simulation of the lb_eval entity (testbench)

# vsim sr_eval
vsim timer_eval
# vsim lb_eval


# Add the wavingform for all the signals
add wave * 

# Format the s_led signal to be binary (and not unsigned as default)
# radix signal sim:/ct_sim/s_led binary

# Run the simulation entirely
run -all
