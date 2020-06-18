--------------------------------------------------------------------------------
--	Testench fuer das Modul zur Ermittlung von Zugriffsadressen von
--	LDM- und STM-Instruktionen im Kontrollpfad des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		13.06.2010
--	Version:	1.10
--------------------------------------------------------------------------------
--	Aenderungen fuer das HWPR 2010:
--	Aenderungen der Steuer- und Dateneingaenge erfolgen mit deutlichem
--	Versatz zu Taktflanken.
--	Fehler in der Bestimmung der Registerliste (Loeschen von Bits)
--	und der Adressbestimmung werden getrennt gezaehlt und fuer eine 
--	nun neue Punkteberechnung herangezogen. Adressfehler als Folge einer
--	fehlerhaften Registerliste fuehren nicht zum Punktabzug, sofern sie
--	konsistent zur fehlerhaften Registerliste sind.
--	16 zusaetzliche Testvektoren wurden hinzugefuegt, damit jede 
--	Anzahl von Bits in der Registerliste mindestens einmal 
--	auftritt. Einige der uebrigen Vektoren werden weiterhin durch
--	einen Zufallsgenerator bestimmt.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmConfiguration.all;
use work.TB_TOOLS.all;

entity ArmLdmStmNextAddress_TB is
end ArmLdmStmNextAddress_TB;

architecture testbench of ArmLdmStmNextAddress_tb is
	component ArmLdmStmNextAddress
	port(
		SYS_RST 		: in std_logic;
		SYS_CLK 		: in std_logic;	
		LNA_LOAD_REGLIST 	: in std_logic;
		LNA_HOLD_VALUE 		: in std_logic;
		LNA_REGLIST 		: in std_logic_vector(15 downto 0);
		LNA_ADDRESS 		: out std_logic_vector(3 downto 0);
		LNA_CURRENT_REGLIST_REG : out std_logic_vector(15 downto 0)
	);
	end component ArmLdmStmNextAddress;	
	
--	Signale fuer die Anbindung der Unit Under Test
	signal SYS_CLK		: std_logic := '0';
	signal SYS_RST		: std_logic := '0';
	signal LOAD_REGLIST 	: std_logic := '0';
	signal HOLD_VALUE 	: std_logic := '0';
	signal REGLIST 		: std_logic_vector(15 downto 0) := (others => '0');
	signal ADDRESS		: std_logic_vector(3 downto 0);
	signal CURRENT_REGLIST	: std_logic_vector(15 downto 0);

--	Steuersignale fuer die Funktionen der Testbench
	signal SIMULATION_RUNNING : boolean := TRUE;

begin
	uut : ArmLdmStmNextAddress
	port map(
		SYS_RST			=> SYS_RST,
		SYS_CLK			=> SYS_CLK,
		LNA_LOAD_REGLIST	=> LOAD_REGLIST,
		LNA_HOLD_VALUE		=> HOLD_VALUE,
		LNA_REGLIST		=> REGLIST,
		LNA_ADDRESS		=> ADDRESS,
		LNA_CURRENT_REGLIST_REG => CURRENT_REGLIST
	);


--	Erzeugung eines Taktsignals
	gen_clk : process is
	begin
		if SIMULATION_RUNNING then
			SYS_CLK <= not SYS_CLK; 
			wait for (ARM_SYS_CLK_PERIOD/2.0);
		else
			wait;
		end if;
	end process gen_clk;


	tb : process is
		variable V_REGLIST	: std_logic_vector(15 downto 0) := (others => '0');
