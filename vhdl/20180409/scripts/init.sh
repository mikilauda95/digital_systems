export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
export PATH=$PATH:/packages/LabSoC/Xilinx/bin
vhdl=/homes/simili/dig_sys/ds-2018/20180409/vhdl
scripts=/homes/simili/dig_sys/ds-2018/20180409/scripts
tmp=/tmp/simili/20180409
mkdir -p $tmp
cd $tmp
vlib myLib
vmap work myLib

