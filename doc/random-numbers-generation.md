<!-- vim: set textwidth=0: -->
# Random numbers generation

Random numbers generation is frequently handy in simulation environments. In VHDL2008 the `ieee.math_real` package provides a uniform pseudo-random generator. Its declaration is (from the 1076-2008 IEEE standard):

```vhdl
procedure UNIFORM(variable SEED1, SEED2 : inout POSITIVE; variable X : out REAL);
-- Purpose:
--         Returns, in X, a pseudo-random number with uniform
--         distribution in the open interval (0.0, 1.0).
-- Special values:
--         None
-- Domain:
--         1 <= SEED1 <= 2147483562; 1 <= SEED2 <= 2147483398
-- Error conditions:
--         Error if SEED1 or SEED2 outside of valid domain
-- Range:
--         0.0 < X < 1.0
-- Notes:
--         a) The semantics for this function are described by the
--            algorithm published by Pierre L'Ecuyer in "Communications
--            of the ACM," vol. 31, no. 6, June 1988, pp. 742-774.
--            The algorithm is based on the combination of two
--            multiplicative linear congruential generators for 32-bit
--            platforms.
--
--         b) Before the first call to UNIFORM, the seed values
--            (SEED1, SEED2) have to be initialized to values in the range
--            [1, 2147483562] and [1, 2147483398] respectively.  The
--            seed values are modified after each call to UNIFORM.
--
--         c) This random number generator is portable for 32-bit
--            computers, and it has a period of ~2.30584*(10**18) for each
--            set of seed values.
--
--         d) For information on spectral tests for the algorithm, refer
--            to the L'Ecuyer article.
```

