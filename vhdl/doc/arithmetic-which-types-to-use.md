<!-- vim: set textwidth=0: -->
# Arithmetic: which types to use?

## Integer types versus arithmetic vector types

Integer types are synthesizable, so when modelling a synthesizable design with some arithmetic, they can perfectly be the right choice. Several standard packages (`ieee.numeric_bit`, `ieee.numeric_std`) define one-dimensional unconstrained array types of `bit`, `std_ulogic` or `std_logic` and overload the arithmetic operators for these types. They can thus also be used for arithmetic.

The `ieee.numeric_std` package, for instance, defines the `unresolved_signed` and `unresolved_unsigned` types with exactly the same definition as `ieee.std_logic_1164.std_ulogic_vector`:

```vhdl
type UNRESOLVED_UNSIGNED is array (NATURAL range <>) of STD_ULOGIC;
type UNRESOLVED_SIGNED is array (NATURAL range <>) of STD_ULOGIC;
```

It also defines two shorter aliases:

```vhdl
alias U_UNSIGNED is UNRESOLVED_UNSIGNED;
alias U_SIGNED is UNRESOLVED_SIGNED;
```

In a synthesizable design, 32 bits signed integers can be represented either by the native `integer` type or by `u_signed(31 downto 0)`. Which type to use in which case is a subtle question. Answering it requires to know several things about these types and how simulators and synthesizers interpret them:

* In most implementations of the VHDL language, by default, the `integer` type is represented on 32 bits and ranges from -2^31 +1 to 2^31 -1 (note that, different from many programming languages, -2^31 is out of range). Using the type `integer` for a variable or signal with a smaller range has two major drawbacks:
  * The simulator cannot accurately detect out of range situations.
  * The synthesizer will probably allocate 32 bits and may produce a larger and/or slower implementation than what is actually needed.
* There is no automatic wrapping with integer types. An error is raised during simulations if an out of range situation is detected. This may be an advantage for debugging but it may also be a drawback if the intended behaviour is the automatic wrapping.
* With the arithmetic vector types the wrapping is automatic in case of overflow or underflow, in simulation and in synthesis. This can be convenient if it is the expected behaviour but it can also prevent the detection of unwanted situations during simulations.
* For most logic synthesizers integer types are finally implemented as vectors of bits with a given fixed width; overflows or underflows lead to wrapping, not errors (that do not really make sense in hardware). The behaviours of the simulation and the synthesized hardware are thus different.
* There is no simple way to model bit-wise operations on integer types; it is much easier with vector types.
* The only way to constrain the range of a vector type is by its bit-width. Their bounds are always powers of two while they can be anything with integer types.

As a consequence, the use of integer types is recommended in situations where there is only a need for arithmetic operations, not for bit-wise operations, and the automatic wrapping around power of two bounds is not desired. The range shall always be constrained to the smallest. This will help the debugging during simulations and improve the performance / size after synthesis:

```vhdl
signal i: integer range 12 to 47;
...
  i <= i + 3;
...
```

In other situations, the use of the `u_unsigned` or `u_signed` types is probably a better choice:

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
...
signal u, v:     u_unsigned(7 downto 0);
signal msb:      std_ulogic;
signal not_zero: std_ulogic;
...
  u <= u + v;
...
  u <= u + 7; -- Mix of vector and integer operands
...
  msb      <= u(7);
  not_zero <= or v;
```

## Conversion functions

The `ieee.numeric_std.u_unsigned` and `ieee.numeric_std.u_signed` types having the same definition as `ieee.std_logic_1164.std_ulogic_vector` it is very easy to convert one to the other:

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
...
signal u: std_ulogic_vector(7 downto 0);
signal v: u_unsigned(7 downto 0);
...
  u <= std_ulogic_vector(v);
...
  v <= u_unsigned(u);
```

The `ieee.numeric_std` package also defines conversion functions between vector types and integer types:

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
...
signal i: integer range 0 to 255;
signal v: std_ulogic_vector(7 downto 0);
signal u: u_unsigned(7 downto 0);
...
  i <= to_integer(u);
...
  u <= to_unsigned(i, 8);
...
  u <= to_unsigned(i, u);
```

## Resolved arithmetic vector types

The `ieee.numeric_std.unresolved_signed` and `ieee.numeric_std.unresolved_unsigned` types (and their aliases) have been introduced with the VHDL 2008 version of the standard. Before that, the arithmetic vector types were `ieee.numeric_std.signed` and `ieee.numeric_std.unsigned`. They were (and still are) defined as the `ieee.std_logic_1164.std_logic_vector` type, that is, resolved. This was extremely unfortunate because most of the time there is no need for multiple drive capabilities with signals dedicated to arithmetic (see [Resolution functions, unresolved and resolved types] for details about resolved types).

A consequence of this unfortunate initial choice is that many VHDL books and VHDL courses advice the use of `ieee.numeric_std.signed` and `ieee.numeric_std.unsigned` for vector arithmetic. When the simulation or synthesis tools do not support VHDL 2008, there is no alternative and designers must be very careful to avoid multiple drive situations. But when the tools allow it, there is absolutely no reason any more to use resolved types when it is not needed.

Conclusion: always use `ieee.numeric_std.unresolved_signed` and `ieee.numeric_std.unresolved_unsigned` or their aliases `ieee.numeric_std.u_signed` and `ieee.numeric_std.u_unsigned`, unless you have a very good reason to use their resolved equivalents `ieee.numeric_std.signed` and `ieee.numeric_std.unsigned`.

[Resolution functions, unresolved and resolved types]: resolution-functions-unresolved-and-resolved-types.md