--	V_CTRL = LOAD_REGLIST, HOLD_VALUE
		variable V_CTRL		: std_logic_vector(1 downto 0) := "00";  
		variable RAND_8BIT	: std_logic_vector(7 downto 0);
		variable RAND_16BIT	: std_logic_vector(15 downto 0);
		constant NR_OF_TESTCASES: natural := 27;
		variable TESTCASE_NR	: natural := 1;
		type TESTCASES_TYPE is array(1 to NR_OF_TESTCASES) of std_logic_vector(15 downto 0);
		type ERRORS_IN_TESTCASES_TYPE is array(1 to NR_OF_TESTCASES) of natural;
		variable TESTCASES : TESTCASES_TYPE :=	(
				X"0001",
				X"0002",
				X"8001",
				X"FFFF",
				X"0000",
				X"0001",
				X"0007",
				X"000F",
				X"001F",
				X"003F",
				X"007F",
				X"00FF",
				X"01FF",
				X"03FF",
				X"07FF",
				X"0FFF",
				X"1FFF",
				X"3FFF",
				X"7FFF",
				X"FFFF",
				X"80FE",
				others => (others => '0'));
		variable TESTCASE_ADDRESS	: std_logic_vector(3 downto 0) := "0000";
		variable TESTCASE_INDEX		: natural range 0 to 15 := 0;
		variable TESTCASE_REGLIST	: std_logic_vector(15 downto 0) := (others => '0');
		variable ERRORS_IN_TESTCASE	: natural := 0;
		variable ERRORS_IN_TESTCASES	: ERRORS_IN_TESTCASES_TYPE := (others => 0);
		variable OVERALL_ERRORS		: natural := 0;
		variable REGLIST_ERRORS		: natural := 0;
		variable ADDRESS_ERRORS		: natural := 0;
		variable RESULT_ADDRESS		: std_logic_vector(3 downto 0) := "0000";
		variable POINTS			: natural := 0;
		variable TEMP			: natural := 0;

		procedure SET_SIGNALS is
		begin
			REGLIST <= V_REGLIST; LOAD_REGLIST <= V_CTRL(1); HOLD_VALUE <= V_CTRL(0);
		end procedure SET_SIGNALS;

--------------------------------------------------------------------------------
--	Zur Verkuerzung der ueblichen wait-statements, mit variabler Zahl von
--	Wartetakten und zusaetzlicher Verzoegerung, damit Signale nicht
--	gleichzeitig mit Taktflanken gesetzt werden.
--------------------------------------------------------------------------------
		procedure WAIT_CLK(NR_OF_CLKS : in natural) IS
		begin		
--	Realistische Setupzeit fuer die Steuersignale annehmen
			wait for ARM_SYS_CLK_PERIOD/16.0;
			SET_SIGNALS;
			if NR_OF_CLKS > 0 then
				for i in 0 to NR_OF_CLKS - 1 loop
					wait until SYS_CLK'event and SYS_CLK = '1';
				end loop;	
--				wait for 1 ps;
			end if;	
			wait for ARM_SYS_CLK_PERIOD/8.0;
		end procedure WAIT_CLK;

		procedure SYNC_HIGH_DELAY(THIS_DELAY: in real) is
		begin
			wait until SYS_CLK'event and SYS_CLK = '1';
			wait for (ARM_SYS_CLK_PERIOD*THIS_DELAY);
		end procedure SYNC_HIGH_DELAY;

--	Index des ersten gesetzten Bits in der Registerliste ermitteln		
		function GET_INDEX(THIS_LIST : in std_logic_vector(15 downto 0)) return natural is
			variable TEMP : natural range 0 to 15 := 0;
		begin
			TEMP := 0;
			for i in 0 to 15 loop
				if THIS_LIST(i) = '1' then
					TEMP := i;
					exit;
				end if;
			end loop;
			return TEMP;
		end function GET_INDEX;

		function GET_ADDRESS(THIS_INDEX : natural range 0 to 15) return std_logic_vector is
			variable TEMP : std_logic_vector(3 downto 0) := "0000";
		begin
			TEMP := std_logic_vector(to_unsigned(THIS_INDEX,4));
			return TEMP;
		end function GET_ADDRESS;

		procedure EVAL(THIS_TESTCASE : inout natural range 1 to NR_OF_TESTCASES; THIS_ERRORS : inout natural; THIS_ERRORS_ARRAY : inout ERRORS_IN_TESTCASES_TYPE) is
		begin
			if THIS_ERRORS > 0 then
				report "Fehler in Testcase " & integer'image(THIS_TESTCASE) severity error;
				report "Fehler in Testcase " & integer'image(THIS_TESTCASE) severity note;
				THIS_ERRORS_ARRAY(THIS_TESTCASE) := THIS_ERRORS;
			else
				report "Testcase " & integer'image(THIS_TESTCASE) & " korrekt" severity note;
				THIS_ERRORS_ARRAY(THIS_TESTCASE) := 0;
			end if;
			if THIS_TESTCASE < NR_OF_TESTCASES then THIS_TESTCASE := THIS_TESTCASE + 1; end if;
			THIS_ERRORS := 0;
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
		end procedure EVAL;

		procedure INC_ERRORS is
		begin
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end procedure INC_ERRORS;

	begin
		SIMULATION_RUNNING <= true;
		report "Start der Simulation...";
		INIT_SEED_ISIM(628);
		for k in 21 to NR_OF_TESTCASES-1 loop
