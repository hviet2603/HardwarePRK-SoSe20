--------------------------------------------------------------------------------
--	Testbench zur ALU des ARM-Kerns fuer das HWPR
--------------------------------------------------------------------------------
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
library work;
use work.tb_tools.all;
use work.ArmTypes.all;

entity ArmALU_TB is
	generic(
		TEST_VECTOR_FILE: string := "ALU_TESTDATA";
--	Ist der folgende Parameter auf true gesetzt, werden die Details aller
--	Testvektoren mit ausgegeben, andernfalls nur die Details von 
--	Testvektoren, die einen Fehler ausloesen.
       	ALWAYS_PRINT_OPERANDS : boolean := false	
	);
end entity ArmALU_TB;

architecture behave OF ArmALU_TB IS 

--	Der Testvektortyp enthält jeweils Werte aller ALU-Eingänge und die erwarteten Ergebnisse.
--	Die Testvektoren liegen in der Datei ALU_TESTDATA und sie sind wahlweise hexadezimal,
--	oktal, binär (dual) oder als Integer kodiert
--	Die Verwendung von vorzeichenlosen oder vorzeichenbehafteten Zahlen
--	ausserhalb des Definitionsbereichs von Integer ist nicht möglich

	type ALU_TESTVECTOR_TYPE is record
		OPERAND_1:	std_logic_vector(31 downto 0);
		OPERAND_2:	std_logic_vector(31 downto 0);
		RESULT	:	std_logic_vector(31 downto 0);
		OPCODE	: 	OPCODE_DATA;
		CC_IN 	:	STD_LOGIC_VECTOR(3 downto 0);
		CC_OUT	:	STD_LOGIC_VECTOR(3 downto 0);
	end record ALU_TESTVECTOR_TYPE;

	-- Component Declaration for the Unit Under Test (UUT)
	component ArmALU
	port(
		ALU_OP1		: in std_logic_vector(31 downto 0);
		ALU_OP2		: in std_logic_vector(31 downto 0);
		ALU_CTRL	: in std_logic_vector(3 downto 0);
		ALU_CC_IN	: in std_logic_vector(1 downto 0);
		ALU_RES		: out std_logic_vector(31 downto 0);
		ALU_CC_OUT	: out std_logic_vector(3 downto 0)
		);
	end component;

	--Inputs
	signal TEST_OP1 	:  std_logic_vector(31 downto 0) := (others=>'0');
	signal TEST_OP2 	:  std_logic_vector(31 downto 0) := (others=>'0');
	signal TEST_ALU_CTRL:  std_logic_vector(3 downto 0)	:= (others=>'0');
	signal TEST_CC_IN 	:  std_logic_vector(3 downto 0) := "0000";

	--Outputs
	signal TEST_RES	 	: std_logic_vector(31 downto 0);
	signal TEST_CC_OUT	: std_logic_vector(3 downto 0);

	signal IS_TEST_INSTRUCTION : boolean := false;

begin
--	Kontrollsignal zeigt an, dass eine der Instruktionen vorliegt, fuer die
--	der ALU-Ausgang keine Rolle spielt
	IS_TEST_INSTRUCTION <= true 	when	TEST_ALU_CTRL = OP_TST or 
			       			TEST_ALU_CTRL = OP_TEQ or 
						TEST_ALU_CTRL = OP_CMP or 
						TEST_ALU_CTRL = OP_CMN else 
						false;

	-- Instantiate the Unit Under Test (UUT)
	uut: ArmALU port map(
		ALU_OP1 	=> TEST_OP1,
		ALU_OP2 	=> TEST_OP2,
		ALU_RES 	=> TEST_RES,
		ALU_CTRL 	=> TEST_ALU_CTRL,
		ALU_CC_IN 	=> TEST_CC_IN(1 downto 0),
		ALU_CC_OUT 	=> TEST_CC_OUT
	);


	tb : process

		--genau einer der 2^32 möglichen Codes eines 32 Bit Vektors kann nicht nach Integer konvertiert werden -> testen
		function NUMBER_IS_PRINTABLE(NUMBER: std_logic_vector(31 downto 0)) return boolean is
		begin
			if NUMBER = X"80000000" then
				return FALSE;
			else 
				return TRUE;
			end if;	
		end function NUMBER_IS_PRINTABLE;

		constant ALU_TEST_FILE_PATH : string := TESTDATA_FOLDER_PATH & TEST_VECTOR_FILE;

		FILE ALU_TEST_FILE : text open read_mode is ALU_TEST_FILE_PATH;
		variable NOT_ENDLINE : boolean;
		variable i 			: integer 	:= 0;
		constant ELEMENTS_IN_TESTVECTOR : integer	:= 6;
