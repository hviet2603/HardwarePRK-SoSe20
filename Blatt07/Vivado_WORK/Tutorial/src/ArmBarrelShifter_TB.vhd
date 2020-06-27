----------------------------------------------------------------------------------
--	Testbench fuer den allgemeinen n-Bit-Shifter. Getestet wird die selbst 
--	implementierte, strukturelle Architektur gegen die vorgegebene Verhaltens-
--	beschreibung.
----------------------------------------------------------------------------------
--	Datum:		06.05.2010
--	Version:	1.0
----------------------------------------------------------------------------------

use std.textio.all;
library ieee;

use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.TB_Tools.all;

entity ArmBarrelShifter_tb is
	generic(	
		OPERAND_WIDTH	: integer := 32;
		AMOUNT_WIDTH	: integer := 5;
--------------------------------------------------------------------------------
--	Die Testbench bricht bei Ueberschreiten folgender Fehlergrenze ab. 
--	Bei Fehlergrenze 0 werden alle Tests durchgefuehrt und alle Fehler
--	ausgegeben.
--------------------------------------------------------------------------------
		BREAK_ON_NUMBER_OF_ERRORS : natural := 100;
--------------------------------------------------------------------------------
--	Bei Bedarf: Test aller Operationen auf allen Operanden von 0 bis n
--	(mit n = (2^32)-1)
--------------------------------------------------------------------------------
		CHECK_ALL	: boolean := TRUE;
--------------------------------------------------------------------------------
--	Statt aller 2^32 Operanden werden nur die ersten (2^32)/(2^TEST_DIVIDER)
--	Operanden getestet, TEST_DEVIDER ist zwingend eine Zweierpotenz
--------------------------------------------------------------------------------
		TEST_DIVIDER	: integer := 4
--------------------------------------------------------------------------------
	 );
end entity ArmBarrelShifter_tb;

architecture behave of ArmBarrelShifter_tb is 

	component ArmBarrelShifter_HILEVEL
	generic(
		OPERAND_WIDTH : integer;
		SHIFTER_DEPTH : integer
	);
	port(
		OPERAND		: in std_logic_vector(OPERAND_WIDTH-1 downto 0);
		MUX_CTRL	: in std_logic_vector(1 downto 0);
		AMOUNT		: in std_logic_vector(AMOUNT_WIDTH-1 downto 0);
		ARITH_SHIFT : in std_logic;
		C_IN		: in std_logic;          
		DATA_OUT	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);
		C_OUT		: out std_logic
	);
	end component;

	component ArmBarrelShifter
	generic(
		OPERAND_WIDTH : integer;
		SHIFTER_DEPTH : integer
	);	
	port(
		    OPERAND		: in std_logic_vector(31 downto 0);
		    MUX_CTRL	: in std_logic_vector(1 downto 0);
		    AMOUNT		: in std_logic_vector(4 downto 0);
		    ARITH_SHIFT : in std_logic;
		    C_IN		: in std_logic;          
		    DATA_OUT	: out std_logic_vector(31 downto 0);
		    C_OUT		: out std_logic
	    );
	end component ArmBarrelShifter;

	constant WORKING_DELAY 	: time 		:= 10 ns;
	signal	OPERAND		: std_logic_vector(OPERAND_WIDTH-1 downto 0) := (others => '0');
	signal	MUX_CTRL	: std_logic_vector(1 downto 0)	:= "00";
	signal	AMOUNT		: std_logic_vector(AMOUNT_WIDTH-1 downto 0) := (others => '0');
	signal	ARITH_SHIFT	: std_logic_vector(0 downto 0) := "0";
	signal	C_IN		: std_logic_vector(0 downto 0) := "0";          
	signal	DATA_OUT_BEHAVE	: std_logic_vector(OPERAND_WIDTH-1 downto 0);
	signal	C_OUT_BEHAVE	: std_logic;
	signal	DATA_OUT_STRUCT	: std_logic_vector(OPERAND_WIDTH-1 downto 0);
	signal	C_OUT_STRUCT	: std_logic;

	signal AMT_INT		: integer;
	signal OP_INT		: integer;
	signal MUX_INT		: integer range 0 to 3;
	type MUX_CTRL_NAMES_TYPE is array(0 to 3) of STRING(1 to 14);
	constant MUX_CTRL_NAMES : MUX_CTRL_NAMES_TYPE :=(	"kein Shift    ",
								"Linksshift    ",
								"Rechtsshift   ",
								"Rechtsrotation");
