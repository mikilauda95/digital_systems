<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# Edge detector (20 minutes)

This challenge consists in designing a 3-stages re-synchronizer and detector of edges of the `data_in` input signal.

## Interface

Edit the file named `edge.vhd` in the `20180409/vhdl` directory. An entity named `edge` is already coded with the following input-output ports:

| Name       | Type                            | Direction | Description                                                            |
| :----      | :----                           | :----     | :----                                                                  |
| `clk`      | `std_ulogic`                    | in        | Master clock. The design is synchronized on the rising edge of `clk`   |
| `sresetn`  | `std_ulogic`                    | in        | **Synchronous**, active **low** reset                                  |
| `data_in`  | `std_ulogic`                    | in        | Data input signal                                                      |
| `re`       | `std_ulogic`                    | out       | Rising edge output                                                     |
| `fe`       | `std_ulogic`                    | out       | Falling edge output                                                    |

## Architecture

`edge` is a 3-stages re-synchronizer and detector of edges of the `data_in` input signal. The `sync` signal (already declared) models the 3-stages re-synchronizer. On rising edges of `clk`, `sync` is shifted by one bit to the right, `data_in` enters to the left, the rightmost bit is lost. `re` is combinatorially computed from bits of `sync`. It is asserted high during one `clk` period to indicate a rising edge of `data_in`. Same for `fe` on falling edges of `data_in`.

![`edge` waveform](figures/edge.png)

![`edge` waveform](figures/edge_waveform.png)

Model the `edge` behaviour in the VHDL architecture named `rtl` in the `20180409/vhdl/edge.vhd` file. Use one synchronous process only (do not forget the reset) and two simple concurrent signal assignments.

## Validation

````bash
$ cd $tmp
$ vcom $vhdl/edge.vhd
$ vcom $vhdl/edge_sim.vhd
$ cd $tmp
$ vsim edge_sim
```

## Peer review

After the end of the challenge, compare your solution with your neighbours'.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
