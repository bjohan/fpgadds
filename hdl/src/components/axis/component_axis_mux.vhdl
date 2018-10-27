library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axis_mux is
	generic(g_axis_words : natural := 4 ; g_word_bits : natural := 8);
    	port ( 
		sel : std_logic;
		--input 1
		s_data0 : in std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		s_valid0 : in std_logic;
		s_last0 : in std_logic;
		s_keep0 : in std_logic_vector(g_axis_words-1 downto 0);
		s_ready0 : out std_logic;

		--input 2
		s_data1 : in std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		s_valid1 : in std_logic;
		s_last1 : in std_logic;
		s_keep1 : in std_logic_vector(g_axis_words-1 downto 0);
		s_ready1 : out std_logic;

		--output
		m_data : out std_logic_vector(g_axis_words*g_word_bits-1 downto 0);
		m_valid : out std_logic;
		m_last : out std_logic;
		m_keep : out std_logic_vector(g_axis_words-1 downto 0);
		m_ready : in std_logic
           	);
end axis_mux;

architecture Behavioral of axis_mux is
begin

	m_data <= s_data1 when sel = '1' else s_data0;
	m_valid <= s_valid1 when sel = '1' else s_valid0;
	m_last <= s_last1 when sel = '1' else s_last0;
	m_keep <= s_keep1 when sel = '1' else s_keep0;
	s_ready0 <=  m_ready when sel = '0' else '0';
	s_ready1 <=  m_ready when sel = '1' else '0';

end Behavioral;

