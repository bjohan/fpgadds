library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axis_serializer is
	generic(g_axis_words : natural := 4; g_parallell_words : natural := 9; g_word_bits : natural := 8);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

		s_in : in std_logic_vector(g_parallell_words*g_word_bits -1 downto 0);
		s_valid : in std_logic;
		s_ready : out std_logic;

		--output
		m_data : out std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		m_valid : out std_logic;
		m_last : out std_logic;
		m_keep : out std_logic_vector(g_axis_words-1 downto 0);
		m_ready : in std_logic
           	);
end axis_serializer;

architecture Behavioral of axis_serializer is
	type serializer_states is (idle, transmit, last);
	type word_vector is array (g_parallell_words-1 downto 0) of std_logic_vector(g_word_bits-1 downto 0);

	constant num_axis_words : natural := (g_parallell_words+g_axis_words-1)/g_axis_words;

	signal beat_in : std_logic;
	signal s_ready_int : std_logic;
	signal words_reg : word_vector;
	signal serializer_state : serializer_states;
	signal keep_vector : std_logic_vector(g_parallell_words-1 downto 0);
	signal word_cnt : natural;

	function word_vector_from_stdlv(stdlv : std_logic_vector) return word_vector is
	variable wv : word_vector;
	begin
	for i in 0 to g_parallell_words-1 loop
		wv(i) := stdlv((i+1)*g_word_bits-1 downto i*g_word_bits);
	end loop;
  	return wv;
	end function word_vector_from_stdlv;

	function stdlv_from_word_vector(words : word_vector) return std_logic_vector is
	variable o : std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
	begin
		for i in 0 to g_axis_words -1 loop
			o((i+1)*g_word_bits-1 downto i*g_word_bits) := words(i);
		end loop;
		return o;
	end function stdlv_from_word_vector;





begin


s_ready <= s_ready_int;
beat_in <= '1' when s_ready_int = '1' and s_valid = '1' else '0'; 

p_transmit : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			serializer_state <= idle;
			m_valid <= '0';
			m_last <= '0';
		else
			case(serializer_state) is 
				when idle =>
					s_ready_int <= '1';
					if beat_in = '1' then
						word_cnt <= 0;
						words_reg <= word_vector_from_stdlv(s_in);
						serializer_state <= transmit;
						keep_vector <= (others => '1');
					end if;	

				when transmit =>
					if beat_in = '1' then
						words_reg(words_reg'high-g_axis_words downto 0)<=
								words_reg(words_reg'high downto g_axis_words);
						keep_vector(keep_vector'high-g_axis_words downto 0) <=
								keep_vector(keep_vector'high downto g_axis_words);
						keep_vector(keep_vector'high downto keep_vector'high-g_axis_words+1)<=
								(others => '0');
						m_data <= stdlv_from_word_vector(words_reg);
						m_keep <= keep_vector(g_axis_words-1 downto 0);
						m_valid <= '1';

						word_cnt <= word_cnt +1;
						if word_cnt = num_axis_words -1 then
							m_last <= '1';
							serializer_state <= last;
						end if;
					end if;
				when last =>
					if beat_in = '1' then
						serializer_state <= idle;
						m_last <= '0';
						m_valid <= '0';
					end if;

			end case;

		end if;
	end if;
end process;

end Behavioral;

