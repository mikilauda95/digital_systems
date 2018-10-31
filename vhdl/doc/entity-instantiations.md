<!-- vim: set textwidth=0: -->
# Entity instantiations

The easiest way to model a design using a hierarchical (structural) approach is the entity instantiation. Any already designed entity/architecture pair can be used as a sub-circuit of another entity/archiecture pair:

```vhdl
entity full_adder is
  port(
    a, b, ci: in  std_ulogic;
    s, co:    out std_ulogic
  );
end entity full_adder;

architecture arc of full_adder is
begin
  s  <= a xor b xor ci;
  co <= (a and (b or ci)) or (b and ci);
end architecture arc;

entity four_bits_adder is
  port(
    a, b: in  std_ulogic_vector(3 downto 0);
    ci:   in  std_ulogic;
    s:    out std_ulogic_vector(3 downto 0);
    co:   out std_ulogic
  );
end entity four_bits_adder;

architecture arc of four_bits_adder is
  signal c:  std_ulogic_vector(3 downto 1);
begin
  u0: entity work.full_adder(arc)
    port map(
      a  => a(0),
      b  => b(0),
      ci => ci,
      s  => s(0),
      co => c(1)
    );
  u1: entity work.full_adder(arc)
    port map(
      a  => a(1),
      b  => b(1),
      ci => c(1),
      s  => s(1),
      co => c(2)
    );
  u2: entity work.full_adder(arc)
    port map(
      a  => a(2),
      b  => b(2),
      ci => c(2),
      s  => s(2),
      co => c(3)
    );
  u3: entity work.full_adder(arc)
    port map(
      a  => a(3),
      b  => b(3),
      ci => c(3),
      s  => s(3),
      co => co
    );
end architecture arc;
```

The main drawback of this approach is that the higher hierarchy level can be compiled only after the lower. It is a bottom-up design strategy. While perfectly acceptable for simple projects, it may become sub-optimal for complex designs.

Top-down approaches are possible using VHDL component declarations, component instantiations and configurations. They are powerful but significantly more verbose and difficult to understand.
