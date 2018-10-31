set SRC_PATH "/home/mikilauda/ds-2018/sha256/vhdl/"
set TMP_PATH "/home/mikilauda/ds-2018/sha256/tmp"

# Compile the vhdl files (in order!)
vcom $SRC_PATH/packages/sha256_pack.vhd
vcom $SRC_PATH/sha256_compr.vhd
vcom $SRC_PATH/sha256_cu.vhd
vcom $SRC_PATH/sha256_msched.vhd
vcom $SRC_PATH/sha256_core.vhd
vcom $SRC_PATH/sha256_sim.vhd

# Start the simulation of the lb_eval entity (testbench)

# vsim sr_eval
vsim sha256sim


# Add the wavingform for all the signals
# add wave * 
# add wave -position insertpoint sim:/sha256sim/sha256_block_0/*
# add wave -position insertpoint sim:/sha256sim/sha256_block_0/compression_0/*
# add wave -position insertpoint sim:/sha256sim/sha256_block_0/cu_0/*

source wave.do
 


# Format the s_led signal to be binary (and not unsigned as default)
# radix signal sim:/ct_sim/s_led binary

# Run the simulation entirely
run 600 ns
