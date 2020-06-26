--------------------------------------------------------------------------------
--	Testbench fuer den Gesamtshifter des HWPR-Prozessors
--------------------------------------------------------------------------------
--	Datum:		10.05.2010
--	Version:	1.0
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library work;
use work.ArmTypes.all;
use work.TB_Tools.all;

use std.textio.all;

entity ArmShifter_tb is
	generic (
		OPERAND_WIDTH : integer:= 32;
		AMOUNT_WIDTH : integer:= 8;
		ELEMENTS_IN_TESTVECTOR : integer := 7
	 );
end entity ArmShifter_tb;

architecture behave of ArmShifter_tb is 

	constant TEST_FILE_PATH	: string := TESTDATA_FOLDER_PATH & "SHIFTER_TESTDATA";
	file TEST_FILE			: text open READ_MODE is TEST_FILE_PATH;
	constant WORKING_DELAY  : time := 10 ns;

--	Component Declaration for the Unit Under Test (UUT)
	component ArmShifter
	port(
		SHIFT_OPERAND	: in std_logic_vector(OPERAND_WIDTH-1 downto 0);
		SHIFT_AMOUNT	: in std_logic_vector(AMOUNT_WIDTH-1 downto 0);
		SHIFT_TYPE_IN	: in std_logic_vector(1 downto 0);
		SHIFT_C_IN		: in std_logic;
		SHIFT_RRX		: in std_logic;          
		SHIFT_RESULT	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);
		SHIFT_C_OUT		: out std_logic
		);
	end component ArmShifter;

	type ArmShifterTestvector is record 
		SHIFT_TEST_OPERAND	: std_logic_vector(OPERAND_WIDTH-1 downto 0);
--------------------------------------------------------------------------------
--	AMOUNT ist hier absichtlich ein Bit zu gross, beim Auslesen
--	der Weitenangabe aus der Testvektordatei mit einer Funktion in 
--	TB_TOOLS treten sonst vereinzelt zusaetzliche Warnings auf, weil als
--	vorzeichenbehaftet betrachtete Vektoren gekuerzt werden. Evtl. sollte
--	dieses Verhalten in TB_Tools noch einmal verbessert werden.	
--------------------------------------------------------------------------------
		SHIFT_TEST_AMOUNT	: std_logic_vector(AMOUNT_WIDTH downto 0);
		SHIFT_TEST_TYPE_IN	: std_logic_vector(1 downto 0);
		SHIFT_TEST_C_IN		: std_logic_vector(0 downto 0);
		SHIFT_TEST_RRX		: std_logic_vector(0 downto 0);
		SHIFT_TEST_RESULT	: std_logic_vector(OPERAND_WIDTH-1 downto 0);
		SHIFT_TEST_C_OUT	: std_logic_vector(0 downto 0);
	end record ArmShifterTestvector; 	

	--Inputs
	signal SHIFT_C_IN	:  std_logic := '0';
	signal SHIFT_RRX	:  std_logic := '0';
	signal SHIFT_OPERAND:  std_logic_vector(OPERAND_WIDTH-1 downto 0)	:= (others=>'0');
	signal SHIFT_AMOUNT	:  std_logic_vector(AMOUNT_WIDTH downto 0) 	:= (others=>'0');
	signal SHIFT_TYPE_IN:  std_logic_vector(1 downto 0) 		:= (others=>'0');

	--Outputs
	signal SHIFT_RESULT	:  std_logic_vector(OPERAND_WIDTH-1 downto 0);
	signal SHIFT_C_OUT	:  std_logic;

	signal TEMP_SHIFT_AMOUNT : std_logic_vector(AMOUNT_WIDTH-1 downto 0);

begin
--	Nur die 8 niederwertigen Bit des gelesenen Laengenvektors
--	werden tatsaechlich benoetigt.
	TEMP_SHIFT_AMOUNT <= SHIFT_AMOUNT(AMOUNT_WIDTH-1 downto 0);

	-- Instantiate the Unit Under Test (UUT)
	uut: ArmShifter port map(
		SHIFT_OPERAND	=> SHIFT_OPERAND,
		SHIFT_AMOUNT	=> TEMP_SHIFT_AMOUNT,
		SHIFT_TYPE_IN	=> SHIFT_TYPE_IN,
		SHIFT_C_IN	=> SHIFT_C_IN,
		SHIFT_RRX	=> SHIFT_RRX,
		SHIFT_RESULT	=> SHIFT_RESULT,
		SHIFT_C_OUT	=> SHIFT_C_OUT
	);

	tb : process
		variable TESTVECTOR	: ArmShifterTestvector := ((others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'));
		variable DATA_ERROR, IS_COMMENT : boolean := false;
		variable DATA_LINE	: line;
		variable RESULT_ERRORS	: natural := 0;
		variable i		: natural := 0;
		variable DATASET_NR	: natural := 0;
		variable SHIFTER_RESULT_ERRORS, C_ERRORS : natural := 0;
	begin
		SHIFTER_RESULT_ERRORS := 0; C_ERRORS := 0;
		TESTVECTOR := ((others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'),(others => '0'));
--		Wartezeit zwischen zwischen Anlegen der Testvektoren 
--		und Ueberpruefung der Ergebnisse, danach wird
--		noch einmal die halbe Wartezeit gewartet (damit 
--		die Zuordnung in der Wave eindeutig ist).
		wait for 10 ns;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Simulationsbeginn...";
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report HT & "Testvektordatei: " & TEST_FILE_PATH;
		report SEPARATOR_LINE;
		while not endfile(TEST_FILE)loop
			i := 0;
			while (i < ELEMENTS_IN_TESTVECTOR and not endfile(TEST_FILE)) loop
				readline(TEST_FILE,DATA_LINE);	
				LINE_IS_COMMENT(DATA_LINE,IS_COMMENT);
				if(IS_COMMENT)then
					next;
				end if;
--				report "Element " & integer'image(i) & " in Datensatz " & integer'image(DATASET_NR);
				case i is
					when 0 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,TESTVECTOR.SHIFT_TEST_OPERAND);
--						report SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_OPERAND);
					when 1 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,TESTVECTOR.SHIFT_TEST_AMOUNT);
--						report SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_AMOUNT);
					when 2 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,TESTVECTOR.SHIFT_TEST_TYPE_IN);
