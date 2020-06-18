--------------------------------------------------------------------------------
--	Typdefinitionen und Konstanten des ARM-SoC (vereinfachte HWPR-Fassung)
--------------------------------------------------------------------------------
--	Datum:		29.10.2013
--	Version:	0.1
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package ArmTypes is
--------------------------------------------------------------------------------
--	Definierte Prozessormodi in CPSR[4:0], andere Werte fuehren zu unvorhersehbarem Verhalten
--	Prioritaeten: RESET>DATA_ABORT>FIQ>IRQ>PREFETCH_ABORT>(SWI|UNDEFINED)
--------------------------------------------------------------------------------
	subtype MODE is std_logic_vector(4 downto 0);
	constant USER		: MODE := "10000";	--16; Benutzermodus
	constant FIQ		: MODE := "10001";	--17; Fast Interrupt Modus
	constant IRQ		: MODE := "10010";	--18; Standard Interrupt Modus
	constant SUPERVISOR	: MODE := "10011";	--19; Softwareinterrupts (SVC, frueher SWI) und RESET
	constant ABORT		: MODE := "10111";	--23; Speicherzugriffsfehler in der Fetchphase einer Operation oder bei der Ausfuehrung einer LDR/STR-Operationen
	constant UNDEFINED	: MODE := "11011";	--27; Trap wegen unbekannter Anweisung
	constant SYSTEM		: MODE := "11111";	--31; Ausfuehren von Systemfunktionen, z.B. I/O-Operationen

--	Anmerkung: Funktion zur Feststellung valider Modi: VALID =  X4 (!X3!X2 + X1X0)

--------------------------------------------------------------------------------
--	Vektoradressen der verschiedenen Exceptions; Abort kennt zwei Vectoren, 
--	hinzu kommt der Resetvector
--------------------------------------------------------------------------------
	subtype Vector_Address is std_logic_vector(31 downto 0);
	constant VCR_RESET		: Vector_Address := X"00000000"; --Reset, wird im SVC-Modus ausgefuehrt
	constant VCR_UNDEFINED		: Vector_Address := X"00000004";
	constant VCR_SWI		: Vector_Address := X"00000008"; --Softwareinterrupt; im SVC-Modus ausgefuehrt	
	constant VCR_PREFETCH_ABORT	: Vector_Address := X"0000000C"; --Speicherzugriffsfehler beim Holen eines Befehls
	constant VCR_DATA_ABORT		: Vector_Address := X"00000010"; --Speicherzugriffsfehler beim Speicherzugriff in Befehlsausfuehrung
--	constant VCR_ADDRESS_EXCEPTION	: Vector_Address := X"00000014"; --wird von modernen ARMs nicht mehr verwendet
	constant VCR_IRQ		: Vector_Address := X"00000018"; --Vektoradresse fuer Interrupthandler
	constant VCR_FIQ		: Vector_Address := X"0000001C"; --Vektoradresse fuer Fast Interrupthandler

--------------------------------------------------------------------------------
--	Bezeichner fuer die verschiedenen Registeradressen
--------------------------------------------------------------------------------
	subtype RegAddress is std_logic_vector(3 downto 0);
	constant R0	: RegAddress := "0000";
	constant R1	: RegAddress := "0001";
	constant R2	: RegAddress := "0010";
	constant R3	: RegAddress := "0011";
	constant R4	: RegAddress := "0100";
	constant R5	: RegAddress := "0101";
	constant R6	: RegAddress := "0110";
	constant R7	: RegAddress := "0111";
	constant R8	: RegAddress := "1000";
	constant R9	: RegAddress := "1001";
	constant R10	: RegAddress := "1010";
	constant R11	: RegAddress := "1011";
	constant R12	: RegAddress := "1100";
	constant R13	: RegAddress := "1101";
	constant R14	: RegAddress := "1110";
	constant R15	: RegAddress := "1111";
