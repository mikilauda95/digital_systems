library IEEE;

use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use WORK.sha256_pack.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
use std.textio.ALL;



entity sha256sim is
	end entity sha256sim;


architecture behav of sha256sim is


	signal s_clk : std_ulogic := '0';	
	signal s_aresetn : std_ulogic := '0';
	signal s_busy_out : std_ulogic; 
	signal CORRECT : std_ulogic;
	signal s_new_mess, s_new_data : std_ulogic := '0';
	signal s_HASH : word_vect(1 to 8);
	signal s_M_in : word;
	signal s_s_sigma0 : word;
	signal s_s_sigma1 : word;
	signal s_b_sigma0 : word;
	signal s_b_sigma1 : word;
	signal s_num_block : natural;

	--constant blocks : word_vect(15 downto 0):=
	--(
	--X"61626380", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	--X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000018"
	--);
	constant blocks : message_t(1 to 2):=
	( (X"61626364", X"62636465", X"63646566", X"64656667", X"65666768", X"66676869", X"6768696a", X"68696a6b",
	X"696a6b6c", X"6a6b6c6d", X"6b6c6d6e", X"6c6d6e6f", X"6d6e6f70", X"6e6f7071", X"80000000", X"00000000"),
	(X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000",
	X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"00000000", X"000001c0")
);


begin

	s_num_block <= 2;

	-- process that implements the clock
	process
	begin
		s_clk <= '0';
		wait for 1 ns;
		s_clk <= '1';
		wait for 1 ns;
	end process;

	-- process that drives the testbench signals
	process
	begin
		--keep reset active for 10 clock cycles
		for i in 1 to 10 loop
			wait until rising_edge(s_clk);
		end loop;
		s_aresetn <= '1';
		-- New mess signal set
		s_new_mess <= '1';
		for i in blocks'range loop
			for j in blocks(i)'range loop
				--every time we want to write new_data must be high
				s_new_data <= '1';
				s_M_in <= blocks(i)(j);
				wait until rising_edge(s_clk);
			end loop;
			s_M_in <= (others => '1');
			s_new_data <= '0';
			-- wait for busy to be low
			wait until s_busy_out = '0';
			-- reset new_mess signal
			s_new_mess <= '0';
			s_new_data <= '1';
		end loop;
		s_new_data <= '0';
		for i in 1 to 100 loop
			wait until rising_edge(s_clk);
		end loop;
	end process;

	sha256_block_0 : entity work.sha256_block(rtl)
	port map (
				 clk		=> s_clk,
				 aresetn	=> s_aresetn,
				 new_data => s_new_data,
				 new_mess => s_new_mess,
				 M_in		=> s_M_in,
				 HASH		=> s_HASH,
				 busy		=> s_busy_out
			 );

	-- Process to check if the HASH is equal to the referece one
	--process 
		--FILE out_file : TEXT OPEN WRITE_MODE IS "true_values";
		--variable myline : LINE;
		--variable HASH_REF : word_vect(1 to 8);
	--begin
		--HASH_REF := sha256(blocks);
		--for i in HASH_REF'range loop
				----write(output, "0x" & to_hstring(to_signed(i, 32)) & LF);  -- Hexadecimal representation
			--hwrite(myline, std_logic_vector(HASH_REF(i)));   -- CHANGED
			--writeline(out_file, myline);
			----writeline(out_file, myline);			
		--end loop;
		--wait;

	--end process;

	--CORRECT <= '1' when sha256(blocks) = s_HASH else
			   --'0';

end behav;
