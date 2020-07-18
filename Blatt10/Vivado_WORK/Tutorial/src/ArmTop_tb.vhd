--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--	Testbench fuer das vollstaendige ARM-SoC
--------------------------------------------------------------------------------
--	Datum:		06.07.2010
--	Version:	0.5
--------------------------------------------------------------------------------
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library work;
use work.ArmConfiguration.all;
use work.ArmTypes.all;
use work.TB_Tools.all;
use work.ArmFilePaths.all;
use work.ArmGlobalProbes.all;

entity ArmTop_tb is
end entity ArmTop_tb;


architecture testbench of ArmTop_tb is 

	constant RUNTIME_AFTER_INIT : time := ARM_SYS_CLK_PERIOD * 300000;
	constant BYTES_TO_LOG : natural := 4096;
	signal INIT_COMPLETE : boolean := false;
	shared variable GET_CHARS_FINISHED : boolean := false;
	signal GET_CHARS_FINISHED_SIGNAL : boolean := false;
	constant TEST_FILE_PATH : STRING := TESTDATA_FOLDER_PATH & "ARM_TEST_MAIN.c.bin";

	signal SVC_SP : std_logic_vector(31 downto 0);
	signal SVC_LR : std_logic_vector(31 downto 0);
	signal USR_SP : std_logic_vector(31 downto 0);
	signal USR_LR : std_logic_vector(31 downto 0);
	signal ABT_SP : std_logic_vector(31 downto 0);
	signal ABT_LR : std_logic_vector(31 downto 0);
	signal IRQ_SP : std_logic_vector(31 downto 0);
	signal IRQ_LR : std_logic_vector(31 downto 0);
	signal USR_PC : std_logic_vector(31 downto 0);
	signal USR_R0 : std_logic_vector(31 downto 0);
	signal USR_R1 : std_logic_vector(31 downto 0);
	signal USR_R2 : std_logic_vector(31 downto 0);
	signal USR_R3 : std_logic_vector(31 downto 0);
	signal USR_R4 : std_logic_vector(31 downto 0);

	signal I_ADDRESS : std_logic_vector(31 downto 0);
	signal D_ADDRESS : std_logic_vector(31 downto 0);
	signal GEN_INT : integer;

--	file TEST_FILE : TEXT open READ_MODE is TEST_FILE_PATH;

	-- Component Declaration for the Unit Under Test (UUT)
	component ArmTop
	port(
		EXT_RST : in std_logic;
		EXT_CLK : in std_logic;
		EXT_RXD : in std_logic;          
		EXT_LDP : in std_logic;
		EXT_TXD : out std_logic;
		EXT_LED : out std_logic_vector(7 downto 0)
		);
	end component;

	--Inputs
	signal EXT_RST :  std_logic := '0';
	signal EXT_CLK :  std_logic := '0';
	signal EXT_RXD :  std_logic := '1';
	signal EXT_LDP :  std_logic := '1';
	signal EXT_IRQ :  std_logic := '0';
	signal EXT_FIQ :  std_logic := '0';

	--Outputs
	signal EXT_TXD :  std_logic;
	signal EXT_LED : std_logic_vector(7 downto 0);
	signal EXT_LCD_DATA : std_logic_vector(3 downto 0);
	signal EXT_LCD_E :  std_logic;
	signal EXT_LCD_RS :  std_logic;
	signal EXT_LCD_RW :  std_logic;

	--INOutputs
	signal EXT_GIO : std_logic_vector(7 downto 0);

	signal TRANSMIT_BYTE : natural := 0;

	signal SIMULATION_RUNNING : boolean := TRUE;

	procedure FILTER_CHAR(THIS_CHAR : inout integer range 0 to 255) is
	begin
		case THIS_CHAR is
			when 0 =>
				THIS_CHAR := 92; --slash statt null fuer die spaetere Ausgabe mit write
			when others =>
				null;
		end case;		
	end procedure FILTER_CHAR;






