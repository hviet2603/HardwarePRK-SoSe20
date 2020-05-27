--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Testbench fuer Arbeitsspeichermodul ArmMemInterface des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		16.05.2010
--	Version:	1.3
--------------------------------------------------------------------------------
--	Hinweise:
--	Die TB stellt fuer verschiedene Testfaelle Vergleiche zwischen
--	dem zu testenden Modul und einem einfachen Referenzspeicher an. Nach 
--	einem Testlauf uebernimmt der Referenzspeicher den getesteten Inhalt
--	des Speichermoduls, damit einmal aufgetretene Fehler nicht doppelt
--	gezaehlt werden.
--	Die Instruktionsadresse ist ein 30-Bit-Vektor. In der Waveform
--	erscheinen _Wort_adressen, waehrend die Datenadressen immer
--	Byteadressen sind.
--------------------------------------------------------------------------------
--	Aenderungen:
--	Zusaetzlicher Testcase eingefuegt. Test auf Tristate des Datenausgangs
--	der Datenseite bei Schreibzugriffen auf die Datenseite.
--	Stimuli werden nicht mehr "gleichzeit" (sofort nach) Taktflanken
--	geaendert, die neuen Funktionen SYNC_HIGH_DELAY und SYNC_LOW_DELAY
--	sorgen fuer einen zusaetzlichen Zeitversatz, nachdem auf eine Takt-
--	flanke gewartet wurde.
--	Rudimentaerer Test auf 'X' in den Datenausgaengen beider Speicherseiten
--	hinzugefuegt, koennte noch auf die Aborts ausgeweitet werden.
--	Funktionsloses Signal "TESTCASE" hinzugefuegt, sollte automatisch
--	in der Waveform auftauchen und zeigt dort die Nummer des aktuell
--	laufenden Testcase an.       
--------------------------------------------------------------------------------
--	Ausblick:
--	Aktuell wird die das Verhalten der Ausgaenge (Tristate unter 
--	bestimmten Voraussetzungen) nur in konkreten Testfaellen ueberprueft.
--	Vorzuziehen waehre eine Loesung, die die Korrektheit permanent sicher-
-- 	stellt.	
--	Aktuell erfolgt kein konsequenter Test auf das Auftreten von Werten
--	jenseits von 1,0 und Z an den Modulausgaengen. Dies sollte zukuenftig
--	geschehen.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
library work;
use work.TB_Tools.all;
use work.ArmConfiguration.all;

entity ArmMemInterface_tb is
--------------------------------------------------------------------------------
--	Soll die Testbench nicht alle 16k Adressen testen (Zeit-/Speicher-
--	aufwand) muss ein Speedup > 1 angegeben werden. Nur Potenzen von 2
--	sollten verwendet werden. Getestete Adressen: 0..16383/SPEED_UP.
--------------------------------------------------------------------------------
	generic( SPEED_UP : integer range 1 to 32 := 1
	);
end entity ArmMemInterface_tb;

architecture behave of ArmMemInterface_tb is 

	component ArmMemInterface
	port(
		RAM_CLK	: in std_logic;
		IDE		: in std_logic;
		IA		: in std_logic_vector(31 downto 2);
		DDE		: in std_logic;
		DnRW	: in std_logic;
		DMAS	: in std_logic_vector(1 downto 0);
		DA		: in std_logic_vector(31 downto 0);    
		DDIN	: in std_logic_vector(31 downto 0);      
		DDOUT	: out std_logic_vector(31 downto 0);      
		ID		: out std_logic_vector(31 downto 0);
		IABORT	: out std_logic;
		DABORT	: out std_logic);
	end component ArmMemInterface;
	constant NR_OF_TESTCASES : natural := 15;

--	RAM_CLK und SYS_CLK laufen 180° phasenversetzt, daher die unterschiedlichen Initialwerte
	signal SYS_CLK : std_logic := '0';
	signal RAM_CLK : std_logic := '1';
--	Signale des Instruktionsbus
	signal IDE	: std_logic := '0';
	signal IA	: std_logic_vector(31 downto 2) := (others=>'0');
	signal ID	: std_logic_vector(31 downto 0);
	signal IABORT : std_logic;
--	signale des Datenbus
	signal DDE	: std_logic := '0';
	signal DnRW	: std_logic := '0';
	signal DMAS	: std_logic_vector(1 downto 0)	:= (others=>'0');
	signal DA 	: std_logic_vector(31 downto 0) := (others=>'0');
	signal DDIN	: std_logic_vector(31 downto 0) := (others => '0');
	signal DDOUT : std_logic_vector(31 downto 0) := (others => '0');
	signal DABORT : std_logic;
	type REFERENCE_MEMORY_TYPE is array (0 to 4095) of std_logic_vector(31 downto 0);
	signal REF_MEMORY : REFERENCE_MEMORY_TYPE := (others => (others =>'0'));
--	Signale des Referenz-Speichermodells
	signal REF_DD_OUT : std_logic_vector(31 downto 0) := (others => '0');

	signal SIMULATION_RUNNING : std_logic := '1';
	signal TESTCASE	: natural := 1;
	signal SIGNAL_NOT_VALID_ERRORS : natural := 0;

	
