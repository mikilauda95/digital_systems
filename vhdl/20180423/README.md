<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# AXI4 lite DHT11 controller

During this lab we will design an AXI4 lite compliant wrapper around the DHT11 controller, such that sensed data can be read from the software stack that runs on the ARM microprocessor of the Zynq core of the Zybo board. After synthesis we will map our design on the FPGA matrix of the Zynq core. Then, we will interact with the GNU/Linux OS running on the ARM processor and read the sensed data with regular load operations at the physical addresses of the interface registers of our hardware peripheral.

## Interface

Edit the file named `dht11_ctrl_axi.vhd` in the `20180423/vhdl` directory. An entity named `dht11_ctrl_axi` is already coded with the following generic parameters:

| Name       | Type                            | Description                                                                 |
| :----      | :----                           | :----                                                                       |
| `freq`     | `positive range 1 to 1000`      | Master clock frequency in MHz (also clock periods per micro-second)         |
| `init`     | `natural`                       | Duration of low pulse of _init_ command in micro-seconds                    |
| `tmax`     | `natural`                       | Maximum value of timer                                                      |
| `cmax`     | `natural`                       | Maximum value of counter                                                    |

... and the following input-output ports:

| Name             | Type                             | Direction | Description                                                           | 
| :----            | :----                            | :----     | :----                                                                 | 
| `aclk`           | `std_ulogic`                     | in        | Master clock. The design is synchronized on the rising edge of `aclk` | 
| `aresetn`        | `std_ulogic`                     | in        | **Synchronous**, active **low** reset                                 | 
| `s0_axi_araddr`  | `std_ulogic_vector(11 downto 0)` | in        | Read request address (12 bits = 4kB)                                  | 
| `s0_axi_arprot`  | `std_ulogic_vector(2 downto 0)`  | in        | Read request protection flags (ignored)                               | 
| `s0_axi_arvalid` | `std_ulogic`                     | in        | Read request (address and protection flags) valid                     | 
| `s0_axi_arready` | `std_ulogic`                     | out       | Read request (address and protection flags) acknowledge               | 
| `s0_axi_awaddr`  | `std_ulogic_vector(11 downto 0)` | in        | Write request address (12 bits = 4kB)                                 | 
| `s0_axi_awprot`  | `std_ulogic_vector(2 downto 0)`  | in        | Write request protection flags (ignored)                              | 
| `s0_axi_awvalid` | `std_ulogic`                     | in        | Write request (address and protection flags) valid                    | 
| `s0_axi_awready` | `std_ulogic`                     | out       | Write request (address and protection flags) acknowledge              | 
| `s0_axi_wdata`   | `std_ulogic_vector(31 downto 0)` | in        | Write request data                                                    | 
| `s0_axi_wstrb`   | `std_ulogic_vector(3 downto 0)`  | in        | Write request byte enables                                            | 
| `s0_axi_wvalid`  | `std_ulogic`                     | in        | Write request (data and byte enables) valid                           | 
| `s0_axi_wready`  | `std_ulogic`                     | out       | Write request (data and byte enables) acknowledge                     | 
| `s0_axi_rdata`   | `std_ulogic_vector(31 downto 0)` | out       | Read response data                                                    | 
| `s0_axi_rresp`   | `std_ulogic_vector(1 downto 0)`  | out       | Read response status (OKAY, EXOKAY, SLVERR or DECERR)                 | 
| `s0_axi_rvalid`  | `std_ulogic`                     | out       | Read response (data and status) valid                                 | 
| `s0_axi_rready`  | `std_ulogic`                     | in        | Read response (data and status) acknowledge                           | 
| `s0_axi_bresp`   | `std_ulogic_vector(1 downto 0)`  | out       | Write response status (OKAY, EXOKAY, SLVERR or DECERR)                | 
| `s0_axi_bvalid`  | `std_ulogic`                     | out       | Write response (status) valid                                         | 
| `s0_axi_bready`  | `std_ulogic`                     | in        | Write response (status) acknowledge                                   | 
| `data`           | `std_logic`                      | inout     | Data line (bidirectional, so **resolved** type)                       |

Note: the tri-state buffer used to drive the data line low is already instantiated.

## Architecture

