--------------------------------------------------------------------------------
--	Systemcontroller zum ARM-SoC
--	Enthaellt den DCM zur Erzeugung des Systemtakts.
--	Nach einem externen Reset beginnt der Controller zu arbeiten, sobald das 
--	DCM-Taktsignal stabil ist. Der Controller liest ARM_PROG_MEM_SIZE Byte
--	aus der seriellen Schnittstelle, schreibt sie in den Speicher, liest sie
--	aus dem Speicher und schreibt sie in die serielle Schnittstelle zurueck.
--	Anschliessend erzeugt der Controller ein Reset-Signal fuer alle
--	Komponenten ausserhalb des Controllers, um den Prozessorkern
--	zurueckzusetzen und geht dann in einen dauerhaft Wartezustand ueber.
--------------------------------------------------------------------------------
--	Datum:		30.05.10
--	Version:	0.96
--------------------------------------------------------------------------------
--	Aenderungen:
--	Wartesignal-Signal hinzugefuegt, mit dem der Prozessorkern waehrend
--	der Speicherinitialisierung angehalten werden kann, dient
--	vor allem dem Test des neuen WAIT-Signals im Prozessorkern.
--	Normalerweise kann der Kern waehrend der Initialisierung weiterlaufen,
--	da er keine Kontrolle ueber den Datenbus hat, kann er den externen
--	Zustand nicht beeinflussen. Falls allerdings ein Coprozessor 
--	verwendet wird, der selbst eine Schnittstelle nach aussen hat, duerfen
--	Prozessorkern und Coprozessor waehrend der Initialisierung nicht
--	arbeiten und muessen mittels Wait-Signal gestoppt werden.
--	Angedachte Aenderung:
--	DATA_ADDRESS_VECTOR wurde versuchsweise in der Laenge beschraenkt, sodass
--	die Warnings nicht mehr auftreten, dass M hochwertige Bit immer 0 sind.
	--> Ist unmoeglich, weil dann die hohen Adressen zum Ansprechen
--	der seriellen Schnittstelle nicht mehr erzeugt werden koennen.
--------------------------------------------------------------------------------

library work;
use work.ArmConfiguration.all;
	use work.ArmTypes.all;
use work.ArmGlobalProbes.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
--	Uncomment the following library declaration if instantiating
--	any Xilinx primitives in this code.
--------------------------------------------------------------------------------
library UNISIM;
use UNISIM.VComponents.all;

entity ArmSystemController is
	Port (	EXT_RST : in STD_LOGIC;
		EXT_CLK 	: in STD_LOGIC;
	    SYS_CLK 	: out STD_LOGIC;
	   	SYS_RST 	: out STD_LOGIC;
		SYS_INV_CLK	: out STD_LOGIC;
		CTRL_DnRW 	: out STD_LOGIC;
		CTRL_DMAS 	: out STD_LOGIC_VECTOR(1 downto 0);
		CTRL_DA 	: out STD_LOGIC_VECTOR(31 downto 0);
		CTRL_DDIN 	: in STD_LOGIC_VECTOR(31 downto 0);
		CTRL_DDOUT 	: out STD_LOGIC_VECTOR(31 downto 0);
		CTRL_DABORT 	: in STD_LOGIC;
		CTRL_DEN 	: out std_logic;
--	Adresseingang fuer die Anzeige der aktuellen Adresse (Bits 9:2) auf dem Instruktionsbus
		CTRL_IA		: in std_logic_vector(9 downto 2);
		CTRL_LDP 	: in std_logic;
		CTRL_STATUS_LED : OUT STD_LOGIC_VECTOR(7 downto 0);
		CTRL_WAIT	: out std_logic
       );
end ArmSystemController;

-- Kais Edit Changed Names
architecture behave of ArmSystemController is
component ArmClkGen
	port(
		clk_in1	: in std_logic;
		reset		: in std_logic;          
		clk_out1	: out std_logic;
		clk_out2	: out std_logic;
		locked	: out std_logic
		);
	end component ArmClkGen;

	signal DCM_LOCKED	: std_logic;
