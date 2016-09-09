library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity lookup_table is
    	port ( 
		clk : in  STD_LOGIC;
	
		x 	: in std_logic_vector(8 - 1 downto 0);
		xout 	: out std_logic_vector(8 - 1 downto 0);
		y	: out std_logic_vector(13 - 1 downto 0)
           	);
end lookup_table;

architecture Behavioral of lookup_table is
begin
	p_coount : process(clk)
	begin
		if rising_edge(clk) then
			xout <= x;
			case x is
				when "00000000" => y <= "0000000000000";
				when "00000001" => y <= "0000001100100";
				when "00000010" => y <= "0000011001000";
				when "00000011" => y <= "0000100101101";
				when "00000100" => y <= "0000110010001";
				when "00000101" => y <= "0000111110101";
				when "00000110" => y <= "0001001011000";
				when "00000111" => y <= "0001010111100";
				when "00001000" => y <= "0001100011110";
				when "00001001" => y <= "0001110000001";
				when "00001010" => y <= "0001111100011";
				when "00001011" => y <= "0010001000100";
				when "00001100" => y <= "0010010100100";
				when "00001101" => y <= "0010100000100";
				when "00001110" => y <= "0010101100011";
				when "00001111" => y <= "0010111000001";
				when "00010000" => y <= "0011000011111";
				when "00010001" => y <= "0011001111011";
				when "00010010" => y <= "0011011010110";
				when "00010011" => y <= "0011100110001";
				when "00010100" => y <= "0011110001010";
				when "00010101" => y <= "0011111100010";
				when "00010110" => y <= "0100000111001";
				when "00010111" => y <= "0100010001110";
				when "00011000" => y <= "0100011100011";
				when "00011001" => y <= "0100100110101";
				when "00011010" => y <= "0100110000111";
				when "00011011" => y <= "0100111010111";
				when "00011100" => y <= "0101000100101";
				when "00011101" => y <= "0101001110010";
				when "00011110" => y <= "0101010111110";
				when "00011111" => y <= "0101100000111";
				when "00100000" => y <= "0101101001111";
				when "00100001" => y <= "0101110010101";
				when "00100010" => y <= "0101111011010";
				when "00100011" => y <= "0110000011100";
				when "00100100" => y <= "0110001011101";
				when "00100101" => y <= "0110010011100";
				when "00100110" => y <= "0110011011001";
				when "00100111" => y <= "0110100010100";
				when "00101000" => y <= "0110101001100";
				when "00101001" => y <= "0110110000011";
				when "00101010" => y <= "0110110111000";
				when "00101011" => y <= "0110111101011";
				when "00101100" => y <= "0111000011011";
				when "00101101" => y <= "0111001001001";
				when "00101110" => y <= "0111001110101";
				when "00101111" => y <= "0111010011111";
				when "00110000" => y <= "0111011000111";
				when "00110001" => y <= "0111011101100";
				when "00110010" => y <= "0111100001111";
				when "00110011" => y <= "0111100110000";
				when "00110100" => y <= "0111101001110";
				when "00110101" => y <= "0111101101010";
				when "00110110" => y <= "0111110000100";
				when "00110111" => y <= "0111110011011";
				when "00111000" => y <= "0111110110000";
				when "00111001" => y <= "0111111000010";
				when "00111010" => y <= "0111111010010";
				when "00111011" => y <= "0111111100000";
				when "00111100" => y <= "0111111101011";
				when "00111101" => y <= "0111111110011";
				when "00111110" => y <= "0111111111010";
				when "00111111" => y <= "0111111111101";
				when "01000000" => y <= "0111111111111";
				when "01000001" => y <= "0111111111101";
				when "01000010" => y <= "0111111111010";
				when "01000011" => y <= "0111111110011";
				when "01000100" => y <= "0111111101011";
				when "01000101" => y <= "0111111100000";
				when "01000110" => y <= "0111111010010";
				when "01000111" => y <= "0111111000010";
				when "01001000" => y <= "0111110110000";
				when "01001001" => y <= "0111110011011";
				when "01001010" => y <= "0111110000100";
				when "01001011" => y <= "0111101101010";
				when "01001100" => y <= "0111101001110";
				when "01001101" => y <= "0111100110000";
				when "01001110" => y <= "0111100001111";
				when "01001111" => y <= "0111011101100";
				when "01010000" => y <= "0111011000111";
				when "01010001" => y <= "0111010011111";
				when "01010010" => y <= "0111001110101";
				when "01010011" => y <= "0111001001001";
				when "01010100" => y <= "0111000011011";
				when "01010101" => y <= "0110111101011";
				when "01010110" => y <= "0110110111000";
				when "01010111" => y <= "0110110000011";
				when "01011000" => y <= "0110101001100";
				when "01011001" => y <= "0110100010100";
				when "01011010" => y <= "0110011011001";
				when "01011011" => y <= "0110010011100";
				when "01011100" => y <= "0110001011101";
				when "01011101" => y <= "0110000011100";
				when "01011110" => y <= "0101111011010";
				when "01011111" => y <= "0101110010101";
				when "01100000" => y <= "0101101001111";
				when "01100001" => y <= "0101100000111";
				when "01100010" => y <= "0101010111110";
				when "01100011" => y <= "0101001110010";
				when "01100100" => y <= "0101000100101";
				when "01100101" => y <= "0100111010111";
				when "01100110" => y <= "0100110000111";
				when "01100111" => y <= "0100100110101";
				when "01101000" => y <= "0100011100011";
				when "01101001" => y <= "0100010001110";
				when "01101010" => y <= "0100000111001";
				when "01101011" => y <= "0011111100010";
				when "01101100" => y <= "0011110001010";
				when "01101101" => y <= "0011100110001";
				when "01101110" => y <= "0011011010110";
				when "01101111" => y <= "0011001111011";
				when "01110000" => y <= "0011000011111";
				when "01110001" => y <= "0010111000001";
				when "01110010" => y <= "0010101100011";
				when "01110011" => y <= "0010100000100";
				when "01110100" => y <= "0010010100100";
				when "01110101" => y <= "0010001000100";
				when "01110110" => y <= "0001111100011";
				when "01110111" => y <= "0001110000001";
				when "01111000" => y <= "0001100011110";
				when "01111001" => y <= "0001010111100";
				when "01111010" => y <= "0001001011000";
				when "01111011" => y <= "0000111110101";
				when "01111100" => y <= "0000110010001";
				when "01111101" => y <= "0000100101101";
				when "01111110" => y <= "0000011001000";
				when "01111111" => y <= "0000001100100";
				when "10000000" => y <= "0000000000000";
				when "10000001" => y <= "1111110011011";
				when "10000010" => y <= "1111100110111";
				when "10000011" => y <= "1111011010010";
				when "10000100" => y <= "1111001101110";
				when "10000101" => y <= "1111000001010";
				when "10000110" => y <= "1110110100111";
				when "10000111" => y <= "1110101000011";
				when "10001000" => y <= "1110011100001";
				when "10001001" => y <= "1110001111110";
				when "10001010" => y <= "1110000011100";
				when "10001011" => y <= "1101110111011";
				when "10001100" => y <= "1101101011011";
				when "10001101" => y <= "1101011111011";
				when "10001110" => y <= "1101010011100";
				when "10001111" => y <= "1101000111110";
				when "10010000" => y <= "1100111100000";
				when "10010001" => y <= "1100110000100";
				when "10010010" => y <= "1100100101001";
				when "10010011" => y <= "1100011001110";
				when "10010100" => y <= "1100001110101";
				when "10010101" => y <= "1100000011101";
				when "10010110" => y <= "1011111000110";
				when "10010111" => y <= "1011101110001";
				when "10011000" => y <= "1011100011100";
				when "10011001" => y <= "1011011001010";
				when "10011010" => y <= "1011001111000";
				when "10011011" => y <= "1011000101000";
				when "10011100" => y <= "1010111011010";
				when "10011101" => y <= "1010110001101";
				when "10011110" => y <= "1010101000001";
				when "10011111" => y <= "1010011111000";
				when "10100000" => y <= "1010010110000";
				when "10100001" => y <= "1010001101010";
				when "10100010" => y <= "1010000100101";
				when "10100011" => y <= "1001111100011";
				when "10100100" => y <= "1001110100010";
				when "10100101" => y <= "1001101100011";
				when "10100110" => y <= "1001100100110";
				when "10100111" => y <= "1001011101011";
				when "10101000" => y <= "1001010110011";
				when "10101001" => y <= "1001001111100";
				when "10101010" => y <= "1001001000111";
				when "10101011" => y <= "1001000010100";
				when "10101100" => y <= "1000111100100";
				when "10101101" => y <= "1000110110110";
				when "10101110" => y <= "1000110001010";
				when "10101111" => y <= "1000101100000";
				when "10110000" => y <= "1000100111000";
				when "10110001" => y <= "1000100010011";
				when "10110010" => y <= "1000011110000";
				when "10110011" => y <= "1000011001111";
				when "10110100" => y <= "1000010110001";
				when "10110101" => y <= "1000010010101";
				when "10110110" => y <= "1000001111011";
				when "10110111" => y <= "1000001100100";
				when "10111000" => y <= "1000001001111";
				when "10111001" => y <= "1000000111101";
				when "10111010" => y <= "1000000101101";
				when "10111011" => y <= "1000000011111";
				when "10111100" => y <= "1000000010100";
				when "10111101" => y <= "1000000001100";
				when "10111110" => y <= "1000000000101";
				when "10111111" => y <= "1000000000010";
				when "11000000" => y <= "1000000000001";
				when "11000001" => y <= "1000000000010";
				when "11000010" => y <= "1000000000101";
				when "11000011" => y <= "1000000001100";
				when "11000100" => y <= "1000000010100";
				when "11000101" => y <= "1000000011111";
				when "11000110" => y <= "1000000101101";
				when "11000111" => y <= "1000000111101";
				when "11001000" => y <= "1000001001111";
				when "11001001" => y <= "1000001100100";
				when "11001010" => y <= "1000001111011";
				when "11001011" => y <= "1000010010101";
				when "11001100" => y <= "1000010110001";
				when "11001101" => y <= "1000011001111";
				when "11001110" => y <= "1000011110000";
				when "11001111" => y <= "1000100010011";
				when "11010000" => y <= "1000100111000";
				when "11010001" => y <= "1000101100000";
				when "11010010" => y <= "1000110001010";
				when "11010011" => y <= "1000110110110";
				when "11010100" => y <= "1000111100100";
				when "11010101" => y <= "1001000010100";
				when "11010110" => y <= "1001001000111";
				when "11010111" => y <= "1001001111100";
				when "11011000" => y <= "1001010110011";
				when "11011001" => y <= "1001011101011";
				when "11011010" => y <= "1001100100110";
				when "11011011" => y <= "1001101100011";
				when "11011100" => y <= "1001110100010";
				when "11011101" => y <= "1001111100011";
				when "11011110" => y <= "1010000100101";
				when "11011111" => y <= "1010001101010";
				when "11100000" => y <= "1010010110000";
				when "11100001" => y <= "1010011111000";
				when "11100010" => y <= "1010101000001";
				when "11100011" => y <= "1010110001101";
				when "11100100" => y <= "1010111011010";
				when "11100101" => y <= "1011000101000";
				when "11100110" => y <= "1011001111000";
				when "11100111" => y <= "1011011001010";
				when "11101000" => y <= "1011100011100";
				when "11101001" => y <= "1011101110001";
				when "11101010" => y <= "1011111000110";
				when "11101011" => y <= "1100000011101";
				when "11101100" => y <= "1100001110101";
				when "11101101" => y <= "1100011001110";
				when "11101110" => y <= "1100100101001";
				when "11101111" => y <= "1100110000100";
				when "11110000" => y <= "1100111100000";
				when "11110001" => y <= "1101000111110";
				when "11110010" => y <= "1101010011100";
				when "11110011" => y <= "1101011111011";
				when "11110100" => y <= "1101101011011";
				when "11110101" => y <= "1101110111011";
				when "11110110" => y <= "1110000011100";
				when "11110111" => y <= "1110001111110";
				when "11111000" => y <= "1110011100001";
				when "11111001" => y <= "1110101000011";
				when "11111010" => y <= "1110110100111";
				when "11111011" => y <= "1111000001010";
				when "11111100" => y <= "1111001101110";
				when "11111101" => y <= "1111011010010";
				when "11111110" => y <= "1111100110111";
				when "11111111" => y <= "1111110011011";
				when others => y <= (others => '0');

			end case;
		end if;
	end process;

end Behavioral;