--	Ermittlung zufaelliger Testwerte
			GET_RANDOM_SLV_ISIM(RAND_16BIT);
			TESTCASES(k) := RAND_16BIT;
		end loop;
--------------------------------------------------------------------------------
--	Letzter Testfall fuer einige Spezialtests, insbesondere das Halten von
--	Werten und das zwischenzeitliche Neuladen eines Datums.
--------------------------------------------------------------------------------
		TESTCASES(NR_OF_TESTCASES) := X"AACC";
		report SEPARATOR_LINE;
--	Wait 100 ns for global reset to finish 
		wait for 100 ns;
		SYNC_HIGH_DELAY(0.25);
		SYS_RST	<= '1';
		wait for ARM_SYS_CLK_PERIOD * 3.0;
		SYS_RST <= '0';
		SYNC_HIGH_DELAY(0.25);
		report "In den folgenden Testcases wird jeweils ein Testvektor geladen und gewartet, bis alle gesetzten Bits zurueckgesetzt wurden.";
		report "Nach jeder Taktflanke werden die Ausgaenge der Unit Under Test ueberprueft und mit Referenzwerten verglichen.";
		report "Zwischen Taktflanke und Wertevergleich liegt eine ausreichende Zeitspanne.";
		report SEPARATOR_LINE;
		for i in 1 to NR_OF_TESTCASES - 1 loop
			report "Testcase " & integer'image(TESTCASE_NR) & ": ";
			report "Testvektor : " & SLV_TO_STRING(TESTCASES(i));
--	Laden des neuen Testvektors
			V_CTRL		:= "10";
			V_REGLIST	:= TESTCASES(i);
			TESTCASE_REGLIST:= TESTCASES(i);
			WAIT_CLK(1);
--------------------------------------------------------------------------------
--	Normalbetrieb der UUT, also Deaktivieren des jeweils am hoechsten
--	priorisierten Bits mit jedem Takt.
--------------------------------------------------------------------------------
			V_CTRL		:= "00";
--			WAIT_CLK(1);
			EVERY_BIT_LOOP : for j in 0 to 15 loop
--	Vor dem Test aktueller Ergebniswerte etwas warten.
				WAIT_CLK(0);
				TESTCASE_INDEX	:= GET_INDEX(TESTCASE_REGLIST);
				TESTCASE_ADDRESS:= GET_ADDRESS(TESTCASE_INDEX);
				RESULT_ADDRESS := GET_ADDRESS(GET_INDEX(CURRENT_REGLIST));
				if TESTCASE_REGLIST /= CURRENT_REGLIST then
					report "Die vom Modul ausgegebene und die erwartete Registerliste stimmen nicht ueberein.";
					report "LNA_CURRENT_REGLIST: " & SLV_TO_STRING(CURRENT_REGLIST);
					report "Referenzliste: " & SLV_TO_STRING(TESTCASE_REGLIST);
					REGLIST_ERRORS := REGLIST_ERRORS + 1;
					INC_ERRORS;
				report SEPARATOR_LINE;
				end if;
				if TESTCASE_ADDRESS /= ADDRESS then
					report "Die ermittelte Adresse stimmt nicht mit der erwarteten Adresse ueberein.";
					report "Erwartet: " & integer'image(to_integer(unsigned(TESTCASE_ADDRESS)));
					report "Ermittelt: " & integer'image(to_integer(unsigned(ADDRESS)));
					report "LNA_CURRENT_REGLIST: " & SLV_TO_STRING(CURRENT_REGLIST);
					if(TESTCASE_REGLIST /= CURRENT_REGLIST and RESULT_ADDRESS = ADDRESS) then
						report "Die Fehlerhafte Adresse ist ein Folgefehler der fehlerhaften Registerliste.";
					else
						ADDRESS_ERRORS := ADDRESS_ERRORS + 1;
					end if;
					INC_ERRORS;
				report SEPARATOR_LINE;
				end if;	
				if TESTCASE_REGLIST /= X"0000" then
					TESTCASE_REGLIST(TESTCASE_INDEX) := '0';
				else