--		Verzoegerung zwischen Anlegen eines Testvektors und überprüfen des Ergebnisses
		constant WORKING_DELAY 		: time 		:= 10 ns;
		variable IS_COMMENT 		: boolean 	:= FALSE;
		variable ALU_TESTVECTOR 	: ALU_TESTVECTOR_TYPE;
		variable DATA_LINE 			: line;
		variable TESTVECTOR_NR 		: integer 	:= 0;
		variable NR_OF_ERRORS		: integer 	:= 0;
		variable NR_OF_RES_ERRORS, NR_OF_CC_ERRORS 	: integer := 0;
		type OPCODE_NAME_TYPE is array(0 to 15) of string(1 to 3);
		type OPCODE_COVERAGE_CNT_TYPE is array(0 to 15) of natural;
		type OPCODE_RES_ERROR_CNT_TYPE is array(0 to 15) of integer;
		type OPCODE_CC_ERROR_CNT_TYPE is array(0 to 15) of integer;
		variable OPCODE_NAMES : OPCODE_NAME_TYPE;
		variable OPCODE_COVERAGE_CNT : OPCODE_COVERAGE_CNT_TYPE := (others=>0);
		variable OPCODE_RES_ERROR_CNT : OPCODE_RES_ERROR_CNT_TYPE := (others =>0);
		variable OPCODE_CC_ERROR_CNT : OPCODE_CC_ERROR_CNT_TYPE := (others =>0);
		variable RESULT_POINTS : integer := 4;
	    variable CC_POINTS : integer := 2;

		procedure REPORT_ALU_OPERATION is
			variable CORRECT : boolean := true;			
			variable RES_ERROR, CC_ERROR : boolean := FALSE;
		begin
			RES_ERROR := FALSE; CC_ERROR := FALSE;
