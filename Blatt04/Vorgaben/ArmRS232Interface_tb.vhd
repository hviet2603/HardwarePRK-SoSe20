--------------------------------------------------------------------------------
--	Testbench fuer die serielle Schnittstelle des HWPR-Prozessorsystems.
--------------------------------------------------------------------------------
--	Datum:		24.05.09
--	Version:	1.2
--------------------------------------------------------------------------------
--	Hinweis: Derzeit scheint in bestimmten Situationen ein
--	Kommunikationsproblem zwischen dem Hauptprozess und dem Timing-Test
--	zu bestehen. Wenn die Datenuebertragung zu schnell ist, bricht
--	der Timing-Test evtl. nicht frueh genug ab, sodass die Synchronisation
--	auf den naechsten Testfall nicht funktioniert.

-- DDIN wird auf Null gesetzt damit nur auf einer Kopie von DDIN gearbeitet
-- werden kann.
--------------------------------------------------------------------------------
  library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use std.textio.all;

  library work;
  use work.TB_TOOLS.all;
  use work.ArmConfiguration.all;


  entity ArmRS232Interface_tb is
  end ArmRS232Interface_tb;

  architecture behave of ArmRS232Interface_tb is

	component ArmRS232Interface
	port(
		SYS_CLK		: in std_logic;
		SYS_RST		: in std_logic;
		RS232_CS	: in std_logic;
		RS232_DnRW	: in std_logic;
		RS232_DMAS	: in std_logic_vector(1 downto 0);
		RS232_DA	: in std_logic_vector(3 downto 0);
		RS232_DDIN	: in std_logic_vector(31 downto 0);
		RS232_RXD	: in std_logic;          
		RS232_DDOUT	: out std_logic_vector(31 downto 0);
		RS232_DABORT	: out std_logic;
		RS232_TXD	: out std_logic;
		RS232_IRQ	: out std_logic
		);
	end component ArmRS232Interface;

	signal SYS_CLK		: std_logic := '0';
	signal SYS_RST		: std_logic := '0';

	signal SIMULATION_RUNNING	: boolean := FALSE;
	signal RS232_RXD, RS232_TXD	: std_logic;
	signal RS232_DDIN		: std_logic_vector(31 downto 0) := X"00000000";
	signal RS232_DDOUT		: std_logic_vector(31 downto 0);
	signal RS232_DnRW		: std_logic := '0';
	signal RS232_IRQ		: std_logic;
	signal DA			: std_logic_vector(31 downto 0) := X"00000000";
	signal TESTVALUE		: std_logic_vector(7 downto 0);
	signal TIMEOUT, TIMEOUT2	: boolean;
	signal CURRENT_TEST_VALUE	: std_logic_vector(7 downto 0);
	signal CURRENT_RECEIVED_VALUE	: std_logic_vector(8 downto 0);
	constant NR_OF_TESTCASES	: natural := 10;
	signal STARTING_SINGLE_TEST, ENDING_SINGLE_TEST : boolean := FALSE;


	type RS232_TESTDATA_TYPE is array(0 to NR_OF_TESTCASES - 1) of std_logic_vector(31 downto 0);
--	Testwerte (relevant ist jeweils das niederwertigste Byte) die durch den Transmitter gesendet werden sollen
	signal RS232_TESTDATA : RS232_TESTDATA_TYPE := (X"00000000",X"00000023",X"000000FF",X"000000AA",X"00000055",X"00000012",X"00000011",X"000000AB",X"00000081",X"0000007E");
	type RS232_TESTDATA_CHECK_TIMING_TYPE is array(0 to NR_OF_TESTCASES - 1) of boolean;
	type RS232_TESTDATA_CHECK_RESULTS_TYPE is array(0 to NR_OF_TESTCASES - 1) of boolean;
	signal RS232_TESTDATA_CHECK_TIMING : RS232_TESTDATA_CHECK_TIMING_TYPE := (others => true);
	signal RS232_TESTDATA_CHECK_RESULTS : RS232_TESTDATA_CHECK_RESULTS_TYPE := (others => false);
	signal RS232_TESTDATA_CHECK_TRANSITIONS : RS232_TESTDATA_CHECK_RESULTS_TYPE := (others => false);
	signal TESTCASE_NR : natural := 0;
	

