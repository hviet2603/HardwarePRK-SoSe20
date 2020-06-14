--------------------------------------------------------------------------------
--	Konfigurationseinstellungen fuer den Prozessorkern und weitere
--	Komponenten.
--	Einige Optionen in diesem Dokument beziehen sich auf eine komplexere
--	Fassung des HWPR-Prozessors und bleiben daher im Praktikum wirkungs-
--	los.
--	Veraendern Sie bei Bedarf die Konstanten ARM_SYS_CLK_FREQ und 
--	ARM_SYS_CLK_PERIOD. Alle anderen Konstanten sollten beibehalten werden.
--------------------------------------------------------------------------------
--	Datum:		29.10.2013
--	Version:	0.1
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
	use work.ArmTypes.all;

package ArmConfiguration is
--------------------------------------------------------------------------------
--	Frequenz des externen Taktsignales (immer 50 MHz auf dem Starter Kit)
--------------------------------------------------------------------------------
--  Auf dem Basys3 Board ist die Frequenz des externen Taktsignals 100Mhz
--------------------------------------------------------------------------------
	constant ARM_EXT_CLK_FREQ : unsigned(31 downto 0) := to_unsigned(100000000,32);
	constant ARM_EXT_CLK_PERIOD : time := 10.0 ns;
--------------------------------------------------------------------------------
--	Kernfrequenz, erzeugt durch DCM
--------------------------------------------------------------------------------
	constant ARM_SYS_CLK_FREQ : unsigned(31 downto 0) := to_unsigned(10000000,32);
--------------------------------------------------------------------------------
--	Periodendauer der Kernfrequenz = ARM_EXT_PERIOD *(MULTIPLY/DIVIDE)
--------------------------------------------------------------------------------
	constant ARM_SYS_CLK_PERIOD_INT : integer := 100; --ns
	constant ARM_SYS_CLK_PERIOD : time := ARM_SYS_CLK_PERIOD_INT * 1 ns;

--------------------------------------------------------------------------------
--	Einstellung der DCM zur Erzeugung des internen Taktsignals.
--	Irrelevant fuer das HWPR.
--------------------------------------------------------------------------------
	constant ARM_DCM_CLKFX_MULTIPLY : integer range 2 to 32 := 2;
	constant ARM_DCM_CLKFX_DIVIDE : integer range 1 to 32 := 10;

--------------------------------------------------------------------------------
-- 	Berechnung des Initialen Prescalerwertes fuer das TIMER-Modul, durch den
--	der Betriebstakt zum Zaehlen dividiert wird. Dabei ist der Divisor um 1
--	groesser als der Prescaler-Wert. Irrelevant fuer das HWPR.
--------------------------------------------------------------------------------
	constant ARM_TIMER_PRESCALER : integer := integer((1000.0/real(ARM_SYS_CLK_PERIOD_INT))-1.0); 

--------------------------------------------------------------------------------
--	Groesse des Programmspeichers in Byte, bestimmt, wie viele Byte durch den
--	Systemcontroller nachgeladen werden.
--------------------------------------------------------------------------------
    constant ARM_PROG_MEM_SIZE : unsigned := to_unsigned(16384,32);
--------------------------------------------------------------------------------
--	Angabe, ob der Systemcontroller ein in den Speicher geladenes
--	Programm wieder auslesen und ueber die serielle Schnittstelle
--	zurueckschicken soll (zum Test der erfolgreichen
--	Speicherinitialisierung).
--------------------------------------------------------------------------------
	constant ARM_SYS_CTRL_REPEAT_PROGRAM : boolean := true;

--------------------------------------------------------------------------------
--	Fuer eine Arbeitsspeicherimplementierung mit waehlbarer Groesse (nicht
--	im HWPR verwendet), Auswahl der notwendigen Adressbits zur 
--	Unterscheidung der Speicherzeile. 	
--------------------------------------------------------------------------------
	constant SELECT_LINES : natural range 0 to 2 := 1;

--------------------------------------------------------------------------------
--	Konfigurationsdaten der seriellen Schnittstelle; Baudrate, daraus 
--	abgeleitete Dauer jedes Zeichens und Angaben ueber die Verwendung von
--	Paritaetsinformationen
--------------------------------------------------------------------------------
	constant RS232_BAUDRATE		: unsigned := to_unsigned(57600,32); --57600,115200, 128000, 460800, 512000
	--ca. 17.36 us bei 57600 Baud
	constant RS232_DELAY 		: unsigned(31 downto 0) := ((ARM_SYS_CLK_FREQ/RS232_BAUDRATE));
	constant RS232_DELAY_TIME 	: time := to_integer(RS232_DELAY) * ARM_SYS_CLK_PERIOD;

