library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;
use ieee.numeric_std.all;


entity ArmRAMB_4kx8 is
	generic (WIDTH : positive := 8;
			 SIZE  : positive := 4096);	
	port (RAM_CLK : in std_logic;
		ADDRA : in  std_logic_vector(integer(ceil(log2(real(SIZE))))-1 downto 0);
		DOA   : out std_logic_vector(WIDTH-1 downto 0);
		ENA	  : in  std_logic;
		ADDRB : in  std_logic_vector(integer(ceil(log2(real(SIZE))))-1 downto 0);
		DIB   : in  std_logic_vector(WIDTH-1 downto 0);
		DOB   : out std_logic_vector(WIDTH-1 downto 0);
		ENB	  : in  std_logic;
		WEB   : in  std_logic);
end entity ArmRAMB_4kx8;


architecture behavioral of ArmRAMB_4kx8 is
    type RAM_BLOCK is array (0 to SIZE-1) of std_logic_vector(WIDTH-1 downto 0);
    signal ram: RAM_BLOCK;

begin
    PORT_A: process(RAM_CLK) is
    begin
        if rising_edge(RAM_CLK) then
            if ENA = '1' then
                DOA <= ram(to_integer(unsigned(ADDRA)));
            end if;
        end if;
    end process PORT_A;
    
    PORT_B: process(RAM_CLK) is
    begin
        if rising_edge(RAM_CLK) then
            if ENB = '1' then
                DOB <= ram(to_integer(unsigned(ADDRB)));
                if (WEB = '1') then
                    ram(to_integer(unsigned(ADDRB))) <= DIB;
                end if;
            end if;
        end if;
    end process PORT_B;
    
end architecture behavioral;
		





