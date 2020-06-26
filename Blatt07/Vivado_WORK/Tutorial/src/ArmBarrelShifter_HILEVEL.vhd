--------------------------------------------------------------------------------
--	Allgemeiner N-Bit-Barrelshifter des ARM-SoC fuer LSL, LSR, ASR, ROR
--	mit Shiftweiten von 0 bis n-1 Bit, verwendet werden die
--	VHDL-Shiftoperanden, die Abbildung erfolgt waehrend der Synthese auf
--	optimierte Makros. Sollten die Makros nicht zur Verfuegung stehen, sind
--	die 3 Shifter von Hand zum implementieren. Ein testweise mit 3
--	4:1-Mux-Stufen oder 8:1-Mux und 4:1-Mux Stufe implementierter
--	Linksshifter war nicht substanziell schneller als die Makros (die
--	Signalverzoegerung der Schaltung allein	minimal besser, jedoch
--	schlechter im Kontext des gesamten Barrelshifters nach Optimierung)
--------------------------------------------------------------------------------
--	Datum:		06.05.2010
--	Version:	1.1
--------------------------------------------------------------------------------
--	Aenderungen:
--	Gegenueber der urspruenglichen Fassung wurde der Ressourcenverbrauch
--	durch Abbildung von ASR und LSR auf einen Shifter verringert, darueber
--	hinaus die Laufzeit durch eine bessere Formulierung des Ergebnisauswahl
--	verringert.
--	Die Konstante BARRELSHIFTER_FULL_COMPATIPLE aus ArmConfiguration
--	entscheidet, ob diese Version des hochsprachlichen Barrelshifters voll
--	kompatibel zum Verhalten der (kompakteren) strukturellen Beschreibung
--	bleibt. Dies ist wichtig, um beide Versionen in der bisherigen Testbench
--	gegeneinander testen zu koennen. Bei Verzicht auf volle Kompatibilitaet
--	werden in der Schaltung zwei LUT-Stufen eingespart. Zum Einen wird
--	das ARITH_SHIFT-Signal unmittelbar als Vorzeichenbit des Rechtsshifts
--	verwendet (und muss in der uebergeordneten Komponente entsprechend 
--	gesetzt werden), zum anderen liefert die Schaltung falsche Ergebnisse
--	wenn eine andere Operation als "00" (kein Shift) mit Schiebeweite 0
--	aufgerufen wird. Die entsprechende Ueberpruefung kann in der ueber-
--	geordneten Schaltung effizienter erfolgen und das korrekte Ergebnis 
--	parallel zum Barrelshifter erzeugt werden.
--	Es handelt sich hier um Altlasten die daher ruehren, dass der
--	strukturelle Shifter zuerst implementiert wurde und die hochsprachliche
--	Beschreibung nur fuer den Test auf Korrektheit gedacht war. Eine 
--	grundsaetzliche Ueberarbeitung des Barrelshifters und der umgebenden
--	Shifterschaltung wuerde evtl. die Laufzeit weiter verkuerzen, ist
--	aber vorerst nicht vorgesehen.
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmConfiguration.BARRELSHIFTER_FULL_COMPATIPLE;

entity ArmBarrelShifter_HILEVEL is
--------------------------------------------------------------------------------
--	Breite der Operanden (n) und die Zahl der notwendigen Multiplexerstufen (m) 
--	um Shifts von 0 bis n-1 Stellen realisieren zu koennen. Es gilt: n = 2^m
--------------------------------------------------------------------------------
	generic (
		OPERAND_WIDTH : integer := 32;
	 	SHIFTER_DEPTH : integer := 5
	);
	Port ( 	
		OPERAND 	: in std_logic_vector(OPERAND_WIDTH-1 downto 0);
    	MUX_CTRL 	: in std_logic_vector(1 downto 0);
    	AMOUNT 		: in std_logic_vector(SHIFTER_DEPTH-1 downto 0);
    	ARITH_SHIFT	: in std_logic; 
    	C_IN 		: in std_logic;
        DATA_OUT 	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);
    	C_OUT 		: out std_logic
	);
end entity ArmBarrelShifter_HILEVEL;

architecture HILEVEL of ArmBarrelShifter_HILEVEL is
--	Integerinterpretation der Schiebeweite, benoetigt fuer die VHDL-Shiftoperationen
	signal AM_INT 		: integer range 0 to (2**SHIFTER_DEPTH) -1 := 0;