--			Fuer die Opcodes OP_TST, OP_TEQ, OP_CMP und OP_CMN spielt der ALU-Ausgang (ALU_RES)
--			keine Rolle
			if (TEST_RES = ALU_TESTVECTOR.RESULT) OR IS_TEST_INSTRUCTION then
			else
				RES_ERROR := TRUE;
				NR_OF_RES_ERRORS := NR_OF_RES_ERRORS + 1;
				OPCODE_RES_ERROR_CNT(to_integer(unsigned(ALU_TESTVECTOR.OPCODE))) := OPCODE_RES_ERROR_CNT(to_integer(unsigned(ALU_TESTVECTOR.OPCODE))) + 1;
			end if;

			if TEST_CC_OUT = ALU_TESTVECTOR.CC_OUT then
			else
				CC_ERROR := TRUE;
				NR_OF_CC_ERRORS := NR_OF_CC_ERRORS + 1;
				OPCODE_CC_ERROR_CNT(to_integer(unsigned(ALU_TESTVECTOR.OPCODE))) := OPCODE_CC_ERROR_CNT(to_integer(unsigned(ALU_TESTVECTOR.OPCODE))) + 1;
			end if;

			if NOT(RES_ERROR OR CC_ERROR) then

				if ALWAYS_PRINT_OPERANDS then
					report TAB_CHAR & "Operand 1: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.OPERAND_1);
					report TAB_CHAR & "Operand 2: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.OPERAND_2);
				end if;
				report "...korrekt";
			else
				NR_OF_ERRORS := NR_OF_ERRORS + 1;
				report SEPARATOR_LINE;
				report "Fehler in Testvektor Nr. " & integer'image(TESTVECTOR_NR) severity error;
				if NUMBER_IS_PRINTABLE(ALU_TESTVECTOR.OPERAND_1) then
				report TAB_CHAR & "Operand 1: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.OPERAND_1) & " = " & integer'image(to_integer(signed(ALU_TESTVECTOR.OPERAND_1)));
				else
					report TAB_CHAR & "Operand 1: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.OPERAND_1);
				end if;

				if NUMBER_IS_PRINTABLE(ALU_TESTVECTOR.OPERAND_2) then
					report TAB_CHAR & "Operand 2: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.OPERAND_2) & " = " & integer'image(to_integer(signed(ALU_TESTVECTOR.OPERAND_2)));
				else
					report TAB_CHAR & "Operand 2: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.OPERAND_2);
				end if;
				if(RES_ERROR) then
					if (ALU_TESTVECTOR.OPCODE = OP_SBC) then
						report TAB_CHAR & "CC_IN(1) [C]:" & std_logic'image(ALU_TESTVECTOR.CC_IN(1));
					end if; 
					report "ALU-Ergebnisausgang nicht korrekt" severity error;
					if NUMBER_IS_PRINTABLE(ALU_TESTVECTOR.RESULT) then
						report TAB_CHAR & "Erwartet: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.RESULT) & " = " & integer'image(to_integer(signed(ALU_TESTVECTOR.RESULT)));
					else
						report TAB_CHAR & "Erwartet: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.RESULT);
					end if;
					if NUMBER_IS_PRINTABLE(TEST_RES) then
						report TAB_CHAR & "Errechnet: " & TAB_CHAR & SLV_TO_STRING(TEST_RES) & " = " & integer'image(to_integer(signed(TEST_RES)));
					else
						report TAB_CHAR & "Errechnet: " & TAB_CHAR & SLV_TO_STRING(TEST_RES);
					end if;

				end if;
				if(CC_ERROR) then
					report "Erzeugter Condition Code nicht korrekt" severity error;
					report TAB_CHAR & "CC_IN [C|V]: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.CC_IN);
					report TAB_CHAR & "Erwarteter  CC [N|Z|C|V]: " & TAB_CHAR & SLV_TO_STRING(ALU_TESTVECTOR.CC_OUT);
					report TAB_CHAR & "Errechneter CC [N|Z|C|V]: " & TAB_CHAR & SLV_TO_STRING(TEST_CC_OUT);
				end if;
				report SEPARATOR_LINE;
			end if;
