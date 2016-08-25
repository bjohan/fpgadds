library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb is
end tb;

architecture Behavioral of tb is
--component phase_accumulator
--    Port ( clk : in  STD_LOGIC;
--           led1 : out  STD_LOGIC);
--end component;
component phase_accumulator
	generic(bits : integer := 64);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;
	
		phase_modulation : in std_logic_vector(bits - 1 downto 0);
		phase_step	: in std_logic_vector(bits - 1 downto 0);
		phase_out	: out std_logic_vector(bits - 1 downto 0)
           	);
end component;



signal clk  : std_logic:= '0';
signal led : std_logic;
signal run : std_logic:='1';
signal reset : std_logic:='1';

signal step : std_logic_vector(63 downto 0);
signal phase_out : std_logic_vector(63 downto 0);
begin

clk <= not clk after 10 ns when run = '1' else '0';
run <= '0' after 10 us;
reset <= '0' after 100 ns;
step <= x"0300000000000000";

i_phase_acc : phase_accumulator
	port map(
		reset => reset,
		clk => clk,
		phase_modulation => (others => '0'),
		phase_step => step,
		phase_out => phase_out
	);
--i_top : phase_accumulator
--port map(clk => clk, led1 => led);

end Behavioral;

