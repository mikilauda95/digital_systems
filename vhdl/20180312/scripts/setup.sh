# Initialize the environment for the simulation

export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
vhdl=/homes/simili/dig_sys/ds-2018/20180312/vhdl
scripts=/homes/simili/dig_sys/ds-2018/20180312/scripts
sim=/tmp/simili/dig_sys/20180312/sim
mkdir -p $sim
cd $sim
vlib myLib
vmap work myLib


# Initialize the environment for the synthesis
export PATH=$PATH:/packages/LabSoC/Xilinx/bin
syn=/tmp/simili/20180312/syn
mkdir -p $syn
cd $syn
cp $vhdl/ct.vhd .
alias syn_board_ct="vivado -mode batch -source $scripts/ct-syn.tcl -notrace"
alias gen_boot="bootgen -w -image $scripts/boot.bif -o boot.bin" 