--	Ausreichende Beschreibung des RS232 Delays fuer das erste Nutzbit im ISIM, funktioniert fuer ModelSim nicht:	
--	constant RS232_START_DELAY 	: unsigned(31 downto 0) :=(((3 * ARM_SYS_CLK_FREQ/RS232_BAUDRATE)/2));

--	Workaround fuer Modelsim, die Berechnung wird als 64bitiges Ergebnis interpretiert weshalb die Zuweisung auf 32 Bit scheitert
	constant MODELSIM_RS232_START_DELAY	: unsigned(63 downto 0) := (((3 * ARM_SYS_CLK_FREQ/RS232_BAUDRATE)/2));
	constant RS232_START_DELAY 		: unsigned(31 downto 0) := MODELSIM_RS232_START_DELAY(31 downto 0);

--	Paritaeten werden vorerst nicht ueberprueft, evtl. in einer zukuenftigen Ausbaustufe
	constant RS232_USE_PARITY : boolean := FALSE;
	constant RS232_PARITY_IS_EVEN : boolean := FALSE;


--------------------------------------------------------------------------------
--	Konfigurationseintraege des CSG fuer die verfuegbaren Peripherie-
--	komponenten, fuer das HWPR sind nur der RAM und die serielle Schnitt-
--	stelle (RS232) von Bedeutung. CSG_ENTRY_DEFAULT ist ein Eintrag,
--	der die zugehoerige CS-Leitung des CSG permanent deaktiviert.
--------------------------------------------------------------------------------
		constant CSG_ENTRY_RAM		: CSG_ENTRY_TYPE := ('1','1',X"00000",CSG_MASK_16K);
		constant CSG_ENTRY_RS232	: CSG_ENTRY_TYPE := ('1','0',X"80000",CSG_MASK_4K);
		constant CSG_ENTRY_AST		: CSG_ENTRY_TYPE := ('1','0',X"80001",CSG_MASK_4K);
		constant CSG_ENTRY_GIO		: CSG_ENTRY_TYPE := ('1','0',X"80002",CSG_MASK_4K);
		constant CSG_ENTRY_AMC		: CSG_ENTRY_TYPE := ('1','0',X"80003",CSG_MASK_4K);
		constant CSG_ENTRY_DEFAULT	: CSG_ENTRY_TYPE := ('0','0',X"00000",CSG_MASK_4K);

--------------------------------------------------------------------------------
--	Bildung der Gesamtkonfiguration des CSG, fuer das HWPR werden nur
--	zwei aktive CS-Signale benoetigt	
--------------------------------------------------------------------------------
		constant CSG_ENTRIES : CSG_ENTRIES_TYPE := (
			CSG_ENTRY_RAM,
			CSG_ENTRY_RS232,
--			CSG_ENTRY_AST,
--			CSG_ENTRY_GIO,
			others => CSG_ENTRY_DEFAULT);

--------------------------------------------------------------------------------
--	Memory Map fuer Instruktionsspeicher, Datenspeicher und
--	RS232-Schnittstelle. Basisgroesse fuer einen
--	Peripherieblock: 4096 Byte = 0x1000.
--	Die verwendeten Registeradressen sind streng genommen
--	nicht absolut sondern Offsets zur jeweiligen Basis, auch
--	Vielfache davon unter der oberen Grenze funktionieren
--	Die Angabe mit LOW- und HIGH-Addressen ist weitgehend ein Relikt
--	aus der urspruenglichen Loesung des CSG. Der Instruktionsspeicher
--	benoetigt diese Angaben jedoch weiterhin zu selbststaendigen
--	Ueberpruefung der Adressgrenzen.
--	Die Einhaltung aller uebrigen Grenzen wird durch den CSG und dort
--	durch die Angabe von Basisadresse und Blockgroesse (4K, 8K,...)
--	im Konfigurationseintrag erreicht.
--	Der System-Controller verwendet aber die im Folgenden definierten
--	Konstanten fuer die Register der seriellen Schnittstelle.
--------------------------------------------------------------------------------
	subtype MEM_ADDRESS is std_logic_vector(31 downto 0);
		constant INST_LOW_ADDR 		: MEM_ADDRESS 	:= X"00000000";
		constant INST_HIGH_ADDR 	: MEM_ADDRESS 	:= X"00003FFF";
		constant DATA_LOW_ADDR 		: MEM_ADDRESS 	:= X"00000000";
		constant DATA_HIGH_ADDR 	: MEM_ADDRESS 	:= X"00003FFF";

		constant RS232_BASE_ADDR 	: MEM_ADDRESS	:= X"80000000";
		constant RS232_LOW_ADDR 	: MEM_ADDRESS	:= X"80000000";
		constant RS232_HIGH_ADDR 	: MEM_ADDRESS	:= X"80000FFF";
