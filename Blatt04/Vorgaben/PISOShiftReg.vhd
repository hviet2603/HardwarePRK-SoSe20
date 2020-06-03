--------------------------------------------------------------------------------
-- PISO-Schieberegister als mögliche Grundlage für die Implementierung der RS232-
-- Schnittstelle im Hardwarepraktikum
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity PISOShiftReg is
	generic(
		WIDTH	 : integer := 8
	);
	port(
		CLK	     : in std_logic;
		CLK_EN	 : in std_logic;
		LOAD	 : in std_logic;
		D_IN	 : in std_logic_vector(WIDTH-1 downto 0);
		D_OUT	 : out std_logic;
		LAST_BIT : out std_logic
	);
end entity PISOShiftReg;

architecture behavioral of PISOShiftReg is
begin

end architecture behavioral;
