library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axis_packet_join is
	generic(g_width_bits : natural := 32);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

		--input 1
		s_data1 : in std_logic_vector(g_width_bits-1 downto 0);
		s_keep1 : in std_logic_Vector(g_width_bits-1 downto 0);
		s_valid1 : in std_logic;
		s_last1 : in std_logic;
		s_ready1 : out std_logic;

		--input 2
		s_data2 : in std_logic_vector(g_width_bits-1 downto 0);
		s_keep2 : in std_logic_Vector(g_width_bits-1 downto 0);
		s_valid2 : in std_logic;
		s_last2 : in std_logic;
		s_ready2 : out std_logic;

		--output
		m_data : out std_logic_vector(g_width_bits-1 downto 0);
		m_keep : out std_logic_Vector(g_width_bits-1 downto 0);
		m_valid : out std_logic;
		m_last : out std_logic;
		m_ready : in std_logic;
           	);
end axis_packet_join;

architecture Behavioral of axis_packet_join is
	type packet_join_states is (idle, head, join, tail);
	signal packet_state : packet_states;
	signal beat_in1 : std_logic;
	signal beat_in2 : std_logic;
	signal beat_out : std_logic;
	signal stored : std_logic_vector(g_width_bits -1 downto 0);
	signal stored_valid : std_logic;
	signal s_ready1_int : std_logic;
	signal s_ready2_int : std_logic;
	signal m_valid_int : std_logic;
begin

function count_keeps(keep : std_logic_vector) return integer is
	variable cnt : natural := 0;
begin
	for i in s'range loop
		if keep(i) = '1' then 
			cnt := cnt + 1;
		else
			return cnt;
 		end if;
	end loop;
  	return cnt;
end function count_keeps;


s_ready1 <= s_ready1_int;
s_ready2 <= s_ready2_int;

beat_in1 <= s_valid1 and s_ready1_int;
beat_in2 <= s_valid2 and s_ready2_int;

m_valid <= m_valid_int;
beat_out <= m_valid_int and m_ready;
--First use a mux to connect the input stream to the output, however use combinatorial logic to 
--clear ready when tlast is set.
--Look at keep bits and setup skewing register for s_data2, then continue with mux with same logic for last
--append the last word to what is left in the skewing register. eventually ad another bus beat if needed.

p_transmit : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			s_ready_int <= '0';
			m_valid_int <= '0';
		else
			case (packet_state) is
				when idle =>
					if s_valid1 = '1' and s_valid2 = '1' then --wait for both packets to start
						s_ready1 <= '1';
						packet_state <= head;
					end if;
				when head =>
					if beat_in = '1' then
					end if;
				when join =>
				when tail=>
			end case;

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

