export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
export PATH=$PATH:/packages/LabSoC/Xilinx/bin
vhdl0=/homes/simili/dig_sys/ds-2018/vhdl
vhdl1=/homes/simili/dig_sys/ds-2018/20180423/vhdl
scripts=/homes/simili/dig_sys/ds-2018/20180423/scripts
ds2018=/homes/simili/dig_sys/ds-2018
tmp=/tmp/simili/20180423
mkdir -p $tmp
cd $tmp
vlib myLib
vmap work myLib