--	Prozedur fuer das Empfangen eines Bytes ueber die serielle Schnittstelle, blockierend waehrender Laufzeit der Simulation
	procedure GET_CHAR(THIS_CHAR_OUT : out std_logic_vector(7 downto 0))is
		variable THIS_CHAR_INT : integer range 0 to 255;
		variable THIS_CHAR : std_logic_vector(7 downto 0);
	begin
		THIS_CHAR := X"00";
		THIS_CHAR_OUT := X"00";
		

		wait until (EXT_TXD'event and EXT_TXD = '0') or not SIMULATION_RUNNING;
		if SIMULATION_RUNNING then
			wait for RS232_DELAY_TIME * 1.5;
			THIS_CHAR(0) := EXT_TXD;
			for i in 1 to 7 loop
				wait until not SIMULATION_RUNNING for RS232_DELAY_TIME;
				THIS_CHAR(i) := EXT_TXD;
			end loop;			
			wait until not SIMULATION_RUNNING for RS232_DELAY_TIME;
			if (EXT_TXD /= '1') and SIMULATION_RUNNING then
				report "Warnung: EXT_TXD /= '1' an erwarteter Stoppbitposition";
			end if;

			THIS_CHAR_INT := to_integer(unsigned(THIS_CHAR));
			FILTER_CHAR(THIS_CHAR_INT);
			THIS_CHAR_OUT := std_logic_vector(to_unsigned(THIS_CHAR_INT,8));
			
		else 
			null;	
		end if;
	end procedure GET_CHAR;

	signal IMODE_NR, DMODE_NR : integer range 0 to 31;	
	signal INIT_RXD, TEST_RXD : std_logic := '1';

	type RS232_TESTDATA_TYPE is array(0 to 15) of std_logic_vector(7 downto 0);

	SIGNAL RS232_TESTDATA : RS232_TESTDATA_TYPE := (X"74",X"23",X"FF",X"AA",X"55",X"12",X"11",X"AB",X"81",X"7E", others => X"00");
	shared variable RS232_NR_SEND : integer := 0;
	
	

begin
-- 	Prozess zum Anhalten der Test Bench wenn eine definierte Bedingung eintritt, z.B.
-- 	wenn eine bestimmte Instruktionsadresse erreicht wurde
	STOPP_ON_CONDITION : process is
	begin
		wait for 1 ns;
		wait until SIMULATION_RUNNING and INIT_COMPLETE;
		while SIMULATION_RUNNING loop
			if false then --if I_ADDRESS = X"00000190" and USE_STOPP_CONDITION then
				report "Bedingung erkannt" severity failure;
			end if;
			wait until I_ADDRESS'event or (not SIMULATION_RUNNING); 	
		end loop;
		wait;
	end process STOPP_ON_CONDITION;

	EXT_RXD <= INIT_RXD and TEST_RXD;

	TESTSIGNALS : process(AGP_I_ADDRESS,AGP_D_ADDRESS,AGP_R13_SVC,AGP_R13,AGP_R14,AGP_R14_IRQ,AGP_R13_IRQ,AGP_R15,AGP_R13_ABT,AGP_R14_ABT) is
	begin
		I_ADDRESS <= AGP_I_ADDRESS;
		D_ADDRESS <= AGP_D_ADDRESS;
		SVC_SP <= AGP_R13_SVC;
		SVC_LR <= AGP_R14_SVC;
		USR_SP <= AGP_R13;
		USR_LR <= AGP_R14;
		ABT_SP <= AGP_R13_ABT;
		ABT_LR <= AGP_R14_ABT;
		IRQ_SP <= AGP_R13_IRQ;
		IRQ_LR <= AGP_R14_IRQ;
		USR_PC <= AGP_R15;
		USR_R0 <= AGP_R0;
		USR_R1 <= AGP_R1;
		USR_R2 <= AGP_R2;
		USR_R3 <= AGP_R3;
		USR_R4 <= AGP_R4;
		GEN_INT <= RS232_NR_SEND;
end process TESTSIGNALS;
	
	GEN_RXD_TESTDATA : process is
	begin
		TEST_RXD <= '1';
		wait until INIT_COMPLETE;
		-- warten bis der Prozessor die Hauptschleife erreicht hat
		wait until I_ADDRESS = X"000001ac";
		report "Sende Testdaten" severity note;
		for i in 0 to 20 loop
			TEST_RXD <= '0';			
			wait for RS232_DELAY_TIME;
			for j in 0 to 7 loop
				TEST_RXD <= RS232_TESTDATA(0)(j);
				wait for RS232_DELAY_TIME;
			end loop;
			TEST_RXD <= '1';
			wait for RS232_DELAY_TIME * 1.0;
			RS232_NR_SEND := RS232_NR_SEND + 1;
		--zusaetzliches Warten damit die Interruptroutine anspringen kann
		--wait for RS232_DELAY_TIME;	
		end loop;
	end process GEN_RXD_TESTDATA;


	EXT_GIO <= (others => 'Z');

	GET_CHARS_FINISHED_SIGNAL <= GET_CHARS_FINISHED;
	-- Instantiate the Unit Under Test (UUT)
	uut: ArmTop port map(
		EXT_RST => EXT_RST,
		EXT_CLK => EXT_CLK,
		EXT_RXD => EXT_RXD,
		EXT_LDP => '1',
		EXT_TXD => EXT_TXD,
		EXT_LED => EXT_LED
	);


	GEN_CLK : process is
	begin
		while SIMULATION_RUNNING loop
			--Kais Edit: Changed Frequency depending on ArmConfiguration
			wait for (ARM_EXT_CLK_PERIOD/2); --Basys Board 100MHz
			EXT_CLK <= NOT EXT_CLK;
		end loop;
		wait;
	end process GEN_CLK;

	tb : process
		type SLV_BUFFER_TYPE is array(0 to to_integer(ARM_PROG_MEM_SIZE)-1) of std_logic_vector(7 downto 0);
		variable SLV_BUFFER : SLV_BUFFER_TYPE := (others => X"00");
  		type BINFILE is file of character;
		file TEST_FILE : BINFILE;
		variable COUNT_BYTE : natural := 0;
		variable C: character;
		variable POSITION: natural range 0 to 255;
		
	begin
--------------------------------------------------------------------------------
		report SEPARATOR_LINE;
		report "Lesen der Programmdatei...";
		file_open(TEST_FILE,TEST_FILE_PATH,read_mode);
		while COUNT_BYTE < to_integer(ARM_PROG_MEM_SIZE) and (not endfile(TEST_FILE))loop
			read(TEST_FILE,C);
--			report TAB_CHAR & C;
			POSITION := character'POS(C);
			SLV_BUFFER(COUNT_BYTE) := std_logic_vector(to_unsigned(position,8));
			--report data(count_byte);
			COUNT_BYTE := COUNT_BYTE +1;
		end loop;
		file_close(TEST_FILE);
		report "Lesen der Programmdatei beendet, es wurden " & integer'image(COUNT_BYTE) & " Byte gelesen";
		report SEPARATOR_LINE;
		if COUNT_BYTE < to_integer(ARM_PROG_MEM_SIZE) then
			report integer'image(to_integer(ARM_PROG_MEM_SIZE)) & " Byte erwartet, " & integer'image(COUNT_BYTE) & " Byte gelesen" severity error;
			report SEPARATOR_LINE;
		end if;
--------------------------------------------------------------------------------
		INIT_COMPLETE <= false;
		EXT_RST <= '1';
		INIT_RXD <= '1';
		SIMULATION_RUNNING <= TRUE;
		-- Wait 100 ns for global reset to finish
		wait for 100 ns;
		wait for 5 ns;
--		Lokales RST
		EXT_RST <= '1';
		wait for 100 ns;
		EXT_RST <= '0';
--		warten auf das Einschwingen der DCM
		wait for 1000 ns;
--------------------------------------------------------------------------------
		report SEPARATOR_LINE;
		report "Beginn der Speicherinitialisierung...";
		report SEPARATOR_LINE;
		INIT_RXD <= '1';
		for WORD in 0 to (to_integer(ARM_PROG_MEM_SIZE)/4)-1 loop --Worte!
			INIT_RXD <= '1';
			for BYTE in 0 to 3 loop
				TRANSMIT_BYTE <= (WORD * 4) + BYTE;
				INIT_RXD <= '0';
				wait for RS232_DELAY_TIME;
				for i in 0 to 7 loop
					INIT_RXD <= slv_buffer((WORD * 4) + BYTE)(i);--REF_MEM(WORD)((8*BYTE)+i);
					wait for RS232_DELAY_TIME;
				end loop;
				INIT_RXD <= '1';
				-- Stoppbit und ein zusaetzliches Wartebit
				wait for RS232_DELAY_TIME* 2.0;
			end loop;
		--	if  (REF_MEM'length/10) mod WORD = 0 then
		--		report integer'image(((100 * WORD)/REF_MEM'length)) & "%";
		--	end if;			
		end loop;
		INIT_COMPLETE <= true;
		report SEPARATOR_LINE;
		report "Speicherinitialisierung abgeschlossen, warte auf Ausgaben";
		report SEPARATOR_LINE;
		-- Wartetakte, in denen Ergebnisse erwartet werden
		wait for RUNTIME_AFTER_INIT;
		SIMULATION_RUNNING <= FALSE;
		wait until GET_CHARS_FINISHED_SIGNAL for 1000 us;
		report SEPARATOR_LINE;
		report "Simulation beendet";
		report SEPARATOR_LINE;
		REPORT " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhängig von tatsächlich aufgetretenen Fehlern!" SEVERITY FAILURE; 

		wait; -- will wait forever
	END PROCESS;

