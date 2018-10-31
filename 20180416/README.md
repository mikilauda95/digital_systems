<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# AXI4 lite register

* [Introduction](#introduction)
* [Environment set-up](#environment-set-up)
* [The AXI4 lite protocol](#the-axi4-lite-protocol)
* [AXI4 lite register](reg_axi.md)
* [Synthesis and tests of the AXI4 lite register](#synthesis-and-tests-of-the-axi4-lite-register)
* [AXI4 lite DHT11 controller](#axi4-lite-dht11-controller)

## Introduction

During this lab we will have other VHDL coding challenges that must be completed in a limited amount of time. Your work is automatically evaluated and scored by the GitLab Continuous Integration System each time you push it. The scores are informative only. Use the challenges to check your VHDL understanding and skills. When instructed to do so:

1. Add-commit-push your branch,
1. Fetch, merge with `origin/master`,
1. Refresh this web page,
1. Follow the link to the next challenge (in the above table of content),
1. Code as fast as you can,
1. Compile, simulate with the provided simulation environment,
1. Add-commit-push your work,
1. Wait for the email (or visit the [Pipelines page]),
1. If the evaluation failed, click on the **run** link in the email (or the red cross and then on the **run** link on the [Pipelines page]) to see what went wrong, fix what needs to be and add-commit-push your work until all tests pass,
1. After the deadline, discuss your solution with your neighbours, ask questions.

## Environment set-up

The `/ds-2018/vhdl` directory now contains VHDL packages to be reused during different labs:
* `ds-2018/vhdl/axi_pkg.vhd` defines VHDL package `axi_pkg` that declares the encoding of the different AXI4 response statuses (OKAY, EXOKAY, SLVERR or DECERR) as 4 VHDL constants. Look at the source code and remember the names of the constants. In your own VHDL code, use them instead of hard-coding the values (which is error prone and not a recommended practice).
* `ds-2018/vhdl/rnd_pkg.vhd` defines VHDL package `rnd_pkg` that declares a random number generator that can be used in simulation environments. It uses [protected types](/doc/protected-types.md), the VHDL feature that resembles most object-oriented programming.

As usual, configure your environment for VHDL simulation with Mentor Graphics Modelsim and synthesis with Xilinx Vivado (adapt the suggested `ds2018` `tmp` paths to your own case):

````bash
$ export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
$ export PATH=$PATH:/packages/LabSoC/Xilinx/bin
$ ds2018=/homes/mary/ds-2018
$ tmp=/tmp/mary/20180416
$ mkdir -p $tmp
$ cd $tmp
$ vlib myLib
$ vmap work myLib
```

And then, for VHDL compilation:

````bash
$ cd $tmp
$ vcom $ds2018/20180416/vhdl/foo.vhd
$ vcom $ds2018/20180416/vhdl/foo_sim.vhd
```

For VHDL simulation:

````bash
$ cd $tmp
$ vsim foo_sim
```

For synthesis:

````bash
$ cd $tmp
$ vivado -mode batch -source $ds2018/20180416/scripts/foo.syn.tcl -notrace -tclargs $ds2018
$ bootgen -w -image $ds2018/20180416/scripts/boot.bif -o boot.bin 
```

## The AXI4 lite protocol

Brief discussion about the AXI4 lite protocol.

## Synthesis and tests of the AXI4 lite register

We will now synthesize our design with the Vivado tool by Xilinx to map it in the programmable logic part of the Zynq core of the Zybo. The `20180416/scripts/reg_axi.syn.tcl` TCL script will automate the synthesis and the `20180416/scripts/boot.bif` file will tell the Xilinx tools what to do with the synthesis result. As usual, before you can use the synthesis script, you will have to edit it and add information about the primary inputs and outputs (I/O) in the definition of the `ios` array, near the top of the file. Cross-check your edits with your neighbors.

Observe the part of the synthesis script entitled "_Addresses ranges_". It defines the base address of the peripheral in the system address map (property `offset`) and its address range (property `range`). Remember these two values.

If everything looks fine, synthesize:

```bash
$ cd $tmp
$ vivado -mode batch -source $ds2018/20180416/scripts/reg_axi.syn.tcl -notrace -tclargs $ds2018
$ bootgen -w -image $ds2018/20180416/scripts/boot.bif -o boot.bin 
```

The synthesis result is in `$tmp/top.runs/impl_1/top_wrapper.bit`. It is a binary file called a *bitstream* that is be used by the Zynq core to configure the programmable logic. The last command (`bootgen`) packed it with the first (`fsbl.elf`) and second (`u-boot.elf`) stage software boot loaders that we already used and that can be found in `/packages/LabSoC/builds/zybo`. The result is a *boot image*: `boot.bin`.

## Test your design on the Zybo

Mount the micro SD card on a computer and define a shell variable that points to it:

```bash
$ SDCARD=<path-to-mounted-sd-card>
```

If your micro SD card does not yet contain the `sab4z` example design, prepare it:

```bash
$ cd /packages/LabSoC/builds/zybo
$ cp uImage devicetree.dtb uramdisk.image.gz $SDCARD
```

Or:

```bash
$ cd /tmp
$ wget https://perso.telecom-paristech.fr/pacalet/archives/zybo/sdcard.tgz
$ tar -C $SDCARD -xf sdcard.tgz
```

Copy the new boot image to the micro SD card:

```bash
$ cp $tmp/boot.bin $SDCARD
$ sync
```

Unmount the micro SD card, eject it, plug it on the Zybo and power up. Use the slide switches to read the read-only register. Does it count as expected? What is the value of the read-write register. In a terminal launch a serial communication program (e.g. `picocom`) and attach it to the serial device that corresponds to the Zybo board:

```bash
$ picocom -b115200 /dev/ttyUSB1
...
Welcome to SAB4Z (c) Telecom ParisTech
sab4z login: root
Sab4z> 
```

You are now connected as the `root` user under the GNU/Linux OS that runs on the Zynq core of the Zybo board. Use the `devmem` utility to read and write the registers:

```bash
Sab4z> devmem -h
BusyBox v1.25.1 (2017-03-29 16:03:15 CEST) multi-call binary.

Usage: devmem ADDRESS [WIDTH [VALUE]]

Read/write from physical address

	ADDRESS	Address to act upon
	WIDTH	Width (8/16/...)
	VALUE	Data to be written
```

When you are done with your experiments, cleanly shut down the Zybo:

```bash
Sab4z> poweroff
...
Requesting system poweroff
reboot: System halted
```

You can now safely power off the board. To quit `picocom` type <kbd>ctrl</kbd>+A <kbd>ctrl</kbd>+X.

## AXI4 lite DHT11 controller

Specify and design a AXI4 lite compliant wrapper for the DHT11 controller.

[Pipelines page]: https://gitlab.eurecom.fr/renaud.pacalet/ds-2018/pipelines
[datashet of the DHT11 sensor]: /doc/DHT11.pdf

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
