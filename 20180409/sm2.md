<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->

# Coding challenge: the `sm2` Mealy finite state machine (60 minutes)

`sm2` is a Mealy state machine (a Mealy state machine is a finite state machine which outputs may combinatorially depend on the inputs). The file named `sm2.vhd` in the `20180409/vhdl` directory contains an already coded entity named `sm2` with the following generic parameters:

| Name       | Type                            | Description                                                                 |
| :----      | :----                           | :----                                                                       |
| `init`     | `natural`                       | Duration of low pulse of _init_ command in micro-seconds                    |
| `tmax`     | `natural`                       | Maximum value of timer                                                      |
| `cmax`     | `natural`                       | Maximum value of counter                                                    |

... and the following input-output ports:

| Name       | Type                             | Direction | Description                                                               |
| :----      | :----                            | :----     | :----                                                                     |
| `clk`      | `std_ulogic`                     | in        | Master clock. The design is synchronized on the rising edge of `clk`      |
| `sresetn`  | `std_ulogic`                     | in        | **Synchronous**, active **low** reset                                     |
| `start`    | `std_ulogic`                     | in        | Start signal, initiate a data transfer when asserted high and `sm2` ready |
| `busy`     | `std_ulogic`                     | out       | Asserted high when not ready to start a new data transfer                 |
| `err `     | `std_ulogic`                     | out       | Asserted high when receiving data and a protocol error is detected        |
| `data_drv` | `std_ulogic`                     | out       | When active, drive data line low with tri-state buffer `tsb`              |
| `tz`       | `std_ulogic`                     | out       | Force timer to zero                                                       |
| `t`        | `natural range 0 to tmax`        | in        | Current value of timer                                                    |
| `cz`       | `std_ulogic`                     | out       | Force counter to zero                                                     |
| `c`        | `natural range 0 to cmax`        | in        | Current value of counter                                                  |
| `inc`      | `std_ulogic`                     | out       | Increment counter and shift shift register                                |
| `di`       | `std_ulogic`                     | out       | Serial input of the shift register                                        |   
| `re`       | `std_ulogic`                     | in        | Rising edge detected on data line                                         |
| `fe`       | `std_ulogic`                     | in        | Falling edge detected on data line                                        |

The 3 states of `sm2` are:

* `idle`: This is the reset state. Wait for `tmax` micro-seconds, ignore `start` as long as the timer did not reach `tmax`. This is the warm-up time after reset and also the recommended delay between two consecutive measurements. When the timer reached `tmax`, monitor `start`. If `start` is high on a rising edge of `clk`, force the timer to 0 and go to state `starting`.
* `starting`: This is the state in which we send the _init_ command to the sensor. Assert `data_drv` high and wait until the timer reaches value `init`, then force the timer and the counter to 0 and go to `receiving`.
* `receiving`: Receive data bits, including those corresponding to the _init_ and _acknowledge_ phases that are not real bits; 42 times, wait for a falling edge of `data_in` (circled numbers on the waveform). Force timer to 0 and increment counter on each falling edge of data line. Use the timer value to distinguish zero and one bits: at each falling edge of the data wire, compare the timer with `100`. If it is less than `100`, the received bit is interpreted as zero, else it is interpreted as one. The new bit is shifted in `sr2`. Note that, with this strategy, the high level pulse following _init_ and the _acknowledge_ are also interpreted as received bits (zero and one, respectively). They are shifted in `sr2`, but as `sr2` is only 40-bits wide, they will be dropped when receiving the last data bits. Finally, after receiving the last data bit, wait for a last rising edge of `data_in` (_end-of-transfer_).

**Protocol errors**: in state `receiving` the `init` generic parameter is also used as a way to detect protocol errors: if the timer reaches `init`, we consider that the transfer failed (unconnected or out of order sensor). Force the timer to 0, assert `err` high and go to `idle`.

Draw the state diagram of `sm2`. Represent the states with named bubbles. Represent state transitions with arrows between bubbles (note that a transition can have same starting and ending state). Indicate the conditions of transitions on the arrows. You can use the special condition `else` to indicate the complementary of the other transition conditions with same source state. Indicate inside the state bubbles the value of the output(s) that depend only on the current state. Indicate on the transition arrows the value of the output(s) that depend on the starting state and on the inputs of `sm2`.

Model the `sm2` behaviour in the VHDL architecture named `rtl` in the `20180409/vhdl/sm2.vhd` file. Declare an enumerated type to represent the states and a signal of this type for the current state. Use one synchronous process only (do not forget the reset) to model the state evolution. Use as many concurrent, conditional or select signal assignments as needed to model the outputs of `sm2`. **All** outputs of `sm2` are assigned by concurrent, conditional or select signal assignments.

## Validation

There is no provided simulation environment for `sm2`. Create your own, use the automatic evaluation or continue with the integration of the complete DHT11 controller for which a simulation environment is provided.

## Peer review

After the end of the challenge, compare your solution with your neighbours'.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
