--------------------------------------------------------------------------------
--	Multiplizierer fuer den Datenpfad des ARM-SoC
--	Einzige Operation OP1 x OP2 => RES; 32Bit x 32Bit => 32Bit(!) 
--------------------------------------------------------------------------------
--	Datum:		??.??.14
--	Version:	0.01
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmTypes.all;


entity ArmMultiplier is
	Port (
		MUL_OP1 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rm
		MUL_OP2 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rs
		MUL_RES 	: out  STD_LOGIC_VECTOR (31 downto 0)	-- Rd bzw. RdLo         	
	);
end entity ArmMultiplier;

architecture behavioral of ArmMultiplier is
signal MUL_64_BITS: std_logic_vector(63 downto 0);
begin

MUL_64_BITS <= std_logic_vector(unsigned(MUL_OP1)*unsigned(MUL_OP2));
MUL_RES <= std_logic_vector(31 downto 0);

end architecture behavioral;	
