library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity lookup_table_interpolated is
	generic(intbits : integer := 8 ; fracbits : integer := 56; ybits : integer := 13 ; ibits : integer := 15);
    	port ( 
		clk : in  STD_LOGIC;
	
		x 	: in std_logic_vector(intbits+fracbits-1 downto 0);
		y	: out std_logic_vector(13 - 1 downto 0)
           	);
end lookup_table_interpolated;

architecture Behavioral of lookup_table_interpolated is

component lookup_table
    	port ( 
		clk : in  STD_LOGIC;
	
		x 	: in std_logic_vector(8 - 1 downto 0);
		xout 	: out std_logic_vector(8 - 1 downto 0);
		y	: out std_logic_vector(12 downto 0)
           	);
end component;

signal xr : std_logic_vector(intbits-1 downto 0);
signal ylutrr : std_logic_vector(ybits-1 downto 0);
signal ylutrrr : std_logic_vector(ybits-1 downto 0);
signal ylutrrrr : std_logic_vector(ybits-1 downto 0);

signal xp1r : std_logic_vector(intbits-1 downto 0);
signal yp1lutrr : std_logic_vector(ybits -1 downto 0);


signal fracr : std_logic_vector(fracbits-1 downto 0);
signal fracrr : std_logic_vector(fracbits-1 downto 0);
signal fracrrr : std_logic_vector(fracbits-1 downto 0);


signal diffrrr : std_logic_vector(ybits -1 downto 0);

signal interprrrr : std_logic_vector(18+ybits-1 downto 0);



--signal intx0 : std_logic_vector(intbits - 1 downto 0);
--signal intx1 : std_logic_vector(intbits - 1 downto 0);
--signal fracx0 : signed(ibits - 1 downto 0);

--signal y0 : std_logic_vector(ybits - 1 downto 0);
--signal y1 : std_logic_vector(ybits - 1 downto 0);
--signal d : std_logic_vector(ybits -1 downto 0);
--signal prod : signed(ybits+ibits - 1 downto 0);
--signal diff : signed(ybits -1 downto 0);
--signal xr :  std_logic_vector(intbits+fracbits-1 downto 0);
--signal xrr :  std_logic_vector(intbits+fracbits-1 downto 0);
--signal xrrr :  std_logic_vector(intbits+fracbits-1 downto 0);
--signal xrrrr :  std_logic_vector(intbits+fracbits-1 downto 0);
--signal xout0 :  std_logic_vector(8-1 downto 0);
--signal xout1 :  std_logic_vector(8-1 downto 0);
begin
	
	p_coount : process(clk)

	--variable vintx0 : std_logic_vector(intbits - 1 downto 0);
	--variable vintx1 : std_logic_vector(intbits - 1 downto 0);
	--variable vfracx0 : signed(ibits - 1 downto 0);

	--variable vd : std_logic_vector(ybits -1 downto 0);

	--variable vdiff : signed(ybits -1 downto 0);
	--variable interp : signed(ybits+fracbits -1 downto 0);
	--variable delta : signed(intbits+fracbits -1 downto 0);
	--variable vprod : signed(ybits+ibits-1 downto 0);
	begin
		if rising_edge(clk) then
            xr <= x(intbits+fracbits-1 downto fracbits);
            xp1r <= std_logic_vector(signed(x(intbits+fracbits -1 downto fracbits))+1);

            fracr <= x(fracbits-1 downto 0);
            fracrr <= fracr;
            fracrrr <= fracrr;

            ylutrrr <= ylutrr;
            ylutrrrr <= ylutrrr;

            diffrrr <= std_logic_vector(signed(yp1lutrr)-signed(ylutrr));

            interprrrr <= std_logic_vector(signed('0'&fracrrr(fracbits-1 downto fracbits-17))*signed(diffrrr));

            y <= std_logic_vector(signed(ylutrrrr)+signed(interprrrr(18+ybits-2 downto 18-1)));
			--xrrrr <= x;
			--xrrr<= xrrrr;
			--xrr <= xrrr;
			--xr <= xrr;
			--vintx0 := x(intbits+fracbits-1 downto fracbits);
			--intx0 <= vintx0;
			--vintx1 := std_logic_vector(unsigned(xr(intbits+fracbits-1 downto fracbits))+1);
			--intx1 <= vintx1;
			--vfracx0 := signed(xrr(fracbits-1 downto fracbits -ibits));
			--fracx0 <= vfracx0;
		 	
			--fracx0 <= x(56-1 downto 0);
			--vdiff := signed(y1) - signed(y0);
			--diff <= vdiff;
			--vd := std_logic_vector(diff);

			--vprod := vdiff*vfracx0;
			--prod <= vprod;
			--interp := diff*fracx0;
			--delta := interp(ybits+fracbits-1 downto ybits-intbits);
			--y <= std_logic_vector(signed(y0)+prod(ybits+ibits-1 downto ibits)); -- + delta;
			--y <= y0;
		end if;
	end process;

--intx0 <= x(intbits+fracbits-1 downto fracbits);
i_lut : lookup_table
    	port map( 
		clk => clk,
		x => xr,
		xout => open,
		y => ylutrr
           	);

--intx1 <= std_logic_vector(unsigned(x(intbits+fracbits-1 downto fracbits))+1);

i_lut_plus_one : lookup_table
    	port map( 
		clk => clk,
		x => xp1r,
		xout => open,
		y => yp1lutrr
           	);



end Behavioral;