--	Ein Referenzspeicher umfasst 4 Kibiworte
--	Die Referenz besteht aus einem Array, auf dem die Speicherzugriffe nachgebildet werden

begin
	SYS_CLK <= not SYS_CLK after ARM_SYS_CLK_PERIOD/2 when SIMULATION_RUNNING = '1' else '0';
	RAM_CLK <= not SYS_CLK;

	uut: ArmMemInterface 
	port map(
		RAM_CLK		=> RAM_CLK,
		IDE		=> IDE,
		IA		=> IA,
		ID		=> ID,
		IABORT		=> IABORT,
		DDE		=> DDE,
		DnRW		=> DnRW,
		DMAS		=> DMAS,
		DA		=> DA,
		DDIN		=> DDIN,
		DDOUT		=> DDOUT,
		DABORT		=> DABORT
	);

	CHECK_VALID_SIGNALS : process(ID,DDOUT)is
		variable LOCAL_ERRORS : natural := 0;
	begin
		LOCAL_ERRORS := 0;
		for i in 31 downto 0 loop
			if ID(i) = 'X' or DDOUT(i) = 'X' then
				if LOCAL_ERRORS = 0 then
					report "'X' in ID oder DDOUT erkannt. Weitere Fehler dieser Art werden protokolliert aber nicht gemeldet." severity error;
				end if;
				LOCAL_ERRORS := LOCAL_ERRORS + 1;
				exit when ID(i) = 'X' or DDOUT(i) = 'X';
			end if;
		end loop;
	SIGNAL_NOT_VALID_ERRORS <= SIGNAL_NOT_VALID_ERRORS + LOCAL_ERRORS;
	end process CHECK_VALID_SIGNALS;

	tb : process

		type RAM_TEST_CASE_TYPE IS ( WORD, HW_0, HW_1, BYTE_0, BYTE_1, BYTE_2, BYTE_3);
		variable RAM_TEST_CASE : RAM_TEST_CASE_TYPE;
		type ERRORS_IN_TESTCASES_TYPE is array(1 to NR_OF_TESTCASES) of natural;
		variable ERRORS_IN_TESTCASES : ERRORS_IN_TESTCASES_TYPE := (others => 0);
		type TESTCASES_NAMES_TYPE is array(1 to NR_OF_TESTCASES) of line;
		variable TESTCASES_NAMES : TESTCASES_NAMES_TYPE;
		type DMAS_NAMES_TYPE is array(0 to 3) of string(15 downto 1);
		constant DMAS_NAMES : DMAS_NAMES_TYPE := (	"Bytezugriff    ",
								"Halbwortzugriff",
								"Wortzugriff    ",
								"Reserviert     ");

		variable DATA_STIMULUS	: std_logic_vector(31 downto 0);
		variable ADDR_UPPER_BITS: std_logic_vector(29 downto 0);
		variable i			: integer;
		variable REF_BIT_HIGH	: integer;
		variable REF_BIT_LOW	: integer;
		variable ITERATOR		: integer range 1 to 4;
		variable LOOP_HIGH		: integer := 16383/SPEED_UP;
		variable LOOP_LOW		: integer;
		variable NR_OF_ERRORS	: integer := 0;
		variable OVERALL_NR_OF_ERRORS	: integer := 0;
		variable ERROR_OCCURED		: boolean := FALSE;
		variable ERRORS_IN_TESTCASE	: integer := 0;
		variable ERROR_IN_FIRST_RUN	: boolean := FALSE;
		variable ERROR_IN_SECOND_RUN: boolean := FALSE;
		variable TESTCASE_NR		: natural := 1;
		variable ABORT_ERRORS		: natural := 0;
		variable OVERALL_ERRORS		: natural := 0;
		variable POINTS				: natural := 0;

	procedure EVAL(THIS_TESTCASE : inout natural range 1 to NR_OF_TESTCASES; THIS_ERRORS : inout natural; THIS_ERRORS_ARRAY : inout ERRORS_IN_TESTCASES_TYPE) is
	begin
		if THIS_ERRORS > 0 then
			report "Fehler in Testcase " & integer'image(THIS_TESTCASE) severity error;
			report "Fehler in Testcase " & integer'image(THIS_TESTCASE) severity note;
			THIS_ERRORS_ARRAY(THIS_TESTCASE) := THIS_ERRORS;
		else
			report "Testcase " & integer'image(THIS_TESTCASE) & " korrekt." severity note;
			THIS_ERRORS_ARRAY(THIS_TESTCASE) := 0;
		end if;
		if THIS_TESTCASE < NR_OF_TESTCASES then THIS_TESTCASE := THIS_TESTCASE + 1; end if;
		THIS_ERRORS := 0;
		TESTCASE <= THIS_TESTCASE;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
	end procedure EVAL;

	procedure INIT_TESTCASES_NAMES is
		begin
			STD.textio.write(TESTCASES_NAMES(1),TAB_CHAR & "Wortzugriffe" & TAB_CHAR & TAB_CHAR & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(2),TAB_CHAR & "Zugriffe auf niederwertiges Halbwort" & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(3),TAB_CHAR & "Zugriffe auf das hochwertige Halbwort" & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(4),TAB_CHAR & "Zugriffe auf das niederwertigste Byte" & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(5),TAB_CHAR & "Zugriffe auf das zweite Byte" & TAB_CHAR & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(6),TAB_CHAR & "Zugriffe auf das dritte Byte" & TAB_CHAR & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(7),TAB_CHAR & "Zugriffe auf das am hoechsten wertige Byte" & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(8),TAB_CHAR & "Lesen des vollstaendigen Speichers, unterschiedliche Adressen an beiden Ports");
			STD.textio.write(TESTCASES_NAMES(9),TAB_CHAR & "Test des write-after-read-Verhaltens" & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(10),TAB_CHAR & "Schreibzugriffe bei deaktiviertem Enable-Signal" & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(11),TAB_CHAR & "Test auf Ueberpruefung der Instruktionsadresse durch die Speicherschnittstelle");
			STD.textio.write(TESTCASES_NAMES(12),TAB_CHAR & "Test auf Tristate aller Ausgaenge bei deaktivierten Enablesignalen und Schreibzugriff");
			STD.textio.write(TESTCASES_NAMES(13),TAB_CHAR & "Test auf Tristate des Datenausgangs bei Schreibzugriff auf Datenschnittstelle");
			STD.textio.write(TESTCASES_NAMES(14),TAB_CHAR & "Test auf Misalignementerkennung" & TAB_CHAR & TAB_CHAR & TAB_CHAR);
			STD.textio.write(TESTCASES_NAMES(15),TAB_CHAR & "Anzahl fehlerhafter Abortsignale waehrend der Tests" & TAB_CHAR);
	end procedure INIT_TESTCASES_NAMES;

	procedure SYNC_HIGH_DELAY(THIS_DELAY: in real) is
	begin
		wait until SYS_CLK'event and SYS_CLK = '1';
		wait for (ARM_SYS_CLK_PERIOD*THIS_DELAY);
	end procedure SYNC_HIGH_DELAY;

	procedure SYNC_LOW_DELAY(THIS_DELAY: real) is
	begin
	wait until SYS_CLK'event and SYS_CLK = '0';
	wait for (ARM_SYS_CLK_PERIOD*THIS_DELAY);
	end procedure SYNC_LOW_DELAY;


	begin
		INIT_TESTCASES_NAMES;
		report "Start der Simulation...";
		report "Hinweis: Alle Instruktionsadressen sind 30 Bit breit, in der Waveform des Simulators erscheinen Wort-Adressen. Datenadressen sind 32 Bit breit, in der Waveform erscheinen Byte-Adressen!";
		report SEPARATOR_LINE;
		SIMULATION_RUNNING	<= '1';
		DnRW			<= '0';
		ERRORS_IN_TESTCASE	:= 0;