--		Kais Edit:
--		Global Signals are NOT allowed in VIVADO (!) -> Using constants instead
		constant RS232_RCV_REG_ADDR : MEM_ADDRESS 	:= std_logic_vector(unsigned(RS232_BASE_ADDR) + 0);
		constant RS232_TRM_REG_ADDR : MEM_ADDRESS 	:= std_logic_vector(unsigned(RS232_BASE_ADDR) + 4);
		constant RS232_STAT_REG_ADDR: MEM_ADDRESS 	:= std_logic_vector(unsigned(RS232_BASE_ADDR) + 8); --X"80000008";

      --The following signal is never used
  		constant RS232_CTRL_REG_ADDR 	: MEM_ADDRESS 	:= std_logic_vector(unsigned(RS232_BASE_ADDR) + 12); --X"8000000C";
		
--	Registerandressen weiterer Peripheriekomponenten, unwichtig fuer das 
--	HWPR
		constant AST_BASE_ADDR		: MEM_ADDRESS	:= X"80001000";
		constant AST_LOW_ADDR 		: MEM_ADDRESS	:= X"80001000";
		constant AST_HIGH_ADDR 		: MEM_ADDRESS	:= X"80001FFF";
		constant AST_TMR_REG_ADDR 	: MEM_ADDRESS 	:= X"80001000";
		constant AST_TER_REG_ADDR 	: MEM_ADDRESS 	:= X"80001004";
		constant AST_TRV0_REG_ADDR 	: MEM_ADDRESS 	:= X"80001008";
		constant AST_TCN0_REG_ADDR 	: MEM_ADDRESS 	:= X"8000100C";
		constant AST_TRV1_REG_ADDR 	: MEM_ADDRESS 	:= X"80001010";
		constant AST_TCN1_REG_ADDR 	: MEM_ADDRESS 	:= X"80001014";
		constant AST_TRV2_REG_ADDR 	: MEM_ADDRESS 	:= X"80001018";
		constant AST_TCN2_REG_ADDR 	: MEM_ADDRESS 	:= X"8000101C";
		
		constant GIO_BASE_ADDR		: MEM_ADDRESS	:= X"80002000";
		constant GIO_LOW_ADDR		: MEM_ADDRESS	:= X"80002000";
		constant GIO_HIGH_ADDR		: MEM_ADDRESS	:= X"80002FFF";
		constant GIO_DDO_REG_ADDR	: MEM_ADDRESS	:= X"80002000";
		constant GIO_DDI_REG_ADDR	: MEM_ADDRESS	:= X"80002004";
		constant GIO_DIR_REG_ADDR	: MEM_ADDRESS	:= X"80002008";
		constant GIO_DMY_REG_ADDR	: MEM_ADDRESS	:= X"8000200C";

		constant AMC_BASE_ADDR		: MEM_ADDRESS	:= X"80003000";
		constant AMC_REG0_ADDR		: MEM_ADDRESS	:= X"80003000";
		constant AMC_REG1_ADDR		: MEM_ADDRESS	:= X"80003004";
		constant AMC_REG2_ADDR		: MEM_ADDRESS	:= X"80003008";
		constant AMC_REG3_ADDR		: MEM_ADDRESS	:= X"8000300C";

	constant ARM_USE_RS232		: boolean := true;
	constant ARM_USE_AST		: boolean := false;
	constant ARM_USE_GIO		: boolean := false;
	constant ARM_USE_AMC		: boolean := false;


