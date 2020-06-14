--------------------------------------------------------------------------------
--	Testbench fuer den Befehlsgruppendecoder.
--------------------------------------------------------------------------------
--	Datum:		19.06.2010
--	Version:	1.1
--------------------------------------------------------------------------------
--	Aenderungen:
--	Kommentare und Ausgaben leicht ueberarbeitet, automatische Punktevergabe
--	hinzugefuegt.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

library work;
use work.ArmTypes.all;
use work.TB_TOOLS.all;
use work.ArmConfiguration.all;

entity ArmCoarseInstructionDecoder_tb is
end ArmCoarseInstructionDecoder_tb;

architecture testbench of ArmCoarseInstructionDecoder_tb is
	signal INST		: std_logic_vector(31 downto 0) := (others => '0');
	signal DECV		: COARSE_DECODE_TYPE := CD_UNDEFINED;
	constant TESTDATA_PATH	: string := TESTDATA_FOLDER_PATH & "COARSE_INSTRUCTION_DECODER_TESTDATA";
	constant WORKING_DELAY	: time := ARM_SYS_CLK_PERIOD/4.0;
--------------------------------------------------------------------------------
--	Punkte auf diese Aufgabe, pro fehlerhafter Gruppe wird ein Punkt
--	abgezogen.	
--------------------------------------------------------------------------------
	constant MAX_POINTS	: natural := 3;

	component ArmCoarseInstructionDecoder
		port(
			CID_INSTRUCTION		: in std_logic_vector(31 downto 0);
			CID_DECODED_VECTOR	: out std_logic_vector(15 downto 0)
		);
	end component ArmCoarseInstructionDecoder;	

begin
	uut : ArmCoarseInstructionDecoder
	port map(
		CID_INSTRUCTION		=> INST,
		CID_DECODED_VECTOR 	=> DECV
	);


	TB : process is
		variable IS_COMMENT	: boolean;
		file TESTDATA_FILE	: text open READ_MODE is TESTDATA_PATH;
		variable DATA_LINE	: line;
		variable i		: integer;
		variable V_INST		: std_logic_vector(31 downto 0);
		variable V_DECV		: COARSE_DECODE_TYPE;
		variable NR_TESTVECTORS	: integer := 0;
		variable NR_OF_ERRORS	: integer := 0;
		variable POINTS		: natural := MAX_POINTS;
--------------------------------------------------------------------------------
--	Array zum Zaehlen der Testfaelle pro Befehlsgruppe sowie der 
--	aufgetretenen Fehler.		
--------------------------------------------------------------------------------
		type COVERAGE_COUNTER_TYPE is array(0 to 17) of natural;
		variable COVERAGE_COUNTER, COVERAGE_ERRORS : COVERAGE_COUNTER_TYPE := (others => 0);
--------------------------------------------------------------------------------
--	Typ fuer die Aufnahme von line-Objekten (als strings ohne feste Laenge)
--	fuer die Testzusammenfassung am Ende der Simulation.	
--------------------------------------------------------------------------------
		type COVERAGE_COUNTER_NAME is array(0 to 17) of line;
		variable COVERAGE_NAMES	: COVERAGE_COUNTER_NAME;

--	Abbildung von Befehlsgruppenvektoren auf Indizes eines Arrays		
		function INDEX_OF_DECV (THIS_CODE: COARSE_DECODE_TYPE) return integer is
			variable INDEX : integer range 0 to 17 := 0;
		begin
			case THIS_CODE is
				when CD_UNDEFINED 			=> INDEX := 0;
				when CD_SWI 				=> INDEX := 1;
				when CD_COPROCESSOR			=> INDEX := 2;
				when CD_BRANCH				=> INDEX := 3;
				when CD_LOAD_STORE_MULTIPLE		=> INDEX := 4;
				when CD_LOAD_STORE_UNSIGNED_IMMEDIATE	=> INDEX := 5;
				when CD_LOAD_STORE_UNSIGNED_REGISTER	=> INDEX := 6;
				when CD_LOAD_STORE_SIGNED_IMMEDIATE	=> INDEX := 7;
				when CD_LOAD_STORE_SIGNED_REGISTER	=> INDEX := 8;
				when CD_ARITH_IMMEDIATE			=> INDEX := 9;
				when CD_ARITH_REGISTER			=> INDEX := 10;
				when CD_ARITH_REGISTER_REGISTER		=> INDEX := 11;
				when CD_MSR_IMMEDIATE			=> INDEX := 12;
				when CD_MSR_REGISTER			=> INDEX := 13;
				when CD_MRS				=> INDEX := 14;
				when CD_MULTIPLY			=> INDEX := 15;
				when CD_SWAP				=> INDEX := 16;
				when others				=> INDEX := 17;
			end case;	
			return INDEX;
		end INDEX_OF_DECV;

