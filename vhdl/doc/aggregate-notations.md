<!-- vim: set textwidth=0: -->
# Aggregate notations

Aggregate notations are a powerful way to express composite values (arrays, records). They associate expressions (values) with the elements of a composite type. Example:

```vhdl
type foo is record
  f1: bit;
  f2: std_ulogic_vector(3 downto 0);
  f3: integer;
end record;

type bar is array(0 to 4) of natural;
...
  variable u: foo;
  variable v: bar;
...
  u := ('1', "0100", 12);
  v := (5, 4, 3, 2, 1);
```

The associations can be positional, as in the previous example, or named:

```vhdl
  u := (f1 => '1', f2 => "0100", f3 => 12);
  v := (0 => 5, 1 => 4, 2 => 3, 3 => 2, 4 => 1);
```

Of course, when the associations are named, they can be out of order:

```vhdl
  u := (f3 => 12, f1 => '1', f2 => "0100");
  v := (4 => 1, 3 => 2, 1 => 4, 0 => 5, 2 => 3);
```

Ranges can be used to express choices:

```vhdl
  v := (0 to 2 => 15, 4 => 17, 3 => 16);
```

The `others` keyword can be used as the last association and means: all choices that have not yet been enumerated:

```vhdl
  v := (3 => 0, others => 1);
```

Finally, positional and named associations can be merged but only if all named associations appear after all positional associations:

```vhdl
  u := ('1', f3 => 12, f2 => "0100"); -- OK
  -- u := (f1 => '1', "0100", 12);    -- INVALID
```

A more complex example:

```vhdl
constant NREGS: positive := 32;
constant PDEPTH: positive := 7;
type codeop is (add, sub, mul, div, nop);
type instruction is record
  op:  codeop;
  rs1: natural range 0 to NREGS;
  rs2: natural range 0 to NREGS;
  rd:  natural range 0 to NREGS;
end record;
type pipeline is array(1 to PDEPTH) of instruction;
...
  variable i: instruction;
  variable p: pipeline;
  variable v: std_ulogic_vector(19 downto 5);
  i := (op => nop, others => 0);
  p := (others => (nop, others => 0));
  v := (others => '1');
...
  i := (op => mul, rd => 1, others => 2);
  p := (1 => (add, 1, 2, 3), others => (nop, others => 0));
  v := (18 => '0', 8 downto 6 => '1', 12 | 13 => '1', others => 'X');
...
  i := (sub, 12, rd => 14, rs2 => 13);                                         -- OK
  -- p := ((mul, 3, 4, 5), 3 => (add, 1, 2, 3), others => (nop, others => 0)); -- INVALID
  -- v := ('1', '0', '1', 7 => '0', others => '1');                            -- INVALID
...
  -- i := (rs1 => 7, 12, others => 0);                                         -- INVALID
```

