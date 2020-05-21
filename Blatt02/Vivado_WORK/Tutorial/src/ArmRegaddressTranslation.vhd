------------------------------------------------------------------------------
--	Paket fuer die Funktionen zur die Abbildung von ARM-Registeradressen
-- 	auf Adressen des physischen Registerspeichers (5-Bit-Adressen)
------------------------------------------------------------------------------
--	Datum:		05.11.2013
--	Version:	0.1
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ArmTypes.all;

package ArmRegaddressTranslation is
  
	function get_internal_address(
		EXT_ADDRESS: std_logic_vector(3 downto 0); 
		THIS_MODE: std_logic_vector(4 downto 0); 
		USER_BIT : std_logic) 
	return std_logic_vector;

end package ArmRegaddressTranslation;

package body ArmRegAddressTranslation is

function get_internal_address(
	EXT_ADDRESS: std_logic_vector(3 downto 0);
	THIS_MODE: std_logic_vector(4 downto 0); 
	USER_BIT : std_logic) 
	return std_logic_vector 
is

--------------------------------------------------------------------------------		
--	Raum fuer lokale Variablen innerhalb der Funktion
--------------------------------------------------------------------------------
    variable ADDR: std_logic_vector(4 downto 0);
	begin
--------------------------------------------------------------------------------		
--	Functionscode
--------------------------------------------------------------------------------		
    if USER_BIT = '1' then
        ADDR := '0' & EXT_ADDRESS;
    else
        if THIS_MODE = "10000" then     --USER
            ADDR := '0' & EXT_ADDRESS;
        elsif THIS_MODE = "11111" then  --SYSTEM
            ADDR := '0' & EXT_ADDRESS;
        elsif THIS_MODE = "10001" then  --FIQ
            if EXT_ADDRESS /= "1111" then ADDR := EXT_ADDRESS(3) & '0' & EXT_ADDRESS(2 downto 0); --Some math work
            else                          ADDR := "01111"; 
            end if;
        elsif THIS_MODE = "10010" then  --IRQ
            if    EXT_ADDRESS = "1101" then ADDR := "10111";
            elsif EXT_ADDRESS = "1110" then ADDR := "11000";
            else                            ADDR := '0' & EXT_ADDRESS;
            end if;
        elsif THIS_MODE = "10011" then  --SUPERVISOR
            if    EXT_ADDRESS = "1101" then ADDR := "11001";
            elsif EXT_ADDRESS = "1110" then ADDR := "11010";
            else                            ADDR := '0' & EXT_ADDRESS;
            end if;
        elsif THIS_MODE = "10111" then  --ABORT
            if    EXT_ADDRESS = "1101" then ADDR := "11011";
            elsif EXT_ADDRESS = "1110" then ADDR := "11100";
            else                            ADDR := '0' & EXT_ADDRESS;
            end if;
        else                            --UNDEFINED
            if    EXT_ADDRESS = "1101" then ADDR := "11101";
            elsif EXT_ADDRESS = "1110" then ADDR := "11110";
            else                            ADDR := '0' & EXT_ADDRESS;   
            end if;
        end if;
    end if;
    if    EXT_ADDRESS(3) = 'U' then ADDR := "00000";
    elsif EXT_ADDRESS(3) = 'X' then ADDR := "00000";
    else 
    end if;
	return ADDR;			

end function get_internal_address;	
	 
end package body ArmRegAddressTranslation;
