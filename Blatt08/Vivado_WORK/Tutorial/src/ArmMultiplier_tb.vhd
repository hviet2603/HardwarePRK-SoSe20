library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.TB_TOOLS.all;

entity ArmMultiplier_tb is
end ArmMultiplier_tb;

architecture testbench of ArmMultiplier_tb is
	component ArmMultiplier
	port(	
		MUL_OP1 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rm
		MUL_OP2 	: in  STD_LOGIC_VECTOR (31 downto 0);	-- Rs
		MUL_RES 	: out  STD_LOGIC_VECTOR (31 downto 0)	-- Rd bzw. RdLo         
	); 
	end component ArmMultiplier;
	
	-- Signals
	signal OP1 : STD_LOGIC_VECTOR (31 downto 0);	
	signal OP2 : STD_LOGIC_VECTOR (31 downto 0);	
	signal RES : STD_LOGIC_VECTOR (31 downto 0);
	
	-- Testcases
	type OPERAND is array (0 to 15) of STD_LOGIC_VECTOR(31 downto 0);
	signal OP1_VECTOR: OPERAND := (
        x"00000000",x"00000001",x"00000010",x"00000100",
        x"00001000",x"43211234",x"87654321",x"11111111",
        x"CAFECAFE",x"FACEB00C",x"ABBAABBA",x"FFFFFFFF",
        x"FACE2387",x"B00C3102",x"BCDE2256",x"CDEF4389"
	);
	signal OP2_VECTOR: OPERAND := (
        x"30041975",x"26031997",x"07061998",x"26032020",
        x"07062020",x"02081997",x"19081945",x"07051954",
        x"01012020",x"66886868",x"96966996",x"FFFFFFFF",
        x"31969624",x"B1CB00B0",x"23155437",x"42792219"
	);
	
	signal RES_64_BITS: STD_LOGIC_VECTOR(63 downto 0);
	signal RES_REF: STD_LOGIC_VECTOR(31 downto 0);
	signal NR_OF_ERRORS: integer := 0;
	
	-- Counter
	signal i: integer := 0;
	

begin
--	Unit under Test
	UUT: ArmMultiplier port map (
        MUL_OP1 => OP1,
        MUL_OP2 => OP2,
        MUL_RES => RES
	);
	
--	TESTBENCH
	tb: process

	begin
		--wait for 100 ns;
		for i in 0 to 15 loop
			wait for 5 ns;
			report "-------------------- Test " & integer'image(i+1) & " --------------------" severity note;
			report "Operand 1: " & SLV_TO_STRING(OP1_VECTOR(i)); 
			report "Operand 2: " & SLV_TO_STRING(OP2_VECTOR(i));
			OP1 <= OP1_VECTOR(i);
			OP2 <= OP2_VECTOR(i);
                        RES_64_BITS <= STD_LOGIC_VECTOR(unsigned(OP1_VECTOR(i))*unsigned(OP2_VECTOR(i)));
            		wait for 5 ns;
			RES_REF <= RES_64_BITS(31 downto 0);
			wait for 5 ns;
            		report "Erwartetes Ergebnis: " & SLV_TO_STRING(RES_REF);
			
			if (RES /= RES_REF) then
				report "Falsches Ergebnis: " & SLV_TO_STRING(RES);
                report "Testcase " & integer'image(i+1) & " nicht bestanden";
                NR_OF_ERRORS <= NR_OF_ERRORS + 1;
			else
				report "Richtiges Ergebnis";
                report "Testcase " & integer'image(i+1) & " bestanden";
			end if;
			wait for 5 ns;
			
		end loop;
		
		if (NR_OF_ERRORS = 0) then 
			report "Funktiontest bestanden."; 
		else 
			report "Funktiontest nicht bestanden: " & integer'image(NR_OF_ERRORS) & " Fehler.";		
		end if;

		report SEPARATOR_LINE;	
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait;
	end process tb;
		
end architecture testbench; 