--------------------------------------------------------------------------------
--	Alternativbezeichner fuer die Register
--	Argument x (Ax): allgemeine Register zur Uebergabe von Argumenten zwischen Funktionsaufrufen, duerfen von der aufgerufenen Funktion
--	frei verwendet werden. Sollen ihre Werte nach dem Funktionsaufruf weiter zur Verfuegung stehen, muss die aufrufende Funktion
--	sie sichern und nach dem Aufruf wiederherstellen. Daher sind diese Register "caller-saved"
--	Variable x (Vx): Diese Register haben ebenfalls keine spezielle Bedeutung, allerdings kann eine aufrufende Funktion davon ausgehen,
--	dass ihr Wert nach Ende eines Funktionsaufrufs unveraendert ist. Nutzt eine aufgerufene Funktion diese Register, muss sie sie sichern und wieder 
--	herstellen, daher die Bezeichnung "callee-saved"
--	Alle uebrigen Register haben im ARM Procedure Call Standard spezielle Funktionen, 
--	duerfen von Funktionen aber ggf. als normale Arbeitsregister verwendet werden. Je nach Anwendungsfall muessen ihre Inhalte gesichert werden. 
--	Nur R15, also der PC ist davon ausgenommen. 
--------------------------------------------------------------------------------
	alias A1 : RegAddress is R0;		--Argument 1
	alias A2 : RegAddress is R1;		--Argument 2
	alias A3 : RegAddress is R2;		--Argumeit 3
	alias A4 : RegAddress is R3;		--Argument 4
	alias V1 : RegAddress is R4;		--Variable 1
	alias V2 : RegAddress is R5;		--Variable 2
	alias V3 : RegAddress is R6;		--Variable 3
	alias V4 : RegAddress is R7;		--Variable 4
	alias V5 : RegAddress is R8;		--Variable 5
	alias SB : RegAddress is R9;		--Static Base
	alias SL : RegAddress is R10;		--Stack Limit
	alias FP : RegAddress is R11;		--Framepointer
	alias IP : RegAddress is R12;
	alias SP : RegAddress is R13;		--StackPointer:
	alias LR : RegAddress is R14; 		--LinkRegister
	alias PC : RegAddress is R15;		--ProgrammCounter

--------------------------------------------------------------------------------
--	Condition Codes des ARM, entsprechen dem OpCode  [31:28], Name ist
--	jeweils das Mnemonic; letzte Angabe: Statusbits, die die Bedingung erfuellen
--------------------------------------------------------------------------------
	subtype ConditionCode is std_logic_vector(31 downto 28);
	constant EQ	: ConditionCode := "0000";		--Equal; 				Z=1
	constant NE	: ConditionCode := "0001";		--Not Equal; 				Z=0
	constant CS	: ConditionCode := "0010";		--Carry Set; 				C=1
	constant HS	: ConditionCode := "0010";		--Unsigned higher or same; 		C=1 		-- identisch mit CS
	constant CC	: ConditionCode := "0011";		--Carry Clear;		 		C=0
	constant LO	: ConditionCode := "0011";		--Unsigned lower;	 		C=0 		-- identisch mit CC
	constant MI	: ConditionCode := "0100";		--Minus/negativ				N=1
	constant PL	: ConditionCode := "0101";		--Plus/positve or zeor			N=0
	constant VS	: ConditionCode := "0110";		--Overflow				V=1
	constant VC	: ConditionCode := "0111";		--No overflow				V=0
	constant HI	: ConditionCode := "1000";		--Unsigned higher			C=1 and Z=0
	constant LS	: ConditionCode := "1001";		--Unsigned lower or same		C=0 or Z=1 	--entspricht !(C=1 andZ=0)
	constant GE	: ConditionCode := "1010";		--Signed Greater or equal		N=V
	constant LT	: ConditionCode := "1011";		--Signed less than			N!=V
	constant GT	: ConditionCode := "1100";		--Signed Greater than			Z=0 and (N=V)
	constant LE	: ConditionCode := "1101";		--Signed less than or equal		Z=1 or (N!=V) 	--entspricht !(Z=0 and (N=V))
	constant AL	: ConditionCode := "1110";		--Always				any
--	Never darf in ARMv4 nicht verwendet werden und ist hier der Vollstaendigkeit halber angegeben
--	In ARMv5 und hoeher wird durch NV eine unbedingte Instruktion [sic!] angezeigt, weil 
--      auf diese Weise bereits verwendete Instruktionscodes, die aber nicht mit NV
--	verwendet werden durften eine neue Bedeutung erhalten koennen	
	constant NV	: ConditionCode := "1111";		--Never					non

