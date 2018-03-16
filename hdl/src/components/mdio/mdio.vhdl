library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mdio is
	generic(bits : integer := 64);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

        phy_addr : in std_logic_vector(4 downto 0);
        reg_addr : in std_logic_vector(4 downto 0);
        data_rd : out std_logic_vector(15 downto 0);
        data_wr : in std_logic_vector(15 downto 0);
        wr : in std_logic;
        start : std_logic;
        busy : std_logic;
           	);
end mdio;

architecture Behavioral of mdio is
	signal mdio : unsigned(bits -1  downto 0);
begin
	p_coount : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				mdio <= (others => '0');
				phase_out <= (others => '0');
			else	
			mdio <= mdio + unsigned(phase_step);
			phase_out <= std_logic_vector(mdio + unsigned(phase_modulation));
			end if;
		end if;
	end process;

end Behavioral;

