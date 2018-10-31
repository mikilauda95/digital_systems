#Define PATHS
env vhdl=/homes/simili/dig_sys/ds-2018/20180305/vhdl
env tmp=/tmp/simili/20180305

#create the temporal folder
mkdir -p $tmp

#create the vhdl library in the tmp directory
cd $tmp
vlib myLib
vmap work myLib
