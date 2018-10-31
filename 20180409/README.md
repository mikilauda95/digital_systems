<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# VHDL coding challenges, DHT11 controller

* [Introduction](#introduction)
* [Environment set-up](#environment-set-up)
* [Learn a bit of VHDL](#learn-a-bit-of-vhdl)
* [Coding challenge: shift register](sr2.md)
* [Coding challenge: 3-stages re-synchronizer and edges detector](edge.md)
* [Coding challenge: counter](counter.md)
* [Coding challenge: timer](timer2.md)
* [Discussion: Moore and Mealy finite state machines](#discussion-moore-and-mealy-finite-state-machines)
* [Coding challenge: state machine](sm.md)
* [The DHT11 controller](#the-dht11-controller)
* [Coding challenge: `sm2` Mealy finite state machine](sm2.md)
* [Coding challenge: the DHT11 controller](dht11_ctrl.md)
* [Stand-alone DHT11 controller](#stand-alone-dht11-controller)

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

As usual, configure your environment for VHDL simulation with Mentor Graphics Modelsim (see the [20180305](../20180305/README.md) lab) and synthesis with Xilinx Vivado (see the [20180312](../20180312/README.md) lab). Remember that it is always better to compile, simulate and synthesize out of the source tree. Example of set-up (adapt the suggested `vhdl`, `scripts` and `tmp` paths to your own case):

````bash
$ export PATH=$PATH:/packages/LabSoC/Mentor/Modelsim/bin
$ export PATH=$PATH:/packages/LabSoC/Xilinx/bin
$ vhdl=/homes/mary/ds-2018/20180409/vhdl
$ scripts=/homes/mary/ds-2018/20180409/scripts
$ tmp=/tmp/mary/20180409
$ mkdir -p $tmp
$ cd $tmp
$ vlib myLib
$ vmap work myLib
```

And then, for VHDL compilation:

````bash
$ cd $tmp
$ vcom $vhdl/foo.vhd
$ vcom $vhdl/foo_sim.vhd
```

For VHDL simulation:

````bash
$ cd $tmp
$ vsim foo_sim
```

For synthesis:

````bash
$ cd $tmp
$ vivado -mode batch -source $scripts/foo.syn.tcl -notrace -tclargs $vhdl
$ bootgen -w -image $scripts/boot.bif -o boot.bin 
```

## Learn a bit of VHDL

You read already chapter 4 of the [Free Range Factory] VHDL book. Just in case you do not remember it, simple processes can be replaced by equivalent *simple*, *conditional* or *selected* *concurrent signal assignments*. These 3 forms are detailed in sections 4.3, 4.4 and 4.5 of the [Free Range Factory] VHDL book.

## Discussion: Moore and Mealy finite state machines

* What is a finite state machine?
* What are the differences between Moore and Mealy state machines?
* What are the advantages and drawbacks of Moore and Mealy state machines?
* Can we say that a Moore state machine is a special case of a Mealy state machine?
* Can we say that a Mealy state machine is a special case of a Moore state machine?
* What does the states diagram of a Moore state machine look like? Where do we indicate the value of the ouptuts? The conditions of the transitions?
* Draw the block diagram of a Moore state machine.
* What is the minimum number of processes needed to model a Moore state machine? Why?
* Are there specific Moore state machines that can be modelled with less processes?
* What does the states diagram of a Mealy state machine look like? Where do we indicate the value of the ouptuts? The conditions of the transitions?
* Draw the block diagram of a Mealy state machine.
* What is the minimum number of processes needed to model a Mealy state machine? Why?
* Are there specific Mealy state machines that can be modelled with less processes?
* What are the differents ways to represent states? What are their respective advantages and drawbacks?

## The DHT11 controller

Note: the [datashet of the DHT11 sensor] is available in `doc/DHT11.pdf`.

The following block diagram represents a DHT11 humidity and temperature sensor connected to a controller (the part enclosed in the dashed box and named `dht11_ctrl`).

![`dht11`](figures/dht11.png)

The single-wire communication protocol between the sensor and our controller is represented on the following waveform. The dashed low levels are driven by the `tsb` tri-state buffer (when `dht11_ctrl` asserts `data_drv` high), and the plain ones are driven by the sensor. All high levels are driven by the pull-up resistor.

![`dht11`](figures/dht11_protocol.png)

We will now assemble our `sr2`, `counter`, `timer2` and `edge` modules to design the `dht11_ctrl` controller. We will also need a state machine (`sm2`) to drive all these modules. It will be the brain of our controller.

### Interface

The file named `dht11_ctrl.vhd` in the `20180409/vhdl` directory contains an already coded entity named `dht11_ctrl` with the following generic parameters:

| Name       | Type                            | Description                                                                 |
| :----      | :----                           | :----                                                                       |
| `freq`     | `positive range 1 to 1000`      | Master clock frequency in MHz (also clock periods per micro-second)         |
| `init`     | `natural`                       | Duration of low pulse of _init_ command in micro-seconds                    |
| `tmax`     | `natural`                       | Maximum value of timer                                                      |
| `cmax`     | `natural`                       | Maximum value of counter                                                    |

... and the following input-output ports:

| Name       | Type                             | Direction | Description                                                             |
| :----      | :----                            | :----     | :----                                                                   |
| `clk`      | `std_ulogic`                     | in        | Master clock. The design is synchronized on the rising edge of `clk`    |
| `sresetn`  | `std_ulogic`                     | in        | **Synchronous**, active **low** reset                                   |
| `data_in`  | `std_ulogic`                     | in        | Data line                                                               |
| `start`    | `std_ulogic`                     | in        | Start signal, initiate a data transfer when active                      |
| `data_drv` | `std_ulogic`                     | out       | When active, drive data line low with tri-state buffer `tsb`            |
| `busy`     | `std_ulogic`                     | out       | Asserted during data transfer                                           |
| `err`      | `std_ulogic`                     | out       | Protocol error indicator                                                |
| `do`       | `std_ulogic_vector(39 downto 0)` | out       | 40-bits read value                                                      |

Note: according the [datashet of the DHT11 sensor] we could get rid of the `init` generic parameter and hard-wire the duration of the low pulse of the _init_ command to `20` ms (`20000` micro-seconds). But simulations would become very long and this would not be convenient. For simulations we will set the `init` generic parameter to a much smaller value (`200`) while for synthesis we will set it to the `20000` default. Same for the clock frequency: for simulation we will set it to a small value (`2 MHz`) while for synthesis we will set it to the actual clock frequency of our system (`125 MHz` in the stand-alone version). And same for the `1` s (`1000000` micro-seconds) warm-up delay and recommended interval between two measurements represented by the `tmax` generic parameter. For synthesis we will set it to `1000000` but for simulations a smaller value will be much more convenient.

### Architecture

The system is synchronous on the rising edge of the `clk` clock. `sresetn` is a synchronous, active low, reset. For better readability, `clk` and `sresetn` are not represented on the block diagram, but, on rising edges of `clk`, all registers of `dht11_ctrl` are reset to zero if `sresetn` is low, else they sample their input. Our VHDL code must be synthesizable, the VHDL standard we are using is 2002, and output ports can thus **not** be read.

`dht11_ctrl` implements the single-wire (`data_in`) communication protocol with the DHT11 sensor. The wire can be driven low by `dht11_ctrl` or by the sensor. Else, it is pulled high by a pull-up resistor. To drive `data_in` low, `dht11_ctrl` asserts `data_drv` high, which turns the `tsb` tri-state buffer in its driving state; the driven value is always `0V`.

## Stand-alone DHT11 controller

As it is our DHT11 controller is not yet ready for synthesis and mapping on the Zybo board. The next step consists in designing a stand-alone wrapper around it such that it can be connected to the slide-switches, LEDs, push-buttons, system clock of the Zybo. The wrapper shall:

* re-synchronize (2 stages) and invert the input from push-button 0 to deliver the `sresetn` synchronous active low reset of `dht11_ctrl`,
* use one more instance of `edge` to re-synchronize the input from push-button 1 and detect its rising edges; connect the `re` output of this `edge` instance to the `start` input of `dht11_ctrl`,
* use the 4 slide-switches to select a 4-bits nibble among the 10 of the `do` output of `dht11_ctrl` and use it to drive the 4 LEDs; the 40 bits `do` output can be split in 10 nibbles; use 10 different configurations of `sw` to select the nibble, from `"0000"` for `do(3 downto 0)` to `"1001"` for `do(39 downto 36)`,
* in configuration `1111` of `sw`, drive the 4 LEDs with `00BE` where `B` and `E` are the `busy` and `err` outputs of `dht11_ctrl` respectively,
* in all other configurations of `sw`, drive the 4 LEDs with `1010`,
* connect the on-board 125 MHz clock to the `clk` clock input of `dht11_ctrl`.
* instantiate the `tsb` tri-state buffer, connect its input to ground, its command to the `data_drv` output of `dht11_ctrl`, and connect its output to pin number one of PMOD connector `JE` and to the `data_in` input of `dht11_ctrl`,

The file named `dht11_ctrl_sa.vhd` in the `20180409/vhdl` directory contains an already coded entity named `dht11_ctrl_sa` with the following generic parameters:

| Name       | Type                            | Description                                                                 |
| :----      | :----                           | :----                                                                       |
| `freq`     | `positive range 1 to 1000`      | Master clock frequency in MHz (also clock periods per micro-second)         |
| `init`     | `natural`                       | Duration of low pulse of _init_ command in micro-seconds                    |
| `tmax`     | `natural`                       | Maximum value of timer                                                      |
| `cmax`     | `natural`                       | Maximum value of counter                                                    |

... and the following input-output ports:

| Name       | Type                             | Direction | Description                                                             |
| :----      | :----                            | :----     | :----                                                                   |
| `clk`      | `std_ulogic`                     | in        | Master clock. The design is synchronized on the rising edge of `clk`    |
| `areset`   | `std_ulogic`                     | in        | **Asynchronous**, active **high** reset                                 |
| `btn`      | `std_ulogic`                     | in        | Push button used for start signal                                       |
| `sw`       | `std_ulogic_vector(3 downto 0)`  | in        | Four slide-switches                                                     |
| `data`     | `std_logic`                      | inout     | Data line (bidirectional, so **resolved** type)                         |
| `led`      | `std_ulogic_vector(3 downto 0)`  | out       | Four LEDs                                                               |

Populate the architecture of `20180409/vhdl/dht11_ctrl_sa.vhd`. The `tsb` tri-state buffer is already instantiated.

### Peer review

Compare your solution with your neighbours'.

### Synthesis and tests on the Zybo board

We will now synthesise our design with the Vivado tool by Xilinx to map it in the programmable logic part of the Zynq core of the Zybo. The `20180409/scripts/dht11_ctrl_sa.syn.tcl` TCL script will automate the synthesis and the `20180409/scripts/boot.bif` file will tell the Xilinx tools what to do with the synthesis result. Before you can use the synthesis script, you will have to edit it and add information about the primary inputs and outputs (I/O). Indeed, Vivado needs to know to which I/O pin of the Zynq core it must route the I/O of our design. All the information we need is available in the [Zybo reference manual] and in the [Zybo schematics]. You will find these two documents in the `doc` sub-directory. Open these two documents. Open the synthesis script with your favourite editor.

The missing information shall be provided in the definition of the `ios` array, near the top of the file. Let us deal with the primary clock `clk`, as an example. It will come from the on-board Ethernet chip depicted on Figure 13, page 21/26, of the [Zybo reference manual]. Note the corresonding pin of the Zynq core (`L16`). In the [Zybo schematics] find the I/O bank for this `L16` pin and deduce its LVCMOS voltage level (`LVCMOS33`). Use this piece of information to assign a value to the `clk` entry of the `io` array in the synthesis script.

Do the same for the other inputs and outputs. Cross-check your findings with your neighbours. If everything looks fine, synthesize (replace `<init>`, `<tmax>` and `<cmax>` by the appropriate values):

```bash
$ export PATH=$PATH:/packages/LabSoC/Xilinx/bin
$ syn=/tmp/mary/20180409/syn
$ mkdir -p $syn
$ cd $syn
$ vivado -mode batch -source $scripts/dht11_ctrl_sa.syn.tcl -notrace -tclargs $vhdl <init> <tmax> <cmax>
$ bootgen -w -image $scripts/boot.bif -o boot.bin 
```

The synthesis result is in `$syn/top.runs/impl_1/top_wrapper.bit`. It is a binary file called a *bitstream* that is be used by the Zynq core to configure the programmable logic. The last command (`bootgen`) packed it with the first (`fsbl.elf`) and second (`u-boot.elf`) stage software boot loaders that we already used and that can be found in `/packages/LabSoC/builds/zybo`. The result is a *boot image*: `boot.bin`.

### Test your design on the Zybo

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

Unmount the micro SD card, eject it, plug it on the Zybo but do not power up now. First imagine how you will connect the DHT11 sensor to the `JE` PMOD connector (you will need the male-female wire). Cross-check with your neighbours. Power on the Zybo and test.

[Pipelines page]: https://gitlab.eurecom.fr/renaud.pacalet/ds-2018/pipelines
[Free Range Factory]: http://freerangefactory.org/
[datashet of the DHT11 sensor]: /doc/DHT11.pdf
[Zybo reference manual]: ../doc/zybo_rm.pdf
[Zybo schematics]: ../doc/zybo_sch.pdf

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
