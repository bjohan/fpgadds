library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axis_serializer is
	generic(g_width_bits : natural := 32; g_parallell_width_bits : natural := 72);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

		s_in : in std_logic_vector(g_parallell_width_bits -1 downto 0);
		s_valid : in std_logic;
		s_ready : out std_logic;

		--output
		m_data : out std_logic_vector(g_width_bits-1 downto 0);
		m_valid : out std_logic;
		m_last : out std_logic;
		m_keep : out std_logic_vector(g_width_bits-1 downto 0);
		m_ready : in std_logic
           	);
end axis_serializer;

architecture Behavioral of axis_serializer is
	type serializer_states is (idle, transmit);
	signal serializer_state : serializer_states;

	--could be optimized out by not asserting ready until transfer is finished
	signal s_in_r : std_logic_vector(g_parallell_width_bits -1 downto 0);
	
	signal current_word : natural range 0 to g_parallell_width_bits;
	signal beat_in : std_logic;
	signal beat_out : std_logic;
	signal s_ready_int : std_logic;
	signal m_valid_int : std_logic;
	signal debug : unsigned(31 downto 0);
	signal low_bit: natural;
	constant num_words : natural := g_parallell_width_bits/g_width_bits;
	constant last_keep : natural := g_parallell_width_bits - num_words*g_width_bits;
	constant keep_ones : std_logic_vector(last_keep -1 downto 0) := (others => '1');
	constant keep_zeros: std_logic_vector(g_width_bits-last_keep-1 downto 0) := (others => '0');
begin

low_bit <= current_word*g_width_bits;
s_ready <= s_ready_int;
m_valid <= m_valid_int;
beat_in <= s_valid and s_ready_int;
beat_out <= m_valid_int and m_ready;
p_transmit : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			s_ready_int <= '0';
			m_valid_int <= '0';
			m_last <= '0';
		else
			debug <= to_unsigned(current_word,32);
			case(serializer_state) is 
				when idle =>
					s_ready_int <= '1';
					if beat_in = '1' then
						s_ready_int <= '0';
						s_in_r <= s_in;
						serializer_state <= transmit;
						m_data <= s_in(g_width_bits-1 downto 0);
						m_valid_int <= '1';
						m_keep <= (others => '1');
						current_word <= 1;
					end if;	

				when transmit =>
					--report "low bit is " & integer'image(low_bit);
					if beat_out = '1' then
						if current_word < num_words then
							current_word <= current_word +1;
							m_data <= s_in_r(g_width_bits-1+low_bit downto low_bit);
							m_keep <= (others => '1');
						elsif current_word = num_words then
							current_word <= current_word +1;
							m_data(last_keep-1 downto 0) <= s_in_r(last_keep-1+low_bit downto low_bit);
							m_keep <= keep_zeros & keep_ones;
						        m_last <= '1';
						else
						        m_last <= '0';	
							m_valid_int <= '0';
							s_ready_int <= '1';
							serializer_state <= idle;
						end if;
					end if;
			end case;

		end if;
	end if;
end process;

end Behavioral;

