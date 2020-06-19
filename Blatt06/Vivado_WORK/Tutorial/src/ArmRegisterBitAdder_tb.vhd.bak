--------------------------------------------------------------------------------
--	Testbench-Vorlage des HWPR-Bitaddierers.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
--	In TB_TOOLS kann, wenn gewuenscht die Funktion SLV_TO_STRING() zur
--	Ermittlung der Stringrepraesentation eines std_logic_vektor verwendet
--	werden und SEPARATOR_LINE fuer eine horizontale Trennlinie in Ausgaben.
--------------------------------------------------------------------------------
library work;
use work.TB_TOOLS.all;

entity ArmRegisterBitAdder_TB is
end ArmRegisterBitAdder_TB;

architecture testbench of ArmRegisterBitAdder_tb is 

	component ArmRegisterBitAdder
	port(
		RBA_REGLIST	: in std_logic_vector(15 downto 0);          
		RBA_NR_OF_REGS	: out std_logic_vector(4 downto 0)
		);
	end component ArmRegisterBitAdder;
	
	signal REGLIST: std_logic_vector(15 downto 0) := x"0000";
	signal NR_OF_REGS: std_logic_vector(4 downto 0);
	-- Test Cases	
	type TEST_DATA is array (0 to 15) of std_logic_vector(15 downto 0);
	type NR_OF_BITS is array (0 to 15) of std_logic_vector(4 downto 0);
	signal TEST_VECTOR: TEST_DATA := (
		x"0000",	
		x"0001",
		x"0011",
		x"0111",
		x"1111",	
		x"000F",
		x"00FF",
		x"0FFF",
		x"FFFF",	
		x"1A2B",
		x"3C4D",
		x"5E6F",
		x"ABCD",	
		x"0706",
		x"2603",
		x"CAFE"
	);
	signal NR_OF_SET_BITS: NR_OF_BITS := (
		"00000",
		"00001",
		"00010",
  		"00011",
		"00100",
		"00100",
		"01000",
		"01100",
		"10000",
		"00111",
		"01000",
		"01011",
		"01010",	
		"00101",
		"00101",
		"01011"
	);
	
begin
--	Unit Under Test
	UUT: ArmRegisterBitAdder port map(
		RBA_REGLIST	=> REGLIST,
		RBA_NR_OF_REGS	=> NR_OF_REGS
	);


--	Testprozess
	tb : process is
	variable NR_OF_ERRORS: integer := 0;
	variable i : integer;
	begin
		
--		...
		wait for 100 ns;
		for i in 0 to 15 loop
			REGLIST <= TEST_VECTOR(i);			
			wait for 11 ns;
			report "Test case: " & integer'image(i+1) & " : " & SLV_TO_STRING(TEST_VECTOR(i));
			if (NR_OF_REGS /= NR_OF_SET_BITS(i)) then
				report "Die Anzahl der gesetzten Bits stimmen nicht überein" severity error;
				report "Erwartet: " & integer'image(to_integer(unsigned(NR_OF_SET_BITS(i))));
				report "Aktuell: " & integer'image(to_integer(unsigned(NR_OF_REGS)));
				NR_OF_ERRORS := NR_OF_ERRORS + 1;
			end if;
			wait for 10 ns;
			assert (NR_OF_REGS'STABLE) report "RBA_NR_OF_REGS ist nicht stabil" severity error;
		end loop;	
		
		if (NR_OF_ERRORS > 0) then
			report "Funktionstest nicht bestanden: " & integer'image(NR_OF_ERRORS) & " Fehler." severity note;		
		else
			report "Funktionstest bestanden.";
		end if;
	
		report SEPARATOR_LINE;	
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
--	Unbegrenztes Anhalten des Testbench Prozess
		wait;
	end process tb;
end architecture testbench;
