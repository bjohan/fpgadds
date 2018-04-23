library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity mdio is
	generic(div : integer := 8);
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
	constant tick_div : integer := div;
	signal tick_pos_edge : std_logic;
	signal tick_neg_edge : std_logic;
	signal mdc_r : std_logic;
	signal tick_cnt : unsigned(10 downto 0);
	signal complete_word : std_logic_vector(31 downto 0);
	signal current_bit : unsigned(5 downto 0);
	signal rdata_r : std_logic_vector(15 downto 0);
	--signal bit_index : std_logic_vector(3 downto 0);
	--signal sample_tick : std_logic;
begin

p_coount : process(clk)
begin
	if rising_edge(clk) then
		if reset = '1' then
			done <= '0';
			rdy <= '0';
			state <= idle;
		else
			--sample_tick <= '0';
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
					if tick_pos_edge = '1' then
						state <= write;
					end if;

				when sync_read =>
					if tick_pos_edge = '1' then
						state <= read;
					end if;

				when write =>
					oe <= '1';
					if tick_pos_edge = '1' then
						do <= complete_word(31-to_integer(current_bit));
						current_bit <= current_bit + 1;
						if current_bit = x"1F" then
							done <= '1';
							state <= idle;
						end if;
					end if;
				when read =>
					oe <= '1';
					if current_bit > 13 then
						oe <= '0';
					end if;

					if current_bit > 15 then
						if tick_neg_edge = '1' then 
							--sample_tick <= '1';
							rdata_r( to_integer(current_bit(3 downto 0))) <= di;
							--bit_index <= std_logic_vector(current_bit(3 downto 0));
						end if;
					else
						do <= complete_word(31-to_integer(current_bit));
					end if;
					if tick_pos_edge = '1' then
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


p_clkgen : process(clk)
begin
	if rising_edge(clk) then
	if reset = '1' then
		mdc_r <=  '0';
		tick_cnt <= to_unsigned(tick_div, 11);
	else
		tick_neg_edge <= '0';
		tick_pos_edge <= '0';

		tick_cnt <= tick_cnt -1;	
		if tick_cnt = 0 then
			tick_cnt <= to_unsigned(tick_div, 11);
			if mdc_r = '1' then
				mdc_r <= '0';
				tick_neg_edge <= '1';
			else
				mdc_r <= '1';
				tick_pos_edge <= '1';
			end if;
		end if;
	end if;
	end if;
end process;

	
mdc <= mdc_r;
end Behavioral;

