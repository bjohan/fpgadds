import math


file_name = "lut.vhdl"
file_start = """library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity lookup_table is
    	port ( 
		clk : in  STD_LOGIC;
	
		x 	: in std_logic_vector({} - 1 downto 0);
		y	: out std_logic_vector({} - 1 downto 0)
           	);
end lookup_table;

architecture Behavioral of lookup_table is
begin
	p_coount : process(clk)
	begin
		if rising_edge(clk) then

			case x is
"""

	
file_end = """				when others => y <= (others => '0');

			end case;
		end if;
	end process;

end Behavioral;
""";



def gen_lut_table(bitsX, bitsY, fn):
	fh = open(fn, 'w');
	ymax = 2**bitsY-1;
	xmax = 2**bitsX-1;
	lut_string = '';
	for i in range(xmax+1):
		yval = math.sin(math.pi*0.5*float(i)/float(xmax))*ymax;
		lut_string+=('\t\t\t\twhen "'+format(i, "0%db"%(bitsX))+'" => y <= "'+format(int(yval), "0%db"%(bitsY))+'";\n')
	fh.write(file_start.format(bitsX, bitsY))
	fh.write(lut_string)
	fh.write(file_end)


gen_lut_table(6, 12, file_name);
