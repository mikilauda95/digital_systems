<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# Timer (15 minutes)

This challenge consists in designing a modified version of the timer we designed last time.

## Interface

Edit the file named `timer2.vhd` in the `20180409/vhdl` directory. An entity named `timer2` is already coded with the following generic parameters:

| Name       | Type                            | Description                                                         |
| :----      | :----                           | :----                                                               |
| `freq`     | `positive range 1 to 1000`      | Master clock frequency in MHz (also clock periods per micro-second) |
| `tmax`     | `natural`                       | Maximum value of timer                                              |

... and the following input-output ports:

| Name       | Type                            | Direction | Description                                                             |
| :----      | :----                           | :----     | :----                                                                   |
| `clk`      | `std_ulogic`                    | in        | Master clock. The design is synchronized on the rising edge of `clk`    |
| `sresetn`  | `std_ulogic`                    | in        | **Synchronous**, active **low** reset                                   |
| `tz`       | `std_ulogic`                    | in        | Force timer to zero                                                     |
| `t`        | `natural range 0 to tmax`       | out       | Current value of timer                                                  |

## Architecture

As its name says, `timer2` is a timer. Its internal signal `cnt` is a counter of clock cycles. On rising edges of `clk`, `cnt` is:

* forced to 0 if `tz` is high,
* else unmodified if `t` = `tmax`,
* else forced to zero if `cnt` = `freq` - 1,
* else incremented by one.

The `t` output is a counter of micro-seconds. On rising edges of `clk`, `t` is:

* forced to 0 if `tz` is high,
* else unmodified if `t` = `tmax`,
* else incremented by one if `cnt` = `freq` - 1,
* else unmodified.

The figure below represents the `clk`, `sresetn`, `tz` and `t` signals, plus the internal `cnt` signal, for `freq=2` and `tmax=3`.

![`timer2` waveform](figures/timer2_waveform.png)

Restarting from the timer you designed last time, model the `timer2` behaviour in the VHDL architecture named `rtl` in the `20180409/vhdl/timer2.vhd` file. Use one synchronous process only (do not forget the reset). As our logic synthesizer does not fully support VHDL 2008 yet, we cannot read the `t` output port in our architecture. Use the `t_local` signal, instead. The already coded concurrent signal assignment assigns `t_local` to `t` every time `t_local` changes.

## Validation

````bash
$ cd $tmp
$ vcom $vhdl/timer2.vhd
$ vcom $vhdl/timer2_sim.vhd
$ cd $tmp
$ vsim timer2_sim
```

## Peer review

After the end of the challenge, compare your solution with your neighbours'.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
