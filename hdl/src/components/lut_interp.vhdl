library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity lookup_table_interpolated is
	generic(intbits : integer := 8 ; fracbits : integer := 56; ybits : integer := 13 ; ibits : integer := 15);
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
		xout 	: out std_logic_vector(8 - 1 downto 0);
		y	: out std_logic_vector(12 downto 0)
           	);
end component;

signal xr : std_logic_vector(intbits-1 downto 0);
signal ylutrr : std_logic_vector(ybits-1 downto 0);
signal ylutrrr : std_logic_vector(ybits-1 downto 0);
signal ylutrrrr : std_logic_vector(ybits-1 downto 0);
signal ylutrrrrr : std_logic_vector(ybits-1 downto 0);

signal xp1r : std_logic_vector(intbits-1 downto 0);
signal yp1lutrr : std_logic_vector(ybits -1 downto 0);


signal fracr : std_logic_vector(fracbits-1 downto 0);
signal fracrr : std_logic_vector(fracbits-1 downto 0);
signal fracrrr : std_logic_vector(fracbits-1 downto 0);
signal fracrrrr : std_logic_vector(fracbits-1 downto 0);


signal diffrrr : std_logic_vector(ybits -1 downto 0);
signal diffrrrr : std_logic_vector(ybits -1 downto 0);

signal interprrrr : std_logic_vector(18+ybits-1 downto 0);
signal interprrrrr : std_logic_vector(18+ybits-1 downto 0);


begin
	
	p_coount : process(clk)

	begin
		if rising_edge(clk) then
            xr <= x(intbits+fracbits-1 downto fracbits);
            xp1r <= std_logic_vector(signed(x(intbits+fracbits -1 downto fracbits))+1);

            fracr <= x(fracbits-1 downto 0);
            fracrr <= fracr;
            fracrrr <= fracrr;
            fracrrrr <= fracrrr;

            ylutrrr <= ylutrr;
            ylutrrrr <= ylutrrr;
            ylutrrrrr <= ylutrrrr;

            diffrrr <= std_logic_vector(signed(yp1lutrr)-signed(ylutrr));
            diffrrrr <= diffrrr;

            interprrrr <= std_logic_vector(signed('0'&fracrrrr(fracbits-1 downto fracbits-17))*signed(diffrrrr));

            y <= std_logic_vector(signed(ylutrrrrr)+signed(interprrrrr(18+ybits-2 downto 18-1)));
		end if;
	end process;

i_lut : lookup_table
    	port map( 
		clk => clk,
		x => xr,
		xout => open,
		y => ylutrr
           	);

i_lut_plus_one : lookup_table
    	port map( 
		clk => clk,
		x => xp1r,
		xout => open,
		y => yp1lutrr
           	);



end Behavioral;
