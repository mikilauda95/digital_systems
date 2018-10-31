<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# Counter (15 minutes)

This challenge consists in designing a counter.

## Interface

Edit the file named `counter.vhd` in the `20180409/vhdl` directory. An entity named `counter` is already coded with the following generic parameter:

| Name       | Type                            | Description                                                         |
| :----      | :----                           | :----                                                               |
| `cmax`     | `natural`                       | Maximum value of counter                                            |

... and the following input-output ports:

| Name       | Type                            | Direction | Description                                                             |
| :----      | :----                           | :----     | :----                                                                   |
| `clk`      | `std_ulogic`                    | in        | Master clock. The design is synchronized on the rising edge of `clk`    |
| `sresetn`  | `std_ulogic`                    | in        | **Synchronous**, active **low** reset                                   |
| `cz`       | `std_ulogic`                    | in        | Force counter to zero                                                   |
| `inc`      | `std_ulogic`                    | in        | Increment counter                                                       |
| `c`        | `natural range 0 to cmax`       | out       | Current value of counter                                                |

## Architecture

As its name says, `counter` is a counter. On rising edges of `clk`, `c` is:

* forced to 0 if `cz` is high,
* else incremented by one if it is strictly less than `cmax` and `inc` is high,
* else unmodified.

The following waveform shows the behaviour of `counter` with `cmax = 5`.

![`counter` waveform](figures/counter_waveform.png)

Model the `counter` behaviour in the VHDL architecture named `rtl` in the `20180409/vhdl/counter.vhd` file. Use one synchronous process only (do not forget the reset). As our logic synthesizer does not fully support VHDL 2008 yet, we cannot read the `c` output port in our architecture. Use the `c_local` signal, instead. The already coded concurrent signal assignment assigns `c_local` to `c` every time `c_local` changes.

## Validation

````bash
$ cd $tmp
$ vcom $vhdl/counter.vhd
$ vcom $vhdl/counter_sim.vhd
$ cd $tmp
$ vsim counter_sim
```

## Peer review

After the end of the challenge, compare your solution with your neighbours'.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