begin
	SYS_CLK <= not SYS_CLK after ARM_SYS_CLK_PERIOD/2 when SIMULATION_RUNNING else '0';  
 
	uut : ArmRS232Interface port map(
		SYS_CLK 	=> SYS_CLK,
		SYS_RST 	=> SYS_RST,
		RS232_CS 	=> '1',
		RS232_DnRW 	=> RS232_DnRW ,
		RS232_DMAS 	=> "10",
		RS232_DA 	=> DA(3 downto 0),
		RS232_DDIN 	=> RS232_DDIN, 
		RS232_DDOUT 	=> RS232_DDOUT,
		RS232_DABORT 	=> open,
		RS232_RXD 	=> RS232_RXD,
		RS232_TXD 	=> RS232_TXD,
	       	RS232_IRQ	=> RS232_IRQ	
	);

--------------------------------------------------------------------------------
--	Der Prozess ueberprueft, ob der Transmitter sendebereit ist und schreibt
--	ggf. ein Datum in das Senderegister, woraufhin der Transmitter
--	selbststaendig senden sollte.
--------------------------------------------------------------------------------
     tb : process
	     variable RECEIVED			: boolean := false;
	     variable RS232_BLOCKED_COUNTER	: natural := 0;
	     variable RS232_BLOCKED		: boolean := false;
	     variable POINTS			: natural := 6;
	     variable DATA_ERROR		: boolean := false;
	     variable TIMING_ERROR		: boolean := false;
	     variable TRANSITIONS_ERROR		: boolean := false;
	    
	procedure SYNC_HIGH_DELAY(THIS_DELAY: in real) is
	begin
		wait until SYS_CLK'event and SYS_CLK = '1';
		wait for (ARM_SYS_CLK_PERIOD*THIS_DELAY);
	end procedure SYNC_HIGH_DELAY;
	     
begin
	SIMULATION_RUNNING <= TRUE;
	report SEPARATOR_LINE;
	report "Test der seriellen Schnittstelle (Transmitter).";
	report "Ueber den Datenbus werden Testdaten in das RS232_INTERFACE geschrieben, die Ausgaben auf der TXD-Leitung ausgewertet und bzgl. Korrektheit und Zeitanforderungen ueberprueft";
	report "Das Signal CURRENT_RECEIVED_VALUE, sichtbar in der ModelSim-Waveform, enthaelt die jeweils von der seriellen Leitung gelesenen Bits, bis zum Empfang des letzten Bits sind unbekannte Werte hier normal. Das letzte Empfangene Bit ist das Stoppbit";
	report "Zusaetzlich erfolgt die Ausgabe der gemessenen oder abgeschaetzten Dauer jeden Bits einer Uebertragung in der Form:";
	report "Startbit | Bit 0 | Bit 1 | ... Bit 6 | Bit 7 | Stoppbit |";
	report "Die Dauer des Stoppbits wird bis zum Ende des aktuellen Tests oder zum Auftreten der nachsten fallenden Flanke auf RS232_TXD gemessen";
 	report SEPARATOR_LINE;
	RS232_BLOCKED	:= false;
	TIMEOUT		<= false;
	POINTS		:= 6;
	RS232_RXD	<= '1';
	SYS_RST		<= '0', '1' after ARM_SYS_CLK_PERIOD *1.25, '0' after ARM_SYS_CLK_PERIOD * 4.25;
	wait for ARM_SYS_CLK_PERIOD * 5.25;

--	gleicher Vorgang fuer alle i Testdaten
	for i in RS232_TESTDATA'range loop
--	Lesezugriff auf das Statusregister
		STARTING_SINGLE_TEST	<= false;
		ENDING_SINGLE_TEST	<= false;
		TIMEOUT			<= false;
		TIMEOUT2		<= false;
		RS232_DnRW		<= '0';
		DA			<= RS232_STAT_REG_ADDR;
