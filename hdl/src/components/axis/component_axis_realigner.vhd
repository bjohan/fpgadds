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

	type aligner_states is (idle, first_data, data, transfer_remaining, last_beat);

	type word_vector is array (g_axis_words-1 downto 0) of std_logic_vector(g_word_bits-1 downto 0);
	
	signal aligner_state : aligner_states;
	signal beat : std_logic;
	--signal word_reg : word_vector;
	signal delay_reg : word_vector;
	signal s_data_wv : word_vector;
	signal extra_data_wv : word_vector;
	signal delay_keep : std_logic_vector(g_axis_words-1 downto 0);
	constant zero_keep : std_logic_vector(g_axis_words-1 downto 0) := (others => '0');

	signal direct_words : natural range 0 to g_axis_words;
	signal extra_words : natural range 0 to g_axis_words;
	signal last_keep : natural range 0 to g_axis_words;
	signal offset : natural range 0 to g_axis_words;
	signal remaining_words : natural range 0 to g_axis_words;
	signal m_last_int : std_logic;
	signal transfer : std_logic;
	signal s_ready_int : std_logic;

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


	function word_vector_from_stdlv(stdlv : std_logic_vector; words : natural) return word_vector is
	variable wv : word_vector;
	begin
	for i in 0 to words-1 loop
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

	function merge_wv(left : word_vector ; right : word_vector ; nright : natural) return word_vector is
	variable o : word_vector;
	begin
		if nright = 0 then
			o := left;
		elsif nright > 0 and nright < g_axis_words then
			o(nright-1 downto 0) := right(nright-1 downto 0);
			o(g_axis_words-1 downto nright) := left(g_axis_words-nright-1 downto 0);
		elsif nright = g_axis_words then
			o := right;
		else
			assert false report "error in merge word vector" severity note;
		end if;
		return o;
	end function merge_wv;

	function join_wv(direct : word_vector ; delay : word_vector ; ndirect : natural) return word_vector is
	variable o : word_vector;
	variable ndelay : natural;
	begin
		ndelay := g_axis_words-ndirect;
		if ndirect = 0 then
			o := delay;
		elsif ndirect > 0 and ndirect < g_axis_words then
			o(g_axis_words-1 downto g_axis_words-1-(ndirect-1)) := direct(ndirect-1 downto 0);
			o((ndelay)-1 downto 0) := delay(g_axis_words-1 downto g_axis_words-1 - (ndelay-1));
		elsif ndirect = g_axis_words then
			o := direct;
		else
			assert false report "error in merge word vector" severity note;
		end if;
		return o;
	end function join_wv;

	function output_last_data(delayed : word_vector ; direct_words : natural ; last_beat : natural) return word_vector is
	variable o : word_vector;
	variable last_words : natural;
	begin
		last_words := last_beat-direct_words;
		o(last_words-1 downto 0) := delayed(last_words+direct_words-1 downto last_words);
		return o;
	end function output_last_data;


	

	function merge_keep(left : std_logic_vector ; right : std_logic_vector ; nright : natural) return std_logic_vector is
	variable o : std_logic_vector(g_axis_words-1 downto 0);
	begin
		if nright = 0 then
			o := left;
		elsif nright > 0 and nright < g_axis_words then
			o(nright-1 downto 0) := right(nright-1 downto 0);
			o(g_axis_words-1 downto nright) := left(g_axis_words-nright-1 downto 0);
		elsif nright = g_axis_words then
			o := right;
		else
			assert false report "error in merge word vector" severity note;
		end if;
		return o;
	end function merge_keep;

	function join_keep(direct : std_logic_vector ; delay : std_logic_vector ; ndirect : natural) return std_logic_vector is
	variable o : std_logic_vector(g_axis_words-1 downto 0);
	variable ndelay : natural;
	begin
		ndelay := g_axis_words-ndirect;
		if ndirect = 0 then
			o := delay;
		elsif ndirect > 0 and ndirect < g_axis_words then
			o(g_axis_words-1 downto g_axis_words-1-(ndirect-1)) := direct(ndirect-1 downto 0);
			o((ndelay)-1 downto 0) := delay(g_axis_words-1 downto g_axis_words-1 - (ndelay-1));
		elsif ndirect = g_axis_words then
			o := direct;
		else
			assert false report "error in merge word vector" severity note;
		end if;
		return o;
	end function join_keep;



