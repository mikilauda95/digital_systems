# commands to be run from tmp directory

set SRC_PATH "/homes/simili/dig_sys/ds-2018/20180305/vhdl/"
set TMP_PATH "/tmp/simili/20180305"

vcom $SRC_PATH\g1.vhd
vcom $SRC_PATH\g1_sim.vhd

vsim g1_sim

add wave *

run -all