--	Beenden des aktuellen Testcase wenn alle Bits zurueckgesetzt sind.
					exit EVERY_BIT_LOOP;
				end if;
				WAIT_CLK(1);
			end loop EVERY_BIT_LOOP;
--	Auswerten des aktuellen Testfalls.			
			EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);
		end loop;

		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
--------------------------------------------------------------------------------
--	Im ersten Schritt Laden eines neuen Wertes, in dem Fall nur Einsen,
--	um unerwuenschte Aenderungen nachvollziehen zu koennen.
--------------------------------------------------------------------------------
		report "Im letzten Testcase wird zuerst ein reiner 1-Vektor geladen, dieser bei gleichzeitig gesetztem LOAD- und HOLD-Signal ueberschrieben, dann 8 Takte mit gesetztem HOLD-Signal gewartet und schliesslich 32 Takte normaler Operation simuliert.";
		report SEPARATOR_LINE;
		V_CTRL		:= "10";
		V_REGLIST	:= TESTCASES(4);
		TESTCASE_REGLIST:= TESTCASES(4);
--	In WAIT_CLK werden auch die Steuersignale neue gesetzt!
		WAIT_CLK(1);		
		if CURRENT_REGLIST /= X"FFFF" then
			report "Im ersten Schritt des Testcase sollte ein reiner 1-Vektor geladen werden, stattdessen:" severity error;
			report "Geladen: " & SLV_TO_STRING(CURRENT_REGLIST); 
			REGLIST_ERRORS := REGLIST_ERRORS + 1;
			INC_ERRORS;
		end if;

--	Gleichzeitiges Setzen von Halte- und Ladesignal, das Laden sollte priorisiert sein
		V_CTRL := "11";
		V_REGLIST := TESTCASES(NR_OF_TESTCASES);
		TESTCASE_REGLIST := TESTCASES(NR_OF_TESTCASES);
		WAIT_CLK(1);
		if TESTCASE_REGLIST /= CURRENT_REGLIST then
			report "Bei gleichzeitig gesetztem Lade- und Haltesignal wurde die neue Registerliste nicht geladen.";
			report "LNA_CURRENT_REGLIST: " & SLV_TO_STRING(CURRENT_REGLIST);
			report "Referenzliste: " & SLV_TO_STRING(TESTCASE_REGLIST);
			INC_ERRORS;
			REGLIST_ERRORS := REGLIST_ERRORS + 1;
			V_CTRL := "10";
			WAIT_CLK(1);
		end if;
--	Nur Haltesignal setzen
		V_CTRL := "01";
		for k in 0 to 7 loop
--	Halten des neuen Signals fuer einige Takte
			WAIT_CLK(1);
			if CURRENT_REGLIST /= TESTCASES(NR_OF_TESTCASES) then
				report "Bei gesetztem Haltesignal unerwartetes Datum an LNA_CURRENT_REGLIST.";
				report "LNA_CURRENT_REGLIST: " & SLV_TO_STRING(CURRENT_REGLIST);
				report "Erwartet: " & SLV_TO_STRING(TESTCASES(NR_OF_TESTCASES)) & " (der unveraenderte letzte Testvektor).";
				INC_ERRORS;
				REGLIST_ERRORS := REGLIST_ERRORS + 1;
			end if;
		end loop;
--	Normalbetrieb fuer einen laengeren Zeitraum
		V_CTRL := "00";