--	
		end procedure REPORT_ALU_OPERATION;



	BEGIN
		OPCODE_NAMES(0) := "AND";
		OPCODE_NAMES(1) := "EOR";
		OPCODE_NAMES(2) := "SUB";
		OPCODE_NAMES(3) := "RSB";
		OPCODE_NAMES(4) := "ADD";
		OPCODE_NAMES(5) := "ADC";
		OPCODE_NAMES(6) := "SBC";
		OPCODE_NAMES(7) := "RSC";
		OPCODE_NAMES(8) := "TST";
		OPCODE_NAMES(9) := "TEQ";
		OPCODE_NAMES(10) := "CMP";
		OPCODE_NAMES(11) := "CMN";
		OPCODE_NAMES(12) := "ORR";
		OPCODE_NAMES(13) := "MOV";
		OPCODE_NAMES(14) := "BIC";
		OPCODE_NAMES(15) := "MVN";

		wait for 10 ns;
		report "Testvektordatei: " & ALU_TEST_FILE_PATH;
		report SEPARATOR_LINE;
		report "Simulation startet..." severity note;
		report SEPARATOR_LINE;

		while not endfile(ALU_TEST_FILE) loop
			i := 0;
			while (i < ELEMENTS_IN_TESTVECTOR and not endfile(ALU_TEST_FILE)) loop
				readline(ALU_TEST_FILE, DATA_LINE);
				LINE_IS_COMMENT(DATA_LINE,IS_COMMENT);
				if(IS_COMMENT)then
					next;
				end if;
				CASE i IS
					when 0 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,ALU_TESTVECTOR.OPERAND_1);
					when 1 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,ALU_TESTVECTOR.OPERAND_2);
					when 2 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,ALU_TESTVECTOR.RESULT);
					when 3 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,ALU_TESTVECTOR.OPCODE);
					when 4 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,ALU_TESTVECTOR.CC_IN);
					when 5 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,ALU_TESTVECTOR.CC_OUT);
					when others =>
						null;	
				END CASE;
				i := i + 1;
			end loop;

			if i = 0 then
				exit;
			elsif i < ELEMENTS_IN_TESTVECTOR then
				exit;
				report "Letzter Testvektor unvollstaendig!" severity error;
			else
				TESTVECTOR_NR := TESTVECTOR_NR + 1;
				report SEPARATOR_LINE;
				report "Teste Testvektor Nr. " & integer'image(TESTVECTOR_NR) & " ; Typ: " & OPCODE_NAMES(to_integer(unsigned(ALU_TESTVECTOR.OPCODE)));
				OPCODE_COVERAGE_CNT(to_integer(unsigned(ALU_TESTVECTOR.OPCODE))) := OPCODE_COVERAGE_CNT(to_integer(unsigned(ALU_TESTVECTOR.OPCODE))) + 1;
				--Anlegen des Testvektors an die UUT
				TEST_OP1 	<= ALU_TESTVECTOR.OPERAND_1;
				TEST_OP2 	<= ALU_TESTVECTOR.OPERAND_2;
				TEST_CC_IN	<= ALU_TESTVECTOR.CC_IN;
				TEST_ALU_CTRL 	<= ALU_TESTVECTOR.OPCODE;
			end if;	

			wait for WORKING_DELAY;
			-- Test auf Korrektheit der Ergebnisse
			REPORT_ALU_OPERATION;

		end loop;		
		file_close(ALU_TEST_FILE);

		report SEPARATOR_LINE;
		
		report "Simulation beendet.." severity note;
		report SEPARATOR_LINE;
	
		report " ";
		report " ";
		report SEPARATOR_LINE;
		report "Opcode: Testabdeckung | Ergebnisfehler | CC-Fehler:";
		for k in 0 to 15 loop
			report TAB_CHAR & OPCODE_NAMES(k) & ": " & TAB_CHAR & integer'image(OPCODE_COVERAGE_CNT(k)) & TAB_CHAR & "|" & TAB_CHAR & integer'image(OPCODE_RES_ERROR_CNT(k)) & TAB_CHAR & "|" & TAB_CHAR & integer'image(OPCODE_CC_ERROR_CNT(k));
		end loop;
		report " ";
		report " ";
		report SEPARATOR_LINE;
		if NR_OF_ERRORS = 0 then
			report "Simulation bestanden";
			report "Punkte: 4 + 2 = 6";				
		else
			report "Test nicht bestanden";
			report "Fehlerhafte Testvektoren: "	& integer'image(NR_OF_ERRORS);
			report "Fehlerhafte ALU-Ergebnisse: "	& integer'image(NR_OF_RES_ERRORS);
			report "Fehlerhafte Condition Codes: "	& integer'image(NR_OF_CC_ERRORS);
		
			for l in 0 to 15 loop
				if (OPCODE_RES_ERROR_CNT(l)) > 0 AND (RESULT_POINTS > 0) then
					RESULT_POINTS := RESULT_POINTS - 1;
				end if;	
				if (OPCODE_CC_ERROR_CNT(l)) > 0 AND (CC_POINTS > 0) then
					CC_POINTS := CC_POINTS - 1;
				end if;	
			end loop;
			
			report "Punkte: " & integer'image(RESULT_POINTS) & " + " & integer'image(CC_POINTS) & " = " & integer'image(RESULT_POINTS + CC_POINTS);
		end if;
	
		report " ";
		report SEPARATOR_LINE;
		report " ";

		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 

		wait; -- will wait forever
	end process;

end architecture BEHAVE;