--	getestet wird mit zufaelligen Vektoren, Zufallsgenerator initialisieren
		INIT_SEED_ISIM(333);	
		GET_RANDOM_SLV_ISIM(DATA_STIMULUS);
		DDIN <= (others => 'Z');
		wait for ARM_SYS_CLK_PERIOD*10.5;

		report "Die Testfaelle 1 bis 7 testen mit regulaeren Zugriffsmustern die Grundfunktionalitaet des Speichers." severity note;
		report "Getestet wird das Schreiben zufaelliger Testdaten ueber den Datenbus in den Speicher." severity note;
		report "Anschliessend werden die Testdaten ueber beide Speicherbusse parallel gelesen und mit mit einem Referenzspeicher verglichen." severity note;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		
--	Test der diversen Zugriffsmuster auf den Speicher
		for TEST_CASE in RAM_TEST_CASE_TYPE'left to RAM_TEST_CASE_TYPE'right loop
			ERRORS_IN_TESTCASE := 0;
			IDE <= '0';
			DDE <= '1';
			DnRW <= '0';
			DMAS <= "00";
			REF_BIT_HIGH := 31;
			REF_BIT_LOW := 0;
			ITERATOR := 4;
			LOOP_LOW := 0;
			RAM_TEST_CASE := TEST_CASE;
			DDIN <= (others => 'Z');--DATA_STIMULUS;
			report "Testcase " & integer'image(TESTCASE_NR) & ": " & RAM_TEST_CASE_TYPE'image(TEST_CASE) & " (" & TESTCASES_NAMES(TESTCASE_NR).all &")";
--			wait until SYS_CLK'event and SYS_CLK = '1';
			SYNC_HIGH_DELAY(0.1);

			case TEST_CASE is
--	Fuer jedes Zugriffsmuster muss die Schleife ueber den 
--	Referenzspeicher etwas anders aussehen. 
				when WORD =>
					DMAS <= "10";
					REF_BIT_HIGH := 31;
					REF_BIT_LOW := 0;
					ITERATOR := 4;
					LOOP_LOW := 0;
				when HW_0 =>
					DMAS <= "01";
					REF_BIT_HIGH := 15;
					REF_BIT_LOW := 0;
					ITERATOR := 4;
					LOOP_LOW := 0;
				when HW_1 =>
					DMAS <= "01";
					REF_BIT_HIGH := 31;
					REF_BIT_LOW := 16;
					ITERATOR := 4;
					LOOP_LOW := 2;
				when BYTE_0 =>	
					DMAS <= "00";
					REF_BIT_HIGH := 7;
					REF_BIT_LOW := 0;
					ITERATOR := 4;
					LOOP_LOW := 0;
				when BYTE_1 =>	
					DMAS <= "00";
					REF_BIT_HIGH := 15;
					REF_BIT_LOW := 8;
					ITERATOR := 4;
					LOOP_LOW := 1;
				when BYTE_2 =>	
					DMAS <= "00";
					REF_BIT_HIGH := 23;
					REF_BIT_LOW := 16;
					ITERATOR := 4;
					LOOP_LOW := 2;
				when BYTE_3 =>	
					DMAS <= "00";
					REF_BIT_HIGH := 31;
					REF_BIT_LOW := 24;
					ITERATOR := 4;
					LOOP_LOW := 3;
			end case;
		ERRORS_IN_TESTCASE := 0;
		ABORT_ERRORS := 0;
		i := LOOP_LOW;
