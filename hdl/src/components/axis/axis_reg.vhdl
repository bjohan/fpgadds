library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axis_reg is
	generic(g_width : natural := 4);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

		--output
		m_data : out std_logic_vector(g_width*8-1 downto 0);
		m_valid : out std_logic;
		m_last : out std_logic;
		m_ready : in std_logic;

		--input
		s_data : in std_logic_vector(g_width*8-1 downto 0);
		s_valid : in std_logic;
		s_last : in std_logic;
		s_ready : out std_logic

           	);
end axis_reg;

architecture Behavioral of axis_reg is
	--type state is (idle_read_01, read_01, read_23, read_45, read_67);
	--signal state : axis_reg_state;
	--signal s_ready_int : std_logic;
	--signal m_data_int : std_logic_vector(5 downto 0);
	signal beat_in : std_logic;
	signal beat_out : std_logic;
	signal stored : std_logic_vector(8*g_width -1 downto 0);
	signal stored_valid : std_logic;
	signal s_ready_int : std_logic;
	signal m_valid_int : std_logic;
begin
s_ready <= s_ready_int;
m_valid <= m_valid_int;
--m_data <= s_data;
--m_valid <= s_valid;
--s_ready <= m_ready;
beat_in <= s_valid and s_ready_int;
beat_out <= m_valid_int and m_ready;
p_transmit : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			stored_valid  <= '0';
			s_ready_int <= '0';
			m_valid_int <= '0';
		else
			if beat_in = '0' and beat_out = '0' then
				if stored_valid = '0' then
					s_ready_int <= '1';
				end if;
			elsif beat_in = '0' and beat_out = '1' then
				if stored_valid = '1' then --if data stored
					m_data <= stored; --present data on output
					m_valid_int <= '1';
					stored_valid <= '0'; --clear store flag
					s_ready_int <= '1'; --ready to accept input
				else
					m_valid_int <= '0'; --no more data on output
					s_ready_int <= '1'; --ready to accept input
				end if;
			elsif beat_in = '1' and beat_out = '0' then --store value and set input unready
				assert not stored_valid='1' report "Accepted input data even when storage register was full" severity error;
				if m_valid_int = '0' then
					m_valid_int <= s_valid;
					m_data <= s_data;
				elsif stored_valid = '0' then
					stored_valid <= '1';
					stored <= s_data;
					s_ready_int <= '0';
				end if;
						
			elsif beat_in = '1' and beat_out = '1' then --transfer data
				assert stored_valid='0' report "Store valid set even during transfer" severity error;
				m_data <= s_data;
			end if;
			
		end if;
	end if;
end process;

end Behavioral;