--	Texte fuer die Zusammenfassung der Simulation vorbereiten
		procedure INIT_COVERAGE_NAMES is
		begin
			STD.textio.write(COVERAGE_NAMES(0),string'("CD_UNDEFINED" & TAB_CHAR & TAB_CHAR & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(1),string'("CD_SWI"  & TAB_CHAR & TAB_CHAR & TAB_CHAR & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(2), string'("CD_COPROCESSOR" & TAB_CHAR & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(3), string'("CD_BRANCH" & TAB_CHAR & TAB_CHAR & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(4), string'("CD_LOAD_STORE_MULTIPLE" & TAB_CHAR & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(5), string'("CD_LOAD_STORE_UNSIGNED_IMMEDIATE" & TAB_CHAR));
			WRITE(COVERAGE_NAMES(6), string'("CD_LOAD_STORE_UNSIGNED_REGISTER" & TAB_CHAR));
			WRITE(COVERAGE_NAMES(7), string'("CD_LOAD_STORE_SIGNED_IMMEDIATE" & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(8), string'("CD_LOAD_STORE_SIGNED_REGISTER" & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(9), string'("CD_ARITH_IMMEDIATE") & TAB_CHAR & TAB_CHAR & TAB_CHAR);
			WRITE(COVERAGE_NAMES(10), string'("CD_ARITH_REGISTER" & TAB_CHAR & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(11), string'("CD_ARITH_REGISTER_REGISTER" & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(12), string'("CD_MSR_IMMEDIATE" & TAB_CHAR & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(13), string'("CD_MSR_REGISTER" & TAB_CHAR & TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(14), string'("CD_MRS" & TAB_CHAR& TAB_CHAR& TAB_CHAR& TAB_CHAR & TAB_CHAR));
			WRITE(COVERAGE_NAMES(15), string'("CD_MULTIPLY" & TAB_CHAR& TAB_CHAR& TAB_CHAR& TAB_CHAR));
			WRITE(COVERAGE_NAMES(16), string'("CD_SWAP" & TAB_CHAR& TAB_CHAR& TAB_CHAR& TAB_CHAR));
			WRITE(COVERAGE_NAMES(17), string'("Fehlerhafte Codes innerhalb der Testvektordatei "), LEFT, 40);
		end procedure INIT_COVERAGE_NAMES;

	begin
		INIT_COVERAGE_NAMES;
		wait for WORKING_DELAY;
		report SEPARATOR_LINE;
		report "Simulationsbeginn";
		report "Verfahren: Testvektoren aus der Testvektordatei werden an den Eingang des Moduls angelegt und nach ausreichender" severity note;
		report "Verzoegerungszeit der Ausgang mit Referenzwerten, ebenfalls aus der Testvektordatei, verglichen." severity note;
		report SEPARATOR_LINE;
		NR_OF_ERRORS := 0;

--------------------------------------------------------------------------------
--	Den jeweils naechsten Datensatz aus der Testvectordatei extrahieren,
--	dabei Kommentar- und Leerzeilen uebergehen.
--	Jeder Datensatz besteht aus einem Befehlswort und dem erwarteten
--	Vektor der Befehlsgruppe.	
--------------------------------------------------------------------------------
		while not endfile(TESTDATA_FILE)loop
			i := 0;
			while (i<2) and (not endfile(TESTDATA_FILE))loop
				readline(TESTDATA_FILE,DATA_LINE);
				LINE_IS_COMMENT(DATA_LINE, IS_COMMENT);
				if IS_COMMENT then
					next;
				else
					if i = 0 then
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,V_INST);
					else
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,V_DECV);
					end if;
					i := i + 1;
				end if;
			end loop;
			if i = 0 then
				exit;
			elsif i = 1 then
				report "Letzter Testvektor unvollstaendig." severity error;
				exit;
			else
				INST <= V_INST; 
				NR_TESTVECTORS := NR_TESTVECTORS + 1;

--------------------------------------------------------------------------------
--	Testvektor ausgeben, dabei die fuer die Instruktionserkennung relevanten& TAB_CHAR
--	Abschnitte optisch absetzen.
--------------------------------------------------------------------------------
					report "Testvektor: " & integer'image(NR_TESTVECTORS);
report ". "  & TAB_CHAR & "Instruktion :          " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(V_INST(31 downto 28)) & "||" &
													SLV_TO_STRING(V_INST(27 downto 20)) & "||" & 
													SLV_TO_STRING(V_INST(19 downto 8)) & "||" & 
													SLV_TO_STRING(V_INST(7 downto 4)) & "||" & 
													SLV_TO_STRING(V_INST(3 downto 0));
				       	
				COVERAGE_COUNTER(INDEX_OF_DECV(V_DECV)) := COVERAGE_COUNTER(INDEX_OF_DECV(V_DECV)) + 1;
				wait for WORKING_DELAY;
				if DECV = V_DECV then
					null;
				else
					NR_OF_ERRORS := NR_OF_ERRORS + 1;
					COVERAGE_ERRORS(INDEX_OF_DECV(V_DECV)) := COVERAGE_ERRORS(INDEX_OF_DECV(V_DECV)) + 1;
					report SEPARATOR_LINE;
					report "Testvektor: " & integer'image(NR_TESTVECTORS);
					report "Decoderausgang und Referenzwert stimmen nicht ueberein." severity error;
					report "Datensatz: "; 
					report ". "  & TAB_CHAR & "Instruktion :          " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(V_INST(31 downto 28)) & "||" &
													SLV_TO_STRING(V_INST(27 downto 20)) & "||" & 
													SLV_TO_STRING(V_INST(19 downto 8)) & "||" & 
													SLV_TO_STRING(V_INST(7 downto 4)) & "||" & 
													SLV_TO_STRING(V_INST(3 downto 0));
				       	report ". " & TAB_CHAR & "Ermitteltets Resultat: " & TAB_CHAR & SLV_TO_STRING(DECV) & " = " & COVERAGE_NAMES(INDEX_OF_DECV(DECV)).all;
				       	report ". " & TAB_CHAR & "Erwartetes Resultat:   " & TAB_CHAR & SLV_TO_STRING(V_DECV) & " = " & COVERAGE_NAMES(INDEX_OF_DECV(V_DECV)).all;
					report SEPARATOR_LINE;
				end if;
			end if;
		end loop;
		report SEPARATOR_LINE;
		report "Simulation beendet.";
		report "Gesamtzahl der Fehler: " & integer'image(NR_OF_ERRORS);		
		if NR_OF_ERRORS > 0 then
			report "Funktionstest nicht bestanden." severity error;
			report "Funktionstest nicht bestanden." severity note;
		else
			report "Funktionstest bestanden." severity note;
		end if;	
		report SEPARATOR_LINE;
		report "Abdeckung der Instruktionsgruppen durch die Testvektoren und jeweils aufgetretene Fehler:";
		for i in 0 to 17 loop
			report integer'image(COVERAGE_COUNTER(i)) & TAB_CHAR & " x  " & TAB_CHAR & COVERAGE_NAMES(i).ALL & " : " & integer'image(COVERAGE_ERRORS(i)) & " Fehler";
			if(COVERAGE_ERRORS(i) > 0 and POINTS > 0)then
				POINTS := POINTS - 1;
			end if;
		end loop;
		report SEPARATOR_LINE;
		report "Punkte: " & integer'image(POINTS) & "/" & integer'image(MAX_POINTS);
		report SEPARATOR_LINE;
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait;
	end process tb;
end architecture testbench;