--	Schleife bis zur hoechsten Wortadresse (LOOP_HIGH)
		while i <= LOOP_HIGH loop	
			GET_RANDOM_SLV_ISIM(DATA_STIMULUS);
--	Setzen von Steuersignalen jeweils nach einer steigenden Systemtaktflanke
--			wait until SYS_CLK'event and SYS_CLK = '1';
			SYNC_HIGH_DELAY(0.1);
			DDIN <= DATA_STIMULUS;
			DnRW <= '1'; --Schreibzugriff
			DA <= std_logic_vector(to_unsigned((i),32));
--			wait until RAM_CLK'event and RAM_CLK='1';
			SYNC_LOW_DELAY(0.1);
--	Im Referenzspeicher den vom aktuellen Testfall betroffenen Abschnitt aktualisieren
			REF_MEMORY(i/4)(REF_BIT_HIGH downto REF_BIT_LOW) <= DATA_STIMULUS(REF_BIT_HIGH downto REF_BIT_LOW);
			wait for ARM_SYS_CLK_PERIOD/10;
			if (IABORT = '1')then
				if ABORT_ERRORS < 10 then
					report "IABORT ausgeloest bei i = " & integer'image(i) & " und Testcase " & RAM_TEST_CASE_TYPE'image(TEST_CASE) severity note;	
				end if;
				ABORT_ERRORS := ABORT_ERRORS + 1;
			end if;
			if (DABORT = '1')then
				if ABORT_ERRORS < 10 then
					report "DABORT ausgeloest bei i = " & integer'image(i) & " und Testcase " & RAM_TEST_CASE_TYPE'image(TEST_CASE) severity note;	
				end if;
				ABORT_ERRORS := ABORT_ERRORS + 1;
			end if;
			i := i + ITERATOR;
		end loop;

		wait for ARM_SYS_CLK_PERIOD/4;
--	Auslesen des ganzen Speichers vorbereiten
		DDIN	<= (others => 'Z');
		DnRW	<= '0';
		DA	<= (others => '0');
		IA	<= (others => '0');
		DMAS	<="10";
		IDE	<= '1';
		
--	Speicher zweimal vollstaendig auslesen, um Aenderungen waehrend des ersten Auslesens zu erkennen
		ERROR_IN_FIRST_RUN := false; ERROR_IN_SECOND_RUN := false;
		for k in 0 to 1 loop
			for i in 0 to (LOOP_HIGH/4) loop
--				wait until SYS_CLK'event and SYS_CLK = '1';
				SYNC_HIGH_DELAY(0.25);
				DA <= std_logic_vector(to_unsigned((i*4),32));
				IA <= std_logic_vector(to_unsigned((i),30));
--				wait until RAM_CLK'event and RAM_CLK='1';
				SYNC_LOW_DELAY(0.1);
				REF_DD_OUT <= REF_MEMORY(i);
				wait for ARM_SYS_CLK_PERIOD/10;
				if(IABORT = '1')then
					if ABORT_ERRORS < 10 then
						report "Unerwartetes IABORT bei ueberpruefendem Lesezugriff an Adresse " & integer'image(i) & " und Testcase " & RAM_TEST_CASE_TYPE'image(TEST_CASE) severity note;
					end if;
					ABORT_ERRORS := ABORT_ERRORS + 1;
				end if;
				if(DABORT = '1')then
					if ABORT_ERRORS < 10 then
						report "Unerwartetes DABORT bei ueberpruefendem Lesezugriff an Adresse " & integer'image(i) & " und Testcase " & RAM_TEST_CASE_TYPE'image(TEST_CASE) severity note;
					end if;	
					ABORT_ERRORS := ABORT_ERRORS + 1;
				end if;
				if(DDOUT = REF_DD_OUT)then
					null;
				else
					if ERRORS_IN_TESTCASE < 10 then
						report "Datenbus-Datenausgang des Speichers und Referenzspeicher stimmen nicht ueberein." severity note;
						report "Adresse: " & integer'image(i) & " und Testcase " & RAM_TEST_CASE_TYPE'image(TEST_CASE) severity note;
						report "Erwartetes Datum: " & TAB_CHAR & SLV_TO_STRING(REF_DD_OUT);
						report "gelesenes Datum: " & TAB_CHAR & SLV_TO_STRING(DDOUT);
					end if;
					ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
					if k = 0 then ERROR_IN_FIRST_RUN := true; else ERROR_IN_SECOND_RUN := true; end if;
				end if;	
				if(ID /= REF_DD_OUT)then
					if ERRORS_IN_TESTCASE < 10 then
						report "Instruktionsbus-Datenausgang des Speichers und Referenzspeicher stimmen nicht ueberein." severity note;
						report "Adresse: " & integer'image(i) & " und Testcase " & RAM_TEST_CASE_TYPE'image(TEST_CASE) severity note;
						report "Erwartetes Datum: " & TAB_CHAR & SLV_TO_STRING(REF_DD_OUT);
						report "gelesenes Datum: " & TAB_CHAR & SLV_TO_STRING(ID);
					end if;
					ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
					if k = 0 then ERROR_IN_FIRST_RUN := true; else ERROR_IN_SECOND_RUN := true; end if;
				end if;
