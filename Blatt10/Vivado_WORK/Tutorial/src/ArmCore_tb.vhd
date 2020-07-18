--------------------------------------------------------------------------------
--	Testbench fuer den ARM-Kern ohne Peripherie des HWPR-Prozessorsystems
--------------------------------------------------------------------------------
--	Datum:		05.07.2010
--	Version:	0.6
--------------------------------------------------------------------------------

use std.textio.all;
library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;
	use ieee.std_logic_textio.hwrite;
library work;
	use work.TB_TOOLS.all;
	use work.ArmConfiguration.all;
	use work.ArmGlobalProbes.all;
	use work.ArmTypes.all;
	use work.ArmRegAddressTranslation.all;
--	library ARM_SIM_LIB;
--	use ARM_SIM_LIB.ArmMeminterface.all;
--	use ARM_SIM_LIB.ArmGlobalProbes.all;

entity ArmCore_tb is
end entity ArmCore_tb;

architecture BEHAVE of ArmCore_tb is
--	Testzyklen nach Speicherinitialisierung und Reset
	constant NR_OF_TESTCYCLES : natural := 61;

	type COVERAGE_COUNTER_NAMES is array(0 to 17) of line;
	shared variable COVERAGE_NAMES : COVERAGE_COUNTER_NAMES;

	type INSTRUCTIONS_MEANING_TYPE is array(0 to 40) of line;
	shared variable  INSTRUCTIONS_MEANING : INSTRUCTIONS_MEANING_TYPE;

	type ALL_VALID_MODES_TYPE is array(0 to 6) of MODE;
	constant ALL_VALID_MODES : ALL_VALID_MODES_TYPE := (SUPERVISOR, USER, SYSTEM, FIQ, IRQ, ABORT, UNDEFINED);

	type EXPECTED_INST_ADDR_TYPE is array(1 to NR_OF_TESTCYCLES) of natural;
	shared variable EXPECTED_INST_ADDR, RECORDED_INST_ADDR : EXPECTED_INST_ADDR_TYPE;

	type EXPECTED_CC_TYPE is array(1 to NR_OF_TESTCYCLES) of std_logic_vector(3 downto 0);
	shared variable EXPECTED_CC : EXPECTED_CC_TYPE := (others => "0000");
	
--	Zaehlvariablen diverser Fehlertypen
	shared variable CC_ERRORS, REG_ERRORS, INST_ERRORS,DATA_TRANSACTION_ERRORS, POINTS : natural := 0;

	signal TESTCYCLE_NR : natural := 0;


	component ArmMemInterface
	port(
		RAM_CLK		: in std_logic;
		IDE		: in std_logic;
		IA		: in std_logic_vector(31 downto 2);
		ID		: out std_logic_vector(31 downto 0);
		IABORT		: out std_logic;
		DDE		: in std_logic;
		DnRW		: in std_logic;
		DMAS		: in std_logic_vector(1 downto 0);
		DA		: in std_logic_vector(31 downto 0);    
		DDIN		: in std_logic_vector(31 downto 0);      
		DDOUT		: out std_logic_vector(31 downto 0);      
		DABORT		: out std_logic
		);
	end component ArmMemInterface;

	signal	CORE_CLK, CORE_RST : std_logic := '1';
	signal	CORE_INV_CLK : std_logic := '0';

	signal	CORE_IEN	: std_logic;
	signal	CORE_IBE	: std_logic;
	signal	CORE_IA		: std_logic_vector(31 downto 2);
	signal	CORE_ID		: std_logic_vector(31 downto 0);
	signal	CORE_IABORT	: std_logic;

	signal	CORE_DEN	: std_logic;
	signal	CORE_DBE	: std_logic;
	signal	CORE_DnRW	: std_logic;
	signal	CORE_DABORT 	: std_logic;
	signal	CORE_DA		: std_logic_vector(31 downto 0);
	signal	CORE_DDIN	: std_logic_vector(31 downto 0);
	signal	CORE_DDOUT	: std_logic_vector(31 downto 0);
	signal	CORE_DMAS	: std_logic_vector(1 downto 0);
	signal	CORE_IMODE	: std_logic_vector(4 downto 0);
	signal	CORE_DMODE	: std_logic_vector(4 downto 0);
	signal TEST_DEN		: std_logic := '0';
	signal MEM_DEN		: std_logic;
	
	type EXPECTED_WRITE_ADDRESSES_TYPE is array(0 to 0) of std_logic_vector(31 downto 0);
	type EXPECTED_WRITE_DATA_TYPE is array(0 to 0) of std_logic_vector(31 downto 0);

	constant EXPECTED_WRITE_ADDRESSES : EXPECTED_WRITE_ADDRESSES_TYPE := (std_logic_vector(to_unsigned(256,32)), others => (others => '0'));
	constant EXPECTED_WRITE_DATA : EXPECTED_WRITE_DATA_TYPE := (X"23232323", others => (others => '0'));