--------------------------------------------------------------------------------
--	Zur Erzeugung der Carry-Signale und der Auswahl eines Vorzeichenbits
--	sind beide Shifter breiter als der Urspruengliche Operand, 
--	die Rotationseinheit benoetigt diese Anpassung nicht.
--------------------------------------------------------------------------------
	signal LSL_OP	: bit_vector(OPERAND_WIDTH downto 0);	--Operand fuer Linksshift
	signal LSL_RES	: std_logic_vector(OPERAND_WIDTH downto 0);
	signal XSR_OP	: bit_vector(OPERAND_WIDTH+1 downto 0); --Operand fuer beide Rechtsshifts
	signal XSR_RES	: std_logic_vector(OPERAND_WIDTH+1 downto 0);
	signal ROR_OP	: bit_vector(OPERAND_WIDTH-1 downto 0); --Operand der Rotation
	signal ROR_RES	: std_logic_vector(OPERAND_WIDTH-1 downto 0);

	signal ARITH_BIT : std_logic;

begin
	AM_INT		<= to_integer(unsigned(AMOUNT));
--------------------------------------------------------------------------------
--	Je nach Konfiguration wird das korrekte Vorzeichenbit bereits im
--	umgebenden Shifter erzeugt.
--------------------------------------------------------------------------------
	ARITH_BIT	<= (ARITH_SHIFT and OPERAND(OPERAND'left)) when BARRELSHIFTER_FULL_COMPATIPLE else ARITH_SHIFT;

	LSL_OP		<= to_bitvector('0' & OPERAND);
	LSL_RES		<= to_stdlogicvector(LSL_OP sll AM_INT);
	
--	Mit ARITH_BIT='0' wird aus dem arithmetischen ein logischer Rechtsshift
	XSR_OP		<= to_bitvector(ARITH_BIT & OPERAND & '0');
	XSR_RES		<= to_stdlogicvector(XSR_OP sra AM_INT);

	ROR_OP		<= to_bitvector(OPERAND);
	ROR_RES		<= to_stdlogicvector(ROR_OP ror AM_INT);

--------------------------------------------------------------------------------
--	Ermittlung des Ergebnisses sowie des Carry-Bits in einem Prozess unter
--	Verwendung der VHDL-eigenen Shift-Operanden
--------------------------------------------------------------------------------
	SHIFT_HL : process(AM_INT,MUX_CTRL,C_IN,LSL_RES, XSR_RES, ROR_RES,OPERAND)
	begin	
--------------------------------------------------------------------------------
--	Bei Schifts um 0 Stellen werden OPERAND und C_IN unveraendert
--	durchgereicht, ebenso bei Multiplexersteuervector "00"; bei C_OUT wird
--	das korrekte Verhalten mit BARRELSHIFTER_FULL_KOMPATIPLE = true
--	erfuellt, weil das Shiften um 0 Stellen	redundant zu einer Operation
--	"nicht schieben" ist und die Schaltung verlangsamt.
--------------------------------------------------------------------------------

		case MUX_CTRL is
			when "00" =>
--------------------------------------------------------------------------------
--	"00" soll keinen Shift verursachen, allerdings ist es im Prinzip
--	bloedsinnig, dann ein Weite > 0 anzugeben. Die Unterscheidung wird nur 
--	aus Kompatibilitaetsgruenden beibehalten.
--------------------------------------------------------------------------------
				if BARRELSHIFTER_FULL_COMPATIPLE then
					DATA_OUT <= OPERAND;
				else
					DATA_OUT <= LSL_RES(OPERAND_WIDTH-1 downto 0);						
				end if;					
			when "01" =>				
				DATA_OUT <= LSL_RES(OPERAND_WIDTH-1 downto 0);
			when "10" =>
				DATA_OUT <= XSR_RES(OPERAND_WIDTH downto 1);				
			when others =>				
				DATA_OUT <= ROR_RES;--			
		end case;

		if AM_INT = 0 and BARRELSHIFTER_FULL_COMPATIPLE then
			C_OUT <= C_IN;
		else
			case MUX_CTRL is
				when "00" => --kein Shift
					C_OUT <= C_IN;
				when "01" =>
--					Linksshift, Carry steht ganz links im Ergebnis
--					(falsch fuer AMOUNT = 0)
					C_OUT <= LSL_RES(OPERAND_WIDTH);
				when "10" =>
--					Rechtsshift, Carry steht ganz rechts im Ergebnis
--					(falsch fuer AMOUNT = 0)
					C_OUT <= XSR_RES(0);
				when others =>
--					Rechtsrotation, Carry ist das letzte hereinrotierte
--					Bit, also das ganz links, sofern um wenigstens 
--					eine Stelle geschoben wurde
					C_OUT <= ROR_RES(OPERAND_WIDTH-1);
			end case;
		end if;	
	end process SHIFT_HL;	
end architecture HILEVEL;