begin


s_data_wv <= word_vector_from_stdlv(s_data, g_axis_words);
extra_data_wv <= word_vector_from_stdlv(extra_data, g_axis_words);
beat <= s_valid and s_ready_int;
s_ready_int <= m_ready when transfer = '1' else '0';
s_ready <= s_ready_int;
m_last <= m_last_int;

p_transmit : process(clk)
	variable word_reg : word_vector;
begin
	if rising_edge(clk) then
		if reset = '1' then
			aligner_state <= idle;
			m_last_int <= '0';
			--s_ready <= '0';
			transfer <= '0';
			m_valid <= '0';
		else
			case(aligner_state) is
				when idle=>
					if s_valid = '1' then
						aligner_state <= first_data;
						direct_words <= g_axis_words-count_keeps(extra_keep);
						extra_words <= count_keeps(extra_keep);
					end if;

				when first_data =>
					transfer <= '1';
					if beat = '1' then
						word_reg := merge_wv(s_data_wv, extra_data_wv, extra_words);
						delay_reg <= s_data_wv;
						m_data <= stdlv_from_word_vector(merge_wv(s_data_wv, extra_data_wv, extra_words));
						m_valid <= '1';
						m_keep <= merge_keep(s_keep, extra_keep, extra_words);
						delay_keep <= s_keep;
						aligner_state <= data;

						if s_last = '1' then
							transfer <= '0';
							if extra_words+count_keeps(s_keep) > g_axis_words then
								aligner_state <= transfer_remaining;
							else
								transfer <= '0';
								aligner_state <= last_beat;
								m_last_int <= '1';
							end if;
						end if;
					end if;
				
				when data =>
					if beat = '1' then
						word_reg := join_wv(s_data_wv, delay_reg, direct_words);
						delay_reg <= s_data_wv;
						m_data <= stdlv_from_word_vector(join_wv(s_data_wv, delay_reg, direct_words));
						m_valid <= '1';
						m_keep <= join_keep(s_keep, delay_keep, direct_words);
						delay_keep <= s_keep;
						aligner_state <= data;
						if s_last = '1' then
							transfer <= '0';
							if extra_words+count_keeps(s_keep) > g_axis_words then
								remaining_words <= extra_words+count_keeps(s_keep)-g_axis_words;
								last_keep <= count_keeps(s_keep);
								offset <= count_keeps(s_keep)-(extra_words+(count_keeps(s_keep)-g_axis_words));
								aligner_state <= transfer_remaining;
							else
								transfer <= '0';
								aligner_state <= last_beat;
								m_last_int <= '1';
							end if;
						end if;
					end if;

				when transfer_remaining =>
					if m_ready = '1' then
						word_reg(remaining_words-1 downto 0) := delay_reg(remaining_words-1+offset downto offset);
						m_data <= stdlv_from_word_vector(word_reg);
						m_keep <= (others => '0');
						m_keep(remaining_words-1 downto 0) <= delay_keep(remaining_words-1+offset downto offset);
						m_valid <= '1';
						m_last_int <= '1';
						if m_ready = '1' then
							transfer <= '0';
							transfer <= '0';
							aligner_state <= last_beat;
							m_last_int <= '1';
						end if;
					end if;


				when last_beat =>
					if m_ready = '1' then
						aligner_state <= idle;
						m_last_int <= '0';
						m_valid <= '0';
					end if;
			end case;
		end if;
	end if;
end process;

end Behavioral;