--	Testsignale aus Datenpfad und Kontrollpfad
	signal TEST_CC		: std_logic_vector(3 downto 0);
	signal TEST_MET		: std_logic;
	signal INIT_RAM		: std_logic := '0';
	signal SIMULATION_RUNNING : boolean := true;

	type ALL_REGISTERS_TYPE is array(0 to 30) of std_logic_vector(31 downto 0);
	type ALL_REGISTERS_FLAT_TYPE is array(0 to 30) of std_logic_vector(31 downto 0);
	signal ALL_REGISTERS : ALL_REGISTERS_TYPE;
	signal ALL_REGISTERS_FLAT : ALL_REGISTERS_FLAT_TYPE;

	signal ALL_REGISTERS_EXPECTED: ALL_REGISTERS_TYPE;

	type ALL_REGISTERS_NAMES_TYPE is array(0 to 30) of STRING(1 to 7);

	constant ALL_REGISTERS_NAMES : ALL_REGISTERS_NAMES_TYPE := 
			 ("R0     ","R1     ","R2     ","R3     ","R4     ","R5     ","R6     ","R7     ",
			  "R8     ","R9     ","R10    ","R11    ","R12    ","R13    ","R14    ","R15    ",
			  "R8_FIQ ","R9_FIQ ", "R10_FIQ", "R11_FIQ","R12_FIQ", "R13_FIQ", "R14_FIQ",
		      	  "R13_IRQ", "R14_IRQ", "R13_SVC", "R14_SVC", "R13_ABT", "R14_ABT", "R13_UND", "R14_UND");

	constant PIPE : string(1 to 1) := "|";
	
	procedure PRINT_REGFILE is
			variable TX_LOC : line;
		begin
			report SEPARATOR_LINE;
			report "USER" & TAB_CHAR & TAB_CHAR & PIPE & "FIQ" & TAB_CHAR & TAB_CHAR & PIPE & "IRQ" & TAB_CHAR & TAB_CHAR & PIPE & "SVC" &TAB_CHAR & TAB_CHAR & PIPE & "ABT" & TAB_CHAR & TAB_CHAR & PIPE & "UND" & TAB_CHAR & TAB_CHAR & PIPE;
			report SEPARATOR_LINE;
			for i in 0 to 15 loop
				hwrite(TX_LOC, ALL_REGISTERS(i));
				STD.textio.write(TX_LOC, TAB_CHAR & PIPE);

				if (i > 7) and (i < 15) then
					hwrite(TX_LOC, ALL_REGISTERS(15 + (i-7))); STD.textio.write(TX_LOC, TAB_CHAR & "|"); 	
					if(i = 13) then
						hwrite(TX_LOC, ALL_REGISTERS(23)); STD.textio.write(TX_LOC,TAB_CHAR & "|"); 
						hwrite(TX_LOC, ALL_REGISTERS(25)); STD.textio.write(TX_LOC,TAB_CHAR & "|"); 
						hwrite(TX_LOC, ALL_REGISTERS(27)); STD.textio.write(TX_LOC,TAB_CHAR & "|"); 
						hwrite(TX_LOC, ALL_REGISTERS(29)); STD.textio.write(TX_LOC,TAB_CHAR & "|");	
					end if;
					if(i = 14) then
						hwrite(TX_LOC, ALL_REGISTERS(24)); STD.textio.write(TX_LOC,TAB_CHAR & "|"); 
						hwrite(TX_LOC, ALL_REGISTERS(26)); STD.textio.write(TX_LOC,TAB_CHAR & "|");
						hwrite(TX_LOC, ALL_REGISTERS(28)); STD.textio.write(TX_LOC,TAB_CHAR & "|"); 
						hwrite(TX_LOC, ALL_REGISTERS(30)); STD.textio.write(TX_LOC,TAB_CHAR & "|");	
					end if;	
				end if;
				report TX_LOC.ALL;
				Deallocate(TX_LOC);
			end loop;
			report SEPARATOR_LINE;
	end procedure PRINT_REGFILE;