--	Beim zweiten Durchlauf: Uebernehmen des Speicherinhalts in den Referenzspeicher
				if k = 1 then
					REF_MEMORY(i) <= DDOUT;
				end if;
				wait for ARM_SYS_CLK_PERIOD/3;
			end loop;
		end loop;
		if (NOT ERROR_IN_FIRST_RUN) AND ERROR_IN_SECOND_RUN then
			report SEPARATOR_LINE;
			report "Fehler nur waehrend des zweiten Lesedurchgangs aufgetreten. Moegliche Ursache: Write-Enablesignale werden bei Lesezugriffen nicht auf 0 gesetzt";
			report SEPARATOR_LINE;
		end if;
		if ABORT_ERRORS > 10 then
			report "10 ABORT-Fehler wurden detailliert aufgefuehrt, weitere nur protokolliert" severity note;
		end if;
		if ERRORS_IN_TESTCASE > 10 then
			report "10 Speicherzugriffsfehler wurden detailliert aufgefuehrt, weitere nur protokolliert" severity note;
		end if;
		if ABORT_ERRORS > 0 then
			report "Unerwartete Abortsignale trotz gueltiger Zugriffsadressen sind aufgetreten in " & integer'image(ABORT_ERRORS) & " Faellen" severity note;
			ERRORS_IN_TESTCASES(15) := ERRORS_IN_TESTCASES(15) + ABORT_ERRORS;
			ABORT_ERRORS := 0;
		end if;
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
	end loop;

	report "Testcase : " & integer'image(TESTCASE_NR) & ": Lesen des gesamten Speichers mit Wortzugriffen mit unterschiedlichen Adressen auf beiden Ports.";
	report "Die Adressen werden gerade gegenlaeufig fuer beide Ports veraendert";
	ERRORS_IN_TESTCASE := 0;
	ABORT_ERRORS := 0;
	i := 0;
	while i <= LOOP_HIGH loop
--		wait until SYS_CLK'event and SYS_CLK = '1';
		SYNC_HIGH_DELAY(0.1);
			DDIN <= (others => 'Z');
			DDE <= '1';
			IDE <= '1';
			DnRW <= '0';
			DA <= std_logic_vector(to_unsigned(i,32));
			IA <= std_logic_vector(to_unsigned((LOOP_HIGH - i)/4,30));	
--		wait until SYS_CLK'event and SYS_CLK = '0';
--		wait for ARM_SYS_CLK_PERIOD/4;
		SYNC_LOW_DELAY(0.25);
		if (DDOUT /= REF_MEMORY(i/4)) OR (ID /= REF_MEMORY((LOOP_HIGH - i)/4)) then
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
			if ERRORS_IN_TESTCASE > 10 then
				null;
			else
				if DDOUT /= REF_MEMORY(i/4) then
					report "Das auf der Datenbusseite gelesene Datum an Adresse " & integer'image(i) & " stimmt nicht mit dem Referenzspeicher ueberein." severity note;
				end if;
				if ID /= REF_MEMORY((LOOP_HIGH - i)/4) then
					report "Das auf der Instruktionsseite gelesene Datum an Adresse " & integer'image(LOOP_HIGH - i) & " stimmt nicht mit dem Referenzspeicher ueberein." severity note;
				end if;				
			end if;
		end if;
		if DABORT /= '0' then
			ABORT_ERRORS := ABORT_ERRORS + 1;
			if ABORT_ERRORS < 10 then
				report "Unerwartetes DABORT bei Zugriff auf Adresse " & integer'image(i);
			end if;	
		end if;
		if IABORT /= '0' then
			ABORT_ERRORS := ABORT_ERRORS + 1;
			if ABORT_ERRORS < 10 then
				report "Unerwartetes IABORT bei Zugriff auf Adresse " & integer'image(LOOP_HIGH - i);
			end if;
		end if;
		i := i + 4;
	end loop;
	if ERRORS_IN_TESTCASE > 10 then
		report "10 Speicherzugriffsfehler wurde detailliert aufgefuehrt, weitere nur protokolliert" severity note;
	end if;
	if ABORT_ERRORS > 0 then
		report "Unerwartete Abortsignale trotz gueltiger Zugriffsadressen sind aufgetreten in " & integer'image(ABORT_ERRORS) & " Faellen" severity note;
	end if;	
	ERRORS_IN_TESTCASES(15) := ERRORS_IN_TESTCASES(15) + ABORT_ERRORS;
	ABORT_ERRORS := 0;
	EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
