vhdl=/homes/simili/dig_sys/ds-2018/20180319/vhdl
scripts=/homes/simili/dig_sys/ds-2018/20180319/scripts
tmp=/tmp/simili/dig_sys/20180319
mkdir -p $tmp
cd $tmp
vlib myLib
vmap work myLib

export VHD=$vhdl/g1.vhd
