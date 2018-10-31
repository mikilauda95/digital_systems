<!-- MASTER-ONLY: DO NOT MODIFY THIS FILE-->
# Shift register (15 minutes)

The DHT11 sensor sends data Most Significant Bit (MSB) first. To store them in a shift register it is thus more convenient if the register shifts from right to left. This coding challenge consists in transforming the shift register we designed last time such that it shifts from right to left instead of left to right.

## Interface

Edit the file named `sr2.vhd` in the `20180409/vhdl` directory. An entity named `sr2` is already coded with the following generic parameters:

| Name       | Type                            | Description                                                         |
| :----      | :----                           | :----                                                               |
| `n`        | `positive`                      | Size (bit length) of the shift register                             |

... and the following input-output ports:

| Name      | Type                              | Direction | Description                                                                | 
| :----     | :----                             | :----     | :----                                                                      | 
| `clk`     | `std_ulogic`                      | in        | Master clock. The design is synchronized on the **rising** edge of `clk`   | 
| `sresetn` | `std_ulogic`                      | in        | **Synchronous**, active **low** reset                                      | 
| `shift`   | `std_ulogic`                      | in        | Shift command input. The register shifts when `shift` is asserted **high** | 
| `di`      | `std_ulogic`                      | in        | Serial input of the shift register                                         | 
| `do`      | `std_ulogic_vector(n-1 downto 0)` | out       | Current value of the shift register                                        | 

## Architecture

Restarting from the shift register you design last time model the `sr2` behaviour in the VHDL architecture named `rtl` in the `20180409/vhdl/sr2.vhd` file. The specification is the same as last time, except that the register now shifts from right to left and the name of the architecture which is now `rtl` for _Register Transfer Level_ instead of `arc`. Use one synchronous process only (do not forget the reset). As our logic synthesizer does not fully support VHDL 2008 yet, we cannot read the `do` output port in our architecture. Use the `reg` signal, instead. The already coded concurrent signal assignment assigns `reg` to `do` every time `reg` changes.

## Validation

````bash
$ cd $tmp
$ vcom $vhdl/sr2.vhd
$ vcom $vhdl/sr2_sim.vhd
$ vsim sr2_sim
```

## Peer review

After the end of the challenge, compare your solution with your neighbours'.

<!-- vim: set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab textwidth=0: -->