--------------------------------------------------------------------------------
--	Dem Transmitter wird mehr als eine komplette Byteuebertragung Zeit
--	gegeben um wieder Sendebereitschaft zu signalisieren.
--------------------------------------------------------------------------------
		SYNC_HIGH_DELAY(0.25);
		for j in 0 to 12 loop
--	Test auf Sendebereitschaft
			if RS232_DDOUT(4) = '0' then
				exit;
			else
				RS232_BLOCKED_COUNTER := j;
			end if;
			wait for RS232_DELAY_TIME;
		end loop;
-- danach evtl. warten...		
		ENDING_SINGLE_TEST <= true, false after ARM_SYS_CLK_PERIOD*2;
		wait for ARM_SYS_CLK_PERIOD * 2.1;
		if RS232_BLOCKED_COUNTER = 12 then
			report "RS232-Interface zeigt dauerhaft Blockade durch laufende Uebertragung an, Testdatum " & integer'image(i) & " wird uebersprungen." severity error;
			RS232_BLOCKED_COUNTER := 0;
			RS232_BLOCKED := true;
			next; --naechstes i
		end if;	
		
		RS232_BLOCKED_COUNTER	:= 0;
		TESTCASE_NR		<= i;
--	Schreibzugriff auf das RS232-Senderegister
		STARTING_SINGLE_TEST	<= TRUE;
		SYNC_HIGH_DELAY(0.25);
		STARTING_SINGLE_TEST	<= FALSE; ENDING_SINGLE_TEST <= FALSE;
		RS232_DnRW		<= '1';
		-- Register/Eingang auf Null setzen, damit nur auf Kopie gearbeitet werden kann
		RS232_DDIN		<= RS232_TESTDATA(i), x"00000000" after ARM_SYS_CLK_PERIOD*2;
		CURRENT_TEST_VALUE	<= RS232_TESTDATA(i)(7 downto 0);
		DA			<= RS232_TRM_REG_ADDR;
		SYNC_HIGH_DELAY(0.25);
		RS232_DnRW		<= '0';

--------------------------------------------------------------------------------
--	Der Sender sollte wenige Takte nach dem Schreiben des Nutzdatums in das
--	Senderegister ein Startbit anzeigen. Als Timeout werde hier 10
--	Prozessortakte verwendet. TIMEOUT dient zur Kommunikation mit den
--	Prozessen, die die Korrektheit der Uebertragung testen. Es wird immer
--	gesetzt, erzeugt aber keine Fehler, wenn bis zu diesem Zeitpunkt 
--	das Startbit auf der seriellen Leitung erscheint.
--------------------------------------------------------------------------------
		wait for ARM_SYS_CLK_PERIOD * 10;
		TIMEOUT			<= TRUE;
		SYNC_HIGH_DELAY(0.25);
	end loop;
