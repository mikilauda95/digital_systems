<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# Synopsys DC tutorial (logic synthesis)

* [Introduction](#introduction)
* [A bit of VHDL: `bit` versus `std_ulogic`](#a-bit-of-vhdl-bit-versus-std_ulogic)
* [Simulation and preparation of the `g1` signal generator](#simulation-and-preparation-of-the-g1-signal-generator)
* [Environment set-up](#environment-set-up)
* [Synthesis of the `g1` signal generator](#synthesis-of-the-g1-signal-generator)
* [Refinement of a VHDL model for synthesis](#refinement-of-a-vhdl-model-for-synthesis)
* [Schematics of synthesis result](#schematics-of-synthesis-result)
* [A bit of VHDL: initial values](#a-bit-of-vhdl-initial-values)
* [Adding a reset to `g1`](#adding-a-reset-to-g1)
* [Adding a chip enable to `g1`, synthesis for the Zybo](#adding-a-chip-enable-to-g1-synthesis-for-the-zybo)
* [A bit of VHDL: initial value declarations](#a-bit-of-vhdl-initial-value-declarations)
* [What's next?](#whats-next)

## Introduction

_Synopsys Design Compiler_ (_Synopsys DC_) is a logic synthesizer. It takes a HDL model, a library of standard logic cells, a set of synthesis commands and it generates a network of interconnected logic cells (a netlist). In this lab we will use a 28 nm standard cells library. With the following instructions you should be able to perform your first VHDL synthesis with _Synopsys DC_ in less than 3 hours.

**Credits**: this lab is made possible thanks to [Synopsys] and the [CNFM]. They provide colleges and universities with leading edge design tools for classroom instruction and academic research at a very low price.

**Note**: in the following the command lines that you're asked to type in begin with a `$`. This character represents the shell prompt and is not a part of the command.

The `scripts` sub-directory contains TCL scripts to automate the synthesis.

The `vhdl` sub-directory contains `g1.vhd`, the VHDL source files of the `g1` signal generator, and `g1_sim.vhd`, its simulation environment. The simulation environment is not synthesizable (as most simulation environments), but it will be useful to functionally re-validate `g1` when we will modify it. There is also a `g1_top.vhd` source file that we will use at the end of this lab to map our design to the FPGA fabric of the Zynq core of the Zybo board.

The trivial errors in `g1.vhd` have been fixed. The functional bug that prevented the immediate start of a new macro-cycle at the end of a macro-cycle has also been fixed. Open the VHDL source files and check your understanding of the error and bug fixes. Note that the `bit` type has been replaced by the more commonly encountered `std_ulogic` type, both in `g1.vhd` and `g1_sim.vhd`.

## A bit of VHDL: `bit` versus `std_ulogic`

The `bit` type is what is called an _enumerated type_ in VHDL. Its declaration is found in the `std.standard` package of the `std` standard library:

```vhdl
type BIT is ('0', '1');
```

It is not very frequently used because it is (a bit) too simple. The 9-valued `std_ulogic` enumerated type (or its resolved subtype `std_logic`) is usually preferred. It is defined in the `ieee.std_logic_1164` package of the `ieee` standard library:

```vhdl
-------------------------------------------------------------------    
-- logic state system  (unresolved)
-------------------------------------------------------------------    
type STD_ULOGIC is ( 'U',             -- Uninitialized
                     'X',             -- Forcing  Unknown
                     '0',             -- Forcing  0
                     '1',             -- Forcing  1
                     'Z',             -- High Impedance   
                     'W',             -- Weak     Unknown
                     'L',             -- Weak     0       
                     'H',             -- Weak     1       
                     '-'              -- Don't care
                     );
```

For now, we will only consider values `'U'`, `'0'` and `'1'` of the `std_ulogic` type. The other values will be explained later.

**Note**: in order to use the `std_ulogic` type it is necessary to declare the `ieee` library and the use of the `ieee.std_logic_1164` package:

```vhdl
-- file foobar.vhd
library ieee;
use ieee.std_logic_1164.all;
...
entity foobar is
  port(clk: in std_ulogic;
...
```

**Note**: contrary to `std_ulogic`, to use the `bit` type we do not need to declare the use of library `std` and of package `std.standard` because this package is so essential (it also defines types `boolean`, `integer`,...) that it is always implicit in any VHDL source code, like if all compilation units were implicitly in the scope of:

```vhdl
library std;
use std.standard.all;
```

**Note**: you can find the VHDL source code of these packages in the installation of the simulation tools. For Modelsim, from the EURECOM GNU/Linux lab rooms, they are respectively in:
* `/packages/LabSoC/Mentor/tools/Modelsim/VERSION/modeltech/vhdl_src/std/standard.vhd`
* `/packages/LabSoC/Mentor/tools/Modelsim/VERSION/modeltech/vhdl_src/ieee/stdlogic.vhd`

(replace `VERSION` by any available version).

## Simulation and preparation of the `g1` signal generator

As synthesis takes time, it is always a good idea to validate the design by simulation before synthesizing it. Let us simulate the current version of `g1`:

````bash
$ vhdl=/homes/mary/ds-2018/20180319/vhdl
$ scripts=/homes/mary/ds-2018/20180319/scripts
$ tmp=/tmp/mary/20180319
$ mkdir -p $tmp
$ cd $tmp
$ vlib myLib
$ vmap work myLib
$ vcom $vhdl/g1.vhd $vhdl/g1_sim.vhd
$ vsim g1_sim
```

Observe the initial values of the various signals. What is the initial value of `s`? At what simulation time does it change? We will come back to this later.

## Environment set-up

Open a terminal and add `/packages/LabSoC/Synopsys/dc/bin` to your `PATH` environment variable:

```bash
$ export PATH=$PATH:/packages/LabSoC/Synopsys/dc/bin
```

Note that you will have to type this command again every time you will want to use the tools from a new shell. In order to automatically perform this initialization at login, such that it is inherited by every new shell, add this command in your `~/.profile` initialization script:

```bash
$ echo 'export PATH=$PATH:/packages/LabSoC/Synopsys/dc/bin' >> ~/.profile
```

We are ready to synthesize with _Synopsys DC_.

## Synthesis of the `g1` signal generator

If the design is functionally correct, it is time to synthesize it. The `syn.tcl` synthesis script contains a list of declarations and commands for the synthesis. `Synopsys DC` will parse this script and execute each of the statements it contains.

* Have a look at the beginning of this script, it is commented. What is the target clock frequency? What are the input and output delays? Try to understand the different synthesis parameters. You can change the default value of any of them by defining (and exporting) shell environment variables with the same name before invoking the `Synopsys DC`. Note that there is no default value for the `VHD` parameter that specifies the path of the VHDL source file to synthesize. You **must** thus define and export the `VHD` shell environment variable.
* Launch the synthesis:

    ```bash
    $ cd $tmp
    $ export VHD=$vhdl/g1.vhd
    $ dc_shell -f $scripts/syn.tcl
    ```

* Look at the error messages. What is wrong?

## Refinement of a VHDL model for synthesis

As it is, our VHDL model of the `g1` signal generator is not synthesizable. Its description is too high level, the synthesizer expects a more detailed description, that is, a description that clearly reflects a digital hardware machine.

* Draw a block diagram of a digital hardware circuit according the method described in the [Digital hardware design using VHDL in a nutshell] chapter of the documentation.
* Modify the VHDL model to reflect your block diagram. Remember that most logic synthesizers support only sensitivity lists, not wait statements. After each modification simulate to verify that the functionality is still what it should be and synthesize again. Repeat until you see no errors and no warnings for which you do not have an explanation.
* The synthesizer generated several report files (`dc_log.html`, `g1.area`, `g1.timing`). Some of them are textual and some others are HTML that you can open with your favourite web browser. Look at them and try to understand their content.
* What is the silicon area of the synthesized circuit? Hint: the unit is the square micron.
* What is the critical path of the circuit (start and end points)? What is its propagation delay? What is the corresponding maximum clock frequency? What was the original timing constraint. Is it met?
* Have a look at the Verilog model (`g1.v`) of the synthesized netlist. Do you understand it?
* How many D-flip-flops (1 bit registers) should it contain, according to your VHDL model? How many DFFs does it actually contain? If there is a mismatch, try to understand it.
* The [datasheet] of the target standard cells library is available in PDF format. Open it and search for the documentation of some of the cells used by the synthesizer. Try to understand as much as you can about these cells.

## Schematics of synthesis result

* Launch the GUI:

    ```bash
    $ cd $tmp
    $ dc_shell -f $scripts/gui.tcl
    ```

  The schematic of your design should be loaded in one of the sub-windows.
* Explore the schematic, query the properties of some logic gate (click on a gate to select it, right-click and select the _Properties_ item in the pop-up menu).
* Locate the endpoint of the critical path in the schematic viewer of the GUI and select it. In the _Select_ menu of the GUI chose _Paths From/Through/To..._ item. A new window pops up that allows you to specify the paths to highlight in the schematic. Specify only the endpoint (the _To_ row) as the currently selected _net_. Click on apply and observe the highlighted critical path on the schematic.

## A bit of VHDL: initial values

In VHDL simulation, when a signal is not assigned a value at time 0, it takes the leftmost value of its type: `'0'` for the `bit` type, `'U'` for the `std_ulogic` type. `'U'` is the leftmost value in `std_ulogic` declaration and it means **U**ninitialized. Do you understand why? Do you understand what you observed during the first simulation?

This `'U'` value of type `std_ulogic` is convenient in simulation because it clearly shows that the signal has not been assigned yet and, in case its value is used before the first assignment, the computations will not work as expected. This is one of the various advantages of type `std_ulogic` over type `bit`. With `bit` the default initial value being `'0'`, things may look correct while they will not necessarily be in the final hardware.

In hardware there is nothing like `'U'` value. We can roughly distinguish two types of hardware target technologies:

* The hardware target technologies that offer one form or another of initialization at power-up, like the FPGA target of the Zynq core of the Zybo board (the one we will be using most of the time during the labs). In FPGAs that support power-up initialization, all memory elements are initialized to a default value (usually `'0'``) just after power-up. **Warning**: never rely on this before having checked that your target FPGA supports power-up initialization.
* The other hardware target technologies, like the one that we use today and that is dedicated to custom integrated circuits. In these technologies, a wire that is not driven by a logic gate is floating and, if used in computations, can lead to any result. A consequence of this is that, in a circuit containing memory elements like registers, it is preferable to add a _reset_ mechanism that forces the value of all memory elements when the _reset_ input is asserted.

## Adding a reset to `g1`

Edit `g1.vhd` to add a `srstn` (Synchronous ReSeT Not) input port. This input will be our synchronous, active low, reset (thus its name). Synchronous means that it will be taken into account only on rising edges of the clock. Modify the VHDL code such that, on any rising edge of the clock, if the `srstn` input is `'0'` (active low), all memory elements are forced to a known fixed value that makes sense. Also edit `g1_sim.vhd` to reflect this modification and to test it: set `srstn` low at the beginning of the simulation, wait for 5 clock periods and set it high until the end of the simulation. Simulate and check that the `s` output takes the expected known value after the first rising edge of the clock.

* Try to synthesize again with different target clock periods (environement variable `CP`). Compare the different silicon area/clock frequency pairs. Compare also with what others got. Try to relax the timing constraints and optimize your design for silicon area. What is the area of the smallest circuit you can get? What is its maximum clock frequency? Conversely, try to optimize your design for speed. What is the area and maximum clock frequency of your fastest circuit? What would you conclude?
* Replace the synchronous reset by an asynchronous one. That is, one that is taken into account immediately when it goes low, not at the next rising edge of the clock.
* Simulate and synthesize again for maximum clock frequency and then for minimum area. What is the impact of the synchronous/asynchronous reset choice? Did the synthesizer use different flip-flops?
* Rework the architecture to improve the maximum clock frequency. Try, for instance, to use shift registers instead of a counter. What is the fastest circuit you can get?
* Same question to reduce the silicon area. What is the smallest circuit you can get?

## Adding a chip enable to `g1`, synthesis for the Zybo

Edit `g1.vhd` to add a `ce` (chip enable) input port. We will use this input to artificially reduce the clock frequency of our design such that we can map it to the FPGA fabric of the Zynq core of the Zybo board and use a LED to vizualize the output of `g1`. Modify the VHDL code to skip all rising edges of the clock for which `ce='0'`. The `g1_top.vhd` wrapper contains a counter that will assert `ce` once every 12500000 clock cycles. As the complete design will be clocked at 125 MHz, this will reduce the clock frequency seen by `g1` to 10 Hz.

* Have a look at `g1_top.vhd` and try to understand it.
* Compile the new `g1.vhd` and `g1_top.vhd` and fix the errors, if any.
* Synthesize the complete design for the Zynq core of the Zybo board, generate the boot image:

    ```bash
    $ cd $tmp
    $ vivado -mode batch -source $scripts/g1_top.tcl -notrace -tclargs $vhdl
    $ bootgen -w -image $scripts/boot.bif -o boot.bin 
    ```

* Mount the micro SD card on a computer, define a shell variable that points to it and copy the boot image to the micro SD card:

    ```bash
    $ SDCARD=<path-to-mounted-sd-card>
    $ cp $syn/boot.bin $SDCARD
    $ sync
    ```

Unmount the micro SD card, eject it, plug it on the Zybo and power up. Use the push-button 1 and the LED 0 to test the design. Try also to test the reset (push-button 0).

## A bit of VHDL: initial value declarations

VHDL supports initial value declaration:

```vhdl
signal foo: std_ulogic := '1'; -- Note the := operator, not <=
```

This forces the simulator to assign the declared value at time 0, instead of the lefmost value in the type declaration. With FPGAs that support power-up initialization, the logic synthesizers (Xilinx Vivado, for instance) can honor these initial value declarations. This may be convenient in case the desired initial value is not the default one.

**Warning**:
* Remember that, depending of the target technology, this is not always synthesizable. If you use this, your design is not portable any more. Moreover, because the simulation always honors initial value declarations, you will not be warned that something is wrong until after it is too late and you already manufactured an expensive and unsuable custom integrated circuit.
* It does not provide a way to restore a known stable state after power-up.
* It works only for signals corresponding to the outputs of memory elements.

Conclusion: unless you have a very very good reason (for instance because it saves a lot of hardware resources or leads to a much faster design), do not use initial value declarations for synthetisable designs.

## What's next?

If we really wanted to manufacture an integrated circuit with our design, the logic synthesis would only be the first step. The produced netlist would be modified by other Computer Aided Design (CAD) tools to guarantee that the clock is evenly distributed, or that the circuit can be efficiently and reliably tested after manufacturing, or for several other reasons. Then, it would be _placed and routed_, that is, each standard cell would be positionned on the floor plan of the circuit and metal wires would be drawn such that the cells are interconnected as specified in the netlist. Some more metal wires would be added for ground and power supply. Next, accurate simulations would be run to verify that the parasitic (but unavoidable) capacitances and resistors created by the metal wires did not compromize the target performance of the circuit. Other verifications would be conducted to verify that the design rules imposed by the manufacturer (wires spacing and minimum width...) are respected. It is only after all this that we would take the risk, send the complete database to the manufacturer, plus a big cheque, wait for a few weeks and get the first samples back for testing.

But in this course, as all this takes time and costs a lot of money, we will mostly use FPGAs; they are much more convenient for education.

[Synopsys]: http://www.synopsys.com/
[CNFM]: http://web-pcm.cnfm.fr/
[datasheet]: ../doc/std_cell_lib_datasheet.pdf
[Digital hardware design using VHDL in a nutshell]: ../doc/digital-hardware-design-using-vhdl-in-a-nutshell.md

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
