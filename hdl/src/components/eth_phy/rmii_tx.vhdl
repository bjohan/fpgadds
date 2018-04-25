library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity rmii_tx is
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;
		s_data : in std_logic_vector(7 downto 0);
		s_valid : in std_logic;
		s_ready : out std_logic;
		tx_dv : out std_logic;
		txd : out std_logic_vector(1 downto 0)
           	);
end rmii_tx;

architecture Behavioral of rmii_tx is
	type rmii_tx_state is (idle, write_01, write_23, write_45, write_67);
	signal state : rmii_tx_state;
	signal s_ready_int : std_logic;
	signal s_data_int : std_logic_vector(7 downto 0);
begin
s_ready <= s_ready_int;
p_transmit : process(clk)
begin
	if falling_edge(clk) then
		if reset = '1' then
			state <= idle;
			s_ready_int <= '0';
			tx_dv <= '0';
		else
			case (state) is
				when idle =>
					tx_dv <= '0';
					s_ready_int <= '1';
					if s_valid = '1' then
						s_ready_int <= '0';
						s_data_int <= s_data;
						--state <= write_01;
						tx_dv <= '1';
						txd <= s_data(1 downto 0);
						state <= write_23;
					end if;

				when write_01 =>
					tx_dv <= '1';
					txd <= s_data_int(1 downto 0);
					state <= write_23;

				when write_23 =>
					tx_dv <= '1';
					txd <= s_data_int(3 downto 2);
					state <= write_45;

				when write_45 =>
					tx_dv <= '1';
					txd <= s_data_int(5 downto 4);
					state <= write_67;
					s_ready_int <= '1';

				when write_67 =>
					tx_dv <= '1';
					txd <= s_data_int(7 downto 6);
					state <= idle;

					if s_valid = '1' then
						s_ready_int <= '0';
						s_data_int <= s_data;
						--state <= write_01;
						--tx_dv <= '1';
						--txd <= s_data(1 downto 0);
						state <= write_01;
					end if;

				when others =>
					state <= idle;
			end case;
		end if;
	end if;
end process;

end Behavioral;