The AXI4 lite DHT11 controller is designed to be connected to the ARM microprocessor of the Zynq core of the Zybo board. The interface with the microprocessor complies with the AXI4 lite protocol. Data busses are 32 bits wide (the ARM microprocessor is a 32 bits microprocessor) and address busses are 12 bits wide, allowing 4 kB of address space for the peripheral (the minimum supported by Xilinx tools). But only 8 bytes in this address space are actually mapped. Each time the microprocessor executes a load or a store instruction at a physical address that falls in these 4 kB, the peripheral receives the corresponding read or write request and must answer the request according the AXI4 lite protocol.

The detailed specifications of the AXI4 lite DHT11 controller are the following. Please read them carefully, each aspect is important.

### DHT11 controller, internal signals and internal registers

* The `dht11_ctrl` that we already designed is instantiated unmodified in `dht11_ctrl_axi` (just as it was in `dht11_ctrl_sa`, the stand-alone version). It is an **entity** instantiation, not a component instantiation. Its `clk`and `sresetn` ports are connected to the `aclk` and `aresetn` inputs of `dht11_ctrl_axi`, respectively. Its `data_in` and `data_drv` ports are connected to the already declared internal signals `data_in` and `data_drv`, respectively. For the four remaining ports declare four more internal signals, with same names, and connect them. The behaviour of the `start` internal signal is explained at the end of this section.
* The `dht11_ctrl` used for the automatic evaluation is not yours. It is a reference one. Only your AXI4 lite wrapper is validated. It must thus work with **any** valid `dht11_ctrl`; avoid making wrong assumptions about `dht11_ctrl`.
* A one-bit register is used to memorize protocol errors. Declare a `perr_reg` internal signal to model the output of this register. On rising edges of the clock `perr_reg` samples:
  * `'0'` if the reset is active,
  * else `'1'` if the `err` output of `dht11_ctrl` is `'1'`,
  * else '0' if `start` is asserted high,
  * else it remains unchanged.
* A 32-bits register is mapped at offset address 0 (from the base address of the peripheral). Its role is to store the last sensed values. From the processor's perspective, it is read-only. Declare a `data_reg` internal signal to model the output of this register. On rising edges of the clock `data_reg` samples:
  * the all-zeroes value if the reset is active,
  * else the 32 Most Significant Bits (MSB) of the 40-bits output `do` of `dht11_ctrl` if the internal signal `start` is asserted high,
  * else it remains unchanged.
* A 32-bits register is mapped at offset address 4 (from the base address of the peripheral). It is a status register. From the processor's perspective, it is read-only. Its reset value is all-zeroes. Its 28 MSBs are constant and always read as `'0'`. Only its four Least Significant Bits (LSBs) are used. Declare a `status_reg` internal signal to model the output of this register.
* `status_reg(0)` indicates if the DHT11 controller is busy. On rising edges of the clock `status_reg(0)` samples:
  * `'0'` if the reset is active,
  * else the `busy` output of `dht11_ctrl`.
* `status_reg(1)` indicates if `data_reg` contains sensed values or not. On rising edges of the clock `status_reg(1)` samples:
  * `'0'` if the reset is active,
  * else `'0'` if `start` is asserted high for the first time after reset,
  * else `'1'` if `start` is asserted high for the second time after reset,
  * else it remains unchanged.
* `status_reg(2)` indicates if there has been a protocol error during the acquisition of the sensed data currently stored in `data_reg`. On rising edges of the clock `status_reg(2)` samples:
  * `'0'` if the reset is active,
  * else `perr_reg` if `start` is asserted high,
  * else it remains unchanged.
* `status_reg(3)` indicates if there is a checksum error with the sensed data currently stored in `data_reg`. On rising edges of the clock `status_reg(3)` samples:
  * `'0'` if the reset is active,
  * else `'1'` if `start` is asserted high and the checksum of the `do` output of `dht11_ctrl` does not match,
  * else `'0'` if `start` is asserted high and the checksum of the `do` output of `dht11_ctrl` matches,
  * else it remains unchanged.
* `status_reg(31 downto 4)` is constant with all-zeroes value.
* The `start` internal signal is always `'0'`, except when the `busy` output of `dht11_ctrl` is `'0'` and `status_reg(0)` is `'1'` (which detects a falling edge of `busy`). Note that `start` has two roles:
  * start a new acquisition as soon as the DHT11 controller is ready,
  * indicate the end of the previous acquisition (except the first time it is asserted after reset).

### Implementation of the AXI4 lite protocol

