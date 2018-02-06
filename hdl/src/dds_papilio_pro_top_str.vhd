----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:09:07 08/24/2016 
-- Design Name: 
-- Module Name:    dds_papilio_pro_top_str - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dds_papilio_pro_top_str is
    Port ( clk : in  STD_LOGIC;
           rx : in STD_LOGIC;
           tx : out STD_LOGIC;
           a : out std_logic_vector(12 downto 0);
    	   reset : in STD_LOGIC;
           led1 : out  STD_LOGIC);
end dds_papilio_pro_top_str;

architecture Behavioral of dds_papilio_pro_top_str is

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


component lookup_table_interpolated
    	port ( 
		clk : in  STD_LOGIC;
	
		x 	: in std_logic_vector(63 downto 0);
		y	: out std_logic_vector(12 downto 0)
           	);
end component;




signal counter : unsigned(31 downto 0);
signal data : unsigned(7 downto 0);
signal vld : std_logic;




signal y : std_logic_vector(12 downto 0);
--constant step : std_logic_vector(63 downto 0):= x"0030000000000001";
constant step : std_logic_vector(63 downto 0):= x"703123412312eef1";
signal phase_out : std_logic_vector(63 downto 0);



begin



i_phase_acc : phase_accumulator
	port map(
		reset => reset,
		clk => clk,
		phase_modulation => (others => '0'),
		phase_step => step,
		phase_out => phase_out
	);

i_lut : lookup_table_interpolated
    	port map( 
		clk => clk,
		x => phase_out, --(63 downto 56),
		y => y
           	);

a<=y;

rx_inst: entity work.rs232rx 
    port map(
        reset => reset,
        rxdata => data,
        rxValid => vld,
        rxd => rx,
        clk => clk,
        baudDiv => to_unsigned(1667,24));

tx_inst: entity work.rs232tx 
    port map(
        reset => reset,
        toTx => data,
        txValid => vld,
        txd => tx,
        clk => clk,
        baudDiv => to_unsigned(1667,24));

p_coount : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			counter <= to_unsigned(0, 32);
		else
			counter <= counter + 1;
		end if;
	end if;
end process;
led1 <= counter(20);

end Behavioral;

