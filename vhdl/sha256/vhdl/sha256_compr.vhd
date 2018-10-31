library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;
use WORK.sha256_pack.ALL;


entity compression is
	port (
			 clk  : in std_ulogic;
			 aresetn  : in std_ulogic;
			 enable : in std_ulogic;
			 count : in natural;
			 W_in : in word;
			 H_prev : in word_vect(1 to 8);
			 H_partial : out word_vect(1 to 8)
		 );
end entity compression;

architecture behav of compression is

	signal a, b, c, d, e, f, g, h : word;	
	signal a_s, b_s, c_s, d_s, e_s, f_s, g_s, h_s : word;	
	signal CH_s, MAJ_s : word;
	signal K_s : word;
	signal T1, T2 : word;

begin

	--First chunk
	process (clk)
	begin
		if rising_edge(clk) then
			if aresetn = '0' then
				a <= (others => '0');
				b <= (others => '0');
				c <= (others => '0');
				d <= (others => '0');
				e <= (others => '0');
				f <= (others => '0');
				g <= (others => '0');
				h <= (others => '0');
			else
				if enable = '1' then
					--If count is equal to zero, a loads the previous values
					if count = 0 then
						a <= H_prev(1);
						b <= H_prev(2);
						c <= H_prev(3);
						d <= H_prev(4);
						e <= H_prev(5);
						f <= H_prev(6);
						g <= H_prev(7);
						h <= H_prev(8);
					else
						-- if we are not in the first stage (count = 0) then the loads are simply updated
						a <= a_s;
						b <= b_s;
						c <= c_s;
						d <= d_s;
						e <= e_s;
						f <= f_s;
						g <= g_s;
						h <= h_s;
					end if;
				end if;
			end if;
		end if;
	end process;

	-- These functions compute the value for the next iteration
	CH_s <= Ch(e,f,g);
	MAj_s <= Maj(a,b,c);
	T1 <= std_ulogic_vector( unsigned(h) + unsigned(B_sigma1(e)) + unsigned(CH_s) + unsigned(K_s) + unsigned(W_in));
	T2 <= std_ulogic_vector(unsigned(B_sigma0(a)) + unsigned(Maj_s));
	a_s <= std_ulogic_vector(unsigned(T1) + unsigned(T2)) ;
	b_s <= a ;
	c_s <= b ;
	d_s <= c ;
	e_s <= std_ulogic_vector(unsigned(d) + unsigned(T1));
	f_s <= e ;
	g_s <= f ;
	h_s <= g ;
    K_s <= K_A(count) when count > 0 else 
           (others => '0');

	-- Return an H_partial which will be summed with previous hash to get the final HASH
	H_partial <= (a, b, c, d, e, f, g, h);

end behav;
