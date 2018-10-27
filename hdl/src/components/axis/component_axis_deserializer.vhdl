library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axis_deserializer is
	generic(g_axis_words : natural := 4; g_parallell_words : natural := 9; g_word_bits : natural := 8);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

		--output
		m_data : out std_logic_vector(g_parallell_words*g_word_bits -1 downto 0);
		m_valid : out std_logic;
		m_ready : in std_logic;
		m_last : out std_logic;

		--input
		s_data : in std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		s_valid : in std_logic;
		s_last : in std_logic;
		s_keep : in std_logic_vector(g_axis_words-1 downto 0);
		s_ready : out std_logic
           	);
end axis_deserializer;

architecture Behavioral of axis_deserializer is
	type deserializer_states is (idle, receive, transact);
	signal deserializer_state : deserializer_states;

	--could be optimized out by not asserting ready until transfer is finished
	signal current_axis_word : natural range 0 to g_parallell_words;
	signal beat_in : std_logic;
	signal beat_out : std_logic;
	signal s_ready_int : std_logic;
	signal m_valid_int : std_logic;
	signal debug_low_bit : unsigned(31 downto 0);
	signal low_bit: natural;
	constant num_complete_axis_words : natural := g_parallell_words/g_axis_words;
	constant num_axis_words : natural := (g_parallell_words+g_axis_words-1)/g_axis_words;
	constant last_keep : natural := g_parallell_words - num_complete_axis_words*g_axis_words;
	constant keep_ones : std_logic_vector(last_keep -1 downto 0) := (others => '1');
	constant keep_zeros: std_logic_vector(g_axis_words-last_keep-1 downto 0) := (others => '0');
begin

low_bit <= current_axis_word*g_axis_words*g_word_bits;
s_ready <= s_ready_int;
m_valid <= m_valid_int;
beat_in <= s_valid and s_ready_int;
beat_out <= m_valid_int and m_ready;
			

debug_low_bit <= to_unsigned(low_bit,32);

p_transmit : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			s_ready_int <= '0';
			m_valid_int <= '0';
		else
			case(deserializer_state) is 
				when idle =>
					s_ready_int <= '1';
					if beat_in = '1' then
						s_ready_int <= '1';
						m_data(g_axis_words*g_word_bits-1 downto 0) <= s_data;
						deserializer_state <= receive;
						current_axis_word <= 1;
					end if;	

				when receive =>
					--report "low bit is " & integer'image(low_bit);
					if beat_in = '1' then
						if current_axis_word < num_axis_words - 1 then
							current_axis_word <= current_axis_word +1;
							m_data(g_axis_words*g_word_bits-1+low_bit downto low_bit)<=s_data;
						elsif current_axis_word = num_axis_words -1 then
							current_axis_word <= current_axis_word +1;
							m_data(last_keep*g_word_bits-1+low_bit downto low_bit)<= s_data(last_keep*g_word_bits-1 downto 0);
							m_valid_int <= '1';
							s_ready_int <= '0';
							m_last <= s_last;
							deserializer_state <= transact;
						end if;
					end if;

				when transact =>
					if beat_out = '1' then
						deserializer_state <= idle;
						m_valid_int <= '0';
					end if;
			end case;

		end if;
	end if;
end process;

end Behavioral;

