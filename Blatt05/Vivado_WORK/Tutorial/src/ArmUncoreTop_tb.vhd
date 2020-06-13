--------------------------------------------------------------------------------
--	Test Bench fuer Komponenten ausserhalb des Prozessorkerns
--------------------------------------------------------------------------------
--	Datum:		30.05.2010
--	Version:	0.96
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmConfiguration.all;
use work.TB_TOOLS.all;

entity ArmUncoreTop_TB is
	generic(	
--	Zahl der Fehler, die im Transcript maximal anzeigt werden, zur
--	Begrenzung der Simulationszeit eines fehlerhaften Designs
--	wird der Testfall anschliessend abgebrochen.
		NR_OF_ERRORS_TO_SHOW : natural := 30;
-------------------------------------------------------------------------------
--	Wartezeit nach einem Reset, bis erste Testdaten angelegt werden
--	Notwendig wegen des Einschwingens des Taktgenerators.
-------------------------------------------------------------------------------
		CLK_STABLE_DELAY : time := 20000 ns
	);
  
end ArmUncoreTop_tb;

architecture behave of ArmUncoreTop_tb is
	-- Kais Edit: Period is already defined in Configuration
	--constant ARM_EXT_CLK_PERIOD : time := 10 ns;

	component ArmUncoreTop
	port(
		EXT_RST : in std_logic;
		EXT_CLK : in std_logic;
		EXT_LDP : in std_logic;
		EXT_RXD : in std_logic;          
		EXT_TXD : out std_logic;
		EXT_LED : out std_logic_vector(7 downto 0)
		);
	end component ArmUncoreTop;	

	signal EXT_CLK : std_logic := '0';
	signal EXT_RST : std_logic := '0';
	signal EXT_LDP : std_logic := '0';
	signal EXT_TXD : std_logic;
	signal EXT_RXD : std_logic := '1';
	signal EXT_LED : std_logic_vector(7 downto 0);
	signal PROG_MEM_SIZE : integer := to_integer(ARM_PROG_MEM_SIZE);
	signal LAST_RECEIVED_BYTE : std_logic_vector(7 downto 0);

	SIGNAL SIMULATION_RUNNING : boolean := true;
--	signal RUNNING_SINGLE_TEST : boolean := false;
	
	type PROG_MEM_TYPE is array(0 to PROG_MEM_SIZE - 1) of std_logic_vector(7 downto 0);
	type ERRORS_IN_TESTCASES_TYPE is array(0 to 1) of natural;

begin
	uut: ArmUncoreTop port map(
		EXT_RST => EXT_RST,
		EXT_CLK => EXT_CLK,
		EXT_LDP => EXT_LDP,
		EXT_RXD => EXT_RXD,
		EXT_TXD => EXT_TXD,
		EXT_LED => EXT_LED
	);

	signals_valid : process is
	begin
		while SIMULATION_RUNNING loop
			wait on EXT_RXD, EXT_TXD;
			assert(EXT_RXD /= 'X') report "RXT unerwartet X, Abbruch der Simulation" severity failure;
			assert(EXT_TXD /= 'X') report "TXD unerwartet X, Abbruch der Simulation" severity failure;
		end loop;
		wait;	
	end process;

	gen_clk: process is
	begin
		if SIMULATION_RUNNING then
			EXT_CLK <= not EXT_CLK;
			wait for (ARM_EXT_CLK_PERIOD/2.0);
		else
			wait;
		end if;		
	end process gen_clk;

	tb : process is
		variable PROG_MEM			: PROG_MEM_TYPE	:= (others => X"00");
		variable BYTE_TO_SEND, BYTE_RECEIVED	: std_logic_vector(7 downto 0) := X"00";
--		variable TIMEOUT_TIME : time;
--		variable ERROR_IN_TESTCASE : boolean := false;
		variable ERRORS_IN_TESTCASE		: natural := 0;
		variable RS232_START_DELAY_TIME		: time;
		variable ERRORS_IN_TESTCASES		: ERRORS_IN_TESTCASES_TYPE := (others => 0);
	begin