--------------------------------------------------------------------------------
--	DCM_SYS_INV_CLK entspricht imemr dem Ausgang SYS_INV_CLK, soll jedoch
--	zusaetzlich an ein globales Testsignal zugewiesen werden.
--------------------------------------------------------------------------------
	signal DCM_SYS_CLK, DCM_SYS_INV_CLK : std_logic;

--------------------------------------------------------------------------------
--	Notwendig, weil SYS_RST mit Modus out bereits in der Schnittstelle steht
--	und buffer besser nicht verwendet werden sollten
--------------------------------------------------------------------------------
	signal SYS_RST_INTERNAL : std_logic := '0';

--------------------------------------------------------------------------------
--	Nach dem Initialisieren und erneuten Ausgeben des Speichers muss der
--	Prozessor einmal neu gestartet werden, dazu wird dieses Signal fuer
--	einige Takte gesetzt.
--------------------------------------------------------------------------------
	signal INIT_RST		: std_logic := '0';


	signal DATA_REG		: std_logic_vector(31 downto 0) := (others => '0');
	signal DATA_nRW_REG	: std_logic := '0';
--------------------------------------------------------------------------------
--	Zugriff auf alle Komponenten in Bytebreite, zusaetzliches Register 
--	ist ueberfluessig, wird aber fuer flexiblere Erweiterungenn in der
--	Zukunft erhalten.	
--------------------------------------------------------------------------------
--	signal DATA_DMAS_REG	: std_logic_vector(1 downto 0) := DMAS_BYTE;
	signal DATA_IN_REG	: std_logic_vector(31 downto 0) := (others => '0');
	
	signal DATA_ADDRESS_VECTOR : std_logic_vector(31 downto 0) := (others => '0');-- := STD_LOGIC_VECTOR(TO_UNSIGNED(DATA_ADDRESS,32));

	signal CTRL_WORKING	: std_logic := '1'; 
	signal CTRL_STATUS_REG	: std_logic_vector(7 downto 0) := (others => '1');
	type CTRL_STATE_TYPE is (CTRL_IDLE,CTRL_READ_STDIN_STATUS,CTRL_READ_STDIN_DATA, CTRL_READ_STDOUT_STATUS, CTRL_WRITE_STDOUT_DATA, CTRL_READ_MEM, CTRL_WRITE_MEM, CTRL_FINISHED, CTRL_WAIT_STATE);
	signal CTRL_STATE : CTRL_STATE_TYPE := CTRL_IDLE;
begin
    --Kais Edit
	Inst_ArmClkGen: ArmClkGen port map(
		clk_in1	=> EXT_CLK,
		reset		=> EXT_RST,
		clk_out1	=> DCM_SYS_CLK,
		clk_out2	=> DCM_SYS_INV_CLK,
		locked	=> DCM_LOCKED
	);

	SYS_CLK		<= DCM_SYS_CLK;
	SYS_INV_CLK	<= DCM_SYS_INV_CLK;
	SYS_RST_INTERNAL<= EXT_RST or not DCM_LOCKED;
--------------------------------------------------------------------------------
--	Das uebrige System muss nach der Speicherinitialisierung einmal neu
--	gestartet werden, der Systemcontroller jedoch muss dauerhaft in
--	seinem Wartezustand verbleiben.
--------------------------------------------------------------------------------
	SYS_RST		<= SYS_RST_INTERNAL or INIT_RST;
--------------------------------------------------------------------------------
--	Bis zum Abschluss der Speicherinitialisierung besetzt der Controller
--	dauerhaft den Datenbus.
--------------------------------------------------------------------------------
	CTRL_DEN	<= CTRL_WORKING;
--------------------------------------------------------------------------------
--	Nach der Initialisierung (CTRL_WORKNIG -> 0) alle Ausgaenge vom Bus
--	abkoppeln.
--------------------------------------------------------------------------------
	CTRL_DDOUT	<= DATA_REG when CTRL_WORKING = '1' else (others => 'Z');
	CTRL_DA		<= DATA_ADDRESS_VECTOR when CTRL_WORKING = '1' else (others => 'Z');
