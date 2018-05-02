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
		m_ready : in std_logic
           	);

end axis_packet_join;

architecture Behavioral of axis_packet_join is
	type packet_join_states is (idle, head, join, tail);
	signal packet_join_state : packet_join_states;
	signal beat_in1 : std_logic;
	signal beat_in2 : std_logic;
	signal beat_out : std_logic;
	signal stored : std_logic_vector(g_width_bits -1 downto 0);
	signal stored_valid : std_logic;
	signal s_ready1_int : std_logic;
	signal s_ready2_int : std_logic;
	
function count_keeps(keep : std_logic_vector) return integer is
	variable cnt : natural := 0;
begin
	for i in keep'range loop
		if keep(i) = '1' then 
			cnt := cnt + 1;
		else
			return cnt;
 		end if;
	end loop;
  	return cnt;
end function count_keeps;

signal m_valid_int : std_logic;
begin

i_mux: entity work.axis_mux(Behavioral)
	generic map (g_width_bits => g_width_bits)
	port map( 


		sel => '0',

		s_data0 => s_data1,
		s_valid0 => s_valid1,
		s_ready0 => s_ready1,
		s_data1 => s_data2,
		s_valid1 => s_valid2,
		s_ready1 => s_ready2,
		m_data => m_data,
		m_valid => m_valid,
		m_ready =>m_ready
           	);

--s_ready1 <= s_ready1_int and not s_last1;
--s_ready2 <= s_ready2_int;

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
			--s_ready_int <= '0';
			m_valid_int <= '0';
		else
			case (packet_join_state) is
				when idle =>
					if s_valid1 = '1' and s_valid2 = '1' then --wait for both packets to start
						--s_ready1 <= '1';
						packet_join_state <= head;
					end if;
				when head =>
					--if beat_in = '1' then
					--end if;
				when join =>
				when tail=>
			end case;

		end if;
	end if;
end process;

end Behavioral;