--------------------------------------------------------------------------------
	report "Testcase : " & integer'image(TESTCASE_NR) & ": Gleichzeitig lesender und schreibender Zugriff auf die gleiche Speicheradresse ueber beide Ports.";
	report "Im Takt, in dem das neue Datum geschrieben wird, ist noch das alte Datum am Ausgang des Speichers sichtbar (write-after-read)";
	ERRORS_IN_TESTCASE := 0;
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
	DnRW	<= '1';
	IA	<= (others => '0');
	DA	<= (others => '0');
	DDIN	<= NOT REF_MEMORY(0);
--------------------------------------------------------------------------------
--	Nach der naechsten steigenden Systemtaktflanke liegt noch das alte Datum
--	auf dem Bus. Der Schreibzugriff hat zwar bereits stattgefunden,
--	gleichzeitig wurde aber das alte Datum in das Ausgangsregister des
--	Speichers kopiert.
--------------------------------------------------------------------------------
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
		DnRW <= '0';
		DDIN <= (others => 'Z');
		if ID /= REF_MEMORY(0) then
			report "Fehler beim Lesen vor der Speichertaktflanke." severity note;
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_LOW_DELAY(0.25);
	if ID /= NOT REF_MEMORY(0) then
		report "Fehler beim Lesen nach der Speichertaktflanke." severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
--------------------------------------------------------------------------------
--	Schreiben trotz deaktiviertem Enablesignal. Fuer beide "Zeilen" der
--	Speicherbloecke jeweils alle Zugriffsmuster.
--------------------------------------------------------------------------------
	report "Testcase " & integer'image(TESTCASE_NR) & ": Schreiben in die jeweils unterste Zelle jeder Speicherzeile (Adressen 0 und 2048) bei deaktiviertem ENABLE-Signal mit allen moeglichen Zugriffsarten (Wort, Halbwort_0, ...)";
	report "Die Schreibzugriffe duerfen keine Wirkung haben.";
	ERRORS_IN_TESTCASE := 0;
	for TEST_CASE in RAM_TEST_CASE_TYPE'left to RAM_TEST_CASE_TYPE'right loop

	case TEST_CASE is
		when WORD =>
			DMAS <= "10";
			DA <= std_logic_vector(to_unsigned(0,32));
		when HW_0 =>	
			DMAS <= "01";
			DA <= std_logic_vector(to_unsigned(0,32));
		when HW_1 =>	
			DMAS <= "01";
			DA <= std_logic_vector(to_unsigned(2,32));
		when BYTE_0 =>
			DMAS <= "00";
			DA <= std_logic_vector(to_unsigned(0,32));
		when BYTE_1 =>
			DMAS <= "00";
			DA <= std_logic_vector(to_unsigned(1,32));
		when BYTE_2 =>
			DMAS <= "00";
			DA <= std_logic_vector(to_unsigned(2,32));
		when BYTE_3 =>
			DMAS <= "00";
			DA <= std_logic_vector(to_unsigned(3,32));
	end case;

--	Schreiben von Referenzwert an Adresse 0
		DDE <= '1';
		DnRW <= '1';
		DA <= (others => '0');
		DDIN <= REF_MEMORY(0);
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
		DDE <= '0';
		DDIN <= NOT REF_MEMORY(0);
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
		DDE <= '1';
		DnRW <= '0';
		DDIN <= (others => 'Z');
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
	if DDOUT /= REF_MEMORY(0) then
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		report "Unerwarteter Schreibzugriff, DDE wird nicht korrekt ausgewertet oder DnRW falsch interpretiert fuer die untere Speicherhaelfte." severity note;	
	end if;	
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);

	case TEST_CASE is
		when WORD =>
			DMAS <= "10";
			DA <= std_logic_vector(to_unsigned(2048,32));
		when HW_0 =>	
			DMAS <= "01";
			DA <= std_logic_vector(to_unsigned(2048,32));
		when HW_1 =>	
			DMAS <= "01";
			DA <= std_logic_vector(to_unsigned(2050,32));
		when BYTE_0 =>
			DMAS <= "00";
			DA <= std_logic_vector(to_unsigned(2048,32));
		when BYTE_1 =>
			DMAS <= "00";
			DA <= std_logic_vector(to_unsigned(2049,32));
		when BYTE_2 =>
			DMAS <= "00";
			DA <= std_logic_vector(to_unsigned(2050,32));
		when BYTE_3 =>
			DMAS <= "00";
			DA <= std_logic_vector(to_unsigned(2051,32));
	end case;
		DnRW <= '1';
		DDIN <= REF_MEMORY(2048);
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
		DDE <= '0';
		DDIN <= NOT REF_MEMORY(2048);
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
		DDE <= '1';
		DnRW <= '0';
		DDIN <= (others => 'Z');
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
	if DDOUT /= REF_MEMORY(2048) then
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		report "Unerwarteter Schreibzugriff, DDE wird nicht korrekt ausgewertet oder DnRW falsch interpretiert fuer die obere Speicherhaelfte." severity note;	
	end if;	
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
	end loop;	
	EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);

--------------------------------------------------------------------------------

