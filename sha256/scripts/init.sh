export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
export PATH=$PATH:/packages/LabSoC/Xilinx/bin

export ds2018=/homes/simili/dig_sys/ds-2018/
export vhdl="$ds2018/sha256/vhdl/"
export scripts="$ds2018/sha256/scripts/"
export tmp=/tmp/simili/sha256/
mkdir -p $tmp
mkdir -p $tmp/vv $tmp/initramfs $tmp/sdcard $tmp/C

cd $tmp
vlib myLib
vmap work myLib