--------------------------------------------------------------------------------	
--	Format der Instruktionen fuer Datenverarbeitung (Arithmetisch Logische Befehle):
--	[cond|00|#|opcode|Rn|Rd|Operand2]
--	12 der 16 Instruktionen erzeugen ein ALU-Ergebnis, das in Register Rd
--	gespeichert wird und zusaetzlich einen neuen Conditioncode der bei Bedarf 
--	ins Statusregister geschrieben wird.
--	Vier der Befehle erzeugen einen Conditioncode der unbedingt ins Statusregister 
--	geschrieben wird. Der ALU-Ergebnisausgang ist fuer diese vier Instruktionen 
--	(OP_TST,OP_TEQ,OP_CMP,OP_CMN) beliebig
--	"ConditionCode:=..." zeigt an, dass hier nur Bedingungsbits veraendert werden
--------------------------------------------------------------------------------	
	subtype OPCODE_DATA is std_logic_vector(24 downto 21);
	constant OP_AND	: OPCODE_DATA	:= "0000";	--Rd:=Rn AND Op2
	constant OP_EOR	: OPCODE_DATA	:= "0001";	--Rd:=Rn XOR Op2
	constant OP_SUB	: OPCODE_DATA	:= "0010";	--Rd:=Rn  - Op2
	constant OP_RSB	: OPCODE_DATA	:= "0011";	--Rd:=Op2 - Rn
	constant OP_ADD	: OPCODE_DATA	:= "0100";	--Rd:=Rn + Op2
	constant OP_ADC	: OPCODE_DATA	:= "0101";	--Rd:=Rn + Op2 + C		
	constant OP_SBC	: OPCODE_DATA	:= "0110";	--Rd:=Rn - Op2 + C -1
	constant OP_RSC	: OPCODE_DATA	:= "0111";	--Rd:=Op2- Rn  + C -1
	constant OP_TST	: OPCODE_DATA	:= "1000";	--ConditionCode:=Rn AND Op2
	constant OP_TEQ	: OPCODE_DATA	:= "1001";	--ConditionCode:=Rn XOR Op2
	constant OP_CMP	: OPCODE_DATA	:= "1010";	--ConditionCode:= Rn - Op2
	constant OP_CMN	: OPCODE_DATA	:= "1011";	--ConditionCode:= Rn + Op2 	;Compare negated
	constant OP_ORR	: OPCODE_DATA	:= "1100";	--Rd:= Rn OR Op2
	constant OP_MOV	: OPCODE_DATA	:= "1101";	--Rd:= Op2		;Move
	constant OP_BIC	: OPCODE_DATA	:= "1110";	--Rd:= Rn AND NOT Op2	;Bit Clear
	constant OP_MVN	: OPCODE_DATA	:= "1111";	--Rd:= NOT Op2		;Move negated

--------------------------------------------------------------------------------
--	Multiplikationsinstruktionen
--	Aufgefuehrt sind hier alle 6 moeglichen Instruktionen fuer M-Typ Armprozessoren. 
--	Bis auf weiteres sind nur OP_MUL und OP_MLA relevant
--	Format der Instruktionen: [cond|0000|mul3|S|Rd/RdHi|Rn/RdLo|Rs|1001|Rm]
--------------------------------------------------------------------------------
	subtype OPCODE_MUL is std_logic_vector(23 downto 21);
	constant OP_MUL 	: OPCODE_MUL	:= "000";	--Rd := (Rm * Rs)[31:0]				; 32Bit result
	constant OP_MLA 	: OPCODE_MUL	:= "001";	--Rd := ((Rm * Rs) + Rn)[31:0]			; 32Bit result, Multiply-accumulate
	constant OP_UMULL	: OPCODE_MUL	:= "100";	--RdHi:RdLo := unsigned(Rm * Rs)		; 64Bit result
	constant OP_UMLAL 	: OPCODE_MUL	:= "101";	--RdHi:RdLo := unsigned(RdHi:RdLo + Rm * Rs)	; 64Bit result, Multiply-accumulate
	constant OP_SMULL 	: OPCODE_MUL	:= "110";	--RdHi:RdLo := signed(Rm * Rs)			; 64Bit result, signed
	constant OP_SMLAL 	: OPCODE_MUL	:= "111";	--RdHi:RdLo := signed(RdHi:RdLo + Rm * Rs)	; 64Bit result, signed multiply-accumulate

--------------------------------------------------------------------------------
--	Codierung fuer Operationen, die der Shifter auf
--	einen Operanden anwenden kann, entspricht der
--	Codierung in den ARM-Instruktionen
--	RRX wird nicht explizit codiert sondern entspricht ROR mit einer Shiftweite von 0
--	Das "SH_"-Prefix ist notwendig, 
--	um die Mnemonics sicher von reservierten
--	Bezeichnern in VHDL unterscheiden zu koennen
--------------------------------------------------------------------------------
	subtype SHIFT_TYPE is STD_LOGIC_VECTOR(1 downto 0);
	constant SH_LSL	: SHIFT_TYPE := "00";
	constant SH_LSR	: SHIFT_TYPE := "01";
	constant SH_ASR	: SHIFT_TYPE := "10";
	constant SH_ROR	: SHIFT_TYPE := "11";

--------------------------------------------------------------------------------
--	Zur Recodierung von Shiftweite und -typ muss festgestellt werden,
--	welche Form von Operand 2 vorliegt. Der Typ kann in der Decodestufe
--	andhand der Ergebnisse von ArmCoarseDecode festgestellt werden.
--------------------------------------------------------------------------------	
	subtype OPERAND_2_TYPE is std_logic_vector(1 downto 0);
	constant OP2_IMMEDIATE 			: OPERAND_2_TYPE := "00";
	constant OP2_REGISTER 			: OPERAND_2_TYPE := "01";
	constant OP2_REGISTER_REGISTER 		: OPERAND_2_TYPE := "10";
	constant OP2_NO_SHIFTER_OPERAND 	: OPERAND_2_TYPE := "11";

--------------------------------------------------------------------------------	
--	Definition des Zugriffstyps auf dem Datenbus
--------------------------------------------------------------------------------	
	subtype DMAS_TYPE is std_logic_vector(1 downto 0);
	constant DMAS_BYTE 	: DMAS_TYPE := "00";	-- Bytezugriff
	constant DMAS_HWORD 	: DMAS_TYPE := "01";	-- Halbwortzugriff
	constant DMAS_WORD 	: DMAS_TYPE := "10";	-- Wortzugriff
	constant DMAS_RESERVED 	: DMAS_TYPE := "11";	-- tritt formal nicht auf

--------------------------------------------------------------------------------	
--	Definition eines Typs fuer die Verwaltung des CPSR und der 5 SPSR
--------------------------------------------------------------------------------	
	type PSR_TYPE is record
		PSR_CC : std_logic_vector(3 downto 0);
		PSR_IF : std_logic_vector(1 downto 0);
		PSR_MODE : MODE;
	end record PSR_TYPE;

--------------------------------------------------------------------------------	
--	Array fuer die geschlossene Darstellung der 5 SPS-register
--------------------------------------------------------------------------------	
	type ARR_OF_PSR_TYPE is array(1 to 5) of PSR_TYPE;

--------------------------------------------------------------------------------	
--	Definitionen fuer die Peripherie
--------------------------------------------------------------------------------	
	type RS232_REGISTER_SET_TYPE is array ( 0 to 3 ) of std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------	
--	Typ und Konstanten fuer die 1-aus-16-Codierung der ersten Decoderstufe.
--------------------------------------------------------------------------------	
	subtype COARSE_DECODE_TYPE is std_logic_vector(15 downto 0);

	constant CD_UNDEFINED				: COARSE_DECODE_TYPE := X"0000";
	constant CD_SWI					: COARSE_DECODE_TYPE := X"0001";
	constant CD_COPROCESSOR				: COARSE_DECODE_TYPE := X"0002";
	constant CD_BRANCH				: COARSE_DECODE_TYPE := X"0004";
	constant CD_LOAD_STORE_MULTIPLE			: COARSE_DECODE_TYPE := X"0008";
	constant CD_LOAD_STORE_UNSIGNED_IMMEDIATE	: COARSE_DECODE_TYPE := X"0010";
	constant CD_LOAD_STORE_UNSIGNED_REGISTER	: COARSE_DECODE_TYPE := X"0020";
	constant CD_LOAD_STORE_SIGNED_IMMEDIATE		: COARSE_DECODE_TYPE := X"0040";
	constant CD_LOAD_STORE_SIGNED_REGISTER		: COARSE_DECODE_TYPE := X"0080";
	constant CD_ARITH_IMMEDIATE			: COARSE_DECODE_TYPE := X"0100";
	constant CD_ARITH_REGISTER			: COARSE_DECODE_TYPE := X"0200";
	constant CD_ARITH_REGISTER_REGISTER		: COARSE_DECODE_TYPE := X"0400";
	constant CD_MSR_IMMEDIATE			: COARSE_DECODE_TYPE := X"0800";
	constant CD_MSR_REGISTER			: COARSE_DECODE_TYPE := X"1000";
	constant CD_MRS					: COARSE_DECODE_TYPE := X"2000";
	constant CD_MULTIPLY				: COARSE_DECODE_TYPE := X"4000";
	constant CD_SWAP				: COARSE_DECODE_TYPE := X"8000";

--------------------------------------------------------------------------------	
--	Typ fuer die Zustaende der Prozessorsteuerung
--------------------------------------------------------------------------------	
	type ARM_STATE_TYPE is (STATE_FETCH, STATE_DECODE, STATE_SWAP, STATE_DABORT, 
				STATE_LINK, STATE_WAIT_TO_DECODE, STATE_WAIT_TO_FETCH, STATE_LDM, STATE_LDC);

--------------------------------------------------------------------------------
--	Typdefinition der Konfigurationseintraege fuer den Chip-Select-Generator
--------------------------------------------------------------------------------
	type CSG_ENTRY_TYPE is record
		ENABLE_CS_LINE		: std_logic;
		ALLOW_USER			: std_logic;
		BASE_ADDRESS		: std_logic_vector(19 downto 0);
		BASE_ADDRESS_MASK 	: std_logic_vector(19 downto 0);
	end record CSG_ENTRY_TYPE;

--------------------------------------------------------------------------------
--	Einige Masken fuer den Maskenparameter von CSG_ENTRY_TYPE
--------------------------------------------------------------------------------
	subtype CSG_MASK_TYPE is std_logic_vector(19 downto 0);
	constant CSG_MASK_4K	: CSG_MASK_TYPE := X"FFFFF";  --11..1111
	constant CSG_MASK_8K	: CSG_MASK_TYPE := X"FFFFE";  --11..1110
	constant CSG_MASK_16K	: CSG_MASK_TYPE := X"FFFFC";  --11..1100
	constant CSG_MASK_32K	: CSG_MASK_TYPE := X"FFFF8";  --11..1000
	constant CSG_MASK_2G	: CSG_MASK_TYPE := X"80000";  --10..0000
	constant CSG_MASK_4G	: CSG_MASK_TYPE := X"00000";  --00..0000

--------------------------------------------------------------------------------
--	Typ fuer die Gesamtheit der Konfigurationseintraege des CSG
--------------------------------------------------------------------------------
	type CSG_ENTRIES_TYPE is array(0 to 7) of CSG_ENTRY_TYPE;

--------------------------------------------------------------------------------
--	Subtypen fuer die verschiedenen langen Pipelines der Kontrollsignale
--	im ARM-Kern und Coprozessoren, soll die Menge der verschiedenen 
--	Signale und Signaldeklarationen reduzieren
--	Die Typen beinhalten jeweils das Signal in der ID-Stufe (Index 0) gefolgt
--	von bis zu 3 Registerstufen
--------------------------------------------------------------------------------
	subtype WB_CTRL_SIG_TYPE	is std_logic_vector(0 to 3);
	subtype MEM_CTRL_SIG_TYPE	is std_logic_vector(0 to 2);
	subtype EX_CTRL_SIG_TYPE	is std_logic_vector(0 to 1);

	type EX_CTRL_SIG_7VEC_TYPE is array(0 to 1) of std_logic_vector(6 downto 0);
	type EX_CTRL_SIG_6VEC_TYPE is array(0 to 1) of std_logic_vector(5 downto 0);
	type EX_CTRL_SIG_5VEC_TYPE is array(0 to 1) of std_logic_vector(4 downto 0);
	type EX_CTRL_SIG_4VEC_TYPE is array(0 to 1) of std_logic_vector(3 downto 0);
	type EX_CTRL_SIG_2VEC_TYPE is array(0 to 1) of std_logic_vector(1 downto 0);
	type MEM_CTRL_SIG_2VEC_TYPE is array(0 to 2) of std_logic_vector(1 downto 0);
	type WB_CTRL_SIG_4VEC_TYPE is array(0 to 3) of std_logic_vector(3 downto 0);
	type WB_CTRL_SIG_8VEC_TYPE is array(0 to 3) of std_logic_vector(7 downto 0);
	type WB_CTRL_SIG_10VEC_TYPE is array(0 to 3) of std_logic_vector(9 downto 0);

--------------------------------------------------------------------------------
--	Typen fuer die Steuersignale des Shifters und den Transport
--	der Steuersignale im Kontrollpfad
--------------------------------------------------------------------------------
	type SHIFT_CTRL_TYPE is record
		SHIFT_CTRL_AMOUNT	: std_logic_vector(5 downto 0);
		SHIFT_CTRL_TYPE		: SHIFT_TYPE;
		SHIFT_CTRL_RRX		: std_logic;
		SHIFT_CTRL_OPC		: std_logic;
	end record SHIFT_CTRL_TYPE;

	type SHIFT_EX_CTRL_TYPE is record
		SHIFT_EX_CTRL_TYPE		: SHIFT_TYPE;
		SHIFT_EX_CTRL_RRX		: std_logic;
	end record SHIFT_EX_CTRL_TYPE;

	type EX_SHIFT_EX_CTRL_TYPE is array(0 to 1) of SHIFT_EX_CTRL_TYPE;

--------------------------------------------------------------------------------
--	Typ fuer die Steuerinformationen zum PSR-Modul zwischen Kontrollpfad
--	und Datenpfad.
--	Das Enablesignal fehlt hier absichtlich, da es innerhalb des 
--	Kontrollpfades haeufig manipuliert werden muss was die Beschreibung
--	in einem Record mit den uebrigen Signalen erschwert
--	READ_PSR fehlt, weil es zur ID statt zur WB-Stufe gehoert
--------------------------------------------------------------------------------
	type PSR_CTRL_TYPE is record --13 Bit
		EXC_ENTRY		: std_logic;
		EXC_RETURN		: std_logic;
		SET_CC			: std_logic;
		WRITE_SPSR		: std_logic;
		MASK			: std_logic_vector(3 downto 0);
		MODE			: std_logic_vector(4 downto 0);
	end record PSR_CTRL_TYPE;
	type WB_PSR_CTRL_TYPE is array(0 to 3) of PSR_CTRL_TYPE;

--------------------------------------------------------------------------------
--	Codierung der Schnittstellensignale zwischen Hauptprozessor und
--	Coprozessor. Der Typ entspricht in etwa den Coprozessorsignalen CPA und
--	CPB der dreistufigen ARM-Prozessoren (konkret: ARM7TDMI), allerdings ist
--	CPA,CPA = 10 dort keine Bedeutung zugeordnet. Die Bezeichnung des
--	Signals ist an den ARM9TDMI angelehnt, dort ist die Zuordnung von
--	Bedeutung und Code jedoch verschieden.
--------------------------------------------------------------------------------
	subtype COPROCESSOR_HANDSHAKE_TYPE is std_logic_vector(1 downto 0); 
	constant CHS_WAIT				: COPROCESSOR_HANDSHAKE_TYPE := "01";
	constant CHS_GO					: COPROCESSOR_HANDSHAKE_TYPE := "00";
	constant CHS_LAST				: COPROCESSOR_HANDSHAKE_TYPE := "10";
	constant CHS_ABSENT				: COPROCESSOR_HANDSHAKE_TYPE := "11";

--------------------------------------------------------------------------------	
--	Typ fuer das uebergeordneten Steuersignal zur Auswahl der aktiven 
--	Teilsteuerung des Coprozessors
--------------------------------------------------------------------------------	
	type COP_CTRL_TOKEN_TYPE is (COP_TOKEN_MAIN, COP_TOKEN_LDC, COP_TOKEN_NOC);			

--------------------------------------------------------------------------------
--	Willkuerliche Konstanten fuer die Resultate des Decoders fuer
--	Coprozessorinstruktionen
--------------------------------------------------------------------------------
	subtype COPROCESSOR_INSTRUCTION_TYPE is std_logic_vector(2 downto 0);
	constant CIT_NON				: COPROCESSOR_INSTRUCTION_TYPE := "000";
	constant CIT_CDP				: COPROCESSOR_INSTRUCTION_TYPE := "010";
	constant CIT_MRC				: COPROCESSOR_INSTRUCTION_TYPE := "100";
	constant CIT_MCR				: COPROCESSOR_INSTRUCTION_TYPE := "101";
	constant CIT_LDC				: COPROCESSOR_INSTRUCTION_TYPE := "110";
	constant CIT_STC				: COPROCESSOR_INSTRUCTION_TYPE := "111";

--------------------------------------------------------------------------------	
--	Konstanten fuer die Werte von DnRW des Datenbusses	
--------------------------------------------------------------------------------	
	constant DnRW_WRITE : std_logic := '1';
	constant DnRW_READ : std_logic := '0';

--------------------------------------------------------------------------------	
--	Tiefe des History-Buffers, der zur Behandlung von Data Aborts
--	benoetigt wird.	
--------------------------------------------------------------------------------	
	constant NR_IAR_HISTORY_BUFFER_ENTRIES : natural := 8;
	type IAR_HISTORY_BUFFER_TYPE is array(0 to NR_IAR_HISTORY_BUFFER_ENTRIES-1) of std_logic_vector(31 downto 2);

--------------------------------------------------------------------------------	
--	Jeder in Ausfuehrung befindlichen Instruktion ist eine ID zugeordnet,
--	die Breite der ID kann Prozessorweit eingestellt werden. Fuer die 
--	gegenwaertige Implementierung ist 3 ausreichend.	
--------------------------------------------------------------------------------	
	constant INSTRUCTION_ID_WIDTH : natural := 3;

--------------------------------------------------------------------------------	
--	Jeweils am Ende einer Stufe, wird die ID der aktuell die Stufe
--	durchlaufenden Instruktion zur naechsten Stufe uebergeben um bei einem
--	Data Abort den PC aus dem History Buffer rekonstruieren zu koennen,
--	im Moment reichen 5 ID-Eintraege mit je drei Bit, streng genommen
--	waeren sogar zwei Bit ausreichend, mit dreien sind zukuenftige
--	Erweiterungen (tiefere Pipeline, out of order issue) flexibler machbar.
--	Ein Signal des folgenden Typs entspricht der Fliessbandkomponente,
--	die die ID von Stufe zu Stufe weiterreicht.
--------------------------------------------------------------------------------	
	type INSTRUCTION_ID_REGISTER_TYPE is array(0 to 4) of std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);

