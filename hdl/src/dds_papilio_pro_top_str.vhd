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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dds_papilio_pro_top_str is
    Port ( clk : in  STD_LOGIC;
           led1 : out  STD_LOGIC);
end dds_papilio_pro_top_str;

architecture Behavioral of dds_papilio_pro_top_str is
signal counter : unsigned(31 downto 0);
begin
p_coount : process(clk)
begin
	if rising_edge(clk) then
		counter <= counter + 1;
	end if;
end process;
led1 <= counter(20);

end Behavioral;