--	procedure PRINT_REGFILE is
--		variable TX_LOC : line;
--	begin
--		report SEPARATOR_LINE;
--		for i in 0 to 31 loop
--			std.textio.write(TX_LOC, "R" & integer'image(i) & ":" & TAB_CHAR); hwrite(TX_LOC, ALL_REGISTERS(i));
--			report TX_LOC.all;
--			Deallocate(TX_LOC);
--		end loop;
--		report SEPARATOR_LINE;
--	end procedure PRINT_REGFILE;


	procedure REPORT_INSTRUCTION(THIS_INST : in std_logic_vector(31 downto 0))is
	begin
		report "Instruktion : " & SLV_TO_STRING(THIS_INST(31 downto 28)) & "||" &	SLV_TO_STRING(THIS_INST(27 downto 20)) & "||" & SLV_TO_STRING(THIS_INST(19 downto 8)) & "||" & SLV_TO_STRING(THIS_INST(7 downto 4)) & "||" & SLV_TO_STRING(THIS_INST(3 downto 0));
	end procedure REPORT_INSTRUCTION;
	

--	Konstanten fuer diverse ARMv4-Instruktionen
	constant NOP		: std_logic_vector(31 downto 0) := X"E" & "000" & OP_MOV & '0' & "0000" & "0000" & "0000" & "0000" & "0000";
	constant NEVER		: std_logic_vector(31 downto 0) := X"F" & "000" & OP_MOV & '0' & "0000" & "0000" & "0000" & "0000" & "0000";
	constant ADD_R0_R1_R2	: std_logic_vector(31 downto 0) := X"E" & "000" & OP_ADD & '0' & "0000" & "0010" & "0000" & "0000" & "0001";
	constant ADD_R2_R3_R4	: std_logic_vector(31 downto 0) := X"E" & "000" & OP_ADD & '0' & "0010" & "0100" & "0000" & "0000" & "0011";
--	Byte-Storebefehl mit preinkrement eines Immediates auf ein Register das 0 enthalten sollte
	constant STRB_R0_R5_256 : std_logic_vector(31 downto 0) := X"E" & "010" & "1111" & '0' & "0101" & "0000" & std_logic_vector(to_unsigned(256,12));
	constant STRB_R4	: std_logic_vector(31 downto 0) := X"E" & "010" & "1110" & '0' & "0101" & "0100" & std_logic_vector(to_unsigned(256,12));

	constant MOV_32_R6	: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & "0110" & "0000" & X"20";
	constant MOV_8_R7	: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & "0111" & "0000" & X"08";
--	56 nach R7 schreiben (ist eine Byteadresse)
	constant MUL_R6_R7_R8	: std_logic_vector(31 downto 0) := X"E" & "0000" & "000" & '1' & "1000" & "0000" & "0111" & "1001" & "0110";
--	Signed Byte Load mit Post Dekrement, R8 als Basisadresse, Writeback der Adresse, Offset 4, schreibt 252 nach R8
	constant LDRSB_R8_0_R13 : std_logic_vector(31 downto 0) := X"E" & "000" & "0010" & '1' & "1000" & "1101" & "0000" & "1101" & "0100";
--	Rn - OP2
	constant CMP_R4_R2	: std_logic_vector(31 downto 0) := X"E" & "000" & OP_CMP & '1' & "0100" & "0110" & "0000" & "0000" & "0010"; -- Rd, hier R6, muss ignoriert werden 
--	Subtraktion R12 = R0 - R2 << 4, Setzen des condition Codes, das Ergebnis muss negativ sein
	constant SUBS_R0_R2_R12_LSL2	: std_logic_vector(31 downto 0) := X"E" & "000" & OP_SUB & '1' & "0000" & "1100" & "00010" & SH_LSL & '0' & "0010";
	constant STOPP		: std_logic_vector(31 downto 0)	:= X"E" & "101" & '0' & std_logic_vector(to_signed(-2,24));
	constant BRANCH_4_LINK	: std_logic_vector(31 downto 0)	:= X"E" & "101" & '1' & std_logic_vector(to_signed(4,24));
	constant BRANCH_2_NO_LINK	: std_logic_vector(31 downto 0)	:= X"E" & "101" & '0' & std_logic_vector(to_signed(2,24));
	constant NO_BRANCH_4_LINK	: std_logic_vector(31 downto 0)	:= X"F" & "101" & '1' & std_logic_vector(to_signed(4,24));
--	Sprung zu einer Wortadresse hinter den Exceptionvektoren (erste gültige Wortadresse: 8)
	-- Reset liegt an 0, dort muss dieser Sprung eingebaut werden, Undefined liegt an 1, dort wird nur eine Rückkehr hinter den verursachenden Befehl eingebaut
--	Der Sprung ist PC-relativ, daher 6 statt 8
	constant BRANCH_START_NO_LINK : std_logic_vector(31 downto 0)	:= X"E" & "101" & '0' & std_logic_vector(to_signed(6,24));

--	Coprozessor um den Kern nach UNDEFINED zu zwingen, Undefined verzweigt nach Adresse 4 (Byteadresse 4!)
	constant LDC : std_logic_vector(31 downto 0)	:= X"E" & "110" & '0' & "0001" & "0000" & "0000" & X"000";
--	Move-Instruktion zur Rueckkehr aus UNDEFINED
	constant MOVS_R14_PC	: std_logic_vector(31 downto 0) := X"E" & "000" & OP_MOV & '1' & R0 & PC & X"00" & LR;

--	constant MOV_11_R11 : std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R11 & "0000" & X"11";

--	Sprung um drei Adressen, normale Arithmetische Instruktion mit Sprungwirkung
	constant ADD_4_PC_PC		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_ADD & '0' & PC & PC & "0000" & "0000" & "0100";
	constant MOV_4_R9		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R9 & "0000" & X"04";
	constant MOV_2_R10		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R10 & "0000" & X"02";
	constant SUBS_R7_32_R11		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_SUB & '1' & R7 & R11 & "0000" & std_logic_vector(to_signed(32,8));
	constant ADDS_R7_R11_R3_ASR1	: std_logic_vector(31 downto 0) := X"E" & "000" & OP_ADD & '1' & R7 & R3 & "00001" & SH_ASR & '0' & R11;

	constant SUBS_R14_4_PC		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_SUB & '1' & R14 & PC & "0000" & std_logic_vector(to_signed(4,8));
	constant SUBS_R14_8_PC		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_SUB & '1' & R14 & PC & "0000" & std_logic_vector(to_signed(8,8));
	constant MOV_0_R0		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R0 & "0000" & X"00";
	constant MOV_1_R1		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R1 & "0000" & X"01";
	constant MOV_2_R2		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R2 & "0000" & X"02";
	constant MOV_3_R3		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R3 & "0000" & X"03";
	constant MOV_4_R4		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R4 & "0000" & X"04";
	constant MOV_5_R5		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R5 & "0000" & X"05";
	constant MOV_6_R6		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R6 & "0000" & X"06";
	constant MOV_7_R7		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R7 & "0000" & X"07";
	constant MOV_8_R8		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R8 & "0000" & X"08";
	constant MOV_9_R9		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R9 & "0000" & X"09";
	constant MOV_10_R10		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R10 & "0000" & X"0A";
	constant MOV_11_R11		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R11 & "0000" & X"0B";
	constant MOV_128_R12		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R12 & "0000" & X"80";--Basisadresse fuer Daten
	constant MOV_13_R13		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R13 & "0000" & X"0D";
	constant MOV_14_R14		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R14 & "0000" & X"0E";
--	constant MOV_15_R15		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_MOV & '0' & "0000" & R15 & "0000" & X"0F";

	constant STM_IAW_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "0101" & "0" & R12 & X"07FF"; --postinkrement
--	constant LDM_DB_R12_R0_to_R10 : std_logic_vector(31 downto 0) := X"E" & "100" & "1000" & "1" & R12 & X"07FF"; --predekrement
	constant SUB_R12_64_R12		: std_logic_vector(31 downto 0) := X"E" & "001" & OP_SUB & '0' & R12 & R12 & "0000" & std_logic_vector(to_signed(64,8));

	constant STM_IA_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "0101" & "0" & R12 & X"07FF"; --postinkrement
	constant STM_IB_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "1101" & "0" & R12 & X"07FF"; --preinkrement
	constant STM_DA_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "0001" & "0" & R12 & X"07FF"; --postdekrement
	constant STM_DB_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "1001" & "0" & R12 & X"07FF"; --predekrement

	constant LDM_IA_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "0101" & "1" & R12 & X"07FF"; --postinkrement
	constant LDM_IB_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "1101" & "1" & R12 & X"07FF"; --preinkrement
	constant LDM_DA_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "0001" & "1" & R12 & X"07FF"; --postdekrement
	constant LDM_DB_R12_R0_to_R10	: std_logic_vector(31 downto 0) := X"E" & "100" & "1001" & "1" & R12 & X"07FF"; --predekrement

	constant STM_IA_R12_R1		: std_logic_vector(31 downto 0) := X"E" & "100" & "0100" & "0" & R12 & X"0002"; --postinkrement
	constant STM_DA_R12_R1		: std_logic_vector(31 downto 0) := X"E" & "100" & "0000" & "0" & R12 & X"0002"; --postdekrement

	constant LDM_DA_R12_R1		: std_logic_vector(31 downto 0) := X"E" & "100" & "0000" & "1" & R12 & X"0002"; --postdekrement
	constant LDM_IA_R12_R1		: std_logic_vector(31 downto 0) := X"E" & "100" & "0100" & "1" & R12 & X"0002"; --postinkrement

	constant LDM_DA_R12_R15		: std_logic_vector(31 downto 0) := X"E" & "100" & "0000" & "1" & R12 & X"8000"; --postdekrement
	constant LDM_IA_R12_R15		: std_logic_vector(31 downto 0) := X"E" & "100" & "0100" & "1" & R12 & X"8000"; --postinkrement
	constant LDMS_IA_R12_R15	: std_logic_vector(31 downto 0) := X"E" & "100" & "0110" & "1" & R12 & X"8000"; --postinkrement, Sprung mit Moduswechsel

	constant SWAP_R12_R4_R4		: std_logic_vector(31 downto 0) := X"E" & "00010000" & R12 & R4 & "0000" & "1001" & R4;


	TYPE REF_MEM_TYPE is array(0 to 256) of std_logic_vector(31 downto 0);
	signal REF_MEM : REF_MEM_TYPE := (
		BRANCH_START_NO_LINK,
		MOVS_R14_PC, -- Behandlung von UNDEFINED... Ist einfach ein Ruecksprung hinter die verursachende Adresse
		NOP, -- Uebrige Exceptionvektoren ... nicht initialisiert
		NOP,
		NOP,
		NOP,
		NOP,
		NOP,
		-- ab Adresse 8 (Wortadresse) darf sinnvoller Code stehen
		X"E" & "001" & OP_MOV & '0' & "0000" & "0000" & "0000" & X"23",
		NOP,
		NOP,
		X"E" & "001" & OP_MOV & '0' & "0000" & "0001" & "0000" & X"42",
		X"E" & "001" & OP_MOV & '0' & "0000" & "0010" & "0000" & X"FF",
		NOP,
		NOP,
		NO_BRANCH_4_LINK, -- Sprung, der nicht ausgefuehrt wird
		ADD_R0_R1_R2, --16
		ADD_R2_R3_R4, -- R2 muss gebypasst werden
		BRANCH_4_LINK, --Adresse 18, allerdings hat der PC den Wert 20 wenn der Sprung ausgefuehrt wird
		NOP,
		NOP,
		NOP,
		NOP,
		NOP,
		X"E" & "001" & OP_MOV & '0' & "0000" & "0101" & "0000" & X"00", -- 0 nach R5 schreiben
		LDC, --Adresse 25
		ADD_4_PC_PC, --sollte die beiden folgenden Instruktionen ueberspringen
		MOV_4_R9,
		MOV_2_R10,
		MOV_32_R6, --erster Operand fuer eine Adressrechnung
		MOV_8_R7, --30
		MUL_R6_R7_R8, --ergibt 256, bzw. Wortadresse 64
		STRB_R0_R5_256, -- Schreibt an Byteadresse 256
		LDRSB_R8_0_R13, --liest von Byteadresse 256
		CMP_R4_R2, --sollte den Condition Code verändern und das Z-Bit setzen sowie das C-Bit [NZCV], wird in Zyklus 48 sichtbar
		SUBS_R0_R2_R12_LSL2,
		SUBS_R7_32_R11, --36 Erzeugt -24 = FFFFFFE8 in R11
		ADDS_R7_R11_R3_ASR1, --Erzeugt -4 = FFFFFFFC in R3, erzeugt kein C-Bit
		STOPP,  --38
		X"FFFFFFFF",	-- Adresse 39 (Wort)
		others => (others => '0')
	);


	function INDEX_OF_DECV (THIS_CODE: COARSE_DECODE_TYPE) return integer is
		variable INDEX : integer range 0 to 17 := 0;
		begin
			case THIS_CODE IS
				when CD_UNDEFINED 			=> INDEX := 0;
				when CD_SWI 				=> INDEX := 1;
				when CD_COPROCESSOR			=> INDEX := 2;
				when CD_BRANCH				=> INDEX := 3;
				when CD_LOAD_STORE_MULTIPLE		=> INDEX := 4;
				when CD_LOAD_STORE_UNSIGNED_IMMEDIATE	=> INDEX := 5;
				when CD_LOAD_STORE_UNSIGNED_REGISTER	=> INDEX := 6;
				when CD_LOAD_STORE_SIGNED_IMMEDIATE	=> INDEX := 7;
				when CD_LOAD_STORE_SIGNED_REGISTER	=> INDEX := 8;
				when CD_ARITH_IMMEDIATE			=> INDEX := 9;
				when CD_ARITH_REGISTER			=> INDEX := 10;
				when CD_ARITH_REGISTER_REGISTER		=> INDEX := 11;
				when CD_MSR_IMMEDIATE			=> INDEX := 12;
				when CD_MSR_REGISTER			=> INDEX := 13;
				when CD_MRS				=> INDEX := 14;
				when CD_MULTIPLY			=> INDEX := 15;
				when CD_SWAP				=> INDEX := 16;
				when others				=> INDEX := 17;
			end case;	
			return INDEX;
	end INDEX_OF_DECV;

	procedure INIT_INSTRUCTION_MEANING is
	begin
		WRITE(INSTRUCTIONS_MEANING(0),string'("B 6; " & TAB_CHAR & TAB_CHAR &" Branch an Adresse 8, ueberspringt die Exception-Vektoren "));
		WRITE(INSTRUCTIONS_MEANING(1),string'("MOVS R14 PC; " & TAB_CHAR & " Schreibt das Link Register in den PC, und ueberschreibt das CPSR mit dem SPSR, Ruecksprung aus einer UNDEFINED_EXCEPTION "));
		WRITE(INSTRUCTIONS_MEANING(2), string'("NOP; " & TAB_CHAR  & TAB_CHAR & "  keine Behandlung von SWI-Exceptions "));
		WRITE(INSTRUCTIONS_MEANING(3), string'("NOP; " & TAB_CHAR  & TAB_CHAR & "  keine Behandlung von PREFETCH-ABORT-Exceptions"));
		WRITE(INSTRUCTIONS_MEANING(4), string'("NOP; " & TAB_CHAR  & TAB_CHAR & "  keine Behandlung von DATA-ABORT-Exceptions"));
		WRITE(INSTRUCTIONS_MEANING(5), string'("NOP; " & TAB_CHAR  & TAB_CHAR & "  Diese Adresse wird in ARMv4 gewoehnlich nicht angesprungen "));
		WRITE(INSTRUCTIONS_MEANING(6), string'("NOP; " & TAB_CHAR  & TAB_CHAR & "  keine Behandlung von IRQ"));
		WRITE(INSTRUCTIONS_MEANING(7), string'("NOP; " & TAB_CHAR  & TAB_CHAR & "  keine Behandlung von FIQ"));
		WRITE(INSTRUCTIONS_MEANING(8), string'("MOV X23 R0; " & TAB_CHAR & "  Schreibt hexadezimal 23 nach Register 0, Bedingung Always "));
		WRITE(INSTRUCTIONS_MEANING(9), string'("NOP " & TAB_CHAR & " "));
		WRITE(INSTRUCTIONS_MEANING(10), string'("NOP " & TAB_CHAR & " "));
		WRITE(INSTRUCTIONS_MEANING(11), string'("MOV X42 R1; " & TAB_CHAR & "  Schreibt hexadezimal 42 nach Register 1, Bedingung Always "));
		WRITE(INSTRUCTIONS_MEANING(12), string'("MOV XFF R2 ; " & TAB_CHAR & "  Schreibt hexadezimal FF nach Register 2, Bedingung Always  "));
		WRITE(INSTRUCTIONS_MEANING(13), string'("NOP"));
		WRITE(INSTRUCTIONS_MEANING(14), string'("NOP"));
		WRITE(INSTRUCTIONS_MEANING(15), string'("B 4; " & TAB_CHAR  & TAB_CHAR & "  Ein Sprung ueber die naechsten 6 Instruktionen ohne Link, Bedingung Never, darf nicht ausgefuehrt werden"));
		WRITE(INSTRUCTIONS_MEANING(16), string'("ADD R0 R1 R2; " & TAB_CHAR & "  R2 = R1 + R0; Schreibt X65 = X23 + X42 nach R0, kein Bypassing notwendig"));
		WRITE(INSTRUCTIONS_MEANING(17), string'("ADD R2 R3 R4; " & TAB_CHAR & "  R4 = R2 + R3; Schreibt X65 = X65 + X0 nach R4, Bypassing von R2 notwendig"));
		WRITE(INSTRUCTIONS_MEANING(18), string'("BL 4; " & TAB_CHAR  & TAB_CHAR & "  Branch with Link zu Adresse PC + 6 (Sprung von Addresse 18 nach 24), Ruecksprungadresse: R14_SVC := X4C (= 76 = 19 * 4)"));
		WRITE(INSTRUCTIONS_MEANING(19), string'("NOP"));
		WRITE(INSTRUCTIONS_MEANING(20), string'("NOP"));
		WRITE(INSTRUCTIONS_MEANING(21), string'("NOP"));
		WRITE(INSTRUCTIONS_MEANING(22), string'("NOP"));
		WRITE(INSTRUCTIONS_MEANING(23), string'("NOP"));
		WRITE(INSTRUCTIONS_MEANING(24), string'("MOV 0 R5;"));
		WRITE(INSTRUCTIONS_MEANING(25), string'("LDC; " & TAB_CHAR  & TAB_CHAR & "  Coprozessorinstruktion, Sprung an Wortadresse 1 (Undefined Exception), Ablegen der Ruecksprungadresse (X68 = 104 = 26 * 4) in Register R14_UND; dann unmittelbarer Ruecksprung an die Instruktion hinter LDC (Wortadresse 26)"));
		WRITE(INSTRUCTIONS_MEANING(26), string'("ADD PC 4 PC; " & TAB_CHAR & "  PC := PC + 4; ueberspringt die naechsten beiden Instruktionen (+4 erhoeht die Wortadresse nur um 1!)"));
		WRITE(INSTRUCTIONS_MEANING(27), string'("MOV 4 R9; " & TAB_CHAR & "  Schreibt 4 nach R9 und sollte wegen des vorherigen Sprungs nicht ausgefuehrt werden"));
		WRITE(INSTRUCTIONS_MEANING(28), string'("MOV 2 R10; " & TAB_CHAR & "  Schreibt 2 nach R10, sollte uebersprungen werden"));
		WRITE(INSTRUCTIONS_MEANING(29), string'("MOV 32 R6; " & TAB_CHAR & "  Schreibt 32 nach R6, erster Operand fuer eine Adressrechnung"));
		WRITE(INSTRUCTIONS_MEANING(30), string'("MOV 8 R7; " & TAB_CHAR & "  Schreibt 8 nach R7, zweiter Operand fuer eine Adressrechnung"));
		WRITE(INSTRUCTIONS_MEANING(31), string'("MUL R6 R7 R8; " & TAB_CHAR & "  R8 = R6 * R7; Adresse fuer einen Speicherzugriff (Byteadresse 256)"));
		WRITE(INSTRUCTIONS_MEANING(32), string'("STRB_R0_R5_256; " & TAB_CHAR & "  MEM[R5 + 256] := R0, Schreibt Byte0 von R0 (X23) an Adresse 256 und schreibt die Adresse nach R5 zurueck"));
		WRITE(INSTRUCTIONS_MEANING(33), string'("LDRSB R8 0 R13; " & TAB_CHAR & "  R13 := MEM[R8], kopiert Byte 0 des Speicherinhalts an Byteadresse 256 (Inhalt von R8) nach R13 mit Vorzeichenerweiterung"));
		WRITE(INSTRUCTIONS_MEANING(34), string'("CMP R4 R2; " & TAB_CHAR & "  Condition Code := R4 - R2, setzt Z- und C-Bit, schreibt aber kein Ergebnis (Rd = R6)"));
		WRITE(INSTRUCTIONS_MEANING(35), string'("SUB R0 R2 R12 LSL4; " & TAB_CHAR & "   R12 = R0 - (R2 << 2); Schiebt den Inhalt von R2 und subtrahiert von R0, Ergebnis: X23 - (X65 << 2) = FFFFF8F"));
		WRITE(INSTRUCTIONS_MEANING(36), string'("SUBS R7 32 R11; " & TAB_CHAR & "  Subtrahiert 32 von R7 (R11 := R7 - 32 = 8 - 32 = -24) und setzt den Condition Code neu (nur N wird gesetzt)"));
		WRITE(INSTRUCTIONS_MEANING(37), string'("ADDS R7 R11 R3 ASR1; " & TAB_CHAR & "  Addiert (R11 >> 1) auf R7, schreibt das Ergebnis (-4 = FFFFFFFC) nach R3 uns setzt den Condition Code"));
		WRITE(INSTRUCTIONS_MEANING(38), string'("B -2; " & TAB_CHAR  & TAB_CHAR & "  Springt effektiv wieder an die gleiche Adresse und wirkt deshalb als STOPP-Befehl"));			
		WRITE(INSTRUCTIONS_MEANING(39), string'("Pseudowert XFFFFFFFF, wird gefetcht aber nicht ausgefuehrt"));
		WRITE(INSTRUCTIONS_MEANING(40), string'("Ab dieser Adresse nur Nullen"));
	end procedure INIT_INSTRUCTION_MEANING; 

	procedure REPORT_PROGRAMM is
	begin
		report "Instruktionsadresse : " & TAB_CHAR & "Instruktion; Bedeutung";
		report SEPARATOR_LINE;
		for i in 0 to 40 loop
			report integer'image(i) & ": " & TAB_CHAR & INSTRUCTIONS_MEANING(i).all;
		end loop;
		report SEPARATOR_LINE;
	end procedure REPORT_PROGRAMM;

	procedure INIT_COVERAGE_NAMES is
	begin
--			Texte für die Zusammenfassung der Simulation vorbereiten
		STD.textio.write(COVERAGE_NAMES(0),string'("CD_UNDEFINED" & TAB_CHAR & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(1),string'("CD_SWI"  & TAB_CHAR & TAB_CHAR & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(2), string'("CD_COPROCESSOR" & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(3), string'("CD_BRANCH" & TAB_CHAR & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(4), string'("CD_LOAD_STORE_MULTIPLE" & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(5), string'("CD_LOAD_STORE_UNSIGNED_IMMEDIATE" & TAB_CHAR));
		WRITE(COVERAGE_NAMES(6), string'("CD_LOAD_STORE_UNSIGNED_REGISTER" & TAB_CHAR));
		WRITE(COVERAGE_NAMES(7), string'("CD_LOAD_STORE_SIGNED_IMMEDIATE" & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(8), string'("CD_LOAD_STORE_SIGNED_REGISTER" & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(9), string'("CD_ARITH_IMMEDIATE") & TAB_CHAR & TAB_CHAR);
		WRITE(COVERAGE_NAMES(10), string'("CD_ARITH_REGISTER" & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(11), string'("CD_ARITH_REGISTER_REGISTER" & TAB_CHAR));
		WRITE(COVERAGE_NAMES(12), string'("CD_MSR_IMMEDIATE" & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(13), string'("CD_MSR_REGISTER" & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(14), string'("CD_MRS" & TAB_CHAR & TAB_CHAR));
		WRITE(COVERAGE_NAMES(15), string'("CD_MULTIPLY" & TAB_CHAR));
		WRITE(COVERAGE_NAMES(16), string'("CD_SWAP" & TAB_CHAR));
		WRITE(COVERAGE_NAMES(17), string'("Fehlerhafte Codes innerhalb der Testvektordatei"), LEFT, 40);
	end procedure INIT_COVERAGE_NAMES;

begin


	
	uut: entity work.ArmCore(BEHAVE) 
	    port map(
		CORE_CLK 	=> CORE_CLK,	
		CORE_INV_CLK	=> CORE_INV_CLK,	
		CORE_RST 	=> CORE_RST,	
	--	weitere Steuersignale
		CORE_WAIT 	=> '0',	
	--    	Instruktionsbus
		CORE_IBE	=> CORE_IBE,	
		CORE_IEN	=> CORE_IEN,	
		CORE_IA 	=> CORE_IA,	
		CORE_ID 	=> CORE_ID,	
		CORE_IABORT 	=> '0',	
	--    	Datenbus
		CORE_DA 	=> CORE_DA,	
		CORE_DDOUT 	=> CORE_DDOUT,	
		CORE_DDIN 	=> CORE_DDIN,	
		CORE_DMAS	=> CORE_DMAS,	
		CORE_DnRW	=> CORE_DnRW,	
		CORE_DABORT	=> '0',	
		CORE_DEN	=> CORE_DEN,	
		CORE_DBE	=> CORE_DBE,	
	--    	Interruptschnittstelle
		CORE_FIQ	=> '0',	
		CORE_IRQ	=> '0',	
	--	weitere Schnittstellensignale
		CORE_IMODE	=> CORE_IMODE,	
		CORE_DMODE	=> CORE_DMODE	
	   );

	   MEM_DEN <= CORE_DEN  or TEST_DEN;
	Inst_ArmMemInterface: ArmMemInterface port map(
		RAM_CLK 	=> CORE_INV_CLK,
		IDE 		=> CORE_IEN,
		IA 		=> CORE_IA,
		ID 		=> CORE_ID,
		IABORT 		=> CORE_IABORT,
		DDE 		=> MEM_DEN,
		DnRW 		=> CORE_DnRW,
		DMAS 		=> CORE_DMAS,
		DA 		=> CORE_DA,
		DDIN 		=> CORE_DDOUT,
		DDOUT 		=> CORE_DDIN,
		DABORT 		=> CORE_DABORT 
	);

	ALL_REGISTERS_FLAT <= (AGP_PHY_R0,AGP_PHY_R1,AGP_PHY_R2,AGP_PHY_R3,AGP_PHY_R4,AGP_PHY_R5,AGP_PHY_R6,AGP_PHY_R7,
			  AGP_PHY_R8,AGP_PHY_R9,AGP_PHY_R10,AGP_PHY_R11,AGP_PHY_R12,AGP_PHY_R13,AGP_PHY_R14,AGP_PHY_R15,
			  AGP_PHY_R16,AGP_PHY_R17,AGP_PHY_R18,AGP_PHY_R19,AGP_PHY_R20,AGP_PHY_R21,AGP_PHY_R22,AGP_PHY_R23,
			  AGP_PHY_R24,AGP_PHY_R25,AGP_PHY_R26,AGP_PHY_R27,AGP_PHY_R28, AGP_PHY_R29, AGP_PHY_R30);
	ALL_REGISTERS <= (
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("0000",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("0001",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("0010",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("0011",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("0100",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("0101",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("0110",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("0111",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1000",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1001",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1010",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1011",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1100",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1101",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1110",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1111",USER,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1000",FIQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1001",FIQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1010",FIQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1011",FIQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1100",FIQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1101",FIQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1110",FIQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1101",IRQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1110",IRQ,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1101",SUPERVISOR,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1110",SUPERVISOR,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1101",ABORT,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1110",ABORT,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1101",UNDEFINED,'0')))),
		  ALL_REGISTERS_FLAT(to_integer(unsigned(GET_INTERNAL_ADDRESS("1110",UNDEFINED,'0'))))
	  );

	TEST_CC <= AGP_EX_CC_MUX;
	TEST_MET <= AGP_CONDITION_MET;
	CORE_DBE <= CORE_DEN and not INIT_RAM;


	GEN_CLK : process is
	begin
		if SIMULATION_RUNNING then
			CORE_INV_CLK <= CORE_CLK;
			wait for 1 ps;
			CORE_CLK <= not CORE_CLK; 
			wait for (ARM_SYS_CLK_PERIOD/2.0);
		else
			wait;
		end if;
	end process GEN_CLK;

   	OBSERVE_DATABUS : process is
	begin
		wait for 1000 ns;
		
		while SIMULATION_RUNNING loop
--			wait on CORE_DA,CORE_DDOUT,CORE_DnRW, CORE_DMAS;
			wait until TESTCYCLE_NR'event;
			wait for ARM_SYS_CLK_PERIOD * 0.75;						
			if CORE_DnRW = '1' and INIT_RAM = '0' then
				report "Prozessorkern schreibt auf Datenbus.";
				report "Zugriffsadresse: " & integer'image(to_integer(unsigned(CORE_DA)));
				report "Erwartete Adresse: " & integer'image(to_integer(unsigned(EXPECTED_WRITE_ADDRESSES(0))));
				report "Datum auf Bus: " & TAB_CHAR & SLV_TO_STRING(CORE_DDOUT);
				report "Erwartetes Datum: " & TAB_CHAR & SLV_TO_STRING(EXPECTED_WRITE_DATA(0));	
				report "Erwarteter Zugriffstyp: " & TAB_CHAR & SLV_TO_STRING(DMAS_BYTE);
				report "Zugriffstyp: " & TAB_CHAR & SLV_TO_STRING(CORE_DMAS);

--	Der einzelne Schreibzugriff erfolt mit dem Zugriffstyp Byte
				if (CORE_DA /= EXPECTED_WRITE_ADDRESSES(0)) or (CORE_DDOUT /= EXPECTED_WRITE_DATA(0)) or CORE_DMAS /= DMAS_BYTE then
					report "Fehler bei Schreibzugriff auf Arbeitsspeicher" severity note;
					report "Fehler bei Schreibzugriff auf Arbeitsspeicher" severity error;									
					DATA_TRANSACTION_ERRORS := DATA_TRANSACTION_ERRORS + 1;
				else
					report "Speicherzugriff korrekt" severity note;
				end if;
				report SEPARATOR_LINE;
			end if;
		end loop;
	end process OBSERVE_DATABUS;

--	21 Zeilen
--	OBSERVE_CC : process is
--	begin
--		-- im Kern guelte Condition Codes am Ende jedes Testzyklus
--		EXPECTED_CC (48) := "0110";
--		EXPECTED_CC(49 to NR_OF_TESTCYCLES) := (others => "1000");
--		wait for 1000 ns; 		
--		while (TESTCYCLE_NR < NR_OF_TESTCYCLES) and SIMULATION_RUNNING loop
--			wait until TESTCYCLE_NR'event;
--			wait for ARM_SYS_CLK_PERIOD * 0.9;
--			if TEST_CC /= EXPECTED_CC(TESTCYCLE_NR) then
--				report "Condition Code im Datenpfad (EX_CC_MUX) entspricht nicht dem Erwartungswert (Zyklus: " & integer'image(TESTCYCLE_NR) & ")" severity error;
--				report "Condition Code im Datenpfad (EX_CC_MUX) entspricht nicht dem Erwartungswert (Zyklus: " & integer'image(TESTCYCLE_NR) & ")" severity note;
--				report "Erwartet: " & SLV_TO_STRING(EXPECTED_CC(TESTCYCLE_NR));
--				report "Gelesen: " & SLV_TO_STRING(TEST_CC);
--				CC_ERRORS := CC_ERRORS + 1;
--				report SEPARATOR_LINE;
--			else
----				report "CC korrekt";
--			end if;
--		end loop;		
--	end process OBSERVE_CC;

--------------------------------------------------------------------------------
--	Zaehler fuer die Testzyklen nach Initialisieren des Speichers und
--	Prozessorreset, wahrend des ersten echten Prozessortakts hat der Zaehler
--	den Wert 1.
--------------------------------------------------------------------------------
	COUNT_CYCLES : process is
	begin
		wait for 1000 ns;
		wait until INIT_RAM = '0';
		wait until CORE_RST = '0';
		TESTCYCLE_NR <= 1;
		wait for ARM_SYS_CLK_PERIOD/4;
		loop
			wait until CORE_CLK'event and CORE_CLK = '1' and SIMULATION_RUNNING; 
			TESTCYCLE_NR <= TESTCYCLE_NR + 1;
		end loop;
	end process COUNT_CYCLES;

	REPORT_STATE : process is
	begin
		wait for 1000 ns;
		wait until INIT_RAM = '0';
		while TESTCYCLE_NR < NR_OF_TESTCYCLES loop
			wait until TESTCYCLE_NR'event;		
--			Auf Aktualisierung beider Speicherbusse nach der fallenden Taktflanke warten
			wait for ARM_SYS_CLK_PERIOD * 0.51;
			-- Aufnehmen der Instruktionsadresse, am Ende der Testbench erfolgt ein Test auf fehlerhafte Verzweigungen
			RECORDED_INST_ADDR(TESTCYCLE_NR) := to_integer(unsigned(CORE_IA));
			report "Zyklus: " & integer'image(TESTCYCLE_NR);
			report "Wortadresseadresse auf dem Instruktionsbus: " & integer'image(to_integer(unsigned(CORE_IA)));
			report "Datum auf dem Instruktionsbus:";
			report SLV_TO_STRING(CORE_ID);
			report "Instruktion im Instruktionsregister: ";
			REPORT_INSTRUCTION(AGP_INSTRUCTION_REG);
			report "Gruppe der Instruktion in der Decodestufe (laut Gruppendekoder) : ";
			report COVERAGE_NAMES(INDEX_OF_DECV(AGP_DECODED_INSTRUCTION)).all;			
			if AGP_REF_W_PORT_A_EN = '1' then
				report "Schreibzugriff an Port A auf den Registerspeicher";
				report "Datum in WB_RES_REG: " & SLV_TO_STRING(AGP_WB_RES_REG);
			end if;
			if AGP_REF_W_PORT_B_EN = '1' then
				report "Schreibzugriff an Port B auf den Registerspeicher";
				report "Datum in WB_LOAD_REG: " & SLV_TO_STRING(AGP_WB_LOAD_REG);
			end if;	
			if CORE_DnRW = '1' then
				report "Schreibzugriff auf den Datenbus im aktuellen Zyklus";
				report "Zugriffsadresse (Byteadresse): "  & integer'image(to_integer(unsigned(CORE_DA)));
			end if;			
			report SEPARATOR_LINE;
		end loop;
	end process REPORT_STATE;

--	Hauptprozess, initialisiert den Speicher, fasst Fehler zusammen und errechnet Punkte
	tb : process
		variable ERRORS_IN_REGS : natural := 0;
		variable ERRORS_ON_WRITE : natural := 0;

		procedure WAIT_CLK(NR_OF_CLKS : in natural) is
		begin
			if NR_OF_CLKS > 0 then
				for i in 0 to NR_OF_CLKS - 1 loop
					wait until CORE_CLK'event and CORE_CLK = '1';
				end loop;	
			end if;	
			wait for (ARM_SYS_CLK_PERIOD*0.25);
		end procedure WAIT_CLK;

		procedure SYNC_HIGH_DELAY(THIS_DELAY: in real) is
		begin
			wait until CORE_CLK'event and CORE_CLK = '1';
			wait for (ARM_SYS_CLK_PERIOD*THIS_DELAY);
		end procedure SYNC_HIGH_DELAY;

		variable DATA		: std_logic_vector(31 downto 0);
		variable NR_OF_ERRORS	: natural := 0;
--		variable THIS_MODE	: mode := SUPERVISOR;
	begin
		INIT_COVERAGE_NAMES;
		INIT_INSTRUCTION_MEANING;
		ALL_REGISTERS_EXPECTED <= (
		X"00000023", X"00000042", X"00000065", X"FFFFFFFC", 	  
		X"00000065", X"00000100", X"00000020", X"00000008", 	  -- FC statt 100, LDRSB konnte vorher kein WriteBack
		X"000000FC", X"00000000", X"00000000", X"FFFFFFE8", 	  
		X"FFFFFE8F", X"00000000", X"00000000", X"000000A0", 	  
		X"00000000", X"00000000", X"00000000", X"00000000", 	  
		X"00000000", X"00000000", X"00000000",  --Ende der FIQ-Register 	  
		X"00000000", X"00000000", X"00000023", X"0000004C",	  
		X"00000000", X"00000000", X"00000000", X"00000068" 	  
		);

		EXPECTED_INST_ADDR := (
		 0,
		 1,
		 1,
		 1,
		 1,
		 8,
		 9,
		 10,
		 11,
		 12,
		 13,
		 14,
		 15,
		 16,
		 16,
		 17,
		 18,
		 19, 19, 20, 20,
		 24,
		 25,
		 26, 26, 27, 27,
		 1,
		 2, 2, 2, 2,
		 26,
		 27, 27, 27, 27,
		 29,
		 30,
		 31,
		 32,
		 33,
		 34,
		 35,
		 36,
		 37,
		 38,
		 39, 39, 39, 39,
		 38,
		 39, 39, 39, 39,
		 38,
		 39, 39, 39, 39,
		 others => 0	
		);

		SIMULATION_RUNNING	<= true;
		CORE_IBE		<= '0';
		CORE_DnRW		<= '0';
--		CORE_DBE <= '0';
		INIT_RAM		<= '1';
		CORE_DDIN		<= (others => 'Z');
		CORE_DDOUT		<= (others => '0');
		CORE_DEN		<= 'Z';
--		INIT_RAM <= '0';
		CORE_DA			<= (others => '0');
		CORE_DMAS		<= DMAS_WORD;
		wait for 100 ns;
		CORE_RST		<= '1';
		wait for 100 ns;
		CORE_RST		<= '0';
		wait for 100 ns;
		INIT_RAM		<= '1';
		WAIT_CLK(1);

		TEST_DEN		<= '1';
--	128 Worte in den Speicher schreiben
		for i in 0 to 255 loop
			CORE_DA		<= std_logic_vector(to_unsigned(i*4,32));
			CORE_DDOUT	<= REF_MEM(i);
			CORE_DnRW	<= '1';
			WAIT_CLK(1);			
		end loop;
		CORE_DnRW	<= 'Z';
--		CORE_IA		<= (others => 'Z');
		CORE_DA		<= (others => 'Z');
--		CORE_ID		<= (others => 'Z');
		CORE_DMAS	<= "ZZ";
		CORE_DDIN	<= (others => 'Z');
		CORE_DDOUT	<= (others => 'Z');
		TEST_DEN	<= '0';


		report SEPARATOR_LINE;
		report "Auszufuehrende Instruktionen:";
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Hinweise zum Verstaendnis des Ablaufs:";
		report "-" & TAB_CHAR & "NOPs sind als MOV-Instruktionen von R0 nach R0 realisiert, verursachen also Schreibzugriffe auf den Registerspeicher.";
		report "-" & TAB_CHAR & "Echte Sprungbefehle (B,BL) sind PC-relativ.";
		report "-" & TAB_CHAR & "Bei echten Sprungbefehle (B,BL) wird der Immediate erst zwei Stellen nach links geschoben (Wordadresse) und dann zum PC addiert.";
		report "-" & TAB_CHAR & "Liest eine Instruktion den PC, so zeigt dieser bereits auf die uebernaechste Instruktion, B 4 springt daher um 6 Adressen.";
		report "-" & TAB_CHAR & "Nicht ausgefuehrte Sprungbefehle erzeugen einen zusaetzlichen Wartetakt.";
		report "-" & TAB_CHAR & "Waehrend des Lesens, Decodierens und Bearbeitens eines Sprungbefehls wird die Instruktionsadresse noch einmal inkrementiert.";
		report "-" & TAB_CHAR & "Die Instruktion B -2 subtrahiert 4 Byte vom PC, dieser ist beim Auslesen 4 Byte groesser als die Instruktionsadresse, " &
								"effektiv wird also wieder zur selben Instruktion gesprungen und das Programm angehalten.";
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;

--------------------------------------------------------------------------------

		report SEPARATOR_LINE;

		INIT_RAM	<= '0';
		CORE_IBE	<= '1';
		CORE_DA		<= (others => 'Z');
		CORE_RST	<= '1';
		WAIT_CLK(5);
		CORE_RST	<= '0';

--		Hauptprozess fuer eine definierte Zeit anhalten, Nebenprozesse ueberpruefen diverse Bedingungen
		WAIT_CLK(NR_OF_TESTCYCLES);
		CORE_DMAS	<= "ZZ";
		SIMULATION_RUNNING <= FALSE;
		POINTS := 5;
		report SEPARATOR_LINE;
		report "Ende der Simulation, Auswertung der Simulationsergebnisse.";
		report SEPARATOR_LINE;
		report "# Registerspeicher am Ende der Simulation:";
		PRINT_REGFILE;
		for i in 0 to 30 loop
				if ALL_REGISTERS(i) /= ALL_REGISTERS_EXPECTED(i) then
					report "Register " & ALL_REGISTERS_NAMES(i) & " weicht vom erwarteten Wert ab";
					report "Erwartet: " & SLV_TO_STRING(ALL_REGISTERS_EXPECTED(i));
					report "Enthaelt: " & SLV_TO_STRING(ALL_REGISTERS(i));
					REG_ERRORS := REG_ERRORS + 1;
				end if;
		end loop;
		if REG_ERRORS = 0 then
			report "Alle Registerinhalte korrekt";
		else
			report "Fehlerhafte Registerinhalte: - 2 Punkte" severity note;
			report "Fehlerhafte Registerinhalte: - 2 Punkte" severity error;
			POINTS := POINTS - 2;

		end if;

		
		report SEPARATOR_LINE;
		report "# Verlauf der Instruktionsadressen: Testzyklus: Erwartungswert | tatsaechliche Adresse | Status";
		for i in 1 to NR_OF_TESTCYCLES loop
			if EXPECTED_INST_ADDR(i) = RECORDED_INST_ADDR(i) then
				report integer'image(i) & ": " & TAB_CHAR & integer'image(EXPECTED_INST_ADDR(i)) & TAB_CHAR & "| " & integer'image(RECORDED_INST_ADDR(i)) & TAB_CHAR &  "| " & "korrekt";
			else
				report integer'image(i) & ": " & TAB_CHAR & integer'image(EXPECTED_INST_ADDR(i)) & TAB_CHAR & "| " & integer'image(RECORDED_INST_ADDR(i)) & TAB_CHAR & "| " & "Fehler";
				INST_ERRORS := INST_ERRORS + 1;
			end if;	
		end loop;

		if INST_ERRORS = 0 then
			report "Adressverlauf korrekt";
		else
			report "Fehlerhafter Adressverlauf: - 2 Punkt" severity note;
			report "Fehlerhafter Adressverlauf: - 2 Punkt" severity error;
			report "Fehlerhafte Instruktionsadressen koennen auf Fehler in Sprungadressberechnungen hinweisen oder fehlerhafte Steuersignale des Instruktionsadressregisters";
			POINTS := POINTS - 2;
		end if;
		report SEPARATOR_LINE;

--		report "# Sichtbarer Condition-Code im Prozessorkern (Ausgang von EX_CC_MUX im Datenpfad)";
--		if CC_ERRORS = 0 then
--			report "Sichtbarer Condition-Code korrekt"; 
--		else
--			report "Sichtbarer Condition-Code fehlerhaft (siehe error-Meldungen fuer Fehlerzyklus): - 1 Punkt" severity note; 
--			report "Sichtbarer Condition-Code fehlerhaft: - 1 Punkt" severity error;
--			POINTS := POINTS - 1;
--		end if;
--		report SEPARATOR_LINE;

		report "# Schreibzugriff auf dem Datenbus waehrend der Simulation";
		if DATA_TRANSACTION_ERRORS = 0 then
			report "Schreibzugriff auf Datenbus korrekt";
		else
			report "Schreibzugriff auf Datenbus fehlerhaft" severity note;
			report "Schreibzugriff auf Datenbus fehlerhaft" severity error;
			if POINTS > 0 then POINTS := POINTS - 1; end if;
		end if;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Punkte: " & integer'image(POINTS);
		if POINTS = 5 then 
			report "Funktionstest erfolgreich"; 
		else
			report "Funktionstest nicht erfolgreich" severity note;
			report "Funktionstest nicht erfolgreich" severity error;
		end if;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		REPORT " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" SEVERITY failure; 
		wait; -- will wait forever
	end process tb;
end architecture behave;


