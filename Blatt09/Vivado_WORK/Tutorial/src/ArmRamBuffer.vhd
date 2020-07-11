--------------------------------------------------------------------------------
--	Einportspeicher (Lesen und Schreiben an derselben Adresse)
--	fuer Pufferschaltungen in Kontroll- und Datenpfad des ARM-Kerns.
--	Der Speicher ist geeignet fuer eine Abbildung auf Distributed RAM.
--------------------------------------------------------------------------------
--	Datum:		29.10.2013
--	Version:	0.1
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRamBuffer is
	generic(
		ARB_ADDR_WIDTH : natural range 1 to 4 := 3;
		ARB_DATA_WIDTH : natural range 1 to 64 := 32
	       );
	port(
		ARB_CLK		: in std_logic;
		ARB_WRITE_EN	: in std_logic;
		ARB_ADDR	: in std_logic_vector(ARB_ADDR_WIDTH-1 downto 0);
		ARB_DATA_IN	: in std_logic_vector(ARB_DATA_WIDTH-1 downto 0);
		ARB_DATA_OUT	: out std_logic_vector(ARB_DATA_WIDTH-1 downto 0)
	    );
end ArmRamBuffer;

architecture behavioral of ArmRamBuffer is
	type ARB_RAM_TYPE is array(0 to (2**ARB_ADDR_WIDTH)-1) of std_logic_vector(ARB_DATA_WIDTH-1 downto 0);
	signal ARB_RAM : ARB_RAM_TYPE := (others =>(others => '0'));
begin
	WRITE_TO_RAM : process(ARB_CLK)is
	begin
		if ARB_CLK'event and ARB_CLK = '1' then
--	Kein Reset, damit der Speicher auf LUTs abgebildet wird
			if ARB_WRITE_EN = '1' then
				ARB_RAM(to_integer(unsigned(ARB_ADDR))) <= ARB_DATA_IN;
			end if;
		end if;
	end process WRITE_TO_RAM;
--	Asynchrones Lesen, geeignet fuer Distributed RAM
	ARB_DATA_OUT <= ARB_RAM(to_integer(unsigned(ARB_ADDR)));
end architecture behavioral;



