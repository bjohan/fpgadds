library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

--This component is intended for joining two axis streams together. It takes 
-- extra_data (masked by extra_keep) and puts them first in the output stream.
-- After the extra_data, whatever on the slave bus is appended until last is
-- asserted. 

entity axis_realigner is
	generic(g_axis_words : natural := 4 ; g_word_bits : natural := 8);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

		extra_keep : in std_logic_vector(g_axis_words -1 downto 0);
		extra_data : in std_logic_vector(g_axis_words*g_word_bits-1 downto 0);

		--output
		m_data : out std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		m_valid : out std_logic;
		m_last : out std_logic;
		m_ready : in std_logic;
		m_keep : out std_logic_vector(g_axis_words -1 downto 0);

		--input
		s_data : in std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		s_valid : in std_logic;
		s_last : in std_logic;
		s_ready : out std_logic;
		s_keep : in std_logic_vector(g_axis_words-1 downto 0)

           	);
end axis_realigner;

architecture Behavioral of axis_realigner is
	signal first : std_logic;
	signal beat : std_logic;
	signal extra_beat : std_logic;
	signal extra : std_logic;
	signal extra_r : std_logic;
	signal last_data : std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
	signal last_keep : std_logic_Vector(g_axis_words-1 downto 0);
	
	signal num_extra_keeps : natural;
	signal num_input_keeps : natural;

	signal delayed_keep : std_logic_vector(g_axis_words-1 downto 0);
	signal dly_keep : natural;
	signal direct_keep : natural;
	
	signal delayed_data : std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
	signal dly_data : natural;
	signal direct_data : natural;
	
	signal data : std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
	signal keep : std_logic_vector(g_axis_words-1 downto 0);
	
	signal debug_dly_keep : unsigned(31 downto 0);
	signal debug_direct_keep : unsigned(31 downto 0);
	signal debug_dly_data : unsigned(31 downto 0);
	signal debug_direct_data : unsigned(31 downto 0);

	constant zeros : std_logic_vector(g_axis_words*g_word_bits-1 downto 0) := (others => '0');

	function count_keeps(keep : std_logic_vector) return integer is
	variable cnt : natural := 0;
	begin
	for i in keep'low to keep'high loop
		if keep(i) = '1' then 
			cnt := cnt + 1;
		else
			return cnt;
 		end if;
	end loop;
  	return cnt;
	end function count_keeps;



begin

num_extra_keeps <= count_keeps(extra_keep);
num_input_keeps <= count_keeps(s_keep);

s_ready <= m_ready and not extra_r;
extra <= '1' when (num_extra_keeps + num_input_keeps > g_axis_words) and s_last = '1' else '0';

dly_data <= num_extra_keeps*g_word_bits; --Number of delayed bits
direct_data <= g_axis_words*g_word_bits-dly_data; --Number of undelayed bits

dly_keep <= num_extra_keeps;
direct_keep <= g_axis_words-dly_keep;

debug_dly_data <= to_unsigned(dly_data, 32);
debug_direct_data <= to_unsigned(direct_data, 32);
debug_dly_keep <= to_unsigned(dly_keep, 32);
debug_direct_keep <= to_unsigned(direct_keep, 32);


keep <= s_keep(direct_keep-1 downto 0) & extra_keep(dly_keep-1 downto 0) when first = '1' and beat = '1'
	else s_keep(direct_keep-1 downto 0) & delayed_keep(g_axis_words-1 downto g_axis_words-dly_keep) when beat = '1';

data <= s_data(direct_data-1 downto 0) & extra_data(dly_data-1 downto 0) when first = '1' and beat = '1' 
	else s_data(direct_data-1 downto 0) & delayed_data(delayed_data'high downto delayed_data'high-dly_data+1) when beat = '1'; 

last_data <= zeros(direct_data-1 downto 0) & delayed_data(delayed_data'high downto direct_data);
last_keep <= zeros(direct_keep-1 downto 0) & delayed_keep(delayed_keep'high downto direct_keep);

m_keep <= last_keep when extra_r = '1' else keep;
m_data <= last_data when extra_r = '1' else data;
m_valid <= s_valid or extra_r;
m_last <= s_last when extra = '0' and extra_r= '0' else '1' when extra_r = '1' else '0';
beat <= s_valid and m_ready;
extra_beat <= extra_r and m_ready; --Internal logic makes su data is valid when extra_r is set


p_transmit : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			extra_r <= '0';
			delayed_data  <= (others => '0');
			delayed_keep <= (others => '0');
			first <= '1';
		else
			if beat = '1' then
				delayed_keep <= s_keep;
				delayed_data <= s_data;
				first <= '0';
				if extra = '1' then
					extra_r <= extra;
				end if;
			end if;

			if s_last = '1' then
				first <= '1';
			end if;

			if extra_beat = '1' then
				extra_r <= '0';
			end if;
		end if;
	end if;
end process;

end Behavioral;