begin
	INST_STRUCTURE: ArmBarrelShifter
	generic map(
			   OPERAND_WIDTH => 32,
			   SHIFTER_DEPTH => 5
		   )
	port map(
			OPERAND		=> OPERAND,
			MUX_CTRL	=> MUX_CTRL,
			AMOUNT		=> AMOUNT,
			ARITH_SHIFT	=> ARITH_SHIFT(0),
			C_IN		=> C_IN(0),
			DATA_OUT	=> DATA_OUT_STRUCT,
			C_OUT		=> C_OUT_STRUCT
		); 
	INST_HILEVEL: ArmBarrelShifter_HILEVEL
	generic map(
			   OPERAND_WIDTH => 32,
			   SHIFTER_DEPTH => 5
		   )
	port map(
			OPERAND		=> OPERAND,
			MUX_CTRL	=> MUX_CTRL,
			AMOUNT		=> AMOUNT,
			ARITH_SHIFT	=> ARITH_SHIFT(0),
			C_IN		=> C_IN(0),
			DATA_OUT	=> DATA_OUT_BEHAVE,
			C_OUT		=> C_OUT_BEHAVE
		); 


	tb : process
		constant TESTDATA_PATH			: string  := "./src/" & "BARRELSHIFTER_TESTDATA";
		file TESTDATA_FILE			: text open read_mode is TESTDATA_PATH;
		variable DATA_LINE			: line; 
		variable IS_COMMENT			: boolean := false;
		variable SLV_VAR			: std_logic_vector(OPERAND'length-1 downto 0);
		variable errors_encountered		: integer := 0;
		variable overall_errors_encountered	: integer := 0;
		variable ITERATIONS 			: integer := 0;
		variable AMOUNT_MIN, AMOUNT_MAX, VALUE_MIN, VALUE_MAX : natural;
		variable RESULT_ERRORS, C_ERRORS	: natural := 0;
		variable V_MUX_CTRL			: std_logic_vector(1 downto 0);
		variable V_ARITH 			: std_logic_vector(0 downto 0);
		variable V_CARRY 			: std_logic_vector(0 downto 0);
		variable V_AMOUNT 			: std_logic_vector(AMOUNT_WIDTH -1 downto 0) := (others => '0');
		variable V_VALUE 			: std_logic_vector(OPERAND_WIDTH -1 downto 0) := (others => '0');
		variable RESULT_ERROR, C_ERROR		: boolean := FALSE;
		

--	Procedure fuer Test der Ergebnisse und Ausgabe der vollstaendigen Fehlermeldung
		procedure REPORT_BARRELSHIFTER_OPERATION is
		begin
			RESULT_ERROR := FALSE;	C_ERROR := FALSE;
			if DATA_OUT_STRUCT /= DATA_OUT_BEHAVE then
				RESULT_ERROR  := TRUE;
				RESULT_ERRORS := RESULT_ERRORS + 1;
			end if;
			if C_OUT_STRUCT /= C_OUT_BEHAVE then
				C_ERROR  := TRUE;
				C_ERRORS := C_ERRORS + 1;
			end if;

			if RESULT_ERROR or C_ERROR then
				report "Fehler aufgetreten..." severity error;
				errors_encountered := errors_encountered + 1;
				if RESULT_ERROR then assert FALSE report "Ergebnis fehlerhaft" severity note; end if;
				if C_ERROR then assert FALSE report "Carry fehlerhaft" severity note; end if;			 
				report TAB_CHAR & "MUX_CTRL: "	& TAB_CHAR & SLV_TO_STRING(MUX_CTRL) & " = " & TAB_CHAR & MUX_CTRL_NAMES(to_integer(unsigned(MUX_CTRL)));
				report TAB_CHAR & "OPERAND: "	& TAB_CHAR & SLV_TO_STRING(OPERAND);
				report TAB_CHAR & "AMOUNT: "	& TAB_CHAR & SLV_TO_STRING(AMOUNT) & " = " & TAB_CHAR & integer'image(to_integer(unsigned(AMOUNT)));
				report TAB_CHAR & "ARITH: "	& TAB_CHAR & TAB_CHAR & SLV_TO_STRING(ARITH_SHIFT);				
				report TAB_CHAR & "C_IN: "	& TAB_CHAR & TAB_CHAR & SLV_TO_STRING(C_IN);
				report " ";
				if RESULT_ERROR then
					report TAB_CHAR & "Referenzergebnis: " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(DATA_OUT_BEHAVE);
					report TAB_CHAR & "Ermitteltes Ergebnis: " & TAB_CHAR & SLV_TO_STRING(DATA_OUT_STRUCT);
				end if;
				if C_ERROR then
					report TAB_CHAR & "C_OUT der Referenz: " & TAB_CHAR & SL_TO_STRING(C_OUT_BEHAVE);
					report TAB_CHAR & "Ermitteltes C_OUT: " & TAB_CHAR & TAB_CHAR & SL_TO_STRING(C_OUT_STRUCT);
				end if;			
				report SEPARATOR_LINE;
			end if;
		end procedure;
		
	begin

--	Die Schiebeweite kann bei 5 Bit breiter Werteangabe 0 bis 31 Bit betragen
		AMOUNT_MIN := 0;
		AMOUNT_MAX := (2**(AMOUNT_WIDTH)) -1;
--	Um nicht mit 2^32 verschiedenen Operanden zu testen kann die Zahl mittels TEST_DEVIDER verringert werden.
--	mit TEST_DIVIDER = 8 => (2**32/8) -1 = 16 verschiedene Operanden; fuer 4: 256 Operanden
		VALUE_MIN := 0;
		VALUE_MAX := (2**(OPERAND_WIDTH/TEST_DIVIDER)) -1;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Beginn der Simulation...";
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
--------------------------------------------------------------------------------
--		Abschnitt fuer Test auf Vollstaendigkeit der Sensitivitaetsliste
--------------------------------------------------------------------------------
		report "Test auf unmittelbare Reaktion auf Aenderungen einzelner Eingangssignale. Ein Fehler in diesen Tests kann auf eine unvollstaendige Sensitivitaetsliste hinweisen." severity note;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Initialisierung aller Stimuli, anschliessend Aenderung einzelner Signale...";
		report SEPARATOR_LINE;
		OPERAND <= X"F0000001"; MUX_CTRL <= "00"; ARITH_SHIFT <= "0"; C_IN <= "0"; AMOUNT <= "00001"; 
		wait for WORKING_DELAY;
		REPORT_BARRELSHIFTER_OPERATION;
		report SEPARATOR_LINE;
		report "Aenderung von C_IN";
		C_IN <= "1";
		wait for WORKING_DELAY;
		REPORT_BARRELSHIFTER_OPERATION;
		report SEPARATOR_LINE;
		report "Aenderung von MUX_CTRL";
		MUX_CTRL <= "10";
		wait for WORKING_DELAY;
		REPORT_BARRELSHIFTER_OPERATION;
		report SEPARATOR_LINE;
		report "Aenderung von ARITH_SHIFT";
	       	ARITH_SHIFT <= "1";	
		wait for WORKING_DELAY;
		REPORT_BARRELSHIFTER_OPERATION;
		report SEPARATOR_LINE;
		report "Aenderung von AMOUNT";
		AMOUNT <= "00010";
		wait for WORKING_DELAY;
		REPORT_BARRELSHIFTER_OPERATION;
		report SEPARATOR_LINE;
		report "Aenderung von OPERAND";
		OPERAND <= X"70000001";
		wait for WORKING_DELAY;
		REPORT_BARRELSHIFTER_OPERATION;
		report SEPARATOR_LINE;
		report "Test auf Verhalten bei Aenderung einzelner Eingangssignale beendet.";
		if((RESULT_ERRORS > 0) OR (C_ERRORS > 0))then
			report "Es sind Fehler aufgetreten." severity note;
			report "Es sind Fehler bei der Aenderung einzelner Eingangssignale aufgetreten." severity error;
		else
			report "Es sind keine Fehler aufgetreten." severity note;
		end if;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Ruecksetzen aller Stimuli.";
		OPERAND <= X"00000000"; MUX_CTRL <= "00"; ARITH_SHIFT <= "0"; C_IN <= "0"; AMOUNT <= "00000"; 
		RESULT_ERRORS := 0; C_ERRORS := 0;
		wait for WORKING_DELAY;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;	
		report SEPARATOR_LINE;
		report " ";
		report " ";

--------------------------------------------------------------------------------
--		optional: Test aller Operationen auf beliebig vielen Operanden 
--		von 0 bis (2^32)-1, ermoeglicht bei Bedarf Test aller Stimuli-
--		kombinationen
--------------------------------------------------------------------------------
		if CHECK_ALL then
			report SEPARATOR_LINE;	
			report "Teste Operanden zwischen 0 und " & integer'image(VALUE_MAX) & " mit allen moeglichen Operationen und Schiebe-/Rotationsweiten";
			report SEPARATOR_LINE;	
			report SEPARATOR_LINE;				
			for value in VALUE_MIN to VALUE_MAX loop
				for mux in 0 to 3 loop		
					for arith in 0 to 1 loop
						-- Test mit Carry-Bit = 0/1
						for carry in 0 to 1 loop
							-- Test aller moeglichen Schiebeweiten
							LOOP_AMOUNT : for am in AMOUNT_MIN to AMOUNT_MAX loop
								V_MUX_CTRL	:= std_logic_vector(to_unsigned(mux,2));
								V_ARITH		:= std_logic_vector(to_unsigned(arith,1));
								V_CARRY		:= std_logic_vector(to_unsigned(carry,1));
								V_AMOUNT	:= std_logic_vector(to_unsigned(am,AMOUNT_WIDTH));
								V_VALUE		:= std_logic_vector(to_signed(value,OPERAND_WIDTH));
								MUX_CTRL	<= V_MUX_CTRL;
								ARITH_SHIFT	<= V_ARITH;
								C_IN		<= V_CARRY;
								AMOUNT		<= V_AMOUNT;
								OPERAND 	<= V_VALUE;--							
								wait for WORKING_DELAY;
								REPORT_BARRELSHIFTER_OPERATION;
								ITERATIONS := ITERATIONS + 1;
								assert (BREAK_ON_NUMBER_OF_ERRORS = 0) or (overall_errors_encountered <= BREAK_ON_NUMBER_OF_ERRORS) report "Breche Simulation wegen Ueberschreitung von mehr als " & natural'image(BREAK_ON_NUMBER_OF_ERRORS) & " fehlerhaften Testdatensaetzen ab!" severity failure;
	--							Shifterausgaenge neutralisieren
								OPERAND <= (others => '0'); MUX_CTRL <= (others => '0'); AMOUNT <= (others => '0'); C_IN <= (others => '0'); ARITH_SHIFT <= (others => '0');
								wait for WORKING_DELAY/2;
--								schlaegt eine Operation fuer eine Schiebeweite fehl ist es unwahrscheinlich, dass sie bei groesseren 
--								Schiebeweiten wieder korrekt funktioniert => Abbruch der inneren Schleife
								if C_ERROR or RESULT_ERROR then
									report "Breche Schleife fuer AMOUNT ab und fahre mit der naechsten Kombination der uebrigen Testsignale fort.";
									report SEPARATOR_LINE;
									exit LOOP_AMOUNT;
								end if;

							end loop LOOP_AMOUNT;					
						end loop;
					end loop;
				end loop;
			end loop;
			report SEPARATOR_LINE;
			report "Iterationen ueber zusammenhaengede Testdaten ausgefuehrt: " & integer'image(ITERATIONS);
			report "Fehler erkannt in " & integer'image(errors_encountered) & " Datensaetzen.";
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
			overall_errors_encountered := errors_encountered;
			ITERATIONS := 0;
			errors_encountered := 0;
			report " ";
			report " ";
		end if;	

--------------------------------------------------------------------------------
--		Test aller Operationen und Schiebeweiten auf Operanden
--		aus einer Testvektordatei
--------------------------------------------------------------------------------
		

-- Raum fuer gezielte Testoperanden, da natuerlich nicht mehr alle Faelle getestet werden koennen
		report "Test mit spezifischen Operanden-Testvektoren aus der Testvektordatei, jeweils mit allen Optionen und Weiten." severity note;
		while not endfile(TESTDATA_FILE)loop
			readline(TESTDATA_FILE,DATA_LINE);
			LINE_IS_COMMENT(DATA_LINE,IS_COMMENT);
			if( IS_COMMENT) then
				next;
			else
				GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,SLV_VAR);
				V_VALUE := SLV_VAR;
				report SEPARATOR_LINE;
				report SEPARATOR_LINE;
				report "OPERAND: " & SLV_TO_STRING(V_VALUE);
				report SEPARATOR_LINE;
				report SEPARATOR_LINE;
				for mux in 0 to 3 loop			
					for arith in 0 to 1 loop
						for carry in 0 to 1 loop
							LOOP_AMOUNT_2 : for am in AMOUNT_MIN to AMOUNT_MAX loop
								V_MUX_CTRL	:= std_logic_vector(to_unsigned(mux,2));
								V_ARITH		:= std_logic_vector(to_unsigned(arith,1));
								V_CARRY		:= std_logic_vector(to_unsigned(carry,1));
								V_AMOUNT	:= std_logic_vector(to_unsigned(am,AMOUNT_WIDTH));
								OPERAND <= V_VALUE;
								MUX_CTRL	<= V_MUX_CTRL;
								ARITH_SHIFT	<= V_ARITH;
								C_IN		<= V_CARRY;
								AMOUNT		<= V_AMOUNT;						
								wait for WORKING_DELAY;						
								REPORT_BARRELSHIFTER_OPERATION;
								ITERATIONS := ITERATIONS + 1;
								assert (BREAK_ON_NUMBER_OF_ERRORS = 0) or (overall_errors_encountered <= BREAK_ON_NUMBER_OF_ERRORS) report "Breche Simulation wegen Ueberschreitung von mehr als " & natural'image(BREAK_ON_NUMBER_OF_ERRORS) & "  fehlerhaften Testdatensaetzen ab!" severity failure;
	--							Shifterausgaenge neutralisieren
								OPERAND <= (others => '0'); MUX_CTRL <= (others => '0'); AMOUNT <= (others => '0'); C_IN <= (others => '0'); ARITH_SHIFT <= (others => '0');
								wait for WORKING_DELAY/2;
								if C_ERROR or RESULT_ERROR then
								report "Breche Schleife fuer AMOUNT ab und fahre mit der naechsten Kombination der uebrigen Testsignale fort.";
								report SEPARATOR_LINE;
								exit LOOP_AMOUNT_2;
								end if;							
							end loop LOOP_AMOUNT_2;
						end loop;
					end loop;
				end loop;	
			end if;	
		end loop;
		FILE_CLOSE(TESTDATA_FILE);
		report "Iterationen ueber Testvektoren aus der Testvektordatei ausgefuehrt: " & integer'image(ITERATIONS);
		report "Fehler darin erkannt in " & integer'image(errors_encountered) & " Datensaetzen.";
		overall_errors_encountered := errors_encountered + overall_errors_encountered;
		if(overall_errors_encountered > 0 )then
			report "Fehler ueber alle Datensaetze: " & integer'image(overall_errors_encountered) severity note;
		else
			report "Keine Fehler gefunden" severity note;
		end if;	
		report " ";
		report " ";
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		if overall_errors_encountered = 0 then
		      report "Funktionspruefung bestanden." severity note;	
	  	else
		      report "Funktionspruefung nicht bestanden." severity error;	
	       	end if;	       
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "...Ende der Simulation." severity note; 
		report " ";
		report " ";
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait; -- will wait forever
	end process tb;

	--  End Test Bench 

end architecture behave;
