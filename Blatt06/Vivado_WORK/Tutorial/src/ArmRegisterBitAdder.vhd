--------------------------------------------------------------------------------
--	Schaltung fuer das Zaehlen von Einsen in einem 16-Bit-Vektor, realisiert
-- 	als Baum von Addierern.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRegisterBitAdder is
	Port (
		RBA_REGLIST 	: in  std_logic_vector(15 downto 0);
		RBA_NR_OF_REGS 	: out  std_logic_vector(4 downto 0)
	);
end entity ArmRegisterBitAdder;

architecture structure of ArmRegisterBitAdder is
type level_1_output: array (7 downto 0) of std_logic_vector(1 downto 0);
type level_2_output: array (3 downto 0) of std_logic_vector(2 downto 0);
type level_3_output: array (1 downto 0) of std_logic_vector(3 downto 0);

signal lvl1_output: level_1_output;
signal lvl2_output: level_2_output;
signal lvl3_output: level_3_output;

begin

-- LEVEL 1 
lvl1_output(7)(1) <= RBA_REGLIST(15) and RBA_REGLIST(14);
lvl1_output(7)(0) <= RBA_REGLIST(15) xor RBA_REGLIST(14);

lvl1_output(6)(1) <= RBA_REGLIST(13) and RBA_REGLIST(12);
lvl1_output(6)(0) <= RBA_REGLIST(13) xor RBA_REGLIST(12);

lvl1_output(5)(1) <= RBA_REGLIST(11) and RBA_REGLIST(10);
lvl1_output(5)(0) <= RBA_REGLIST(11) xor RBA_REGLIST(10);

lvl1_output(4)(1) <= RBA_REGLIST(9) and RBA_REGLIST(8);
lvl1_output(4)(0) <= RBA_REGLIST(9) xor RBA_REGLIST(8);

lvl1_output(3)(1) <= RBA_REGLIST(7) and RBA_REGLIST(6);
lvl1_output(3)(0) <= RBA_REGLIST(7) xor RBA_REGLIST(6);

lvl1_output(2)(1) <= RBA_REGLIST(5) and RBA_REGLIST(4);
lvl1_output(2)(0) <= RBA_REGLIST(5) xor RBA_REGLIST(4);

lvl1_output(1)(1) <= RBA_REGLIST(3) and RBA_REGLIST(2);
lvl1_output(1)(0) <= RBA_REGLIST(3) xor RBA_REGLIST(2);

lvl1_output(0)(1) <= RBA_REGLIST(1) and RBA_REGLIST(0);
lvl1_output(0)(0) <= RBA_REGLIST(1) xor RBA_REGLIST(0);

-- LEVEL 2
lvl2_output(3) <= std_logic_vector(to_unsigned(lvl1_output(7),3) + to_unsigned(lvl1_output(6),3));
lvl2_output(2) <= std_logic_vector(to_unsigned(lvl1_output(5),3) + to_unsigned(lvl1_output(4),3));
lvl2_output(1) <= std_logic_vector(to_unsigned(lvl1_output(3),3) + to_unsigned(lvl1_output(2),3));
lvl2_output(0) <= std_logic_vector(to_unsigned(lvl1_output(1),3) + to_unsigned(lvl1_output(0),3));

-- LEVEL 3
lvl3_output(1) <= std_logic_vector(to_unsigned(lvl2_output(3),4) + to_unsigned(lvl2_output(2),4));
lvl3_output(0) <= std_logic_vector(to_unsigned(lvl2_output(1),4) + to_unsigned(lvl2_output(0),4));

-- LEVEL 4 (OUTPUT)
RBA_NR_OF_REGS <= std_logic_vector(to_unsigned(lvl3_output(1),5) + to_unsigned(lvl3_output(0),5));


end architecture structure;
