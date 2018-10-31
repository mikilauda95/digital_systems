vhdl=/homes/simili/dig_sys/ds-2018/20180326/vhdl
scripts=/homes/simili/dig_sys/ds-2018/20180326/scripts
tmp=/tmp/simili/dig_sys/20180326
mkdir -p $tmp
cd $tmp
vlib myLib
vmap work myLib

# Initialize the environment for the synthesis
export PATH=$PATH:/packages/LabSoC/Xilinx/bin
syn="/tmp/simili/20180326/syn"
mkdir -p $syn


alias syn_board="vivado -mode batch -source $scripts/lb-syn.tcl -notrace -tclargs $vhdl"
alias gen_boot="bootgen -w -image $scripts/boot.bif -o boot.bin" 
