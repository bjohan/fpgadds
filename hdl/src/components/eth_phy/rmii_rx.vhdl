library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity rmii_rx is
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;
		m_data : out std_logic_vector(7 downto 0);
		m_valid : out std_logic;
		--s_ready : in std_logic;
		crs : in std_logic;
		rxd : in std_logic_vector(1 downto 0)
           	);
end rmii_rx;

architecture Behavioral of rmii_rx is
	type rmii_rx_state is (idle_read_01, read_01, read_23, read_45, read_67);
	signal state : rmii_rx_state;
	signal s_ready_int : std_logic;
	signal m_data_int : std_logic_vector(5 downto 0);
begin
p_transmit : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			state <= idle_read_01;
			m_valid <= '0';
		else
			case (state) is
				when idle_read_01 =>
					m_valid <= '0';
					if crs = '1' then
						m_data_int(1 downto 0) <= rxd;
						state <= read_23;
					end if;

				when read_23 =>
					if crs = '1' then
						m_data_int(3 downto 2) <= rxd;
						state <= read_45;
					end if;

				when read_45 =>
					if crs = '1' then
						m_data_int(5 downto 4) <= rxd;
						state <= read_67;
					end if;

				when read_67 =>
					if crs = '1' then
						m_data(7 downto 6) <= rxd;
						m_data(5 downto 0) <= m_data_int(5 downto 0);
						state <= idle_read_01;
						m_valid <= '1';
					end if;

				when others =>
					state <= idle_read_01;
			end case;
		end if;
	end if;
end process;

end Behavioral;

