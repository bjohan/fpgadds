----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:40:53 08/24/2016 
-- Design Name: 
-- Module Name:    tb - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb is
end tb;

architecture Behavioral of tb is
component dds_papilio_pro_top_str
    Port ( clkin : in  STD_LOGIC;
    	   rx : in STD_LOGIC;
    	   tx : out STD_LOGIC;
    	   reset : in STD_LOGIC;
           led1 : out  STD_LOGIC);
end component;


signal clk  : std_logic:= '0';
signal led : std_logic:='0';
signal rx : std_logic:='0';
signal reset : std_logic:='1';
signal tx : std_logic;


begin
--reset <= '1' after 0 ns;
clk <= not clk after 15.625 ns;
reset <= '0' after 60 ns;

i_top : dds_papilio_pro_top_str
port map(clkin => clk, led1 => led, rx => rx, reset=>reset, tx => tx);

end Behavioral;