--		TIMEOUT_TIME := RS232_DELAY_TIME * 8.0;
--		RS232_START_DELAY_TIME := (RS232_DELAY_TIME * 15)/10;
--		SIMULATION_RUNNING <= TRUE;
		report SEPARATOR_LINE;
		report "Simulationsbeginn." severity note;
		report "Speichergroesse gemaess ARM_PROG_MEM_SIZE: " & integer'image(PROG_MEM_SIZE);
		report SEPARATOR_LINE;
		INIT_SEED_ISIM(123);
		GET_RANDOM_SLV_ISIM(BYTE_TO_SEND);
--		Global Reset ablaufen lassen
		wait for ARM_EXT_CLK_PERIOD * 1.1;

		TESTCASE_LOOP : for TESTCASE_NR in 0 to 1 loop
			report SEPARATOR_LINE;
			report "Simulationslauf " & Integer'image(TESTCASE_NR) & " beginnt. Fortschrittsmeldungen erfolgen alle 256 Byte.";
			report SEPARATOR_LINE;
			ERRORS_IN_TESTCASE := 0;
			wait until EXT_CLK'event and EXT_CLK = '1';
			EXT_RST <= '0' after ARM_EXT_CLK_PERIOD* 0.25, '1' after ARM_EXT_CLK_PERIOD * 1.25, '0' after ARM_SYS_CLK_PERIOD * 4.25;
			EXT_LDP <= '0' after ARM_EXT_CLK_PERIOD* 0.24, '1' after ARM_EXT_CLK_PERIOD * 1.65;
--			EXT_LDP <= '0';
--			wait for 22 ns;
--			EXT_RST <= '1';
--			EXT_LDP <= '1';
--			Der Taktgenerator benoetigt mind. 3 Takte eines stabilen Resetsignals
--			wait for 130 ns;
--			EXT_RST <= '0';
--			wait for 20000 ns;
			wait for ARM_SYS_CLK_PERIOD * 5.0;
			wait for CLK_STABLE_DELAY;
			wait until EXT_CLK'event and EXT_CLK = '1';
			wait for ARM_EXT_CLK_PERIOD * 0.25;		

--	Bytes fuer den gesamten Speicher uebertragen.
			for i in 0 to PROG_MEM_SIZE -1 loop
				if i mod 256 = 0 then
					report "Senden: Byte " & integer'image(i) & "/" & integer'image(PROG_MEM_SIZE);
				end if;
--	Zufallswert erzeugen.
				GET_RANDOM_SLV_ISIM(BYTE_TO_SEND);
--	Startbit senden.
				EXT_RXD <= '0';
				wait for RS232_DELAY_TIME;
--	8 Bit pro Nutzbyte.
				for j in 0 to 7 loop
					EXT_RXD <= BYTE_TO_SEND(j);
					wait for RS232_DELAY_TIME;
				end loop;
--	Stoppbit senden, fuer langsame Empfaenger etwas zusaetzliche
--	Wartezeit.
				EXT_RXD <= '1';
				if i < PROG_MEM_SIZE -1 then
					wait for RS232_DELAY_TIME * 1.1;
				end if;	
--	Gesendetes Datum in Referenzspeicher uebernehmen.
				PROG_MEM(i) := BYTE_TO_SEND;
			end loop;		
			report SEPARATOR_LINE;
			for m in 0 to PROG_MEM_SIZE -1 loop
				if m mod 256 = 0 then
					report "Lesen: Byte " & integer'image(m) & "/" & integer'image(PROG_MEM_SIZE);
				end if;
