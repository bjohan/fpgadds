library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axis_packet_join is
	generic(g_axis_words : natural := 4 ; g_word_bits : natural := 8);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

		--input 0
		s_data0 : in std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		s_keep0 : in std_logic_Vector(g_axis_words-1 downto 0);
		s_valid0 : in std_logic;
		s_last0 : in std_logic;
		s_ready0 : out std_logic;

		--input 1
		s_data1 : in std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		s_keep1 : in std_logic_vector(g_axis_words-1 downto 0);
		s_valid1 : in std_logic;
		s_last1 : in std_logic;
		s_ready1 : out std_logic;

		--output
		m_data : out std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		m_keep : out std_logic_vector(g_axis_words-1 downto 0);
		m_valid : out std_logic;
		m_last : out std_logic;
		m_ready : in std_logic
           	);

end axis_packet_join;

architecture Behavioral of axis_packet_join is
	type packet_join_states is (idle, head, tail);
	signal packet_join_state : packet_join_states;
	signal beat_in0 : std_logic;
	signal beat_in1 : std_logic;
	signal beat_out : std_logic;
	signal go0 : std_logic;
	signal go1 : std_logic;
	signal sel : std_logic;
	signal s_ready0_int : std_logic;
	signal s_ready1_int : std_logic;
	signal s_valid0_int : std_logic;
	
	signal s_ready0g : std_logic; -- gated version of s_ready0
	signal s_ready1g : std_logic; --gated version of s_ready1

	signal data1_a : std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
	signal keep1_a : std_logic_vector(g_axis_words-1 downto 0);
	signal valid1_a : std_logic;
	signal last1_a : std_logic;
	signal ready1_a : std_logic;
	
	signal extra_data : std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
	signal extra_keep : std_logic_vector(g_axis_words-1 downto 0);

	
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


i_realigner: entity work.axis_realigner(behavioral)
	generic map (g_axis_words=> g_axis_words , g_word_bits => g_word_bits)
	port map(
		reset => reset, 
		clk => clk,

		extra_keep => extra_keep,
		extra_data => extra_data,

		--output
		m_data => data1_a,
		m_valid => valid1_a,
		m_last => last1_a,
		m_ready => ready1_a,
		m_keep => keep1_a,

		--input
		s_data => s_data1,
		s_valid => s_valid1,
		s_last => s_last1,
		s_ready => s_ready1_int,
		s_keep => s_keep1
	);



i_mux: entity work.axis_mux(Behavioral)
	generic map (g_axis_words=> g_axis_words , g_word_bits => g_word_bits)
	port map( 
		sel => sel,

		s_data0 => s_data0,
		s_valid0 => s_valid0_int,
		s_last0 => s_last0,
		s_keep0 => s_keep0,
		s_ready0 => s_ready0_int,

		s_data1 => data1_a,
		s_valid1 => valid1_a,
		s_last1 => last1_a,
		s_keep1 => keep1_a,
		s_ready1 => ready1_a,

		m_data => m_data,
		m_valid => m_valid_int,
		m_last => m_last,
		m_keep => m_keep,
		m_ready =>m_ready
           	);

s_ready0g <= s_ready0_int and go0;
s_ready1g <= s_ready1_int and go1;

s_ready0 <= s_ready0g;
s_ready1 <= s_ready1g;

s_valid0_int <= s_valid0 and not s_last0; --deassert valid to mux when last is set.


beat_in0 <= s_valid0 and s_ready0_int;
beat_in1 <= s_valid1 and s_ready1_int;

m_valid <= m_valid_int;
beat_out <= m_valid_int and m_ready;

--First use a mux to connect the input stream to the output, however use combinatorial logic to 
--clear ready when tlast is set.
--Look at keep bits and setup skewing register for s_data1, then continue with mux with same logic for last
--append the last word to what is left in the skewing register. eventually ad another bus beat if needed.

p_transmit : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			go0 <= '0';
			go1 <= '1';
			packet_join_state <= idle;
			extra_keep <= (others => '0');
			extra_data <= (others => '0');
		else
			case (packet_join_state) is
				when idle =>
					sel <= '0';
					if s_valid0 = '1' and s_valid1 = '1' then --wait 4 both packets to start
						go0 <= '1';
						packet_join_state <= head;
					end if;
				when head =>
					if beat_in0 = '1' and s_last0 = '1' then
					        go0 <= '0';	
						extra_data <= s_data0;
						extra_keep <= s_keep0;
						packet_join_state <= tail;
						go1 <= '1';
						sel <= '1';
					end if;

				when tail=>
					if beat_in1 = '1' and s_last1 = '1' then
					       go1 <= '0';
					       packet_join_state <= idle;
				       end if;

			end case;

		end if;
	end if;
end process;

end Behavioral;

