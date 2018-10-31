<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# VHDL coding challenges

* [Introduction](#introduction)
* [Environment set-up](#environment-set-up)
* [Learn a bit of VHDL](#learn-a-bit-of-vhdl)
* [Coding challenge: a shift register](sr.md)
* [Learn a bit more of VHDL](#learn-a-bit-more-of-vhdl)
* [Coding challenge: a timer](timer.md)
* [Learn again a bit more of VHDL](#learn-again-a-bit-more-of-vhdl)
* [Coding challenge: blinking LEDs](lb.md)
* [Logic synthesis and test on the Zybo](#logic-synthesis-and-test-on-the-zybo)
* [The DHT11 controller](#the-dht11-controller)
* [The `g1` signal generator](#the-g1-signal-generator-continued)

## Introduction

During this lab we will have VHDL coding challenges. Each challenge must be completed in a limited amount of time. Your work is automatically evaluated and scored by the GitLab Continuous Integration System each time you push it. The scores are informative only. Use the challenges to check your VHDL understanding and skills. When instructed to do so:

1. Add-commit-push your branch,
1. Fetch, merge with `origin/master`,
1. Refresh this web page,
1. Follow the link to the next challenge (in the above table of content),
1. Code as fast as you can,
1. Compile, simulate with the provided simulation environment,
1. Add-commit-push your work,
1. Wait for the email,
1. If the evaluation failed, click on the **run** link in the email to see what went wrong, fix what needs to be and add-commit-push your work until all tests pass,
1. After the deadline, discuss your solution with your neighbours, ask questions.

## Environment set-up

First visit the [EURECOM GitLab web site], go to `Settings -> Notifications`. For the `pacalet/ds-2018` project select the `Custom` notification mode. Check the `Failed pipeline` and ` Successful pipeline` options such that you will receive the results of the evaluations by email each time you push.

As usual, configure your environment for VHDL simulation with Mentor Graphics Modelsim (see the [20180305](../20180305/README.md) lab) and synthesis with Xilinx Vivado (see the [20180312](../20180312/README.md) lab). Remember that it is always better to compile, simulate and synthesize out of the source tree. Example of set-up (adapt the suggested `vhdl`, `scripts` and `tmp` paths to your own case):

````bash
$ export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
$ export PATH=$PATH:/packages/LabSoC/Xilinx/bin
$ vhdl=/homes/mary/ds-2018/20180326/vhdl
$ scripts=/homes/mary/ds-2018/20180326/scripts
$ tmp=/tmp/mary/20180326
$ mkdir -p $tmp
$ cd $tmp
$ vlib myLib
$ vmap work myLib
```

And then, for VHDL compilation:

````bash
$ cd $tmp
$ vcom $vhdl/sr.vhd
$ vcom $vhdl/sr_sim.vhd
```

For VHDL simulation:

````bash
$ cd $tmp
$ vsim sr_sim
```

For synthesis:

````bash
$ cd $tmp
$ vivado -mode batch -source $scripts/lb-syn.tcl -notrace -tclargs $vhdl
$ bootgen -w -image $scripts/boot.bif -o boot.bin 
```

## Learn a bit of VHDL

Before starting our first challenge we need to learn how vectors can be sliced and concatenated. Open your copy of the [Free Range Factory] VHDL book and read carefully section 6.5, page 74. Make sure you understand:

* how to extract a sub-range of a vector (slicing),
* how to left-concatenate a single bit to a vector,
* how to right-concatenate a single bit to a vector,
* how to concatenate two vectors.

As an exercise, consider the following declarations:

```vhdl
signal a: std_ulogic_vector(31 downto 0);
signal x: std_ulogic;
signal m: std_ulogic_vector(23 downto 16);
```

How would you express the concatenation (left to right) of `m`, the 16 Least Significant Bits (LSBs) of `a`, two zero bits, the 16 Most Significant Bits (MSBs) of `a`, and `x`?

## Learn a bit more of VHDL

Before starting the next challenge read the following chapters of the documentation, they will be needed:

* [Generic parameters](../doc/generics.md)
* [Arithmetic: which types to use?](../doc/arithmetic-which-types-to-use.md)

Rework the shift register `sr.vhd` such that the length of the shift register is not hard-wired to 4 but a generic parameter `n` of type `positive` with default value 4. This will allow us to reuse it with a different length, if needed. Simulate again with `sr_sim.vhd`. Add-commit-push and check again that it passes the tests.

## Learn again a bit more of VHDL

Before starting the next challenge read the following chapter of the documentation, it will be needed:

* [Entity instantiations](../doc/entity-instantiations.md)

Have a look at the `sr_sim.vhd` and `timer_sim.vhd` provided simulation environments to see examples of entity instantiations.

## Logic synthesis and test on the Zybo

We will now synthesise our blinking LEDs design with the Vivado tool by Xilinx to map it in the programmable logic part of the Zynq core of the Zybo. The `lb-syn.tcl` TCL script will automate the synthesis and the `boot.bif` file will tell the Xilinx tools what to do with the synthesis result. Before you can use the synthesis script, you will have to edit it and add information about the primary inputs and outputs (I/O). Indeed, Vivado needs to know to which I/O pin of the Zynq core it must route the I/O of our design. All the information we need is available in the [Zybo reference manual] and in the [Zybo schematics]. You will find these two documents in the `doc` sub-directory. Open these two documents. Open the synthesis script with your favourite editor.

The missing information shall be provided in the definition of the `ios` array, near the top of the file. Let us deal with the primary clock `clk`, as an example. It will come from the on-board Ethernet chip depicted on Figure 13, page 21/26, of the [Zybo reference manual]. Note the corresonding pin of the Zynq core (`L16`) and the clock frequency (125 MHz). In the [Zybo schematics] find the I/O bank for this `L16` pin and deduce its LVCMOS voltage level (`LVCMOS33`). Use this piece of information to assign a value to the `frequency` variable and `clk` entry of the `io` array in the synthesis script.

The `areset` asynchronous reset will come from the righmost press-button (`BTN0`) of the Zybo board. The `led` output, of course, will be sent to the 4 LEDs of the Zybo board. Identify the corresponding pins and voltage levels.

Finally, select a `timeout` value. Remember that it represents the time, in micro-seconds, between two LED events. If it is too large the show will probably not be very exciting, while if it is too small, it will very likely be too fast for your eyes.

Cross-check your findings with your neighbours. If everything looks fine, synthesize:

````bash
$ cd $tmp
$ vivado -mode batch -source $scripts/lb-syn.tcl -notrace -tclargs $vhdl
$ bootgen -w -image $scripts/boot.bif -o boot.bin 
```

The synthesis result is in `top.runs/impl_1/top_wrapper.bit`. It is a binary file called a *bitstream* that is be used by the Zynq core to configure the programmable logic. Two important reports have also been produced:

* The resources usage report (`top.runs/impl_1/top_wrapper_utilization_placed.rpt`).
* The timing report (`top.runs/impl_1/top_wrapper_timing_summary_routed.rpt`).

Have a look at them and try to understand what you can. The last command (`bootgen`) packed the bitstream with the first (`fsbl.elf`) and second (`u-boot.elf`) stage software boot loaders that we already used with the continuity tester and that can be found in `/packages/LabSoC/builds/zybo`. The result is a *boot image*: `boot.bin`.

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
$ cp $syn/boot.bin $SDCARD
$ sync
```

Unmount the micro SD card, eject it, plug it on the Zybo, power on the Zybo and test your design.

## The DHT11 controller

Imagine how you could use one instance of the shift register and one instance of the timer to implement the DHT11 controller. What value would you give to their generic parameters? What other component(s) would we need? Start specifying the missing component(s).

## The `g1` signal generator (continued)

If you have some time left, continue working on the [previous lab](../20180319/README.md).

[Zybo reference manual]: ../doc/zybo_rm.pdf
[Zybo schematics]: ../doc/zybo_sch.pdf
[EURECOM GitLab web site]: https://gitlab.eurecom.fr/
[Free Range Factory]: http://freerangefactory.org/

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
