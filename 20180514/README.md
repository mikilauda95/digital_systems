<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# Hardware-software integration: the DHT11 controller in a GNU/Linux environment

# Table of content
* [License](#license)
* [Conventions](#conventions)
* [Introduction](#introduction)
* [Environment set-up](#environment-set-up)
* [Hardware synthesis](#hardware-synthesis)
* [Device tree](#device-tree)
* [First Stage Boot Loader (FSBL)](#first-stage-boot-loader-fsbl)
* [Das U-Boot](#das-u-boot)
* [Zynq boot image](#zynq-boot-image)
* [Linux kernel](#linux-kernel)
* [Root file system](#root-file-system)
* [Xilinx software device drivers](#xilinx-software-device-drivers)
* [DHT11 Linux driver](#dht11-linux-driver)
* [Testing](#testing)

# License

Copyright (C) [Telecom ParisTech]  
Copyright (C) Renaud Pacalet ([renaud.pacalet@telecom-paristech.fr])

Licensed uder the CeCILL license, Version 2.1 of  
2013-06-21 (the "License"). You should have  
received a copy of the License. Else, you may  
obtain a copy of the License at:  

http://www.cecill.info/licences/Licence_CeCILL_V2.1-en.txt

## Conventions

Throughout this document we will use different prompts for the different contexts:

* `Host>` is the shell prompt of the regular user (you) on the host PC
* `hsi%` is the prompt of the `hsi` Xilinx tool in interactive command line mode
* `dht11>` is the shell prompt of the root user on the board (the only user we will use on the board)

## Introduction

All provided instructions are for a host computer running a GNU/Linux operating system and have been tested on a Debian (stretch) distribution. Porting to other GNU/Linux distributions should be very easy. If you are working under Microsoft Windows or Apple Mac OS X, installing a virtualization framework and running a Debian OS in a virtual machine is probably the easiest path.

The embedded system world sometimes looks overcomplicated to non-specialists. But most of this complexity comes from the large number of small things that make this world, not really from the complexity of these small things themselves. Understanding large portions of this exciting field is perfectly feasible, even without a strong background in computer sciences. And, of course, doing things alone is probably one of the best ways to understand them.

In the following we will progressively design, build and test a complete computer system based on a Zynq-based board, with a custom hardware extensions (the AXI version of our DHT11 controller) and a complete GNU/Linux software stack. We will equip the software stack with a software driver for our DHT11 controller. Finally, we will test all this on the board and see how we can control the hardware extensions from the software world. Each step will be briefly explained. Do not hesitate to search for complementary information, there are many on-line manuals and tutorials.

This lab can be ported on any board based on Xilinx Zynq cores but has been specifically designed for the Zybo board by Digilent. The version of the Xilinx tools (Vivado and its companion SDK) that we used when designing this lab was `2016.3`. More recent versions should be OK but may require small modifications.

Three Xilinx git repository are also used:

* `device-tree-xlnx`, the device tree sources for Xilinx devices
* `u-boot-xlnx`, a version of the [Das U-Boot] boot loader customized by Xilinx
* `linux-xlnx`, a version of the [Linux kernel] customized by Xilinx

For your convenience they have already been cloned in `/packages/LabSoC`, their `xilinx-v2016.3` tags have been checked out and the clones have been protected against accidental modifications. If you are working on your own laptop or if, for any reason, you do not have access to the`/packages/LabSoC` NFS share, clone these 3 git repositories. Example for `device-tree-xlnx` with the same path as on EURECOM desktop PCs (of course, you can use another path; if you do so, adapt the instructions by replacing `/packages/LabSoC` by your own path when needed):

```bash
Host> mkdir -p /packages/LabSoC
Host> cd /packages/LabSoC
Host> git clone https://github.com/Xilinx/device-tree-xlnx.git
Host> cd device-tree-xlnx
Host> git checkout xilinx-v2016.3
Host> chmod -R a-w .
```

Please signal errors and send suggestions for improvements to [renaud.pacalet@telecom-paristech.fr].

## Environment set-up

As usual, configure your environment for synthesis with Xilinx Vivado (see the [20180312](../20180312/README.md) lab). Remember that it is always better to work out of the source tree. As we will build several independent software components, we will use several sub-directories of the same temporary directory:

* `vv`: Vivado synthesis results
* `fsbl`: First Stage Boot Loader
* `u-boot`: [Das U-Boot], second-stage boot loader
* `kernel`: [Linux kernel]
* `dts`: Device Tree Sources
* `initramfs`: root file system
* `sdcard`: what must be copied on the SD card
* `C`: source code of the [Linux] loadable module that will serve as device driver

Some of these sub-directories will be created automatically by the tools. Example of set-up (adapt the suggested `ds2018` and `tmp` paths to your own case):

```bash
Host> ds2018=/homes/mary/ds-2018
Host> tmp=/tmp/mary/20180514
Host> mkdir -p $tmp/vv $tmp/initramfs $tmp/sdcard $tmp/C
```

## Hardware synthesis

We need two files that have been generated by the Vivado Xilinx tool during the synthesis of our `dht11_ctrl_axi` hardware design:

* `top_wrapper.bit`: the bistream that will be used to configure the FPGA part of the Zynq core with our `dht11_ctrl_axi` design
* `top_wrapper.sysdef`: a binary description of our design (name, interfaces...) that the `hsi` Xilinx tool will use to generate hardware-dependent software components

If you already synthesized your `dht11_ctrl_axi` design and tested it on the Zybo board, you can simply copy these two files. Assuming your synthesis results are in `/tmp/mary/20180423`:

```bash
Host> old=/tmp/mary/20180423/top.runs/impl_1
Host> new=$tmp/vv/top.runs/impl_1
Host> mkdir -p $new
Host> cd $old
Host> cp top_wrapper.bit top_wrapper.sysdef $new
```

Else, synthesize your `dht11_ctrl_axi` design (replace `<init>`, `<tmax>` and `<cmax>` by the appropriate values):

```bash
Host> cd $tmp/vv
Host> vivado -mode batch -source $ds2018/20180423/scripts/dht11_ctrl_axi.syn.tcl -notrace -tclargs $ds2018 <init> <tmax> <cmax>
```

Alternately you can copy the provided reference files:

```bash
Host> mkdir -p $tmp/vv/top.runs/impl_1
Host> cd /packages/LabSoC/builds/dht11
Host> cp top_wrapper.bit top_wrapper.sysdef $tmp/vv/top.runs/impl_1
```

## Device tree

A device tree is a textual description of the hardware platform on which the [Linux kernel] runs. Before the concept of device trees have been introduced, running the same kernel on different platforms was difficult, even if the processor was the same. It was quite common to distribute different kernel binaries for very similar platforms because the set of devices was different or because some parameters, like the hardware address at which a device is found, were different. Thanks to device trees, the same kernel can discover the hardware architecture of the target and adapt itself during boot. To make a long story short, we generate a textual description of the board (including our custom hardware peripheral) - the device tree source or `dts` - and transform it into an equivalent binary form - the device tree blob or `dtb` - with `dtc`, the device tree compiler. We then add this device tree blob to the SD card. During the boot it will be loaded in memory, the [Linux kernel] will parse this data structure and configure itself accordingly.

Use the `hsi`  Xilinx tool to generate the device tree sources from the binary description of our hardware design (`top_wrapper.sysdef`):

```bash
Host> cd $tmp
Host> hsi
hsi% set design [ open_hw_design vv/top.runs/impl_1/top_wrapper.sysdef ]
hsi% set_repo_path /packages/LabSoC/device-tree-xlnx
hsi% create_sw_design device-tree -os device_tree -proc ps7_cortexa9_0
hsi% generate_target -dir dts
hsi% quit
```

A `$tmp/dts` directory has been created and populated with the device tree sources. Look at the `$tmp/dts/pl.dtsi` file (included by the `$tmp/dts/system.dts` top-level). It defines one parent node named `amba_pl`. AMBA is the generic name of the ARM bus protocols, including the AXI protocol. PL is a short hand for Programmable Logic, the FPGA part of the Zynq core. This `amba_pl` node corresponds to the interface between the ARM CPUs of the Zynq and the FPGA part. The file also declares a child node of `amba_pl`, named `dht11_ctrl_axi@40000000`. This is our DHT11 controller, embedded in the FPGA part of the Zynq core. Two attributes are declared for this child node:

* `compatible`, a string that the [Linux kernel] will use to search for a software driver compatible with this hardware peripheral.
* `reg`, a physical address range definition for the hardware peripheral. In our case, this attribute tells the [Linux kernel] that all addresses in range `[0x40000000..0x40001000[` (4 kB) are mapped to our peripheral.

Remember these two attributes, we will need them when designing a software driver for our peripheral.

Use the device tree compiler to compile the device tree and generate the binary form that [linux] expects:

```bash
Host> dtc -I dts -O dtb -o $tmp/sdcard/devicetree.dtb $tmp/dts/system.dts
```

The `$tmp/sdcard` directory now contains the first of the 4 files we need to boot our system: `devicetree.dtb`, the binary version of the device tree.

## First Stage Boot Loader (FSBL)

When the Zynq core of the board is powered up, the ARM processor executes its first instructions from an on-chip ROM. This BootROM code performs several initializations, reads the configuration of the blue jumper that selects the boot medium (the SD card in our case) and loads a boot image from the selected medium. This boot image is a binary archive file that, in our case, encapsulates 3 different binary files:

* The executable binary in ELF format of the next software to run: the First Stage Boot Loader (FSBL)
* The configuration bitstream of the FPGA part
* The executable binary in ELF format of the software application that will be executed after the FSBL, [Das U-Boot] in our case

The BootROM code loads the FSBL in the On-Chip RAM (OCR) of the Zynq core and jumps into the FSBL. So, technically speaking, the FSBL is not the **first** boot loader, as its name says, but the second. The real first boot loader is the BootROM code. Anyway, the FSBL, in turn, performs several initializations, extracts the bitstream from the boot image and uses it to configures the FPGA. Then, it loads the next software application from the boot image, installs it in memory and jumps into it. In our case, this software application is [U-Boot], that we use as a Second Stage Boot Loader (or shall we write **third**?) to load the [Linux kernel], the device tree blob and the root file system before jumping into the kernel.

Use the `hsi`  Xilinx tool to generate the FSBL source code from the binary description of our hardware design (`top_wrapper.sysdef`):

```bash
Host> cd $tmp
Host> hsi
hsi% set design [ open_hw_design vv/top.runs/impl_1/top_wrapper.sysdef ]
hsi% generate_app -hw $design -os standalone -proc ps7_cortexa9_0 -app zynq_fsbl -sw fsbl -dir fsbl
hsi% quit
```

The FSBL source code is in `$tmp/fsbl`. It is written mainly in C language. Compile the FSBL using the Makefile generated by the Xilinx tools:

```bash
Host> make -j1 -C $tmp/fsbl
```

The produced binary, in ELF format, is `$tmp/fsbl/executable.elf`. Note that the compilation used the cross-compiler of the Xilinx tools suite.

## Das U-Boot

Our second stage boot loader is [Das U-Boot], [U-Boot] for short, a free and open source boot loader frequently encountered in the embedded system world. It is highly flexible and can be used to continue the boot sequence in many different ways (using the network, a SD card...) [U-Boot] is responsible for loading the [Linux kernel], the device tree blob, the root file system (we will see later what it is) in DDR memory, before handing off to the [Linux kernel] by jumping at its entry point.

We will configure and compile a version of [U-Boot] customized by Xilinx. The compiler we need is the cross-compiler (from host PC to target ARM architecture) provided by Xilinx. Define the `CROSS_COMPILE` environment variable and test it:

```bash
Host> export CROSS_COMPILE=arm-linux-gnueabihf-
Host> ${CROSS_COMPILE}gcc --version
```

Then, use the default [U-Boot] configuration for the Zybo board to initialize a build directory:

```bash
Host> cd /packages/LabSoC/u-boot-xlnx
Host> make O=$tmp/u-boot zynq_zybo_defconfig
```

This created the `$tmp/u-boot` directory and populated it. Compile [U-Boot]:

```bash
Host> cd $tmp/u-boot
Host> make -j4
```

The generated executable binary in ELF format is `$tmp/u-boot/u-boot`. The Xilinx `bootgen` utility that we will use to pack the `boot.bin` boot image needs that ELF files have the `.elf` extension. Rename the executable:

```bash
Host> cp $tmp/u-boot/u-boot $tmp/u-boot/u-boot.elf
```

Note: [U-Boot] is highly configurable. We could have changed its default configuration by running:

```bash
Host> cd $tmp/u-boot
Host> make menuconfig
```

before compiling.

## Zynq boot image

The three parts that compose the `boot.bin` boot image are now available:

* The FSBL executable binary in ELF format (`$tmp/fsbl/executable.elf`)
* The bitstream (`$tmp/vv/top.runs/impl_1/top_wrapper.bit`)
* The [U-Boot] executable binary in ELF format with the correct extension (`$tmp/u-boot/u-boot.elf`)

The provided `boot.bif` text file defines the content of the boot image:

```bash
Host> cat $ds2018/20180514/scripts/boot.bif
image:
{
  [bootloader]fsbl/executable.elf
  vv/top.runs/impl_1/top_wrapper.bit
  u-boot/u-boot.elf
}
```

Use the `bootgen` Xilinx utility to pack them in a boot image. 

```bash
Host> cd $tmp
Host> bootgen -w -image $ds2018/20180514/scripts/boot.bif -o sdcard/boot.bin 
```

The `$tmp/sdcard` directory now contains the second of the 4 files we need to boot our system: `boot.bin`, the boot image containing the FSBL, the bitstream and [U-Boot].

## Linux kernel

The [Linux kernel] is a key component of our software stack, even if it is not sufficient and would not be very useful without our root file system and all the software applications in it. The kernel and its software device drivers are responsible for the management of our small computer. They control the sharing of all resources (memory, peripherals...) among the different software applications and serve as intermediates between the software and the hardware, hiding most of the low level details. They also offer the same (software) interface, independently of the underlying hardware: thanks to the kernel and its device drivers we will access the various features of our board exactly as we would do on another type of computer. This is what is called _hardware abstraction_ in computer science.

Never compiled the [Linux kernel]? It is time to do it. It is very similar to the [U-Boot] build process. We will also use a version that has been customized by Xilinx:

```bash
Host> cd /packages/LabSoC/linux-xlnx
Host> make O=$tmp/kernel ARCH=arm xilinx_zynq_defconfig
Host> cd $tmp/kernel
Host> make -j4 ARCH=arm
```

Be patient, the [Linux kernel] is a large piece of software and its compilation takes some time. After compilation the kernel is available in different formats:

* `$tmp/kernel/vmlinux`: uncompressed executable in ELF format
* `$tmp/kernel/arch/arm/boot/zImage`: compressed executable

None of these is the one we will use on the board. In order to load the kernel in memory with [U-Boot] we must generate a kernel image in [U-Boot] format. This can be done using a small utility, `mkimage`, that was built with [U-Boot]. Add its location to your `PATH`:

```bash
Host> export PATH=$PATH:$tmp/u-boot/tools
```

The [Linux kernel] build system knows how to use `mkimage`. We just need to provide the load address and entry point that [U-Boot] will use when loading the kernel into memory and when jumping into the kernel:

```bash
Host> cd $tmp/kernel
Host> make ARCH=arm LOADADDR=0x8000 uImage
```

The result is in `$tmp/kernel/arch/arm/boot/uImage` and, as its size shows, it is the same as `$tmp/kernel/arch/arm/boot/zImage` with a 64 bytes [U-Boot] header added:

```bash
Host> ls -l $tmp/kernel/arch/arm/boot/zImage $tmp/kernel/arch/arm/boot/uImage
-rw------- 1 mary users 3817736 May  4 10:23 /tmp/mary/20180514/kernel/arch/arm/boot/uImage
-rwx------ 1 mary users 3817672 May  4 10:15 /tmp/mary/20180514/kernel/arch/arm/boot/zImage
```

The 64 bytes header, among other parameters, contains the load address and entry point we specified (starting at offset `0x20):

```bash
Host> od -N64 -tx1 $tmp/kernel/arch/arm/boot/uImage
0000000 27 05 19 56 06 53 27 b5 5a ec 18 83 00 3a 40 c8
0000020 00 00 80 00 00 00 80 00 49 23 08 7d 05 02 02 00
0000040 4c 69 6e 75 78 2d 34 2e 36 2e 30 2d 78 69 6c 69
0000060 6e 78 2d 64 69 72 74 79 00 00 00 00 00 00 00 00
0000100
```

When loading the kernel, [U-Boot] will copy the `uImage` somewhere in memory, parse the 64 bytes header, uncompress the kernel, install it starting at address `0x8000`, add some more information in the first 32 kB of memory and jump at the entry point, which is also `0x8000`. This kernel `uImage` is thus the one we will store on the SD card and use on the board. Copy it in `$tmp/sdcard`:

```bash
Host> cp $tmp/kernel/arch/arm/boot/uImage $tmp/sdcard
```

The `$tmp/sdcard` directory now contains the third of the 4 files we need to boot our system: `uImage`, the compressed [Linux kernel] image with [U-Boot] header.

Note: the [Linux kernel], just like [U-Boot], is highly configurable. We could have changed its default configuration by running:

```bash
Host> cd $tmp/kernel
Host> make menuconfig
```

before compiling.

## Root file system

At the heart of an OS there is a kernel ([linux] in our case). But the kernel alone is not very useful. It needs a lot more software applications and configuration files to make a real OS. In our case it is the root file system that contains all these other components. A file system is a software layer that manages the data stored on a storage device like a Hard Disk Drive (HDD) or a flash card. It organizes the data in a hierarchy of directories and files. The term is also used to designate a hierarchy of directories that is managed by this software layer. The **root** file system, as its name says, is itself a file system and also the root of all other file systems, that are bound to (mounted on) sub-directories. The `df` command can show you all file systems of your host PC and their mount point:

```bash
Host> df
Filesystem                                        1K-blocks     Used Available Use% Mounted on
/dev/dm-0                                         492126216 84731012 382373560  19% /
udev                                                  10240        0     10240   0% /dev
tmpfs                                               6587916    27648   6560268   1% /run
tmpfs                                              16469780        8  16469772   1% /dev/shm
tmpfs                                                  5120        4      5116   1% /run/lock
...
```

The file system mounted on `/` is the root file system:

```bash
Host> cd /
Host> ls -al
total 120
drwxr-xr-x  25 root    root     4096 Mar 17 17:31 .
drwxr-xr-x  25 root    root     4096 Mar 17 17:31 ..
drwxrwxr-x   2 root    root     4096 Apr  4 08:05 bin
drwxr-xr-x   3 root    root     4096 Apr 11 15:48 boot
drwxr-xr-x  20 root    root     3500 Apr 14 10:04 dev
...
drwxrwxrwt  25 root    root    20480 Apr 14 10:42 tmp
drwxr-xr-x  12 root    root     4096 Oct 23 11:53 usr
drwxr-xr-x  12 root    root     4096 Oct 22 12:26 var
```

`/bin` and all its content are part of the root file system but `/dev` is the mount point of a different file system. In most cases it makes no difference whether a file is part of a file system or another: they all seem to be somewhere in the same unique hierarchy of directories that start at `/`.

Our root file system is what is called an `initramfs`, a file system that is loaded entirely in RAM at boot time, while the more classical root file system of your host resides on a Hard Disk Drive (HDD). With `initramfs`, a portion of the available memory is presented and used just like if it was mass storage. This portion is initialized at boot time from a binary file stored on the boot medium (the SD card in our case), the root file system image. The good point with `initramfs` is that it is ultra-fast because memory accesses are much faster than accesses to HDDs. The drawbacks are that it is not persistent across reboot (it is restored to its original state every time you boot) and that its size is limited by the available memory (512MB on the Zybo - and even less because we need some working memory too - compared to the multi-GB capacity of the HDD of your host).

We could build it from scratch using, for instance, the excellent [Buildroot], but this is a long process. In order to save time we will start from an already built (with [Buildroot]) root file system image that we will unpack in `$tmp/initramfs`, enrich with our own components, and repack.

The provided root file system image, `/packages/LabSoC/builds/dht11/rootfs.cpio.gz`, is in `gzip`-compressed `cpio` format. We could (don't do it now) try to unpack it using the `zcat` uncompress utility and the `cpio` archive utility:

```bash
Host> cd $tmp/initramfs
Host> zcat /packages/LabSoC/builds/dht11/rootfs.cpio.gz | cpio -i
```

But a root file system is not a regular hierarchy of files and directories. It contains special files (in `/dev`), many files must be owned by the `root` superuser... As we are not superuser on our host computers we cannot just unpack like this. The `fakeroot` utility is one solution to this problem. It offers an execution environment where guest applications run as if they were `root` while they are not:

```bash
Host> cd $tmp/initramfs
Host> zcat /packages/LabSoC/builds/dht11/rootfs.cpio.gz | fakeroot -s $tmp/fakeroot.lst cpio -i
```

If you look at the content of `$tmp/initramfs` you will see that all files are owned by you and are regular files. Special files in `$tmp/initramfs/dev`, for instance, became empty regular files. But the information (ownership, permissions, file type...) is not lost: `fakeroot` stored it in the `$tmp/fakeroot.lst` text file, indexed by inode numbers (a numeric index of files):

```bash
Host> stat $tmp/initramfs/bin/busybox
  File: '/tmp/mary/20180514/initramfs/bin/busybox'
  Size: 675524    	Blocks: 1320       IO Block: 4096   regular file
Device: 802h/2050d	Inode: 5505801     Links: 1
Access: (4755/-rwsr-xr-x)  Uid: ( 8001/ mary)   Gid: (  105/systemd-bus-proxy)
Access: 2018-05-03 13:46:17.324881828 +0200
Modify: 2018-05-03 13:02:48.894743906 +0200
Change: 2018-05-03 13:02:48.894743906 +0200
 Birth: -
```

Note the inode number (`5505801` in the above example) and search it in the `$tmp/fakeroot.lst` file:

```bash
Host> grep 5505801 $tmp/fakeroot.lst
dev=802,ino=5505801,mode=104755,uid=0,gid=0,nlink=1,rdev=0
```

In `$tmp/initramfs` the `bin/busybox` file is owned by user `mary` that has user identifier (`Uid`) `8001`, and group `systemd-bus-proxy` (group identifier `105`). In the `$tmp/fakeroot.lst` file it is listed as owned by user with identifier `0`, group identifier `0`, that is the `root` supersuser. When repacking the image we will use `fakeroot` again and, thanks to the `$tmp/fakeroot.lst` file, it will pack everything with the original ownership, permissions, file type...

Note that the files we will add to the unpacked image are not listed in `$tmp/fakeroot.lst`. `fakeroot` will treat them with its default policy: in the resulting image they will be owned by user `root`, which is what we want.

## Xilinx software device drivers

The [Linux kernel] customized by Xilinx embeds a collection of software device drivers that are responsible for the management of the various hardware devices (network interface, timer, interrupt controller...) Some are integrated into the kernel, some are delivered as _external modules_, a kind of device driver that is dynamically loaded in memory by the kernel when it is needed. These external modules must also be built and installed in our root file system, in `/lib/modules`, where the kernel will find them. If you look at the content of `$tmp/initramfs/lib` you will see that they are not here yet.

Note: you can explore the `/lib/modules` of your host PC to discover what modules are available. You can even look at the `/proc/modules` pseudo file to see what modules are currently loaded by the kernel running on your PC:

```bash
Host> cat /proc/modules
nvidia_uvm 36864 0 - Live 0x0000000000000000 (POE)
ipt_MASQUERADE 16384 1 - Live 0x0000000000000000
nf_nat_masquerade_ipv4 16384 1 ipt_MASQUERADE, Live 0x0000000000000000
...
pps_core 20480 1 ptp, Live 0x0000000000000000
fjes 28672 0 - Live 0x0000000000000000
video 40960 0 - Live 0x0000000000000000
```

The `lsmod` command (for LiSt MODules) displays the same type of information:

```bash
Host> lsmod
Module                  Size  Used by
nvidia_uvm             36864  0
ipt_MASQUERADE         16384  1
nf_nat_masquerade_ipv4    16384  1 ipt_MASQUERADE
...
pps_core               20480  1 ptp
fjes                   28672  0
video                  40960  0
```

Compile the Xilinx modules and install them in our unpacked root file system:

```bash
Host> cd $tmp/kernel
Host> make -j4 ARCH=arm modules
Host> make ARCH=arm modules_install INSTALL_MOD_PATH=$tmp/initramfs
```

You can see the added modules in `$tmp/initramfs/lib/modules/4.6.0-xilinx-dirty` and its sub-directories. We could now repack the root file system, put everything on the SD card and boot, but we would be about in the same situation as at the end of the last lab. We could communicate with our peripheral only using `devmem` or an equivalent, which is not very convenient because it accesses directly physical addresses and for obvious security reasons it requires `root` privileges. The only difference with the last lab would be that we compiled a large part of the software stack ourself. Good enough but we can do better than this.

Let us enter now the tricky part and design a [linux] device driver for our peripheral.

## DHT11 Linux driver

Accessing the DHT11 hardware device using the `devmem` utility is not very convenient. In this section we will create a [linux] software driver for DHT11 and use it to interact more conveniently with the hardware. The provided example can be found in the `$ds2018/20180514/C/dht11_driver.c`.

The proposed driver follows a model called _platform device driver_. To now more about this model you can read the [Linux kernel] documentation (`/packages/LabSoC/linux-xlnx/Documentation/driver-model/platform.txt`) and/or the corresponding header file in the [Linux kernel] sources (`/packages/LabSoC/linux-xlnx/include/linux/platform_device.h`).

Carefuly read the source code of the `dht11_driver.c` [Linux] device driver, it is commented. Try to understand as much as you can:

1. Locate the compatible string that we already encountered in the device tree sources.
1. Note that messages are printed by the `dht11_probe` and `dht11_remove` functions using the kernel `printk` function, not the user space `printf` function.
1. Note that five different functions are defined:
    * `dht11_open`: called by the kernel when the device file (`/dev/dht11`) corresponding to our peripheral is opened
    * `dht11_close`: called by the kernel when the device file (`/dev/dht11`) corresponding to our peripheral is closed
    * `dht11_read`: called by the kernel when the device file (`/dev/dht11`) corresponding to our peripheral is read
    * `dht11_remove`: called by the kernel when the module is unloaded
    * `dht11_probe`: called by the kernel when the module is loaded
1. Try to understand how `dht11_read` handles the endianess 
1. Study how `dht11_remove` undoes in reverse order what has been done by `dht11_probe` when the module has been loaded
1. Study how `dht11_probe` checks for errors at each step and, when an error is detected, uses a series of `goto` instructions to undo only what has been succesfuly done

To compile our module device driver we will use the [Linux kernel] build system. First copy the source code:

```bash
Host> cp -r $ds2018/20180514/C/dht11_driver.c $tmp/C
```

Create a very simple `Makefile` to tell the [Linux kernel] build system what object files are part of the module device driver:

```bash
Host> echo 'obj-m := dht11_driver.o' > $tmp/C/Makefile
```

Finally, compile the module and install it in the root file system:

```bash
Host> cd $tmp/kernel
Host> make ARCH=arm M=$tmp/C modules
Host> make ARCH=arm M=$tmp/C INSTALL_MOD_PATH=$tmp/initramfs modules_install
Host> ls $tmp/initramfs/lib/modules/4.6.0-xilinx-dirty/extra
dht11_driver.ko
Host> 
```

## Testing

Our root file system is now complete. Repack it and use once again the `mkimage` utility to prepare it for [U-Boot]:

```bash
Host> cd $tmp/initramfs
Host> find | fakeroot -i $tmp/fakeroot.lst cpio -o -H newc | gzip -c > $tmp/new_rootfs.cpio.gz
Host> mkimage -A arm -T ramdisk -C gzip -d $tmp/new_rootfs.cpio.gz $tmp/sdcard/uramdisk.image.gz
```

The `$tmp/sdcard` directory now contains the last of the 4 files we need to boot our system: `uramdisk.image.gz`, the compressed root file system image with [U-Boot] header. Mount the micro SD card on a computer and define a shell variable that points to it:

```bash
$ SDCARD=<path-to-mounted-sd-card>
```

Copy the four files in `$tmp/sdcard` to the SD card:

```bash
Host> cp $tmp/sdcard/* $SDCARD
```

Unmount the micro SD card, eject it, plug it on the Zybo and power up. In a terminal launch a serial communication program (e.g. `picocom`) and attach it to the serial device that corresponds to the Zybo board:

```bash
Host> picocom -b115200 /dev/ttyUSB1
...
Welcome to dht11 (c) Telecom ParisTech
dht11 login: root
dht11> 
```

You are now connected as the `root` user under the GNU/Linux OS that runs on the Zynq core of the Zybo board. The device file does not exist yet:

```bash
dht11> ls -l /dev/dht11
ls: /dev/dht11: No such file or directory
```

The `/proc` and `/sys` pseudo file systems contain information about the loaded modules and the device files but nothing yet about our module:

```bash
dht11> cat /proc/modules
dht11> ls /sys/class/dht11
ls: /sys/class/dht11: No such file or directory
```

Load the module device driver:

```bash
dht11> insmod /lib/modules/4.6.0-xilinx-dirty/extra/dht11_driver.ko
DHT11 module loaded
DHT11 probed at VA 0xe0964000
```

The device file has now been created and can be used to read the interface registers of our peripheral:

```bash
dht11> ls -l /dev/dht11
crw-------    1 root     root      244,   0 Jan  1 00:07 /dev/dht11
dht11> cat /proc/modules
dht11_driver 2837 0 - Live 0xbf008000 (O)
dht11> ls /sys/class/dht11
dht11
dht11> od -N8 -tu1 /dev/dht11
0000000   0   0   0   0   7   0   0   0
0000010
```

Plug the sensor and read actual data:

```bash
dht11> od -N8 -tu1 /dev/dht11
0000000   0  24   0  37   3   0   0   0
0000010
```

Continue looking around and testing the system. Once you are done, remove the module device driver and properly shut down:

```bash
dht11> rmmod dht11_driver
DHT11 module removed.
dht11> poweroff
dht11> Stopping network...Saving random seed... done.
Stopping logging: OK
umount: devtmpfs busy - remounted read-only
umount: can't unmount /: Invalid argument
The system is going down NOW!
Sent SIGTERM to all processes
Sent SIGKILL to all processes
Requesting system poweroff
reboot: System halted
```

[U-Boot]: http://www.denx.de/wiki/U-Boot
[Das U-Boot]: http://www.denx.de/wiki/U-Boot
[Buildroot]: https://buildroot.org/
[Linux]: https://www.kernel.org/
[Linux kernel]: https://www.kernel.org/
[renaud.pacalet@telecom-paristech.fr]: mailto:renaud.pacalet@telecom-paristech.fr
[Telecom ParisTech]: https://www.telecom-paristech.fr/eng

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