--	Lesen ungueltiger Adressen, erkannt werden muss das nur Instruktionsseitig, Test erfolgt
--	fuer die Adressen 16384 und 2**31
	report "Testcase " & integer'image(TESTCASE_NR) & ": Instruktionsseitiges Lesen an Adressen ausserhalb des Instruktionsspeicherbereichs.";
	report "Getestet werden die Adressen 16384 und 2**31, IABORT muss den Zugriffsfehler anzeigen.";
	ERRORS_IN_TESTCASE := 0;
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
--		4096 weil IA die beiden niederwertigsten Bits fehlen	
		IA <= std_logic_vector(to_unsigned(4096,30));
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
	if IABORT /= '1' then
		report "Instruktionsseite erkennt ungueltige Adresse 16384 nicht." severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;	
		IA <= (others => '0');
		DA <= std_logic_vector(to_unsigned(17000,32));
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
--	Nach der Vorgabe werden Zugriffe auf der Datenseite durch den Chip Select Generator ausgewertet
	if DABORT /= '0' then
		report "Datenseite wertet unnoetigerweise Adressfehler aus." severity warning;
	end if;
	if IABORT /= '0' then
		report "IABORT trotz gueltiger Adresse ausgeloest." severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;

--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
--	Test mit 2**31 (bzw. 2**29) um vorzeichenbedingte Vergleichsfehler zu finden 
--		IA <= X"1000000" & "00";
		IA <= std_logic_vector(to_unsigned(2**29,30));
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
	if IABORT /= '1' then
		report "Instruktionsseite erkennt ungueltige Adresse X" & '"' & "10000000" & '"' & " nicht." severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;	
	EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);	

--------------------------------------------------------------------------------
--	Bei deaktivierten Ports Tristateausgange testen	
--	report SEPARATOR_LINE;
--	report "Tristate bei deaktivierten Ports...";
	report "Testcase " & integer'image(TESTCASE_NR) & ": Test auf Tristate an ID, DDOUT, IABORT und DABORT fuer DDE = 0, IDE = 0";
	ERRORS_IN_TESTCASE := 0;
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
		DDE <= '0';
		IDE <= '0';
		DA <= std_logic_vector(to_unsigned(0,32));
--	wait until SYS_CLK'event and SYS_CLK = '1';
--	wait for ARM_SYS_CLK_PERIOD/4;
	SYNC_HIGH_DELAY(0.25);
	if ID /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		report "ID nicht im Tristate" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if IABORT /= 'Z'then
		report "IABORT nicht im Tristate" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if DDOUT /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		report "DDOUT nicht im Tristate" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if DABORT /= 'Z' then
		report "DABORT nicht im Tristate" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
		DDE <= '1';
		IDE <= '1';
--	wait until SYS_CLK'event and SYS_CLK = '0';
	SYNC_LOW_DELAY(0.1);	
	EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);

--------------------------------------------------------------------------------
	report "Testcase " & integer'image(TESTCASE_NR) & ": Test auf Tristate an DDOUT fuer (DDE = 1 und DnRW = 1), zeitgleich IDE = 0";
	ERRORS_IN_TESTCASE := 0;
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
		DDE <= '1'; DnRW <= '1';
		IDE <= '0';
		DDIN <= (others => '1');
		DA <= std_logic_vector(to_unsigned(23,32));
--	wait until SYS_CLK'event and SYS_CLK = '1';
--	wait for ARM_SYS_CLK_PERIOD/4;
	SYNC_HIGH_DELAY(0.25);
	if ID /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		report "ID nicht im Tristate" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if IABORT /= 'Z'then
		report "IABORT nicht im Tristate" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if DDOUT /= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" then
		report "DDOUT nicht im Tristate" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if DABORT /= '0' then
		report "DABORT nicht 0" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
		DDE <= '1';
		IDE <= '1';
		DnRW <= '0';
		DDIN <= (others => 'Z');
--	wait until SYS_CLK'event and SYS_CLK = '0';
	SYNC_LOW_DELAY(0.1);
	EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);

--------------------------------------------------------------------------------

	report "Testcase " & integer'image(TESTCASE_NR) & ": Test auf Erkennung unausgerichteter Daten.";
	report "Ein Zugriffsversuch auf nicht ausgerichtete Daten wird durch DABORT angezeigt, das Datum an der abgerundeten Wortadresse muss dennoch gelesen werden.";
	ERRORS_IN_TESTCASE := 0;
--	Reset um die Ausgaenge des Speichers zurueckzusetzen
	wait for ARM_SYS_CLK_PERIOD;