--						report SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_TYPE_IN);
					when 3 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,TESTVECTOR.SHIFT_TEST_C_IN);
--						report SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_C_IN);
					when 4 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,TESTVECTOR.SHIFT_TEST_RRX);
--						report SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_RRX);
					when 5 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,TESTVECTOR.SHIFT_TEST_RESULT);
--						report SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_RESULT);
					when 6 =>
						GET_LOGIC_VECTOR_FROM_LINE(DATA_LINE,TESTVECTOR.SHIFT_TEST_C_OUT);
--						report SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_C_OUT);
					when others =>
						null;	
				end case;
				i := i +1;
			end loop;
			if( i = 0) then
-- 				Das Ende der Datei wird von Leer- oder Kommentarzeilen gebildet				
				exit;
			elsif(i < ELEMENTS_IN_TESTVECTOR)then
				report "Letzter Datensatz unvollstaendig : Datensatz " & integer'image(DATASET_NR + 1) severity error;
				exit;
			else
				i := 0;
				DATASET_NR 	:= DATASET_NR + 1;
				SHIFT_OPERAND 	<= TESTVECTOR.SHIFT_TEST_OPERAND;
				SHIFT_AMOUNT 	<= TESTVECTOR.SHIFT_TEST_AMOUNT;
				SHIFT_TYPE_IN 	<= TESTVECTOR.SHIFT_TEST_TYPE_IN;
				SHIFT_C_IN    	<= TESTVECTOR.SHIFT_TEST_C_IN(0);
				SHIFT_RRX 	<= TESTVECTOR.SHIFT_TEST_RRX(0);
			end if;	
			wait for WORKING_DELAY;
			if((TESTVECTOR.SHIFT_TEST_RESULT = SHIFT_RESULT) and (TESTVECTOR.SHIFT_TEST_C_OUT(0) = SHIFT_C_OUT))then
--				Erwartetes Ergebnis, kein Bericht notwendig
				null;
			else
--				Fehler aufgetreten
				RESULT_ERRORS := RESULT_ERRORS + 1; 
				report SEPARATOR_LINE;
				report "Fehler aufgetreten..." severity error;
				report HT & "Fehler in Datensatz: " & HT & integer'image(DATASET_NR) severity note;
				report HT & "OPERAND: " & HT & SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_OPERAND);
				report HT & "AMOUNT: " & HT & SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_AMOUNT(AMOUNT_WIDTH-1 downto 0)) & " = " & integer'image(to_integer(unsigned(TESTVECTOR.SHIFT_TEST_AMOUNT)));
				report HT & "TYP: " & HT & HT & SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_TYPE_IN);
				report HT & "C_IN: " & HT & HT & SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_C_IN);
				report HT & "RRX: " & HT & HT & SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_RRX);
				if (TESTVECTOR.SHIFT_TEST_RESULT /= SHIFT_RESULT) then
					SHIFTER_RESULT_ERRORS := SHIFTER_RESULT_ERRORS + 1;
					report HT & "Ergebnis: " & HT & SLV_TO_STRING(SHIFT_RESULT) & " <> ";
					report HT & "Erwartet: " & HT &	SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_RESULT);
				end if;
				if (TESTVECTOR.SHIFT_TEST_C_OUT(0) /= SHIFT_C_OUT) then
					C_ERRORS := C_ERRORS + 1;
					report HT & "Carry: " & HT & HT & SL_TO_STRING(SHIFT_C_OUT) & " <> ";
					report HT & "Erwartet: " & HT & SLV_TO_STRING(TESTVECTOR.SHIFT_TEST_C_OUT);
				end if;
				report HT & HT & HT & HT;
				report SEPARATOR_LINE;
			end if;	
			wait for WORKING_DELAY/2;
		end loop;

		file_close(TEST_FILE);
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Testvektoren geprueft: " & integer'image(DATASET_NR);
		if(RESULT_ERRORS = 0)then
			report "Funktionstest bestanden" severity note;	
		else
			report "Fehlerhafte Shifter-Resultate: " & HT & integer'image(SHIFTER_RESULT_ERRORS);	
			report "Fehlerhafte Carrys: " & HT & HT & integer'image(C_ERRORS);
			report "Simulation nicht bestanden, fehlerhafte Ergebnisse in " & integer'image(RESULT_ERRORS) & " Datensaetzen." severity error;
			report "Simulation nicht bestanden, fehlerhafte Ergebnisse in " & integer'image(RESULT_ERRORS) & " Datensaetzen." severity note;
		end if;	
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait; -- will wait forever
	end process;

end architecture behave;