--------------------------------------------------------------------------------	
--	unwichtige und obsolete Typen, Konstanten und Funktionen
--------------------------------------------------------------------------------		
	function boolToSl(THIS_BOOL : boolean) return std_logic;
	type ARR3_OF_BOOLEAN is array(2 downto 0) of boolean; 
	type ARM_SHIFTER_TYPE IS (SMALL,FAST);
	type IAR_HB_CAM_TYPE is array(0 to NR_IAR_HISTORY_BUFFER_ENTRIES-1) of std_logic_vector(INSTRUCTION_ID_WIDTH -1 downto 0);
	type ModeAndReg is record
		aMode : MODE;
		addr : integer range 0 to 15;
	end record ModeAndReg;
--------------------------------------------------------------------------------
--	Typ fuer die Steuerung der Wortmanipulationseinheit (obsolet?)
--------------------------------------------------------------------------------
--	type WMP_CTRL_TYPE is record
--		WMP_SIGNED	: std_logic;
--		WMP_HW		: std_logic;
--		WMP_BYTE	: std_logic;
--	end record WMP_CTRL_TYPE;
--	type MEM_WMP_CTRL_TYPE	is array(0 to 2) of WMP_CTRL_TYPE;	
end ArmTypes;

package body ArmTypes is
	function boolToSl(THIS_BOOL : boolean) return std_logic is
   	begin
	if THIS_BOOL = false then
		return '0';
	else
		return '1';
	end if;	   
   end function boolToSl;
end ArmTypes;
