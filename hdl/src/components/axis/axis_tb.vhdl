library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity axis_tb is
end axis_tb;

architecture Behavioral of axis_tb is

component axis_reg is
	generic (g_width_bits : natural := 31);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;

		--input
		m_data : out std_logic_vector(g_width_bits-1 downto 0);
		m_valid : out std_logic;
		m_last : out std_logic;
		m_ready : in std_logic;

		--input
		s_data : in std_logic_vector(g_width_bits-1 downto 0);
		s_valid : in std_logic;
		s_last : in std_logic;
		s_ready : out std_logic

           	);
end component;

component axis_serializer is
	generic(g_width_bits : natural := 32; g_parallell_width_bits : natural := 124);
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
end component;


type test_states is(test_start, test_end_delay, tx_test_1, tx_test_1_wait_done, rx_last, test_done);
type tx_control_states is (tx_control_idle, tx_control_transmit);
type rx_control_states is (rx_control_idle, rx_control_receive);

--Test signals
signal test_state : test_states;

signal clk  : std_logic:= '0';
signal test_stop : std_logic := '0';
signal reset : std_logic:='1';
signal end_delay : unsigned(5 downto 0) := "111111";

--transmit control signals
signal tx_control_state : tx_control_states;
signal tx_data 	: std_logic_vector(31 downto 0);
signal beats_to_tx : unsigned(31 downto 0);
signal tx_beats_left : unsigned(31 downto 0);
signal tx_start : std_logic;
signal tx_done : std_logic;
signal tx_ready : std_logic;

--receive control signals
signal rx_control_state : rx_control_states;
signal rx_data 	: std_logic_vector(31 downto 0);
signal beats_to_rx : unsigned(31 downto 0);
signal rx_beats_left : unsigned(31 downto 0);
signal rx_start : std_logic;
signal rx_done : std_logic;
signal rx_ready : std_logic;


--axis signals
--input
signal m_data 	: std_logic_vector(31 downto 0);
signal m_valid 	: std_logic;
signal m_last 	: std_logic;
signal m_ready 	: std_logic;
--input
signal s_data 	: std_logic_vector(31 downto 0);
signal s_valid 	: std_logic;
signal s_last 	: std_logic;
signal s_ready 	: std_logic;

begin


clk <= not clk after 5 ns when (test_stop = '0') else '0';
reset <= '0' after 100 ns;

i_axis_serializer : axis_serializer
	generic map(g_width_bits => 16, g_parallell_width_bits => 40)
    	port map( 
		reset => reset,
		clk => clk,

		s_in => x"9876543210",
		s_valid =>'1',
		s_ready => open,

		--output
		m_data => open,
		m_valid => open,
		m_last => open,
		m_keep => open,
		m_ready => '1'
           	);


i_axis_reg : axis_reg
	generic map(g_width_bits=>32)
	port map(
		reset => reset,
		clk => clk,
		m_data => m_data, 
		m_valid => m_valid,
		m_last => m_last,
		m_ready => m_ready,
		s_data => s_data, 
		s_valid => s_valid,
		s_last => s_last,
		s_ready => s_ready
	);


	p_test : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				test_state <= test_start;
			else
				case (test_state) is
					when test_start =>
						--m_data <= x"00000001";
						--m_valid <= '1';
						--s_ready <= '1';
						test_state <= tx_test_1;

					when tx_test_1 =>
						if tx_ready = '1' then
							beats_to_tx <= to_unsigned(5, 32);
							tx_start <= '1';
							test_state <= tx_test_1_wait_done;
							beats_to_rx <= to_unsigned(2, 32);
							rx_start <= '1';
						end if;

					when tx_test_1_wait_done =>
						tx_start <= '0';
						rx_start <= '0';
						if rx_done = '1' then
							test_state <= rx_last;
							rx_start <= '1';
							beats_to_rx <= to_unsigned(3, 32);
						end if;
					
					when rx_last =>
						--tx_start <= '0';
						rx_start <= '0';
						if rx_done = '1' then
							test_state <= test_end_delay;
							--rx_start <= '1';
							--beats_to_rx <= to_unsigned(1, 32);
						end if;


					when test_end_delay =>
						end_delay <= end_delay -to_unsigned(1, 6);
						if end_delay = "000000" then
							test_state <= test_done;
						end if;
								      
					when test_done =>
					       --report "simulation ended" severity warning;
					       test_stop <= '1';	
				end case;
			end if;
		end if;
	end process p_test;


	p_transmit_control : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				s_data <= (others => '0');
				s_valid <= '0';
				tx_ready <= '0';
				tx_control_state <= tx_control_idle;
			else
				case (tx_control_state) is
					when tx_control_idle =>
						tx_done <= '0';
						tx_ready <= '1';
						if tx_start = '1' then
							tx_control_state <= tx_control_transmit;
							tx_beats_left <= beats_to_tx;
							tx_ready <= '0';
						end if;

					when tx_control_transmit =>
						--s_data <= tx_data;
						s_valid <= '1';
						s_last <= '0';
						if s_ready = '1' and s_valid = '1' then
							s_data <= std_logic_vector(unsigned(s_data)+1);
							tx_beats_left <= tx_beats_left -1;

							if tx_beats_left = 1 then
								tx_control_state <= tx_control_idle;
								tx_done <= '1';
								s_valid <= '0';
							end if;
						end if;
				end case;
						

			end if;
		end if;
	end process;

	p_receive_control : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				rx_data <= (others => '0');
				--s_valid <= '0';
				rx_ready <= '0';
				rx_control_state <= rx_control_idle;
			else
				case (rx_control_state) is
					when rx_control_idle =>
						rx_done <= '0';
						rx_ready <= '1';
						if rx_start = '1' then
							rx_control_state <= rx_control_receive;
							rx_beats_left <= beats_to_rx;
							rx_ready <= '0';
						end if;

					when rx_control_receive =>
						rx_data <= m_data;
						m_ready <= '1';
						if m_ready = '1' and m_valid = '1' then
							rx_beats_left <= rx_beats_left -1;

							if rx_beats_left = 1 then
								rx_control_state <= rx_control_idle;
								rx_done <= '1';
								m_ready <= '0';
							end if;
						end if;
				end case;
						

			end if;
		end if;
	end process;



end Behavioral;