--	Regelmaessige Statusmeldung, bisher durchlaufene Simulationszeit
	REPORT_PERCENTAGE : process is
		variable START_TIME : time;
		variable atime : time;
		variable percentage : natural := 0;
	begin
		wait for 1000 ns;
		wait until INIT_COMPLETE;
		START_TIME := now;
		wait for 1 ns; -- gegen eine folgende Division durch 0;
		while ((now - START_TIME) < RUNTIME_AFTER_INIT) and SIMULATION_RUNNING 	loop
			--report time'image(now/1000.0);
			--report time'image(START_TIME/1000.0);
			percentage := (((now - START_TIME) * 100.0) /RUNTIME_AFTER_INIT);
			report "Simulation durchlaufen zu " & integer'image(percentage) & "%";
			wait for RUNTIME_AFTER_INIT/10.0;
		end loop;
		wait;		
	end process REPORT_PERCENTAGE;


--	Aufnehmen alle Uebertragungen auf der seriellen Schnittstelle, nach Ende der Simulation Ausgabe der Daten
	GET_CHARS : process is
		variable THIS_CHAR 	: std_logic_vector(7 downto 0);
		type READ_BYTES_TYPE is array(0 to BYTES_TO_LOG - 1) of std_logic_vector(7 downto 0);
		variable READ_BYTES 	: READ_BYTES_TYPE := (others => X"00");
		variable i,CHAR_COUNT 	: natural := 0;
		variable TX_LOC, TX_CHAR : line;
	begin
		GET_CHARS_FINISHED := false;
		wait for 1000 ns;
		while SIMULATION_RUNNING loop
			GET_CHAR(THIS_CHAR);
			READ_BYTES(CHAR_COUNT) := THIS_CHAR;
			CHAR_COUNT := CHAR_COUNT + 1;
			--report SLV_TO_STRING(THIS_CHAR);
		end loop;

		report SEPARATOR_LINE;
		report "Ausgaben waehrend der Simulation (Wortweise):";
		report SEPARATOR_LINE;
		report "Hexadezimal "& TAB_CHAR &  "| " & " Character";
		report SEPARATOR_LINE;
		if ARM_SYS_CTRL_REPEAT_PROGRAM then
			report "Die ersten " & integer'image(to_integer(ARM_PROG_MEM_SIZE)) & " Zeichen sollten dem Testprogramm entsprechen";
			report "Innerhalb einer Gruppe von 4 Byte steht das zuerst empfangene Byte aus Gruenden der Lesbarkeit ganz rechts!";			
			report SEPARATOR_LINE;
		end if;	
		-- Fuer die ersten 128 Zeichen Ausgabe von Vierergruppen und umgekehrter Reihenfolge, entspricht der ueblichen Darstellung
		-- eines Befehlswortes
		while i < CHAR_COUNT loop
			if i < to_integer(ARM_PROG_MEM_SIZE) and ARM_SYS_CTRL_REPEAT_PROGRAM then
				hwrite(TX_LOC, READ_BYTES(i+3 )); std.textio.write(TX_LOC, SPACE_CHAR);
				std.textio.write(TX_CHAR, TAB_CHAR &  "| " & TAB_CHAR & character'val(to_integer(unsigned(READ_BYTES(i+3)))));
				hwrite(TX_LOC, READ_BYTES(i+2 )); std.textio.write(TX_LOC,  SPACE_CHAR);
				std.textio.write(TX_CHAR, SPACE_CHAR & character'val(to_integer(unsigned(READ_BYTES(i+2)))));
				hwrite(TX_LOC, READ_BYTES(i+1 )); std.textio.write(TX_LOC,  SPACE_CHAR);
				std.textio.write(TX_CHAR, SPACE_CHAR & character'val(to_integer(unsigned(READ_BYTES(i+1)))));
				hwrite(TX_LOC, READ_BYTES(i+0 )); std.textio.write(TX_LOC,  SPACE_CHAR);
				std.textio.write(TX_CHAR, SPACE_CHAR & character'val(to_integer(unsigned(READ_BYTES(i+0)))));
			else
				hwrite(TX_LOC, READ_BYTES(i )); std.textio.write(TX_LOC, SPACE_CHAR);
				std.textio.write(TX_CHAR, TAB_CHAR &  "| " & TAB_CHAR & character'val(to_integer(unsigned(READ_BYTES(i)))));
				hwrite(TX_LOC, READ_BYTES(i+1 )); std.textio.write(TX_LOC,  SPACE_CHAR);
				std.textio.write(TX_CHAR, SPACE_CHAR & character'val(to_integer(unsigned(READ_BYTES(i+1)))));
				hwrite(TX_LOC, READ_BYTES(i+2 )); std.textio.write(TX_LOC,  SPACE_CHAR);
				std.textio.write(TX_CHAR, SPACE_CHAR & character'val(to_integer(unsigned(READ_BYTES(i+2)))));
				hwrite(TX_LOC, READ_BYTES(i+3 )); std.textio.write(TX_LOC,  SPACE_CHAR);
				std.textio.write(TX_CHAR, SPACE_CHAR & character'val(to_integer(unsigned(READ_BYTES(i+3)))));
			end if;
			report TX_LOC.all & TX_CHAR.all;
			Deallocate(TX_LOC);
			Deallocate(TX_CHAR);
--			report " " & character'val(to_integer(unsigned(READ_BYTES(i+3))));
			i := i + 4;
			if i = to_integer(ARM_PROG_MEM_SIZE) and ARM_SYS_CTRL_REPEAT_PROGRAM then
				report SEPARATOR_LINE;
				report "Prognostiziertes Programmende erreicht, es folgen Ausgaben durch den Prozessor zur Programmlaufzeit";
				report "Innerhalb der folgenden Bytegruppen steht das zuerst empfangene Byte links!";
				report SEPARATOR_LINE;
			end if;
		end loop;
		report SEPARATOR_LINE;
		GET_CHARS_FINISHED := true;

		wait;
	end process GET_CHARS;

--	procedure PRINT_WORD_LINE is
--	begin
--	end procedure PRINT_WORD_LINE;

end architecture testbench;
