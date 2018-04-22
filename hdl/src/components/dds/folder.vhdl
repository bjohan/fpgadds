library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity folder is
    	port ( 
		clk : in  STD_LOGIC;
		x 	: in std_logic_vector(7 downto 0);
		y	: out std_logic_vector(5 downto 0)
           	);
end folder;

architecture Behavioral of folder is
begin
	p_coount : process(clk)
	begin
		if rising_edge(clk) then
			
			case x(7 downto 6) is
				when "00" => y <= x(5 downto 0);
				when "01" => y <= std_logic_vector(to_unsigned(63,6)-unsigned(x(5 downto 0)));
				when "10" => y <= x(5 downto 0);
				when "11" => y <= std_logic_vector(to_unsigned(63,6)-unsigned(x(5 downto 0)));
				when others => y <= (others => '0');

			end case;
		end if;
	end process;

end Behavioral;