* the `s0_axi_rdata`, `s0_axi_rresp` and `s0_axi_bresp` outputs of the wrapper are outputs of dedicated internal registers: they are assigned in a synchronous process. They are not targets of concurrent signal assignments (even with registered right-hand sides). This is mandatory to fulfil all requirements of the AXI4 lite protocol. Note that if `s0_axi_rdata`, for instance, was assigned by a concurrent signal assignment, there would be a possibility that its value changes while `s0_axi_rvalid` is asserted high, which is strictly forbidden by the protocol: `s0_axi_rdata` and `s0_axi_rresp` **must** be assigned a value when `s0_axi_rvalid` is asserted high to respond a read request, and they **must** remain unmodified until the response is acknowledged by the master (with `s0_axi_rready`). Same for `s0_axi_bresp` for the write responses.
* If the master reads at an unmapped offset address (`addr >= 8`), the response status is `DECERR` and the response data is zero.
* If the master writes at an unmapped offset address (`addr >= 8`), the response status is `DECERR`.
* If the master writes to one of the two mapped read-only registers (`0 <= addr <= 7`), the response status is `SLVERR`.
* The peripheral groups write address and write data requests: it waits until both are pending before acknowledging both and responding.
* Read and write requests can be submitted simultaneously.
* The read and write acknowledges (`arready`, `awready`, `wready`) are not asserted high by default. They are asserted only after the rising edge of the clock for which valid request flags are asserted high.
* Read and write requests are served as soon as possible: when a valid request is pending on a rising edge `N` of clock, the acknowledge(s) is(are) asserted high, and the response is submitted. After the next (`N+1`) rising edge of the clock the acknowledge(s) is(are) de-asserted. If the microprocessor acknowledges the response on the same rising edge, the response is also de-asserted. Else the response is maintained until a rising edge of the clock where the microprocessor acknowledges the response.
* New read (write) requests are ignored as long as a pending read (write) response has not been acknowledged.
* The processor can assert its ready flags high by default.

The following waveform represents several read transactions. The rising edges of the clock where the peripheral notices a read request are indicated by a blue vertical line. The rising edges of the clock where the processor acknowledges a read response are indicated by a red vertical line. The highest possible throughput (two clock cycles per read operation) corresponds to the two last transactions. Write transactions are similar (remember that the peripheral groups write address and write data requests).

![`dht11_ctrl_axi` waveform](figures/waveforms.png)

Model the `dht11_ctrl_axi` behaviour in the VHDL architecture named `rtl` in the `20180423/vhdl/dht11_ctrl_axi.vhd` file.

## Validation

The provided simulation environment uses the `axi_pkg` and `rnd_pkg` packages.

````bash
$ ds2018=/homes/mary/ds-2018
$ tmp=/tmp/mary/20180423
$ mkdir -p $tmp
$ cd $tmp
$ vcom $ds2018/vhdl/axi_pkg.vhd
$ vcom $ds2018/vhdl/rnd_pkg.vhd
...
$ vcom $ds2018/20180423/vhdl/dht11_ctrl_axi.vhd
$ vcom $ds2018/20180423/vhdl/dht11_ctrl_axi_sim.vhd
$ vsim dht11_ctrl_axi_sim
```

## Peer review

Compare your solution with your neighbors'.

## Synthesis and tests of the AXI4 lite DHT11 controller

We will now synthesize our design with the Vivado tool by Xilinx to map it in the programmable logic part of the Zynq core of the Zybo. The `20180423/scripts/dht11_ctrl_axi.syn.tcl` TCL script will automate the synthesis and the `20180423/scripts/boot.bif` file will tell the Xilinx tools what to do with the synthesis result. As usual, before you can use the synthesis script, you will have to edit it and add information about the primary inputs and outputs (I/O) in the definition of the `ios` array, near the top of the file. Cross-check your edits with your neighbours.

Observe the part of the synthesis script entitled "_Addresses ranges_". It defines the base address of the peripheral in the system address map (property `offset`) and its address range (property `range`). Remember these two values.

If everything looks fine, synthesize (replace `<init>`, `<tmax>` and `<cmax>` by the appropriate values):

```bash
$ cd $tmp
$ vivado -mode batch -source $ds2018/20180423/scripts/dht11_ctrl_axi.syn.tcl -notrace -tclargs $ds2018 <init> <tmax> <cmax>
$ bootgen -w -image $ds2018/20180423/scripts/boot.bif -o boot.bin 
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

You are now connected as the `root` user under the GNU/Linux OS that runs on the Zynq core of the Zybo board. Use the `devmem` utility to read the registers:

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

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
