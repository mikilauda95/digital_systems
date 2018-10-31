set ds2018 "/homes/simili/dig_sys/ds-2018/"
set SRC_PATH "$ds2018/sha256/vhdl/"
set TMP_PATH "/tmp/simili/sha256/"

# Compile the vhdl files (in order!)
vcom $SRC_PATH/packages/axi_pkg.vhd
vcom $SRC_PATH/packages/sha256_pack.vhd
vcom $SRC_PATH/packages/sha256_pack.vhd
vcom $SRC_PATH/sha256_compr.vhd
vcom $SRC_PATH/sha256_cu.vhd
vcom $SRC_PATH/sha256_msched.vhd
vcom $SRC_PATH/sha256_core.vhd
vcom $SRC_PATH/sha256_wrap.vhd
vcom $SRC_PATH/sha256_wrap_sim.vhd

# Start the simulation of the lb_eval entity (testbench)

# vsim sr_eval
vsim sha256_wrapsim


# Add the wavingform for all the signals
add wave * 
add wave -position insertpoint  \
sim:/sha256_wrapsim/sha256_wrap_0/aclk \
sim:/sha256_wrapsim/sha256_wrap_0/aresetn \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_araddr \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_arprot \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_arvalid \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_rready \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_awaddr \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_awprot \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_awvalid \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_wdata \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_wstrb \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_wvalid \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_bready \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_arready \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_rdata \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_rresp \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_rvalid \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_awready \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_wready \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_bresp \
sim:/sha256_wrapsim/sha256_wrap_0/s0_axi_bvalid \
sim:/sha256_wrapsim/sha256_wrap_0/NextStateR \
sim:/sha256_wrapsim/sha256_wrap_0/CurrStateR \
sim:/sha256_wrapsim/sha256_wrap_0/NextStateW \
sim:/sha256_wrapsim/sha256_wrap_0/CurrStateW \
sim:/sha256_wrapsim/sha256_wrap_0/addr_r_aligned \
sim:/sha256_wrapsim/sha256_wrap_0/addr_w_aligned \
sim:/sha256_wrapsim/sha256_wrap_0/count_r \
sim:/sha256_wrapsim/sha256_wrap_0/count_w \
sim:/sha256_wrapsim/sha256_wrap_0/data_in \
sim:/sha256_wrapsim/sha256_wrap_0/data_drv \
sim:/sha256_wrapsim/sha256_wrap_0/data_drvn \
sim:/sha256_wrapsim/sha256_wrap_0/s_new_data \
sim:/sha256_wrapsim/sha256_wrap_0/s_busy \
sim:/sha256_wrapsim/sha256_wrap_0/err \
sim:/sha256_wrapsim/sha256_wrap_0/perr_reg \
sim:/sha256_wrapsim/sha256_wrap_0/first_start \
sim:/sha256_wrapsim/sha256_wrap_0/do \
sim:/sha256_wrapsim/sha256_wrap_0/status_reg \
sim:/sha256_wrapsim/sha256_wrap_0/s_HASH \
sim:/sha256_wrapsim/sha256_wrap_0/s_M_in \
sim:/sha256_wrapsim/sha256_wrap_0/s_new_mess
add wave -position insertpoint sim:/sha256_wrapsim/sha256_wrap_0/sha256_block_0/*
# add wave -position insertpoint sim:/sha256sim/sha256_block_0/*
# add wave -position insertpoint sim:/sha256sim/sha256_block_0/compression_0/*
# add wave -position insertpoint sim:/sha256sim/sha256_block_0/cu_0/*

# source wave.do
 


# Format the s_led signal to be binary (and not unsigned as default)
# radix signal sim:/ct_sim/s_led binary

# Run the simulation entirely
run 1000 ns
