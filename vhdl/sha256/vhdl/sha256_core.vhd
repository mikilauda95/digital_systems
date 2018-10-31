library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use WORK.sha256_pack.ALL;

entity sha256_block is
	port (

			 clk  : in std_ulogic;
			 aresetn  : in std_ulogic;
			 new_data : std_ulogic;
			 new_mess : std_ulogic;
			 M_in :in word;
			 HASH : out word_vect(7 downto 0);
			 busy : out std_ulogic
		 );
end entity sha256_block;



architecture rtl of sha256_block is

	signal count : natural; 
	signal HASH_s, H_next : word_vect(1 to 8);
	signal H_prev : word_vect(1 to 8);
	signal H_partial : word_vect(1 to 8);
	signal W_in : word;
	signal enable, fill : std_ulogic;
	signal CW : std_ulogic_vector(3 downto 0);


begin

	--Final HASH assigned (to avoid to read from the output)
	HASH <= HASH_s;

	-- Update the Hash on next clock cycles 
    HASH_s <= (others => ("00000000000000000000000000000000")) when aresetn = '0' and rising_edge(clk) else
             H_next when CW(3) = '1' and rising_edge(clk);

	--Fill signals means that the component is loading the words to be hashed (first 16 cycles)
	fill <= CW(2);

	-- Enable notifies that the pipeline can proceed and can increment the counter of cycles
	enable <= CW(1);

	-- The busy signal tells that the cpu is not able to receive new data (it will ignore them)
	busy <= CW(0);

	compression_0 : entity work.compression(behav)
	port map (
				 clk   => clk,
				 aresetn   => aresetn,
				 enable => enable,
				 count  => count,
				 W_in  => W_in,
				 H_prev  => H_prev,
				 H_partial  => H_partial

			 );

	msched_0 : entity work.msched(behav)
	port map (
				 clk   => clk,
				 aresetn   => aresetn,
				 enable => enable,
				 fill => fill,
				 M_in  => M_in,
				 Wout  => W_in
			 );


	cu_0 : entity work.cu(behav)
	port map (
				 clk	 => clk,
				 aresetn	 => aresetn,
				 new_data => new_data,
				 new_mess => new_mess,
				 H_prev  => HASH_s,
				 CW => CW,
				 count  => count,
				 H_start  => H_prev
			 );


	-- Compute the next HASH from the partial hash from the compression stage and the previous HASH (driven by the control unit)
	adders : for i in 1 to 8 generate
		H_next(i) <= std_ulogic_vector(unsigned(H_partial(i)) + unsigned(H_prev(i)));
	end generate;

end rtl;
