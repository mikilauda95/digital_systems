<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# AXI4 lite register

This lab consists in designing an AXI4 lite compliant peripheral with two 32-bits interface registers.

## Interface

Edit the file named `reg_axi.vhd` in the `20180416/vhdl` directory. An entity named `reg_axi` is already coded with the following input-output ports:

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
| `sw`             | `std_ulogic_vector(3 downto 0)`  | in        | Slide switches (for debug)                                            | 
| `led`            | `std_ulogic_vector(3 downto 0)`  | out       | LEDs (for debug)                                                      | 

## Architecture

The AXI4 lite registers peripheral is designed to be connected to the ARM microprocessor of the Zynq core of the Zybo board. The interface with the microprocessor complies with the AXI4 lite protocol. Data busses are 32 bits wide (the ARM microprocessor is a 32 bits microprocessor) and address busses are 12 bits wide, allowing 4 kB of address space for the peripheral (the minimum supported by Xilinx tools). But only 8 bytes in this address space are actually mapped. Each time the microprocessor executes a load or a store instruction at a physical address that falls in these 4 kB, the peripheral receives the corresponding read or write request and must answer the request according the AXI4 lite protocol.

The detailed specifications of the AXI4 lite registers peripheral are the following. Please read them carefully, each aspect is important.

* The `led` output is driven by a 4-bits nibble of one of the two registers. The `sw` input selects which nibble of which register is sent to `led`, from `ro(3 downto 0)` when `sw = 0000` to `ro(31 downto 28)` when `sw = 0111` and from `rw(3 downto 0)` when `sw = 1000` to `rw(31 downto 28)` when `sw = 1111`.
* Only word-aligned transactions are supported by the peripheral: the two least significant bits of the addresses are ignored.
* The first register `ro` is mapped at offset address 0 (from the base address of the peripheral). From the processor's perspective, it is read-only. The peripheral increments its content by one on every rising edge of the clock and wraps to zero around the maximum value. Its reset value is zero.
* The second register `rw` is mapped at offset address 4 (from the base address of the peripheral). From the processor's perspective, it is read-write. Its reset value is zero.
* If the master reads at an unmapped offset address (`addr >= 8`), the response status is `DECERR` and the response data is zero.
* If the master writes at an unmapped offset address (`addr >= 8`), the response status is `DECERR`.
* If the master writes to the `ro` read-only register (`0 <= addr <= 3`), the response status is `SLVERR`.
* The peripheral groups write address and write data requests: it waits until both are pending before acknowledging both and performing the write operation.
* Read and write requests can be submitted simultaneously. When a simultaneous read and write request to `rw` happens, the read value is the old one (read-before-write).
* The read and write acknowledges (`arready`, `awready`, `wready`) are not asserted high by default. They are asserted only after the rising edge of the clock for which valid request flags are asserted high.
* Read and write requests are served as soon as possible: when a valid request is pending on a rising edge `N` of clock, the acknowledge(s) is(are) asserted high, and the response is submitted. After the next (`N+1`) rising edge of the clock the acknowledge(s) is(are) de-asserted. If the microprocessor acknowledges the response on the same rising edge, the response is also de-asserted. Else the response is maintained until a rising edge of the clock where the microprocessor acknowledges the response.
* New read (write) requests are ignored as long as a pending read (write) response has not been acknowledged.
* The processor can assert its ready flags high by default.

The following waveform represents several read transactions. The rising edges of the clock where the peripheral notices a read request are indicated by a blue vertical line. The rising edges of the clock where the processor ackowledges a read response are indicated by a red vertical line. The highest possible throughput (two clock cycles per read operation) corresponds to the two last transactions. Write transactions are similar (remember that the peripheral groups write address and write data requests).

![`reg_axi` waveform](figures/waveforms.png)

Model the `reg_axi` behavior in the VHDL architecture named `rtl` in the `20180409/vhdl/reg_axi.vhd` file.

## Validation

The provided simulation environment uses the `axi_pkg` and `rnd_pkg` packages.

````bash
$ cd $tmp
$ vcom $ds2018/vhdl/axi_pkg.vhd
$ vcom $ds2018/vhdl/rnd_pkg.vhd
$ vcom $ds2018/20180416/vhdl/reg_axi.vhd
$ vcom $ds2018/20180416/vhdl/reg_axi_sim.vhd
$ vsim reg_axi_sim
```

## Peer review

Compare your solution with your neighbors'.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
