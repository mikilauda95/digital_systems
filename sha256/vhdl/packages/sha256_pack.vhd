library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;


package  sha256_pack is

    subtype word is std_ulogic_vector(31 downto 0);
    --subtype word is UNRESOLVED_UNSIGNED(31 downto 0);

	type word_vect is array (natural range <>) of word;

	type message_t is array (natural range <>) of word_vect(1 to 16);

	constant H0 : word_vect (1 to 8) := ( 
	X"6a09e667",
	X"bb67ae85",
	X"3c6ef372",
	X"a54ff53a",
	X"510e527f",
	X"9b05688c",
	X"1f83d9ab",
	X"5be0cd19");

	constant K_a : word_vect (1 to 64) := (
	X"428a2f98", X"71374491", X"b5c0fbcf", X"e9b5dba5",
	X"3956c25b", X"59f111f1", X"923f82a4", X"ab1c5ed5",
	X"d807aa98", X"12835b01", X"243185be", X"550c7dc3",
	X"72be5d74", X"80deb1fe", X"9bdc06a7", X"c19bf174",
	X"e49b69c1", X"efbe4786", X"0fc19dc6", X"240ca1cc",
	X"2de92c6f", X"4a7484aa", X"5cb0a9dc", X"76f988da",
	X"983e5152", X"a831c66d", X"b00327c8", X"bf597fc7",
	X"c6e00bf3", X"d5a79147", X"06ca6351", X"14292967",
	X"27b70a85", X"2e1b2138", X"4d2c6dfc", X"53380d13",
	X"650a7354", X"766a0abb", X"81c2c92e", X"92722c85",
	X"a2bfe8a1", X"a81a664b", X"c24b8b70", X"c76c51a3",
	X"d192e819", X"d6990624", X"f40e3585", X"106aa070",
	X"19a4c116", X"1e376c08", X"2748774c", X"34b0bcb5",
	X"391c0cb3", X"4ed8aa4a", X"5b9cca4f", X"682e6ff3",
	X"748f82ee", X"78a5636f", X"84c87814", X"8cc70208",
	X"90befffa", X"a4506ceb", X"bef9a3f7", X"c67178f2");



	--function sha256 (x : message_t) return word_vect;
	function Ch (x, y, z : word) return word;
	function Maj (x, y, z : word) return word;
	function B_sigma0 (x : word) return word;
	function B_sigma1 (x : word) return word;
	function S_sigma0 (x : word) return word;
	function S_sigma1 (x : word) return word;

end package ;

package body sha256_pack is

	function Ch (x, y, z : word) return word is
		variable res : word;
	begin
		res := (x and y) xor (not(x) and z);
		return res;
	end function;


	function Maj (x, y, z : word) return word is
		variable res : word;
	begin
		res := (x and y) xor (x and z) xor (y and z);
		return res;
	end function;


	function B_sigma0 (x : word) return word is
		variable res : word;
		variable R2 : word;
		variable R13 : word;
		variable R22 : word;
	begin
		R2 := x(1 downto 0) & x(31 downto 2);
		R13 := x(12 downto 0) & x(31 downto 13);
		R22 := x(21 downto 0) & x(31 downto 22);
		res := R2 xor R13 xor R22;
		return res;
	end function;

	function B_sigma1 (x : word) return word is 
		variable res : word;
		variable R6 : word;
		variable R11 : word;
		variable R25 : word;
	begin
		R6 := x(5 downto 0) & x(31 downto 6);
		R11 := x(10 downto 0) & x(31 downto 11);
		R25 := x(24 downto 0) & x(31 downto 25);
		res := R6 xor R11 xor R25;
		return res;
	end function;

	function S_sigma0 (x : word) return word is
		variable res : word;
		variable R7 : word;
		variable R18 : word;
		variable S3 : word;
	begin
		R7 := x(6 downto 0) & x(31 downto 7);
		R18 := x(17 downto 0) & x(31 downto 18);
		S3 := "000" & x(31 downto 3);
		res := R7 xor R18 xor S3;
		return res;
	end function;

	function S_sigma1 (x : word) return word is
		variable res : word;
		variable R17 : word;
		variable R19 : word;
		variable S10 : word;
	begin
		R17 := x(16 downto 0) & x(31 downto 17);
		R19 := x(18 downto 0) & x(31 downto 19);
		S10 := "0000000000" & x(31 downto 10);
		res := R17 xor R19 xor S10;
		return res;
	end function;

-- Function used for testing the correctness of the hash
	--function sha256 (x : message_t) return word_vect is 
		--variable M_in : word_vect(1 to 16);
		--variable W : word_vect(1 to 64);
		--variable prev_H : word_vect(1 to 8);
		--variable a,b,c,d,e,f,g,h : word;
		--variable T1, T2 : word;
		--variable block_iter : integer;
	---- for printing
		----FILE out_file : TEXT OPEN WRITE_MODE IS "true_values";
		----variable myline : LINE;
	--begin
		--block_iter := x'length;

		--for i in x'range loop
			--M_in := x(i);
			--for k in M_in'range loop
			--end loop;
			--if i = 1 then
				--prev_H := H0;
			--end if;
			--a := prev_H(1);
			--b := prev_H(2);
			--c := prev_H(3);
			--d := prev_H(4);
			--e := prev_H(5);
			--f := prev_H(6);
			--g := prev_H(7);
			--h := prev_H(8);
			--for j in 1 to 64 loop
				--if j < 17 then
					--W(j) := M_in(j);
				--else 
					--W(j) := S_sigma1(W(j-2)) + W(j-7) + S_sigma0(W(j-15)) + W(j-16);
				--end if;
				--T1 := h + B_sigma1(e) + Ch(e,f,g) + K_a(j) + W(j);
				--T2 := B_sigma0(a) + Maj(a,b,c);
				--h := g;
				--g := f;
				--f := e;
				--e := d + T1;
				--d := c;
				--c := b;
				--b := a;
				--a := T1 + T2;
			--end loop;
			--prev_H(1) := a + prev_H(1);
			--prev_H(2) := b + prev_H(2);
			--prev_H(3) := c + prev_H(3);
			--prev_H(4) := d + prev_H(4);
			--prev_H(5) := e + prev_H(5);
			--prev_H(6) := f + prev_H(6);
			--prev_H(7) := g + prev_H(7);
			--prev_H(8) := h + prev_H(8);
		--end loop;
		--return prev_H;
	--end function;

end package body ;			
