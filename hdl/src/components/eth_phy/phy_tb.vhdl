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
	generic(bits : integer := 64);
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


type test_states is(test_start, init_write, wait_write_done, init_read, wait_read_done, test_done);

signal test_state : test_states;
signal clk  : std_logic:= '0';
signal run : std_logic:='1';
signal test_stop : std_logic := '0';
signal reset : std_logic:='1';

signal cnt : unsigned(15 downto 0);
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

begin


di <= '1';
clk <= not clk after 5 ns when (run = '1' and test_stop = '0') else '0';
run <= '0' after 3000 us;
reset <= '0' after 100 ns;

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
			cnt <= (others => '0');
					test_state <= test_start;
			else
			cnt <= cnt + 1;
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
							test_state <= test_done;
						end if;
					when test_done =>
					       test_stop <= '1';	
				end case;
			end if;
		end if;
	end process p_test;

end Behavioral;

