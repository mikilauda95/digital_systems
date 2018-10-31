set SRC_PATH "/homes/simili/dig_sys/ds-2018/20180416/vhdl"
set TMP_PATH "/tmp/simili/20180409/sim/"

# Compile the vhdl files (in order!)
vcom $SRC_PATH/rnd_pkg.vhd
vcom $SRC_PATH/axi_pkg.vhd
vcom $SRC_PATH/reg_axi.vhd
vcom $SRC_PATH/reg_axi_sim.vhd

# Start the simulation of the lb_eval entity (testbench)

# vsim sr_eval
vsim reg_axi_sim


# Add the wavingform for all the signals
add wave * 
add wave -position insertpoint  \
sim:/reg_axi_sim/dut/ro \
sim:/reg_axi_sim/dut/rw

# Format the s_led signal to be binary (and not unsigned as default)
# radix signal sim:/ct_sim/s_led binary

# Run the simulation entirely
run -all
