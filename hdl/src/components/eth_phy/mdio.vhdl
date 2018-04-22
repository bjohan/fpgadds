library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mdio is
	generic(bits : integer := 64);
    	port ( 
		reset : in STD_LOGIC;
		clk : in  STD_LOGIC;
	
		phy_addr : in std_logic_vector(4 downto 0);
		reg_addr : in std_logic_vector(4 downto 0);
		wdata    : in std_logic_vector(15 downto 0);
		rdata    : out std_logic_vector(15 downto 0);
		rw	 	 : in std_logic;
		start    : in std_logic;
		mdc		 : out std_logic;
		do		 : out std_logic;
		di		 : in std_logic;
		oe 		 : out std_logic;
		rdy	 	 : out std_logic;
		done 		 : out std_logic
           	);
end mdio;

architecture Behavioral of mdio is
	type mdio_state is (idle, sync_write, write, sync_read, read, read_done);
	signal state : mdio_state;
	signal mdio : unsigned(bits -1  downto 0);
	constant tick_div : integer := 8;
	signal tick : std_logic;
	signal tick_dbl : std_logic;
	signal mdc_r : std_logic;
	signal mdc_rr : std_logic;
	signal tick_cnt : unsigned(10 downto 0);
	signal complete_word : std_logic_vector(31 downto 0);
	signal current_bit : unsigned(5 downto 0);
	signal rdata_r : std_logic_vector(15 downto 0);
	signal bit_index : std_logic_vector(3 downto 0);

begin

p_coount : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			done <= '0';
			rdy <= '0';
			state <= idle;
		else
			case (state) is
				when idle =>
				        done <= '0';	
					rdy <= '1';
					if start = '1' then
						rdy <= '0';
						current_bit <= (others => '0');
						if rw = '0' then --start write operation
							complete_word <= "01"&"01"&phy_addr&reg_addr&"10"&wdata;
							state <= sync_write;
						else
							complete_word <= "01"&"10"&phy_addr&reg_addr&"10"&x"beef";
							state <= sync_read;
						end if;
					end if;
				when sync_write =>
					if tick = '1' then
						state <= write;
					end if;

				when sync_read =>
					if tick = '1' then
						state <= read;
					end if;

				when write =>
					oe <= '1';
					if tick = '1' then
						do <= complete_word(31-to_integer(current_bit));
						current_bit <= current_bit + 1;
						if current_bit = x"1F" then
							done <= '1';
							state <= idle;
						end if;
					end if;
				when read =>
					oe <= '1';
					if current_bit > 11 then
						oe <= '0';
					end if;

					if tick = '1' then
						if current_bit > 15 then
							rdata_r( to_integer(current_bit(3 downto 0))) <= di;
							bit_index <= std_logic_vector(current_bit(3 downto 0));
						else
							do <= complete_word(31-to_integer(current_bit));
						end if;
						current_bit <= current_bit + 1;
						if current_bit = x"1F" then
							state <= read_done;
						end if;
					end if;

				when read_done =>
					done <= '1';
					rdata <= rdata_r;
			end case;
		end if;
	end if;
end process;

p_tick : process(clk) 
begin
	if rising_edge(clk) then
		if reset = '1' then
			tick_cnt <= (others => '0');
			tick_dbl <= '0';
		else
			if state = idle then
				tick_cnt <= (others => '0');
			else 
				tick_cnt <= tick_cnt +1;
				tick_dbl <= '0';
				if tick_cnt = tick_div -1 then
					tick_cnt <= (others => '0');
				tick_dbl <= '1';
				end if;	
			end if;	
		end if;
	end if;
end process;
	
p_mdc : process(clk)
begin
	if rising_edge(clk) then
		tick <= '0';
		if tick_dbl = '1' then
			if mdc_r = '1' then
				tick <= '1';
				mdc_r <= '0';
			else
				mdc_r <= '1';
			end if;
		end if;
		mdc_rr <= mdc_r;
	end if;
end process;
	
mdc <= mdc_rr;
end Behavioral;

