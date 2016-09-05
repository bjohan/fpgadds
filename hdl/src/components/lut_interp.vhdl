library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity lookup_table_interpolated is
	generic(intbits : integer := 8 ; fracbits : integer := 56; ybits : integer := 13);
    	port ( 
		clk : in  STD_LOGIC;
	
		x 	: in std_logic_vector(intbits+fracbits-1 downto 0);
		y	: out std_logic_vector(13 - 1 downto 0)
           	);
end lookup_table_interpolated;

architecture Behavioral of lookup_table_interpolated is

component lookup_table
    	port ( 
		clk : in  STD_LOGIC;
	
		x 	: in std_logic_vector(8 - 1 downto 0);
		y	: out std_logic_vector(12 downto 0)
           	);
end component;

signal intx0 : std_logic_vector(intbits - 1 downto 0);
signal intx1 : std_logic_vector(intbits - 1 downto 0);
--signal fracx0 : signed(56 - 1 downto 0);

signal y0 : std_logic_vector(ybits - 1 downto 0);
signal y1 : std_logic_vector(ybits - 1 downto 0);


begin
	
	p_coount : process(clk)
	variable diff : signed(ybits -1 downto 0);
	variable interp : signed(ybits+fracbits -1 downto 0);
	variable delta : signed(intbits+fracbits -1 downto 0);
	begin
		if rising_edge(clk) then
			intx0 <= x(intbits+fracbits-1 downto fracbits);
			intx1 <= std_logic_vector(unsigned(x(intbits+fracbits-1 downto fracbits))+1);
			--fracx0 <= x(fracbits-1 downto 0);
			--fracx0 <= x(56-1 downto 0);
			--diff := y0 - y1;
			--interp := diff*fracx0;
			--delta := interp(ybits+fracbits-1 downto ybits-intbits);
			y <= std_logic_vector(y0); -- + delta;
		end if;
	end process;

i_lut : lookup_table
    	port map( 
		clk => clk,
		x => intx0,
		y => y0
           	);

i_lut_plus_one : lookup_table
    	port map( 
		clk => clk,
		x => intx1,
		y => y1
           	);



end Behavioral;
