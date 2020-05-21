library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;


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

begin

end architecture behavioral;
		





