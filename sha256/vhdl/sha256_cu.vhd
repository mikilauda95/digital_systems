library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use work.sha256_pack.ALL;

entity cu is
	port (
			 clk	: in std_ulogic;
			 aresetn	: in std_ulogic;
			 new_data: in std_ulogic;
			 new_mess: in std_ulogic;
			 H_prev : in word_vect(1 to 8);
			 CW : out std_ulogic_vector(3 downto 0);
			 count : out natural;
			 H_start : out word_vect(1 to 8)
		 );
end entity cu;

architecture behav of cu is

	signal count_it : natural;
	signal endblock, enable, enable_i,  busy, fill : std_ulogic;
	type states is (IDLE, RECEIVING, ELABORATING, WRITING);
	signal CURR_STATE, NEXT_STATE : states;
	signal count_it_s, count_block_s: natural;
    signal H_start_s : word_vect(1 to 8);

begin

	-- Use  a signal for avoiding reading the output
	count <= count_it;

	-- process for updating the state and counters implementations
	process (clk)
	begin
		if rising_edge(clk) then
			if aresetn = '0' then
				CURR_STATE <= IDLE;
			else
				CURR_STATE <= NEXT_STATE;
				count_it <= count_it_s;
				--count_block <= count_block_s;
			end if;	
		end if;
	end process;



	--NEXT STATE PROCESS

	process (CURR_STATE, new_data, count_it)
	begin
		case CURR_STATE is
			when IDLE   =>
				if  new_data = '1' then
					NEXT_STATE <= RECEIVING ;
				else
					NEXT_STATE <= IDLE ;
				end if;
			when RECEIVING =>
				if new_data = '1' and count_it < 16 then
					NEXT_STATE <= RECEIVING;
				elsif new_data = '0' and count_it <16 then
					NEXT_STATE <= IDLE;
				else
					NEXT_STATE <= ELABORATING;
				end if;
			when ELABORATING =>
				if count_it < 64 then
					NEXT_STATE <= ELABORATING;
				else
					NEXT_STATE <= WRITING;
				end if;
			when WRITING =>
					NEXT_STATE <= IDLE;
		end case;
	end process;

	--OUTPUT PROCESS
	process (CURR_STATE)
	begin
		case CURR_STATE is
			when IDLE =>
				busy <= '0';
				enable_i <= '0';
				fill <= '1';
				endblock <= '0';
			when RECEIVING =>
				busy <= '0';
				enable_i <= '0';
				fill <= '1';
				endblock <= '0';
			when ELABORATING =>
				busy <= '1';
				enable_i <= '1';
				fill <= '0';
				endblock <= '0';
			when WRITING =>
				busy <= '1';
				enable_i <= '0';
				fill <= '0';
				endblock <= '1';

		end case;
	end process;

    H_start <= H_start_s;

    H_start_s <= H0 when new_mess = '1' else
               --H_prev when CURR_STATE = IDLE and count_it = 0;
               H_prev;

	count_it_s <= 0 when (aresetn = '0') or (count_it = 64) else
				  count_it+1 when count_it /= 64 and enable = '1' else
				  count_it;

	--endblock <= '1' when count_it = 65 else
				--'0';

	--CW <= busy & enable & fill;
	enable <= new_data or enable_i;
	CW(0) <= busy;
	CW(1) <= enable;
	CW(2) <= fill;
	CW(3) <= endblock;

end behav;