--------------------------------------------------------------------------------
--	Konfiguration (Generics) des Datenpfades:
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	Auswahl und Einstellung der Registerspeicher-Implementierung
--	Version 2 des Registerspeichers nutzt Distributed RAM, 
--	mit REGFILE_BYPASS enthaelt der Registerspeicher interne Bypaesse
--	um mit dem regulaeren Pipelinetakt betrieben werden zu koennen.
--	Mit PC_LOOP_THROUGH = true existiert kein echtes Register mehr
--	fuer den PC sondern der Wert des Adressregisters wird durchgereicht.
--	Diese Optionen sind fuer das HWPR irrelevant.
--------------------------------------------------------------------------------
	constant USE_REGFILE_V2			: boolean := false;
	constant PC_LOOP_THROUGH		: boolean := false;
	constant REGFILE_BYPASS			: boolean := false;--true;

--------------------------------------------------------------------------------
--	Die Pipelineregister im Datenpfad sowie der Registerspeicher
--	sind standardmaessig nicht von einem systemweiten Reset
--	betroffen, auf Wunsch kann dieses Verhalten aber erzwungen 
--	werden (hilfreich fuer die Herstellung definierter Ausgangswerte
--	in Simulationen).
-- 	Achtung: Die Neufassung des Registerspeichers
-- 	kann nicht mehr auf Distributed RAM abgebildet werden,
-- 	wenn die Option aktiv ist.
--------------------------------------------------------------------------------
	constant USE_OPTIONAL_RESET : boolean := true;

--------------------------------------------------------------------------------
--	Mit USE_FAST_BRANCH existiert ein direkter Pfad zwischen Operand B-Pfad
--	oder ALU-Ausgang der EX-Stufe und dem Instruktions-Adressregister. Auf
--	diese Weise muss die Sprungzieladresse in vielen Faellen nicht die 
--	MEM- und WB-Stufe durchlaufen und die Sprünge werden um zwei Takte
--	beschleunigt.
--	Mit USE_DEDICATED_BRANCH_ADDER existiert neben der ALU ein weiterer
--	Addierer zur Berechnung der Sprungzieladressen ohne die Shifter-
--	Verzoegerung. Der Ausgang des Sprungaddierers ist durch einen
--	zusaetzlichen Pfad mit dem Datenadressregister verbunden. Bisher ist der 
--	zusaetzliche Addierer weitgehend sinnlos.
--------------------------------------------------------------------------------
	constant USE_FAST_BRANCH		: boolean := false;
	constant USE_DEDICATED_BRANCH_ADDER	: boolean := false;

--------------------------------------------------------------------------------
--	Statt der strukturellen Variante des Barrelshifters aus dem HWPR kann
--	eine alternative Loesung mit VHDL-Shiftoperatoren gewaehlt werden, sie
--	ist deutlich schneller und etwas groesser.
-- 	type ARM_SHIFTER_TYPE IS (SMALL,FAST);
--------------------------------------------------------------------------------
	constant SHIFTER_TYPE : ARM_SHIFTER_TYPE := SMALL; --FAST

--------------------------------------------------------------------------------
-- 	Die schnellere Neufassung des Barrelshifters wird etwas
-- 	schneller, wenn in Einzelfaellen ein abweichendes Verhalten
-- 	zur Ursprungsversion erlaubt wird. Version 2 der uebergeordneten
-- 	Shifterschaltung beruecksichtigt dies bereits. Bei Verwendung der 
-- 	Ursprungsversion und wenn beide Barrelshifter gegeneinander getestet
-- 	werden so ist FULL_COMPATIBLE auf jeden fall zu setzen.
-- 	Die Aenderung bringt keine substanzielle Verbesserung
--------------------------------------------------------------------------------
	constant BARRELSHIFTER_FULL_COMPATIPLE	: boolean := true;

--------------------------------------------------------------------------------
--	Etwas schnellere aber groessere Variante des allgemeinen Shifters
--------------------------------------------------------------------------------
	constant USE_SHIFTER_V2 : boolean := false;

--------------------------------------------------------------------------------
--	Version 2 der ALU besteht aus zwei getrennten Teilkomponenten fuer
--	arithmetische und logische Verknüpfungen und dabei für alle arithmetisch
--	Verknüpfungen genau eine gemeinsame Carry-Chain (deren Bestandteile
--	direkt instanziiert sind). In dieser Variante ist die ALU deutlich
--      kleiner und schneller als in der HWPR-Version und vermutlich nahe am
--	Optimum auf dem Spartan 3E.	
--	DEDICATED_ARITH_ZERO_ALU verlegt den Test auf 0 fuer den arithmetischen
--	Teil der neuen ALU in die Teilkomponenten in der Hoffnung,
--	eine geringere Verzoegerung durch den Test zu erhalten. Bisher zeitigt
--	das keinen nennenswerten Erfolg.
--------------------------------------------------------------------------------
	constant USE_ALU_V2 : boolean := false;
 	constant USE_DEDICATED_ARITH_ZERO_ALU : boolean := false;

