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
    type RAM_array is array(0 to SIZE-1) of std_logic_vector(WIDTH-1 downto 0);
	signal RAM: RAM_array;
	
begin
	process (RAM_CLK) 
	begin
		if rising_edge(RAM_CLK) then
			if ENA ='1' then
				DOA <= RAM(to_integer(unsigned(ADDRA)));
			end if;
			if ENB ='1' then 
				DOB <= RAM(to_integer(unsigned(ADDRB)));
				if WEB='1' then
					RAM(to_integer(unsigned(ADDRB))) <= DIB;
				end if;
			end if;
		end if;
	end process;
    
end architecture behavioral;
		