--------------------------------------------------------------------------------
--	Absichtlich zu gross angelegte Schleife, um auch das Verhalten
--	bei leerem Register zu testen.	
--------------------------------------------------------------------------------
		for i in 0 to 31 loop
			if i > 0 then WAIT_CLK(0); end if;
			TESTCASE_INDEX		:= GET_INDEX(TESTCASE_REGLIST);
			TESTCASE_ADDRESS	:= GET_ADDRESS(TESTCASE_INDEX);
			RESULT_ADDRESS		:= GET_ADDRESS(GET_INDEX(CURRENT_REGLIST));
			if TESTCASE_REGLIST /= CURRENT_REGLIST then
				report "Die vom Modul ausgegebene und die erwartete Registerliste stimmen nicht ueberein.";
				report "LNA_CURRENT_REGLIST: " & TAB_CHAR & SLV_TO_STRING(CURRENT_REGLIST);
				report "Referenzliste:       " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(TESTCASE_REGLIST);
				report "Schleifenindex: " & integer'image(i);
				REGLIST_ERRORS := REGLIST_ERRORS + 1;
				INC_ERRORS;
			report SEPARATOR_LINE;
			end if;
			if TESTCASE_ADDRESS /= ADDRESS then
				report "Die ermittelte Adresse stimmt nicht mit der erwarteten Adresse ueberein.";
				report "Erwartet: " & integer'image(to_integer(unsigned(TESTCASE_ADDRESS)));
				report "Ermittelt: " & integer'image(to_integer(unsigned(ADDRESS)));
				report "LNA_CURRENT_REGLIST: " & SLV_TO_STRING(CURRENT_REGLIST);
				if(TESTCASE_REGLIST /= CURRENT_REGLIST and RESULT_ADDRESS = ADDRESS) then
					report "Die Fehlerhafte Adresse ist ein Folgefehler der fehlerhaften Registerliste.";
				else
					ADDRESS_ERRORS := ADDRESS_ERRORS + 1;
				end if;
				INC_ERRORS;
				report SEPARATOR_LINE;
			end if;	
			if TESTCASE_REGLIST /= X"0000" then
				TESTCASE_REGLIST(TESTCASE_INDEX) := '0';
			end if;
			WAIT_CLK(1);
		end loop;

		EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);
--------------------------------------------------------------------------------
		for i in 1 to NR_OF_TESTCASES loop
			if ERRORS_IN_TESTCASES(i) = 0 then
				report "Testcase " & integer'image(i) & " : " & TAB_CHAR & "fehlerfrei.";
			else
				report "Testcase " & integer'image(i) & " : " & TAB_CHAR & integer'image(ERRORS_IN_TESTCASES(i)) & " Fehler.";
--				if POINTS > 0 then POINTS := POINTS - 1; end if;
			end if;
			OVERALL_ERRORS := OVERALL_ERRORS + ERRORS_IN_TESTCASES(i);
		end loop;
		report SEPARATOR_LINE;

		
		report "Fehler in der Registerliste insgesamt: " & integer'image(REGLIST_ERRORS);
		if(REGLIST_ERRORS > 2)then
			TEMP := 0;
		else
			TEMP := 2 - REGLIST_ERRORS;	
		end if;
		report "Punkte fuer die Fehlerfreiheit der Registerliste: " & integer'image(TEMP) &"/2";
		POINTS := TEMP;
		report SEPARATOR_LINE;
		report "Fehler in der Adressbestimmung abzueglich Folgefehlern insgesamt: " & integer'image(ADDRESS_ERRORS);
		if(ADDRESS_ERRORS > 2)then
			TEMP := 0;
		else
			TEMP := 2 - ADDRESS_ERRORS;	
		end if;
		report "Punkte fuer die Fehlerfreiheit der Adressbestimmung: " & integer'image(TEMP) & "/2";
		POINTS := POINTS + TEMP;

		report SEPARATOR_LINE;
		report "Gesamtpunktzahl: " & integer'image(POINTS) & "/4";
		report SEPARATOR_LINE;
		if OVERALL_ERRORS = 0 then
			report "Funktionstest bestanden." severity note;		
		else
			report "Funktionstest nicht bestanden." severity note;
			report "Funktionstest nicht bestanden." severity error;
		end if;
		report SEPARATOR_LINE;	
		report SEPARATOR_LINE;	
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait; -- will wait forever
	end process tb;

end architecture testbench;
