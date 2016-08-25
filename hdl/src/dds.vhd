library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity dds_papilio_pro_top_str is
	generic(bits : integer := 64);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;
	
		phase_modulation : in std_logic_vector(bits - 1 downto 0);
		phase_step	: in std_logic_vector(bits - 1 downto 0);
		phase_out	: out std_logic_vector(bits - 1 downto 0)
           	);
end dds_papilio_pro_top_str;

architecture Behavioral of dds_papilio_pro_top_str is
	signal phase_accumulator : unsigned(bits -1  downto 0);
begin
	p_coount : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				phase_accumulator <= (others => '0');
				phase_out <= (others => '0');
				
			end if;
			phase_accumulator <= phase_accumulator + unsigned(phase_step);
			phase_out <= std_logic_vector(phase_accumulator + unsigned(phase_modulation));
		end if;
	end process;

end Behavioral;

