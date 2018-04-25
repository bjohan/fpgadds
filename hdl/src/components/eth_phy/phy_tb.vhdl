library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity phy_tb is
end phy_tb;

architecture Behavioral of phy_tb is
--component phase_accumulator
--    Port ( clk : in  STD_LOGIC;
--           led1 : out  STD_LOGIC);
--end component;
component mdio
	generic(div : integer := 8);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;
		phy_addr : in std_logic_vector(4 downto 0);
		reg_addr : in std_logic_vector(4 downto 0);
		wdata    : in std_logic_vector(15 downto 0);
		rdata    : out std_logic_vector(15 downto 0);
		rw	 : in std_logic;
		start    : in std_logic;
		rdy	 : out std_logic;
		done	 : out std_logic;
		do	 : out std_logic;
		di	 : in std_logic;
		oe	 : out std_logic
	
           	);
end component;

component rmii_tx is
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;
		s_data : in std_logic_vector(7 downto 0);
		s_valid : in std_logic;
		s_ready : out std_logic;
		tx_dv : out std_logic;
		txd : out std_logic_vector(1 downto 0)
           	);
end component;

component rmii_rx is
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;
		m_data : out std_logic_vector(7 downto 0);
		m_valid : out std_logic;
		crs : in std_logic;
		rxd : in std_logic_vector(1 downto 0)
           	);
end component;




type test_states is(test_start, init_write, wait_write_done, init_read, wait_read_done, test_rmii_tx, test_rmii_tx2, wait_rmii_ready_low, wait_rmii_ready, test_done, wait_rmii_rx_valid1, wait_rmii_rx_valid2);


--Test signals
signal test_state : test_states;
signal clk  : std_logic:= '0';
signal clk_eth : std_logic:='0';
signal run : std_logic:='1';
signal test_stop : std_logic := '0';
signal reset : std_logic:='1';

--MDIO signals
signal phy_addr : std_logic_vector(4 downto 0);
signal reg_addr : std_logic_vector(4 downto 0);
signal wdata : std_logic_vector(15 downto 0);
signal rdata : std_logic_vector(15 downto 0);
signal rw : std_logic;
signal start : std_logic;
signal rdy : std_logic;
signal done : std_logic;
signal di : std_logic;
signal do : std_logic;
signal oe : std_logic;

--RMII tx signals
signal s_data : std_logic_vector(7 downto 0);
signal s_valid : std_logic;
signal s_ready : std_logic;
signal tx_dv : std_logic;
signal txd : std_logic_vector(1 downto 0);

signal m_data : std_logic_vector(7 downto 0);
signal m_valid : std_logic;

begin


di <= '1';
clk <= not clk after 5 ns when (run = '1' and test_stop = '0') else '0';
run <= '0' after 3000 us;
reset <= '0' after 100 ns;

clk_eth <= not clk_eth after 10 ns when (run = '1' and test_stop = '0') else '0';

i_rmii_tx : rmii_tx 
	port map ( 
		reset => reset, 
		clk => clk_eth, 
		s_data => s_data,
		s_valid => s_valid,
		s_ready => s_ready,
		tx_dv => tx_dv,
		txd => txd
           	);

i_rmii_rx : rmii_rx
	port map(
		reset => reset,
		clk => clk_eth,
		m_data => m_data,
		m_valid => m_valid,
		rxd => txd,
		crs => tx_dv
	);

i_mdio : mdio
	port map(
		reset => reset,
		clk => clk,
		phy_addr => phy_addr, 
		reg_addr => reg_addr,
		wdata => wdata,
		rdata => rdata,
		rw => rw,
		start => start,
		rdy => rdy,
		done => done,
		do => do,
		di => di,
		oe => oe
	);


	p_test : process(clk)
	begin
		if rising_edge(clk) then
			if reset = '1' then
				test_state <= test_start;
			else
				case (test_state) is
					when test_start =>
						if rdy = '1' then
							test_state <= init_write;
						end if;

					when init_write =>
						phy_addr <= "00100";
						reg_addr <= "00011";
						wdata <= x"ABCD";
						rw <= '0';
						if rdy = '1' then	
							start <= '1';
							test_state <= wait_write_done;
						end if;

					when wait_write_done =>
						start <= '0';
						--reg_addr <= (others => '0');
						if done = '1' then	
							test_state <= init_read;
						end if;

					when init_read =>
						phy_addr <= "00100";
						reg_addr <= "11011";
						wdata <= x"0000";
						rw <= '1';	
						if rdy = '1' then
							start <= '1';
							test_state <= wait_read_done;
						end if;

					when wait_read_done =>
						start <= '0';
						--reg_addr <= (others => '0');
						if done = '1' then	
							test_state <= test_rmii_tx;
						end if;

					when test_rmii_tx =>
						s_valid <= '1';
						s_data <= "11001100";
						if s_ready = '0' then
							test_state <= test_rmii_tx2;
						end if;


					when test_rmii_tx2 =>
						s_valid <= '0';
						if s_ready = '1' then
							s_valid <= '1';
							s_data <= "01010101";
							test_state <= wait_rmii_ready_low;
						end if;
						
					when wait_rmii_ready_low =>
						s_valid <= '1';
						if s_ready = '0' then
							s_valid <= '1';
							test_state <= wait_rmii_ready;
						end if;

					when wait_rmii_ready =>
						s_valid <= '0';
						if s_ready = '1' then
							test_state <= wait_rmii_rx_valid1;
						end if;

					when wait_rmii_rx_valid1 =>
						if m_valid = '1' then
							test_state <= wait_rmii_rx_valid2;
						end if;

					when wait_rmii_rx_valid2 =>
						if m_valid = '0' then
							test_state <= test_done;
						end if;

					when test_done =>
					       test_stop <= '1';	
				end case;
			end if;
		end if;
	end process p_test;

end Behavioral;

