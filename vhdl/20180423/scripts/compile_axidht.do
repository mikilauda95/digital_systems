set SRC_PATH "/homes/simili/dig_sys/ds-2018/20180423/vhdl"
set SRC_DHTPATH "/homes/simili/dig_sys/ds-2018/20180409/vhdl"
set TMP_PATH "/tmp/simili/20180423/sim/"

# Compile the vhdl files (in order!)
vcom $SRC_PATH/rnd_pkg.vhd
vcom $SRC_PATH/axi_pkg.vhd

vcom $SRC_DHTPATH/edge.vhd
vcom $SRC_DHTPATH/timer2.vhd
vcom $SRC_DHTPATH/counter.vhd
vcom $SRC_DHTPATH/sr2.vhd
vcom $SRC_DHTPATH/sm2.vhd
vcom $SRC_DHTPATH/dht11_ctrl.vhd

vcom $SRC_PATH/dht11_ctrl_axi.vhd
vcom $SRC_PATH/dht11_ctrl_axi_sim.vhd

# Start the simulation of the lb_eval entity (testbench)

vsim dht11_ctrl_axi_sim


# Add the wavingform for all the signals
add wave * 

# Format the s_led signal to be binary (and not unsigned as default)
# radix signal sim:/ct_sim/s_led binary

# Run the simulation entirely
run -all