--	wait until SYS_CLK'event and SYS_CLK = '1';
	SYNC_HIGH_DELAY(0.1);
	DnRW <= '0';
	DMAS <= "10";
	DA <= X"00000001"; --Wortzugriff an Byteadresse	
	SYNC_HIGH_DELAY(0.25);
	if DABORT = '0' then
		report "Unausgerichteter Wortzugriff mit DA(1:0) = 01 nicht erkannt" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if DDOUT /= REF_MEMORY(0) then
		report "Datum an naechst niedriger Wortadresse wurde nicht gelesen" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	DA <= X"00000002";	
	SYNC_HIGH_DELAY(0.25);
	if DABORT = '0' then
		report "Unausgerichteter Wortzugriff mit DA(1:0) = 10 nicht erkannt" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if DDOUT /= REF_MEMORY(0) then
		report "Datum an naechst niedriger Wortadresse wurde nicht gelesen" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	DA <= X"00000003";	
	SYNC_HIGH_DELAY(0.25);
	if DABORT = '0' then
		report "Unausgerichteter Wortzugriff mit DA(1:0) = 11 nicht erkannt" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if DDOUT /= REF_MEMORY(0) then
		report "Datum an naechst niedriger Wortadresse wurde nicht gelesen" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	DMAS <= "01"; --Halbwort
	DA <= X"00000001";	
	SYNC_HIGH_DELAY(0.25);
	if DABORT = '0' then
		report "Unausgerichteter Halbwortzugriff mit DA(1:0) = 01 nicht erkannt" severity error;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	if DDOUT /= REF_MEMORY(0) then
		report "Datum an naechst niedriger Wortadresse wurde nicht gelesen" severity note;
		ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
	end if;
	EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		
--------------------------------------------------------------------------------

	SIMULATION_RUNNING <= '0';
	report SEPARATOR_LINE;	
	report SEPARATOR_LINE;	
	report "...Simulation beendet";
	report SEPARATOR_LINE;	
	report SEPARATOR_LINE;	

	OVERALL_ERRORS := 0;
	report "Fehler in Testcases:";
	for i in 1 to NR_OF_TESTCASES loop
		report "Testcase " & integer'image(i) & ": " & TESTCASES_NAMES(i).all & ": " & integer'image(ERRORS_IN_TESTCASES(i));
		OVERALL_ERRORS := OVERALL_ERRORS + ERRORS_IN_TESTCASES(i);
	end loop;
	report SEPARATOR_LINE;
	report "erzielte Punkte:";

	Points := 3;
	if ERRORS_IN_TESTCASES(1) /= 0 then if Points > 0 then Points := Points - 1; end if; end if;	
	if (ERRORS_IN_TESTCASES(2) /= 0) or (ERRORS_IN_TESTCASES(3) /= 0) then if Points > 0 then Points := Points - 1; end if; end if;	
	if (ERRORS_IN_TESTCASES(4) /= 0) or (ERRORS_IN_TESTCASES(5) /= 0) or (ERRORS_IN_TESTCASES(6) /= 0) or (ERRORS_IN_TESTCASES(7) /= 0) then if Points > 0 then Points := Points - 1; end if; end if;
	if ERRORS_IN_TESTCASES(8) /= 0 then if Points > 0 then Points := Points - 1; end if; end if;
	if ERRORS_IN_TESTCASES(9) /= 0 then if Points > 0 then Points := Points - 1; end if; end if;
	if ERRORS_IN_TESTCASES(10) /= 0 then if Points > 0 then Points := Points - 1; end if; end if;
	report "Basisfunktionalitaet (Testcases 1 bis 10): " & TAB_CHAR & TAB_CHAR & integer'image(POINTS) &"/3";


	if ERRORS_IN_TESTCASES(11) = 0 then
		report "Auswertung der Instruktionsadresse (Testcase 11): " & TAB_CHAR & "1/1";
		POINTS := POINTS + 1;
	else
		report "Auswertung der Instruktionsadresse (Testcase 11): " & TAB_CHAR & "0/1";
	end if;

	if ERRORS_IN_TESTCASES(14) = 0 then
		report "Erkennung fehlerhafter Datenausrichtung (Testcase 14): " & TAB_CHAR & "1/1";
		POINTS := POINTS + 1;
	else
		report "Erkennung fehlerhafter Datenausrichtung (Testcase 14): " & TAB_CHAR & "0/1";
	end if;

	if ERRORS_IN_TESTCASES(12) = 0 and ERRORS_IN_TESTCASES(13) = 0 then
		report "Test auf Tristateausgaenge (Testcases 12,13): " & TAB_CHAR & TAB_CHAR & "1/1";
		POINTS := POINTS + 1;
	else
		report "Test auf Tristateausgaenge (Testcases 12,13): " & TAB_CHAR & TAB_CHAR & "0/1";
	end if;
	if ERRORS_IN_TESTCASES(15) /= 0 then
		report "Punktabzug wegen unerwarteter ABORT-Signale waehrend regulaerer Tests:" & TAB_CHAR & "1";
		if POINTS > 0 then POINTS := POINTS - 1; end if;
	end if;	
	if SIGNAL_NOT_VALID_ERRORS /= 0 then
		report "Punktabzug wegen 'X' in ID oder DDOUT:" & TAB_CHAR & TAB_CHAR & "1";
		if POINTS > 0 then POINTS := POINTS - 1; end if;
	end if;	

	report "Gesamtpunktzahl: " & TAB_CHAR & TAB_CHAR & TAB_CHAR &  TAB_CHAR & TAB_CHAR & integer'image(POINTS) & "/6";
	if (POINTS = 6 ) then
		report "Funktionstest bestanden" severity note;
	else
		report "Funktionstest nicht bestanden" severity error;
		report "Funktionstest nicht bestanden" severity note;
	end if;

	report SEPARATOR_LINE;	
	report SEPARATOR_LINE;	
	report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
	wait; -- will wait forever
end process;


end architecture behave;
