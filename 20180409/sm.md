<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# State machine (30 minutes)

This challenge consists in designing a Moore finite state machine.

## Interface

Edit the file named `sm.vhd` in the `20180409` directory. An entity named `sm` (for State Machine) is arlready coded with the following input-output ports:

| Name       | Type                            | Direction | Description                                                             |
| :----      | :----                           | :----     | :----                                                                   |
| `clk`      | `std_ulogic`                    | in        | Master clock. The design is synchronized on the rising edge of `clk`.   |
| `sresetn`  | `std_ulogic`                    | in        | **Synchronous**, active **low** reset.                                        |
| `go`       | `std_ulogic`                    | in        | Go command input.                                                       |
| `stp`      | `std_ulogic`                    | in        | Stop command input.                                                     |
| `spin`     | `std_ulogic`                    | in        | Spin command input.                                                     |
| `up`       | `std_ulogic`                    | out       | On output.                                                              |

## Architecture

`sm` is a 3-states Moore state machine which states are `IDLE`, `RUN` and `HALT`. It uses `clk` as its master clock. The design is synchronized on the rising edge of `clk`. It uses `sresetn` as its **synchronous**, active **low** reset. The `IDLE` state is the reset state. The following table details the value of the output and the state transitions when the reset is not active (`-` means *don't care*):

| State      | `up` | (`go`,`stp`,`spin`) | Next state |
| :----      | :--- | :----               | :----      |
| `IDLE`     | `0`  | (`0`,`-`,`-`)       | `IDLE`     |
| `IDLE`     | `0`  | (`1`,`-`,`-`)       | `RUN`      |
| `RUN`      | `1`  | (`-`,`0`,`-`)       | `RUN`      |
| `RUN`      | `1`  | (`-`,`1`,`-`)       | `HALT`     |
| `HALT`     | `0`  | (`-`,`-`,`1`)       | `HALT`     |
| `HALT`     | `0`  | (`1`,`-`,`0`)       | `RUN`      |
| `HALT`     | `0`  | (`0`,`-`,`0`)       | `IDLE`     |

Draw a state diagram of `sm` and a block diagram of its architecture. Translate all this in a VHDL architecture named `rtl` in the `sm.vhd` VHDL source file. Use a custom enumerated type to represent the states (see example 18, page 92 of the [Free Range Factory] VHDL book).

## Validation

````bash
$ cd $tmp
$ vcom $vhdl/sm.vhd
$ vcom $vhdl/sm_sim.vhd
$ cd $tmp
$ vsim sm_sim
```

## Peer review

After the end of the challenge, compare your solution with your neighbours'.

[Free Range Factory]: http://freerangefactory.org/

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
