<!-- vim: set textwidth=0: -->
# Recursivity

Recursivity is a programming method where sub-programs call themselves. It is very convenient to solve some kinds of problems in an elegant and generic way. VHDL supports recursion. Most logic synthesizers also support it. In some cases the inferred hardware is even better (faster, same size) than with the equivalent loop-based description.

## Computing the Hamming weight of a vector

```vhdl
  -- loop-based version
  function hw_loop(v: bit_vector) return natural is
    variable h: natural;
  begin
    h := 0;
    for i in v'range loop
      if v(i) = '1' then
        h := h + 1;
      end if;
    end loop;
    return h;
  end function hw_loop;

  -- recursive version
  function hw_tree(v: bit_vector) return natural is
  constant size: natural := v'length;
  constant vv: bit_vector(size - 1 downto 0) := v;
  variable h: natural;
  begin
    h := 0;
    if size = 1 and vv(0) = '1' then
      h := 1;
    elsif size > 1 then
      h := hw_tree(vv(size - 1 downto size / 2)) + hw_tree(vv(size / 2 - 1 downto 0));
    end if;
    return h;
  end function hw_tree;
```