--	assert(2**DATA_ADDRESS_VECTOR'length >= ARM_PROG_MEM_SIZE) report "DATA_ADDRESS_VECTOR im System-Controller zu klein fuer den zu initialisierenden Speicher, bitte anpassen!" severity error;
	CTRL_DnRW	<= DATA_nRW_REG when CTRL_WORKING = '1' else 'Z';
--	CTRL_DMAS	<= DATA_DMAS_REG when CTRL_WORKING = '1' else (others => 'Z');
	CTRL_DMAS	<= DMAS_BYTE when CTRL_WORKING = '1' else (others => 'Z');
	
--------------------------------------------------------------------------------
--	In dieser Variante wird das Wartesignal extern verodert und deshalb
--	nicht nicht in den Tristate geschaltet. Das ist inkonsistent zu den 
--	uebrigen Steuersignalen und sollte evtl. ueberdacht werden.
--------------------------------------------------------------------------------
	CTRL_WAIT	<= CTRL_WORKING;
	CTRL_STATUS_LED	<= CTRL_STATUS_REG(7 downto 0);

	process(DCM_SYS_CLK)
--------------------------------------------------------------------------------
--	Variable zum zaehlen der bereits initialisierten Bytes, muss fuer
--	groesser Speicher als auf dem Spartan-3E 500 moeglich sind, ggf. 
--	vergroessert werden.	
--------------------------------------------------------------------------------
		variable BYTE_CNT : unsigned(15 downto 0) := (others => '0');
	begin
		assert (2**(BYTE_CNT'left + 1)) >= ARM_PROG_MEM_SIZE report "BYTE_CNT in SystemController nicht ausreichend fuer die Initialisierung des Speichers, BYTE_CNT_MAX: "
										& integer'image((2**(BYTE_CNT'left + 1))-1) severity warning;
		if DCM_SYS_CLK'event and DCM_SYS_CLK ='1' then
			if SYS_RST_INTERNAL = '1' then
				CTRL_STATE	<= CTRL_IDLE;
				DATA_nRW_REG	<= '0';
--				DATA_DMAS_REG	<= DMAS_BYTE;
				CTRL_STATUS_REG	<= (others => '1');
				DATA_REG	<= (others => '0');
				CTRL_WORKING	<= '1'; --war 0
				BYTE_CNT	:= (others => '0');
				DATA_ADDRESS_VECTOR <= (others => '0');
				INIT_RST	<= '0';

			else 
				CTRL_STATE	<= CTRL_STATE;
				DATA_nRW_REG	<= '0';
--				DATA_DMAS_REG	<= DMAS_BYTE;
				CTRL_STATUS_REG <= std_logic_vector(BYTE_CNT(7 downto 0));
				DATA_ADDRESS_VECTOR <= DATA_ADDRESS_VECTOR;
				DATA_REG	<= DATA_REG;
				CTRL_WORKING	<= CTRL_WORKING;
				INIT_RST	<= '0';
				if ((CTRL_LDP = '0') and (CTRL_STATE = CTRL_IDLE)) then