--	Auf Ende der letzten Uebertragung warten und Ergebnisse auswerten.
		wait for RS232_DELAY_TIME * 12;
		TIMEOUT			<= false;
		ENDING_SINGLE_TEST	<= true;
		wait for 1 ns;
		DATA_ERROR		:= false;
		TIMING_ERROR		:= false;
		TRANSITIONS_ERROR	:= false;
		report SEPARATOR_LINE;
		report "Auswertung der Simulationsergebnisse:";
		for i in RS232_TESTDATA'range loop
			report "Datensatz " & integer'image(i) & ":";
			if RS232_TESTDATA_CHECK_RESULTS(i) = TRUE then
				report " . " & TAB_CHAR & "Datum korrekt";
			else
				report " . " & TAB_CHAR & "Datum nicht korrekt";
				DATA_ERROR := TRUE;
			end if;
			if RS232_TESTDATA_CHECK_TIMING(i) = TRUE then
				report " . " & TAB_CHAR & "Timing korrekt";
			else
				report " . " & TAB_CHAR & "Timing nicht korrekt";
				TIMING_ERROR := TRUE;
			end if;
			if RS232_TESTDATA_CHECK_TRANSITIONS(i) = TRUE then
				report " . " & TAB_CHAR & "Transitionen korrekt";
			else
				report " . " & TAB_CHAR & "Transitionen nicht korrekt";
				TRANSITIONS_ERROR := TRUE;
			end if;
		end loop;

		report SEPARATOR_LINE;
		if RS232_BLOCKED then
			report "Blockade der Seriellen Schnittstelle aufgetreten: -1 Punkt";
			POINTS := POINTS - 1;
		else
			report "Keine Blockade der Seriellen Schnittstelle aufgetreten: 1 Punkt";
		end if;
		if DATA_ERROR then
			report "Datenfehler aufgetreten: -2 Punkte";
			POINTS := POINTS - 2;
		else
			report "Keine Datenfehler aufgetreten: 2 Punkte";
		end if;
		if TIMING_ERROR then
			report "Timingfehler aufgetreten: -2 Punkte";
			POINTS := POINTS - 2;
		else
			report "Keine Timingfehler aufgetreten: 2 Punkte";
		end if;
		if TRANSITIONS_ERROR then
			report "Transitionsfehler aufgetreten: -1 Punkt";
			POINTS := POINTS - 1;
		else
			report "Keine Transitionsfehler aufgetreten: 1 Punkte";
		end if;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Gesamtpunktzahl: " & integer'image(POINTS) & "/6";
		if POINTS = 6 then
			report "Funktionspruefung bestanden" severity note;
		else
			report "Funktionspruefung nicht bestanden" severity note;
			report "Funktionspruefung nicht bestanden" severity error;
		end if;
		report SEPARATOR_LINE;
		SIMULATION_RUNNING <= FALSE;
		report "Simulation beendet.";
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" SEVERITY FAILURE; 
		wait;

     end process tb;

	CHECK_TRANSMISSION_DATA : process 
		variable RCV_DATA : std_logic_vector(8 downto 0);
	begin
		RS232_TESTDATA_CHECK_RESULTS <= (others => false);
		wait until SYS_RST'event and SYS_RST = '0';

		o_loop : for i in RS232_TESTDATA'range loop			
			CURRENT_RECEIVED_VALUE	<= (others => 'U');
			CURRENT_TEST_VALUE	<= RS232_TESTDATA(i)(7 downto 0);
			wait until STARTING_SINGLE_TEST;
--	Uebersprungene Testfaelle werden nicht ausgewertet			
			if i < TESTCASE_NR then 
--				report "i: " & integer'image(i);
--				report "test: " & integer'image(TESTCASE_NR);
				next o_loop;
			end if;
			report SEPARATOR_LINE;
			report "Testdatensatz: " & integer'image(i);
