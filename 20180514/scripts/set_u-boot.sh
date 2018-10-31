export CROSS_COMPILE=arm-linux-gnueabihf-
${CROSS_COMPILE}gcc --version

# Configure U-boot
cd /packages/LabSoC/u-boot-xlnx/
make 0=$tmp/u-boot zynq_zybo_defconfig

# Compile Uboot
cd $tmp/u-boot
make -j4

# rename the extension in .elf in order to pack the boot.bin later
cp $tmp/u-boot/u-boot $tmp/u-boot/u-boot.elf