--------------------------------------------------------------------------------
--	Statt der automatisch inferierten Variante des Multiplizierers fuer
--	32-Bit-Ergebnisse fuer den *-Operator kann eine haendisch erzeugte
--	Struktur aus 3 Block-Multiplizierern gewaehlt werden. Diese ist, 
--	ueberraschenderweise, 1 ns schneller.
--	Fuer die Zukunft ist eine Multiplikation in zwei Fliessbandstufen an-
--	gedacht, aktuell ist die entsprechende Option wirkungslos.
--------------------------------------------------------------------------------
	constant USE_STRUCTURAL_MULTIPLIER : boolean := false;
	constant USE_2_STAGE_MULTIPLIER	: natural range 0 to 1 := 0;

--------------------------------------------------------------------------------
--	Wenn nur schnell angebundener Speicher verwendet wird, kann
--	auf die Wartesignale verzichtet werden, was je nach uebriger
--	Konfiguration den moeglichen Takt steigert. Langsame Peripherie
--	zeigt sonst auf den Bussen einen Wartezyklus durch das WAIT-Signal an.
--------------------------------------------------------------------------------
	constant DISABLE_BUS_WAIT : boolean := false;

--------------------------------------------------------------------------------
--	Ist sichergestellt, dass Prozessorstruktur und Anwendung niemals
--	Data Aborts ausloesen, koennen die zusaetzlichen Bauteile zu deren
--	Unterstuetzung deaktiviert werden.
--------------------------------------------------------------------------------
	constant ENABLE_DATA_ABORT : boolean := true;

--------------------------------------------------------------------------------
--	Die folgenden Optionen legen fest, ob im Topmodul ein Network-
--	on-a-Chip (Teil einer Diplomarbeit) und ein ARM-Coprozessor
--	zur Anbindung an das NoC synthetisiert wird. Die letzte Konstante
--	ist der Initialwert es Zufallsgenerators im NoC.
--------------------------------------------------------------------------------
	constant USE_NoC			: boolean := false;
	constant USE_COPROCESSOR	: boolean := false;
	constant ACP_RAND_INIT		: std_logic_vector(31 downto 0) := X"10EF5C7A";

--------------------------------------------------------------------------------
--	In ArmTop_TB koennen beliebige Bedingungen
--	fuer das Anhalten der Simulation definiert werden.
--	Nur wenn die folgende Option gesetzt ist, werden diese Stoppbedingungen
--	in der Simulation beruecksichtigt.
--------------------------------------------------------------------------------
	constant USE_STOPP_CONDITION	: boolean := true;

--------------------------------------------------------------------------------
--	Die Hauptsteuerung zeigt normalerweise mit dedizierten Steuerleitungen
--	an, welche Leseports des Registerspeichers fuer die aktuelle Instruk-
--	tion verwendet werden. Experimentell kann ein ungenutzter Leseport
--	die bisher nicht verwendete, 32. physische Adresse erhalten. Sie wird
--	fuer Schreibports nie verwendet, sodass in der Bypasssteuerung
--	keine Uebereinstimmung zwischen der Adresse eines ungenutzten 
--	Leseports und einem Schreibport besteht.
--------------------------------------------------------------------------------
	constant USE_SPECIAL_ADDRESS_FOR_UNUSED_PORT	: boolean := false;

--------------------------------------------------------------------------------
--	Unwichtige, veraltete und weitere experimentielle Optionen
--------------------------------------------------------------------------------
	constant USE_STRUCTURAL_PRIORITY_ENCODER: boolean := false;
	constant MUL_USE_64BIT			: boolean := false;
	constant USE_OLD_IAR			: boolean := true;
	constant INC_DELAY				: natural range 2 to 3 := 2;

--------------------------------------------------------------------------------
--	Zeigt an, dass alle Signale des Datenbus Tristatetreiber verwenden.
--	Alternativ muessten alle Signale auf der Topebene des Projekts
--	gemultiplext werden.
--------------------------------------------------------------------------------
	constant ARM_DBUS_USE_TSDRIVERS : BOOLEAN := TRUE;

end package ArmConfiguration;