--------------------------------------------------------------------------------
--	Die Abfragen auf ENDING_SINGLE_TEST sollen sicherstellen, dass der
--	Prozess bei einer fehlerhaften Uebertragung nicht blockiert und fuer den
--	naechsten Testfall wieder bereit ist.	
--------------------------------------------------------------------------------
			wait until ((RS232_TXD'event and RS232_TXD = '0') or TIMEOUT or ENDING_SINGLE_TEST);
			if not TIMEOUT then
--	Bis Ende des prognostizierten Startbits warten
				wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME;
				if ENDING_SINGLE_TEST then exit; end if;
				for j in 0 to 8 loop
--	Halbe Bitperiode warten und Nutzbit entgegennehmen
					if not ENDING_SINGLE_TEST then
						wait until ENDING_SINGLE_TEST for (RS232_DELAY_TIME/2);
					end if;	
					RCV_DATA(j) := RS232_TXD;
					CURRENT_RECEIVED_VALUE <= RS232_TXD & CURRENT_RECEIVED_VALUE(8 downto 1);
					if ENDING_SINGLE_TEST then exit; end if;
					
--	Bis zum Ende des Nutzbits warten
					if not ENDING_SINGLE_TEST then
						wait until ENDING_SINGLE_TEST=true for RS232_DELAY_TIME/2;
					end if;	
					if ENDING_SINGLE_TEST=true then exit; end if;
--					if j < 8 then
--						wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME/2;
--					else
--						wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME/2;
--					end if;	
				end loop;
				if RCV_DATA(7 downto 0) = RS232_TESTDATA(TESTCASE_NR)(7 downto 0) then
					RS232_TESTDATA_CHECK_RESULTS(TESTCASE_NR) <= TRUE;
				else
					RS232_TESTDATA_CHECK_RESULTS(TESTCASE_NR) <= FALSE;
					report "Empfangenes Datum enspricht nicht dem Testwert." severity error;
					report "Empfangenes Datum enspricht nicht dem Testwert." severity note;
					report TAB_CHAR & "Empfangen: " & TAB_CHAR & SLV_TO_STRING(RCV_DATA(7 downto 0));
					report TAB_CHAR & "Testwert: " & TAB_CHAR & SLV_TO_STRING(RS232_TESTDATA(TESTCASE_NR)(7 downto 0));
				end if;
			else
				report "Timeout aufgetreten, RS232-Transmitter hat auch 10 Takte nach Schreibzugriff auf Transmissionsregister kein Startbit gesendet. Testdatensatz: " & integer'image(TESTCASE_NR) severity error;
			end if;
--	Warten bis die Hauptsteuerung den Testfall fuer abgeschlossen erklaert.
--	Die Formulierung des wait ist paradox, funktioniert aus 
--	unerklaerlichen Gruenden aber nur so.		
			if not ENDING_SINGLE_TEST then			
				wait until ENDING_SINGLE_TEST=true;
			end if;	
		end loop;
		wait;
	end process CHECK_TRANSMISSION_DATA;


--------------------------------------------------------------------------------
--	Test der Zeichen-Timings. Jedes Zeichen muss fuer eine definierte
--	Dauer auf der Leitung angezeigt werden. Der Test erfolgt, indem die 
--	Sendeleitung abgetastet und der Zeitpunkt der letzten Signaltransition
--	ermittelt wird. Eine zu grosse Abweichung des Transitionszeitpunkts
--	vom Erwartungswert deutet auf eine nicht korrekte Zeichendauer hin.
--	Der Prozess richtet den Test an allen auftretenden Signaltransitionen 
--	aus. Je weniger Transitionen auftreten, desto staerker akkumulieren sich
--	leichte Abweichungen. Theoretisch koennen daher einzelne Uebertragungen
--	Timings innerhalb der vorgesehenen Toleranzen (ca. 10% zu Beginn und
--	Ende eines Bits) aufweisen und andere scheitern.
--------------------------------------------------------------------------------
	check_transmission_timing : process is
		variable START_TIME, END_TIME, CURRENT_TIME, FRAME_TIME, BIT_TIME : time;
		type BIT_TIMING_ARRAY_TYPE is array(0 to 9) of time;
		variable BIT_TIMING_ARRAY : BIT_TIMING_ARRAY_TYPE := (others => 0 ns);
		variable TEST_VALUE : std_logic_vector(0 to 9); --entspricht CURRENT_TEST_VALUE
		variable EQUAL_BITS_NR : natural range 0 to 9 := 0;
		variable ZEILE: line;
		
	begin
		for i in RS232_TESTDATA'range loop
			wait until STARTING_SINGLE_TEST;
--	Uebersprungene Testfaelle ignorieren			
			if i < TESTCASE_NR then next; end if;
			TEST_VALUE(0) := '0'; TEST_VALUE(9) := '1';
			RS232_TESTDATA_CHECK_TIMING(i)	<= TRUE;
			for k in 1 to 8 loop
				TEST_VALUE(k) := RS232_TESTDATA(i)(k - 1);
			end loop;
			BIT_TIMING_ARRAY	:= (others => 0 ns);
--	Auf Startbit oder Timeout warten
			if not ENDING_SINGLE_TEST then			
				wait until  (RS232_TXD'event and RS232_TXD = '0') or TIMEOUT or ENDING_SINGLE_TEST;
			end if;	
			START_TIME	:= NOW;
			EQUAL_BITS_NR	:= 1;
			if TEST_VALUE(1)= '0' then
--	Erstes Nutzbit ist 0, damit mind. zwei identische Bits hintereinander				
				EQUAL_BITS_NR := 2;
--------------------------------------------------------------------------------
--	Zur vermuteten Mitte des Startbits springen und sicherstellen, dass es
--	bisher (mit etwas Toleranz) seit einer halben Zeichenzeit stabil war.
--------------------------------------------------------------------------------
				if not ENDING_SINGLE_TEST then			
					wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME*0.5;
				end if;	
				if RS232_TXD'last_event < (RS232_DELAY_TIME * 0.4) then
					report "Startbit nicht stabil." ;
					RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
				end if;
				if not ENDING_SINGLE_TEST then			
					wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.4;
				end if;
				if RS232_TXD'last_event < (RS232_DELAY_TIME * 0.4) then
					report "Startbit nicht stabil." ;
					RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
				end if;
--	Bis zum vermuteten Ende des Startbits warten (0.5 + 0.4 + 0.1)
				if not ENDING_SINGLE_TEST then			
					wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.1;
				end if;	
			else
				if not ENDING_SINGLE_TEST then			
					wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.9;
				end if;
				if not RS232_TXD'stable(RS232_DELAY_TIME * 0.8) then
					report "Startbit nicht stabil." ;
					RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
				end if;
--	Erstes Nutzbit ist 1 -> Aufsynchronisieren auf steigende Flanke			
				if not ENDING_SINGLE_TEST then			
					wait until RS232_TXD'event or ENDING_SINGLE_TEST;
				end if;
				END_TIME		:= NOW;
				BIT_TIME		:= END_TIME - START_TIME;
				BIT_TIMING_ARRAY(0)	:= BIT_TIME;
				START_TIME		:= NOW;
			end if;
			inner_loop: for j in 1 to 8 loop
				if ((j < 8) and (TEST_VALUE(j) = TEST_VALUE(j+1)))then
--	Mehrere identische Bits hintereinander					
					EQUAL_BITS_NR := EQUAL_BITS_NR + 1;
--------------------------------------------------------------------------------
--	Vermutetes Timing fuer aktuelles Bit testen, Synchronisation
--	zu tatsaechlichem Bittiming mangels Flanke unmoeglich.
--------------------------------------------------------------------------------
					if not ENDING_SINGLE_TEST then			
						wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.5;
					end if;	
					if RS232_TXD'last_event < (RS232_DELAY_TIME * 0.4) then
						report "Bit " & integer'image(j) & " nicht stabil (Bitmitte)" ;
						RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
					end if;
					if not ENDING_SINGLE_TEST then			
						wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.4;
					end if;	
					if RS232_TXD'last_event < (RS232_DELAY_TIME * 0.4) then
						report "Bit " & integer'image(j) & " nicht stabil" ;
						RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
					end if;
					if not ENDING_SINGLE_TEST then			
						wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.1;
					end if;
--	Beende aktuellen Schleifendurchlauf und berechne BIT_TIME nicht neu					
					next inner_loop;
				elsif (j < 8) and (TEST_VALUE(j) /= TEST_VALUE(j +1)) then
--------------------------------------------------------------------------------
--	Aktuelles und naechstes Bit unterschiedlich -> Testen des Timings und 
--	dann aufsynchronisieren auf Flanke.					
--------------------------------------------------------------------------------
					if not ENDING_SINGLE_TEST then			
						wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.9;
					end if;	
					if not RS232_TXD'stable(RS232_DELAY_TIME * 0.8) then
						report "Bit " & integer'image(j) & " nicht stabil" ;
						RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
					end if;
					wait until RS232_TXD'event or ENDING_SINGLE_TEST;
				else
--	letztes Nutzbit ist 1 und damit nicht vom Stoppbit unterscheidbar					
					if TEST_VALUE(8) = '1' then
						if not ENDING_SINGLE_TEST then			
							wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME/2.0;
						end if;	
						if RS232_TXD'last_event < (RS232_DELAY_TIME * 0.4) then
							report "Bit " & integer'image(j) & " nicht stabil (Bitmitte)" ;
							RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
						end if;
						if not ENDING_SINGLE_TEST then			
							wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.4;
						end if;	
						if RS232_TXD'last_event < (RS232_DELAY_TIME * 0.4) then
							report "Bit " & integer'image(j) & " nicht stabil" ;
							RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
						end if;
						if not ENDING_SINGLE_TEST then			
							wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.1;
						end if;	
					else
						if not ENDING_SINGLE_TEST then			
							wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.9;
						end if;	
						if not RS232_TXD'stable(RS232_DELAY_TIME * 0.8) then
							report "Bit " & integer'image(j) & " nicht stabil" ;
							RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
						end if;
						if not ENDING_SINGLE_TEST then			
							wait until RS232_TXD'event or ENDING_SINGLE_TEST;
						end if;	
					end if;
					
				end if;				
				END_TIME := NOW;
				BIT_TIME := END_TIME - START_TIME;
--	Bei mehreren gleichen Bits hintereinander -> Zeit durch Bits dividieren				
				for l in j - (EQUAL_BITS_NR -1 ) to j loop
					BIT_TIMING_ARRAY(l) := BIT_TIME/EQUAL_BITS_NR;					
				end loop;
				EQUAL_BITS_NR	:= 1;
				START_TIME	:= NOW;
			end loop inner_loop;
--	Stoppbit testen
			START_TIME := NOW;
			if not ENDING_SINGLE_TEST then			
				wait until ENDING_SINGLE_TEST for RS232_DELAY_TIME * 0.9;
			end if;	
			if not RS232_TXD'stable(RS232_DELAY_TIME * 0.9) then
				report "Stoppbit nicht stabil" ;
				RS232_TESTDATA_CHECK_TIMING(i) <= false;
			end if;
			if not ENDING_SINGLE_TEST then			
				wait until ENDING_SINGLE_TEST;
			end if;	
--	Stabilitaet der Leitung nach Uebertragungsende testen
			END_TIME := NOW;
			if RS232_TXD'last_event < (END_TIME - START_TIME)then
				report "TXD nach Ende der Uebertragung nicht stabil 0" ;
				RS232_TESTDATA_CHECK_TIMING(i) <= false;
			end if;
			BIT_TIME := END_TIME - START_TIME;
			BIT_TIMING_ARRAY(9) := BIT_TIME;			
			for k in 0 to 9 loop	
--	time'image zeigt ps an, zur besseren Lesbarket etwas umformatieren				
				STD.TEXTIO.write(ZEILE, time'image((BIT_TIMING_ARRAY(k)/1000)) & "*10^3 | ");
			end loop;
			report ZEILE.all;
			Deallocate(ZEILE);
			if (BIT_TIMING_ARRAY(0) < (RS232_DELAY_TIME * 0.9)) or (BIT_TIMING_ARRAY(0) > (RS232_DELAY_TIME * 1.1)) then
				report "Zeitanforderungen fuer das Startbit nicht erfuellt: erwartete Dauer: 17361 ns, ermittelt: " & time'image(BIT_TIMING_ARRAY(0)/1000) & "*10^3 | ";
				RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
			end if;

			for j in 1 to 8 loop
				if (BIT_TIMING_ARRAY(j) < (RS232_DELAY_TIME * 0.9)) OR (BIT_TIMING_ARRAY(j) > (RS232_DELAY_TIME * 1.1)) then
					report "Zeitanforderungen fuer Bit " & integer'image(j) & " nicht erfuellt: erwartete Dauer: 17361 ns, ermittelt: " & time'image(BIT_TIMING_ARRAY(j)/1000) & "*10^3 | ";
				RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
				end if;
			end loop;
			if (BIT_TIMING_ARRAY(9) < (RS232_DELAY_TIME * 0.9)) then
				report "Zeitanforderungen fuer das Stoppbit nicht erfuellt: erwartete Dauer: 17361 ns, ermittelt: " & time'image(BIT_TIMING_ARRAY(9)/1000) & "*10^3 | ";
				RS232_TESTDATA_CHECK_TIMING(i) <= FALSE;
			end if;
		end loop;
	end process check_transmission_timing;

--------------------------------------------------------------------------------
--	Vergleich der Anzahl der bei einem Einzeltest aufgetretenen Signal-
--	transitionen mit einem aus dem Testdatum abgeleiteten Erwartungswert.
--	Eine zu grosse Zahl von Transitionen tritt auf, wenn die Sendeleitung
--	vom Transmitter beim Senden eines Zeichens nicht konstant gehalten 
--	wird (nicht registrierter Ausgang eines Mealy-Automaten!).
--	Dennoch kann das in CHECK_TRANSMISSION_DATA ermittelte Datum korrekt
--	sein, weil die Abtastung nur zu diskreten Zeitpunkten stattfindet.
--	check_transmission_timing reagiert zwar auch auf Flanken, wuerde
--	aber z.B. Transitionen in den Toleranzperioden nicht erkennen.
--------------------------------------------------------------------------------
	check_transitions : process is
		variable NR_OF_TRANSITIONS_IN_TESTCASE	: natural := 0;
		variable NR_OF_TRANSITIONS_ON_TXD	: natural := 0;
	begin
		wait until SIMULATION_RUNNING;
		RS232_TESTDATA_CHECK_TRANSITIONS <= (others => false);
		while SIMULATION_RUNNING loop
--			NR_OF_TRANSITIONS_IN_TESTCASE	:= 0;
--			NR_OF_TRANSITIONS_ON_TXD	:= 0;
			wait until STARTING_SINGLE_TEST or (not SIMULATION_RUNNING);
			NR_OF_TRANSITIONS_IN_TESTCASE	:= 1; --Startbit-Flanke
			NR_OF_TRANSITIONS_ON_TXD	:= 0;
--	Flanken im Testdatum zaehlen			
			for i in 0 to 6 loop
				if RS232_TESTDATA(TESTCASE_NR)(i) /= RS232_TESTDATA(TESTCASE_NR)(i + 1)then
					NR_OF_TRANSITIONS_IN_TESTCASE := NR_OF_TRANSITIONS_IN_TESTCASE + 1;
				end if;
			end loop;
			if RS232_TESTDATA(TESTCASE_NR)(0) = '1' then
				NR_OF_TRANSITIONS_IN_TESTCASE := NR_OF_TRANSITIONS_IN_TESTCASE + 1;
			end if;	
			if RS232_TESTDATA(TESTCASE_NR)(7) = '0' then
				NR_OF_TRANSITIONS_IN_TESTCASE := NR_OF_TRANSITIONS_IN_TESTCASE + 1;
			end if;	
--	Flanken im uebertragenen Datum zaehlen			
				while SIMULATION_RUNNING and (not ENDING_SINGLE_TEST) loop
					wait until RS232_TXD'event or ENDING_SINGLE_TEST;
					if not ENDING_SINGLE_TEST then
						NR_OF_TRANSITIONS_ON_TXD := NR_OF_TRANSITIONS_ON_TXD + 1;
					end if;	
				end loop;
				if NR_OF_TRANSITIONS_ON_TXD /= NR_OF_TRANSITIONS_IN_TESTCASE then
					report "Fehlerhafte Anzahl von Transitionen." severity note;
					report "Fehlerhafte Anzahl von Transitionen." severity error;
					RS232_TESTDATA_CHECK_TRANSITIONS(TESTCASE_NR) <= false;
				else
					RS232_TESTDATA_CHECK_TRANSITIONS(TESTCASE_NR) <= true;
				end if;
			report "Transitionen: " & integer'image(NR_OF_TRANSITIONS_ON_TXD) & "; Erwartet: " & integer'image(NR_OF_TRANSITIONS_IN_TESTCASE);
		end loop;
		wait;
	end process check_transitions;
  end architecture behave;