--	Timeout entspricht ca. einer vollstaendigen RS232-Uebertragung				
				wait until (EXT_TXD'event and EXT_TXD = '0') for RS232_DELAY_TIME * 10.0;
--				wait until (EXT_TXD'event) for 170 us;
				if EXT_TXD = '1' then
					ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
					if ERRORS_IN_TESTCASE <= NR_OF_ERRORS_TO_SHOW then
						report "Timeout beim Warten auf das Byte von Adresse " & integer'image(m) & " aufgetreten, warte auf naechste Uebertragung.";
						next;
					else
						report "Timeout beim Warten auf das Byte von Adresse " & integer'image(m) & " aufgetreten, Testfall " & Integer'image(TESTCASE_NR) &" wird abgebrochen." severity error;
						ERRORS_IN_TESTCASES(TESTCASE_NR) := ERRORS_IN_TESTCASE;
						next TESTCASE_LOOP;
					end if;
				end if;
-------------------------------------------------------------------------------
--	Nach Detektion des Startbits Synchronisation auf die Mitte des ersten
--	Nutzbits.
-------------------------------------------------------------------------------
--				wait for 26041 ns;--(RS232_DELAY_TIME * 15.0)/10.0 ;--26041 ns;
				wait for RS232_DELAY_TIME * 1.5;--(RS232_DELAY_TIME * 15.0)/10.0 ;--26041 ns;
				for j in 0 to 7 loop
					BYTE_RECEIVED(j) := EXT_TXD;
					wait for RS232_DELAY_TIME;
				end loop;
				LAST_RECEIVED_BYTE <= BYTE_RECEIVED;
				if EXT_TXD /= '1' then
					ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
					report "EXT_TXD waehrend des erwarteten Stoppbits von Byte " & integer'image(m) & "nicht 1." severity note;
					if ERRORS_IN_TESTCASE >= NR_OF_ERRORS_TO_SHOW then
						report "Testfall " & integer'image(TESTCASE_NR) & " wird nach " & integer'image(ERRORS_IN_TESTCASE) & " Fehlern abgebrochen.";
						ERRORS_IN_TESTCASES(TESTCASE_NR) := ERRORS_IN_TESTCASE;
						next TESTCASE_LOOP;
					end if;
				end if;
				if PROG_MEM(m) /= BYTE_RECEIVED then
					ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
					report "Empfangenes Datum " & Integer'image(m) & " und Speicher-Referenzdatum stimmen nicht ueberein." severity note;
					report TAB_CHAR & "Erwartet: " & TAB_CHAR & SLV_TO_STRING(PROG_MEM(m));
					report TAB_CHAR & "Empfangen: " & TAB_CHAR & SLV_TO_STRING(BYTE_RECEIVED);
					if ERRORS_IN_TESTCASE >= NR_OF_ERRORS_TO_SHOW then
						report "Testfall " & integer'image(TESTCASE_NR) & " wird nach " & integer'image(ERRORS_IN_TESTCASE) & " Fehlern abgebrochen.";
						ERRORS_IN_TESTCASES(TESTCASE_NR) := ERRORS_IN_TESTCASE;
						next TESTCASE_LOOP;
					end if;
				end if;
			end loop;
--			if ERRORS_IN_TESTCASE > NR_OF_ERRORS_TO_SHOW then
--				report "Es sind mehr als " & integer'image(NR_OF_ERRORS_TO_SHOW) & " Fehler aufgetreten. Diese wurden gezaehlt aber nicht detailiert angezeigt";
--			end if;
			ERRORS_IN_TESTCASES(TESTCASE_NR) := ERRORS_IN_TESTCASE;
			report SEPARATOR_LINE;
--			exit;
		end loop TESTCASE_LOOP;


		report SEPARATOR_LINE;
		if (ERRORS_IN_TESTCASES(0) > 0) or (ERRORS_IN_TESTCASES(1) > 0) then
			report "Funktionstest nicht erfolgreich." severity note;
			report "Funktionstest nicht erfolgreich." severity error;
			report "Fehler in Durchgang 1: " & integer'image(ERRORS_IN_TESTCASES(0));
			report "Fehler in Durchgang 2: " & integer'image(ERRORS_IN_TESTCASES(1));
		else
			report "Funktionstest erfolgreich." severity note;
		end if;
		report SEPARATOR_LINE;

		SIMULATION_RUNNING <= false;
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait;
	end process tb;
end architecture behave;
