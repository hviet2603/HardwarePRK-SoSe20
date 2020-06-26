--------------------------------------------------------------------------------
--	Shifter des HWPR-Prozessors, instanziiert einen Barrelshifter.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

entity ArmShifter is
	port (
		SHIFT_OPERAND	: in	std_logic_vector(31 downto 0);
		SHIFT_AMOUNT	: in	std_logic_vector(7 downto 0);
		SHIFT_TYPE_IN	: in	std_logic_vector(1 downto 0);
		SHIFT_C_IN		: in	std_logic;
		SHIFT_RRX		: in	std_logic;
		SHIFT_RESULT	: out	std_logic_vector(31 downto 0);
		SHIFT_C_OUT		: out	std_logic    		
 	);
end entity ArmShifter;

architecture behave of ArmShifter is

begin

end architecture behave;

