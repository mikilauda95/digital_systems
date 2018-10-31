<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# The DHT11 controller (20 minutes)

Note: the [datashet of the DHT11 sensor] is available in `doc/DHT11.pdf`.

The following block diagram represents a DHT11 humidity and temperature sensor connected to a controller (the part enclosed in the dashed box and named `dht11_ctrl`).

![`dht11`](figures/dht11.png)

The single-wire communication protocol between the sensor and our controller is represented on the following waveform. The dashed low levels are driven by the `tsb` tri-state buffer (when `dht11_ctrl` asserts `data_drv` high), and the plain ones are driven by the sensor. All high levels are driven by the pull-up resistor.

![`dht11`](figures/dht11_protocol.png)

We will now assemble our `sr2`, `counter`, `timer2` and `edge` modules to design the `dht11_ctrl` controller. We will also need a state machine (`sm2`) to drive all these modules. It will be the brain of our controller.

## Interface

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

Note: according the [datashet of the DHT11 sensor] we could get rid of the `init` generic parameter and hard-wire the duration of the low pulse of the _init_ command to `20` ms (`20000` micro-seconds). But simulations would become very long and this would not be convenient. For simulations we will set the `init` generic parameter to a much smaller value (`200`) while for synthesis we will set it to the `20000` default. Same for the clock frequency: for simulation we will set it to a small value (`2 MHz`) while for synthesis we will set it to the actual clock frequency of our system (`125 MHz` in the stand-alone version). And same for the `1` s (`1000000` micro-seconds) warm-up delay and recommended interval between two measurements; it is represented by the `tmax` generic parameter. For synthesis we will set it to `1000000` but for simulations a smaller value will be much more convenient.

## Architecture

The system is synchronous on the rising edge of the `clk` clock. `sresetn` is a synchronous, active low, reset. For better readability, `clk` and `sresetn` are not represented on the block diagram, but, on rising edges of `clk`, all registers of `dht11_ctrl` are reset to zero if `sresetn` is low, else they sample their input. Our VHDL code must be synthesizable, the VHDL standard we are using is 2002, and output ports can thus **not** be read.

`dht11_ctrl` implements the single-wire (`data_in`) communication protocol with the DHT11 sensor. The wire can be driven low by `dht11_ctrl` or by the sensor. Else, it is pulled high by a pull-up resistor. To drive `data_in` low, `dht11_ctrl` asserts `data_drv` high, which turns the `tsb` tri-state buffer in its driving state; the driven value is always `0V`.

## VHDL coding of the DHT11 controller

Edit `20180409/vhdl/dht11_ctrl.vhd`. Add all necessary signal declarations to interconnect `sm2`, `timer2`, `counter`, `sr2` and `edge`. Instantiate the 5 modules as entity instantiations.

## Validation

Notes about the provided simulation environment:

* It contains a model of the DHT11 sensor.
* It instantiates the DHT11 sensor model, plus the `dht11_ctrl` DHT11 controller, a model of the tri-state buffer and several processes and concurrent signal assignments to drive the main inputs.
* Before using it you must edit it and give values of the generic parameters of `dht11_ctrl_sim`. The `value` parameter is the 40-bits value returned by the DHT11 model.
* During the last simulated transfer a protocol error is artificially created to test the protocol error detection.

````bash
$ cd $tmp
$ vcom $vhdl/timer2.vhd $vhdl/counter.vhd $vhdl/sr2.vhd $vhdl/edge.vhd $vhdl/sm2.vhd
$ vcom $vhdl/dht11_ctrl.vhd $vhdl/dht11_ctrl_sim.vhd
$ vsim dht11_ctrl_sim
```

[datashet of the DHT11 sensor]: /doc/DHT11.pdf

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