--------------------------------------------------------------------------------
--	Der Controller tut nichts, solange das externe LDP-Signal nicht
--	gesetzt ist, er gibt lediglich einige Bits der Instruktionsadresse
--	des letzten Takts auf einem Statusausgang aus.	
--------------------------------------------------------------------------------
					CTRL_STATE	<= CTRL_IDLE;
					CTRL_WORKING	<= '0'; --war 0
					BYTE_CNT	:= (others => '0');
					CTRL_WORKING	<= '0';
					CTRL_STATUS_REG <= CTRL_IA;
				else					
					case CTRL_STATE is
						when CTRL_IDLE =>
							CTRL_STATE	<= CTRL_READ_STDIN_STATUS;
							CTRL_WORKING	<= '1';
							DATA_ADDRESS_VECTOR <= RS232_STAT_REG_ADDR(DATA_ADDRESS_VECTOR'length -1 downto 0);
						when CTRL_READ_STDIN_STATUS =>
--------------------------------------------------------------------------------
--	Warten, bis im Statusregister der seriellen Schnittstelle ein
--	Empfang angezeigt wird.							
--------------------------------------------------------------------------------
							if(BYTE_CNT < ARM_PROG_MEM_SIZE)then
								if(CTRL_DDIN(0) = '1')then
									DATA_ADDRESS_VECTOR	<= RS232_RCV_REG_ADDR(DATA_ADDRESS_VECTOR'length -1 downto 0);
									CTRL_STATE		<= CTRL_READ_STDIN_DATA;
								end if;
							else
								CTRL_STATE		<= CTRL_READ_MEM;									
								BYTE_CNT		:= (others => '0');
								DATA_ADDRESS_VECTOR	<= DATA_LOW_ADDR(DATA_ADDRESS_VECTOR'length -1 downto 0);
							end if;	
--------------------------------------------------------------------------------
--	Datum aus dem Empfangsregister der seriellen Schnittstelle lesen,
--	Datum sofort wieder in ein Ausgangsregister schreiben, sodass
--	es im naechsten Takt in den RAM geschrieben wird.	
--------------------------------------------------------------------------------
						when CTRL_READ_STDIN_DATA =>
							CTRL_STATE		<= CTRL_WRITE_MEM;
							DATA_ADDRESS_VECTOR	<= std_logic_vector(unsigned(DATA_LOW_ADDR) + BYTE_CNT);
							DATA_nRW_REG		<= '1';
							DATA_IN_REG		<= CTRL_DDIN;
							DATA_REG		<= CTRL_DDIN(7 downto 0) & CTRL_DDIN(7 downto 0) & CTRL_DDIN(7 downto 0) & CTRL_DDIN(7 downto 0);
						when CTRL_WRITE_MEM =>	
							CTRL_STATE		<= CTRL_READ_STDIN_STATUS;
							DATA_ADDRESS_VECTOR	<= RS232_STAT_REG_ADDR(DATA_ADDRESS_VECTOR'length -1 downto 0);
							BYTE_CNT		:= BYTE_CNT + 1;
						when CTRL_READ_MEM =>
--------------------------------------------------------------------------------
--	Datum aus dem Speicher zuruecklesen und dann in einen Zustand wechseln,
--	indem gewartet wird, bis die serielle Schnittstelle wieder eine
--	Uebertragung starten kann.	
--	Bedingung <=, damit waehrend der letzten Uebertragung noch einmal
--	gewartet wird bis diese beendet ist,  mit der aktuellen Konstruktion
--	in WRITE_STOUT_DATA sollte diese Abfrage eigentlich nicht mehr
--	notwendig sein. WRITE_STOUT_DATA wird erst verlassen, wenn die Schnitt-
--	stelle die letzte Uebertragung beendet hat.
--------------------------------------------------------------------------------
							if(BYTE_CNT <= ARM_PROG_MEM_SIZE)then
								DATA_IN_REG		<= CTRL_DDIN;
								CTRL_STATE		<= CTRL_READ_STDOUT_STATUS;
								DATA_ADDRESS_VECTOR	<= RS232_STAT_REG_ADDR(DATA_ADDRESS_VECTOR'length -1 downto 0);
							else
								CTRL_STATE		<= CTRL_WAIT_STATE;
								INIT_RST		<= '1';
--------------------------------------------------------------------------------
--	Zaehler fuer die Wartetakte in CTRL_WAIT_STATE initialisieren.
--	SYS_RST bleibt so fuer mehrere Takte aktiv.							
--------------------------------------------------------------------------------
								BYTE_CNT		:= to_unsigned(2,BYTE_CNT'length);
							end if;	
						when CTRL_READ_STDOUT_STATUS =>	
--------------------------------------------------------------------------------
--	Neu: Abfrage, ob das Programm aus dem Speicher gelesen und
--	zurueckgesendet werden soll. Speziell bei der Simulation ist das nicht
--	sinnvoll, sobald die korrekte Funktionsweise von Speicher und RS232
--	verifiziert sind, und kostet zu viel Simulationszeit.
--------------------------------------------------------------------------------
							if(CTRL_DDIN(4) = '0') or not ARM_SYS_CTRL_REPEAT_PROGRAM then
--	Sender nicht busy
								if (BYTE_CNT < ARM_PROG_MEM_SIZE) and ARM_SYS_CTRL_REPEAT_PROGRAM then
									CTRL_STATE	<= CTRL_WRITE_STDOUT_DATA;
									DATA_nRW_REG	<= '1';
									DATA_ADDRESS_VECTOR <= RS232_TRM_REG_ADDR(DATA_ADDRESS_VECTOR'length -1 downto 0);
									case BYTE_CNT(1 downto 0)is
										when "01" =>
											DATA_REG <= X"000000" & DATA_IN_REG(15 downto 8);
										when "10" =>
											DATA_REG <= X"000000" & DATA_IN_REG(23 downto 16);
										when "11" =>
											DATA_REG <= X"000000" & DATA_IN_REG(31 downto 24);
										when others => --"00"
											DATA_REG <= X"000000" & DATA_IN_REG(7 downto 0);
									end case;
								else
									DATA_nRW_REG	<= '0';
									CTRL_STATE	<= CTRL_WAIT_STATE;
									INIT_RST	<= '1';
									BYTE_CNT	:= to_unsigned(2,BYTE_CNT'length);
								end if;

							end if;	
						when CTRL_WRITE_STDOUT_DATA =>
								if BYTE_CNT < ARM_PROG_MEM_SIZE-1 then
									DATA_ADDRESS_VECTOR	<= std_logic_vector(unsigned(DATA_LOW_ADDR) + BYTE_CNT + 1);
									CTRL_STATE		<= CTRL_READ_MEM;
									BYTE_CNT		:= BYTE_CNT + 1;
								else
--------------------------------------------------------------------------------
--	Nach dem Senden des letzten Bytes sollte nach READ_STDOUT_STATUS
--	gewechselt und dort gewartet werden, bis die letzte Uebertragung beendet
--	ist. Anschliessend findet ein Wechsel nach CTRL_WAIT_STATE statt, wo die
--	uebrigen SoC-Komponenten neugestartet werden. Die Speicher-
--	Zugriffsadresse wird hier nicht mehr inkrementiert.
--------------------------------------------------------------------------------
									CTRL_STATE		<= CTRL_READ_STDOUT_STATUS;
									DATA_ADDRESS_VECTOR	<= RS232_STAT_REG_ADDR(DATA_ADDRESS_VECTOR'length -1 downto 0);
									BYTE_CNT		:= BYTE_CNT + 1;

								end if;	
						when CTRL_WAIT_STATE	=>
							if BYTE_CNT > 0 then
								INIT_RST	<= '1';
								BYTE_CNT	:= BYTE_CNT -1;
								CTRL_STATE	<= CTRL_WAIT_STATE;
							else
								INIT_RST	<= '0';
								CTRL_STATE	<= CTRL_FINISHED;
							end if;

						when CTRL_FINISHED =>	
							CTRL_WORKING		<= '0';
							BYTE_CNT		:= (others => '0');
							CTRL_STATE		<= CTRL_FINISHED;
--------------------------------------------------------------------------------
--	Nach Abgabe der Kontrolle ueber die Busse zeigen die LEDs einen Teil der
--	Instruktionsadresse des letzten Takts an.
--------------------------------------------------------------------------------
							CTRL_STATUS_REG	<= CTRL_IA;
						when others =>
							CTRL_WORKING	<= '0';
							CTRL_STATE	<= CTRL_FINISHED;	
					end case;	
				end if;
			end if;
		end if;
	end process;

-- synthesis translate_off
	AGP_CLK		<= DCM_SYS_CLK;
	AGP_INV_CLK	<= DCM_SYS_INV_CLK;
	AGP_CLK_LOCK	<= DCM_LOCKED;
-- synthesis translate_on
end architecture behave;
