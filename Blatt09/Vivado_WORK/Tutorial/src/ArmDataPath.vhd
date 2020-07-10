--------------------------------------------------------------------------------
--	Datenpfad des ARM-Prozessors
--------------------------------------------------------------------------------
--	Datum:		??.??.2018
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.all;
use work.ArmConfiguration.all;
use work.ArmGlobalProbes.all;

use work.ArmInstructionAddressRegister;
use work.ArmDataReplication;
use work.ArmRegfile;
use work.ArmShifter;
use work.ArmALU;
use work.ArmMultiplier;

--------------------------------------------------------------------------------
--	Anweisungen zur Verwendung von Simulationsmodellen in ModelSim,
--	nur fuer die Verhaltenssimulation geeignet.
--------------------------------------------------------------------------------
--Fuer Synthese auskommentieren!
library ARM_SIM_LIB;
-- Simulationsmodelle vorgegebener Komponenten:
	use ARM_SIM_LIB.ArmProgramStatusRegister;
	use ARM_SIM_LIB.ArmWordManipulation;

-- Simulationsmodelle selbst implementierter Komponenten
--	use ARM_SIM_LIB.ArmInstructionAddressRegister;
--	use ARM_SIM_LIB.ArmDataReplication;
--	use ARM_SIM_LIB.ArmRegfile;
--	use ARM_SIM_LIB.ArmShifter;
--	use ARM_SIM_LIB.ArmALU;
--	use ARM_SIM_LIB.ArmMultiplier;

entity ArmDataPath is
	port(
		DPA_CLK 			: in std_logic;
--	Registerspeicher-Taktsignal	
		DPA_INV_CLK			: in std_logic;
--------------------------------------------------------------------------------
--	Reset-Signal des Datenpfades, wirkt auf alle Register, wenn
--	USE_OPTIONAL_RESET in ArmConfiguration gesetzt ist, sonst
--	nur auf IAR und PSR.
--------------------------------------------------------------------------------
		DPA_RST 			: in std_logic;
		DPA_ENABLE			: in std_logic;		
--	Instruktionsadresse, zum Instruktionsbus	
		DPA_IF_IA			: out std_logic_vector(31 downto 2);
--	Steuersignale des Instruktionsadressregisters in IF und ID	
		DPA_IF_IAR_INC			: in std_logic;	
		DPA_IF_IAR_UPDATE_HB		: in std_logic;
		DPA_ID_IAR_REVOKE		: in std_logic;
		DPA_ID_IAR_HISTORY_ID		: in std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
--	Leseadressen des Registerspeichers [C,B,A]
		DPA_ID_REF_R_PORTS_ADDR 	: in std_logic_vector(14 downto 0);
--	Immediate aus einem Befehlswort auf 32Bit
		DPA_ID_IMMEDIATE		: in std_logic_vector(31 downto 0);
--------------------------------------------------------------------------------
--	Direkt in Instruktionen angegebene Schiebeweiten, unbedingt notwendig
--	sind nur 6 Bit.
--------------------------------------------------------------------------------
		DPA_ID_SHIFT_AMOUNT		: in std_logic_vector(5 downto 0);
--	Steuerung des OPB-Multiplexers der Decodestufe
		DPA_ID_OPB_MUX_CTRL 		: in std_logic;
		DPA_ID_SHIFT_MUX_CTRL		: in std_logic;
--	Auswahl zwischen CPSR und SPSR als Operand in der EX-Stufe
		DPA_EX_PSR_MUX_CTRL		: in std_logic;
--	Vollstaendiger CPSR-Vektor zum Kontrollpfad	
		DPA_EX_CPSR			: out std_logic_vector(31 downto 0);
--	Enablesignale der Pipelineregister zur Executestufe
		DPA_EX_OPA_REG_EN 		: in std_logic;
		DPA_EX_OPB_REG_EN 		: in std_logic;
		DPA_EX_OPC_REG_EN 		: in std_logic;
		DPA_EX_SHIFT_REG_EN		: in std_logic;
--	Steuerung der Bypassmultiplexer der EX-Stufe[C,B,A],Shift,CC
		DPA_EX_OPX_MUX_CTRLS 		: in std_logic_vector(5 downto 0);
		DPA_EX_SHIFT_MUX_CTRL 		: in std_logic_vector(1 downto 0);
		DPA_EX_CC_MUX_CTRL		: in std_logic_vector(1 downto 0);
--	Steuerung weiterer Multiplexer der EX-Stufe
		DPA_EX_OPB_ALU_MUX_CTRL		: in std_logic;
		DPA_EX_PSR_CC_MUX_CTRL		: in std_logic;
		DPA_EX_OPA_PSR_MUX_CTRL		: in std_logic;
--	Steuerung von Shifter, ALU, DataReplication
		DPA_EX_SHIFT_TYPE		: in std_logic_vector(1 downto 0);
		DPA_EX_SHIFT_RRX		: in std_logic;
		DPA_EX_ALU_CTRL			: in std_logic_vector(3 downto 0);
		DPA_EX_DRP_DMAS			: in std_logic_vector(1 downto 0);
--	Steuersignale zur Fortschaltung des Daten-Addressregisters	
		DPA_EX_DAR_EN			: in std_logic;
		DPA_EX_DAR_MUX_CTRL		: in std_logic;
		DPA_EX_DAR_INC			: in std_logic;
--	Enablesignale der Eingangsregister der MEM-Stufe	
		DPA_MEM_DATA_REG_EN 		: in std_logic;
		DPA_MEM_RES_REG_EN		: in std_logic;
		DPA_MEM_CC_REG_EN		: in std_logic;
		DPA_MEM_BASE_REG_EN		: in std_logic;
--------------------------------------------------------------------------------
--	Steuersignal zum Einspeisen der gesicherten Basisadresse in
--	den RES-Pfad der MEM-Stufe.	
--------------------------------------------------------------------------------
		DPA_MEM_BASE_MUX_CTRL		: in std_logic;
--------------------------------------------------------------------------------
--	Im Datenpfad relevante Signale des Datenbus, das Schalten
--	der Tristate-Ausgaenge erfolgt in der uebergeordneten Hierarchieebene.
--------------------------------------------------------------------------------
		DPA_MEM_DA			: out std_logic_vector(31 downto 0);
		DPA_MEM_DDOUT			: out std_logic_vector(31 downto 0);
		DPA_MEM_DDIN			: in std_logic_vector(31 downto 0);
--	Steuerung der Wortmanipulationseinheit.	
		DPA_MEM_WMP_DMAS		: in std_logic_vector(1 downto 0);
		DPA_MEM_WMP_SIGNED		: in std_logic;
--	Steuersignal zum maskieren der beiden niederwertigen Adressbits.	
		DPA_MEM_TRUNCATE_ADDR		: in std_logic;
--------------------------------------------------------------------------------
--	Steuersignal zum Einspeisen eines neuen Datums in den CC-Pfad
--	der MEM-Stufe, wird nur fuer die Coprozessorinstruktion MRC mit
--	Rd=15, L=1 benoetigt, irrelevant fuer das HWPR.
--------------------------------------------------------------------------------
		DPA_MEM_CC_MUX_CTRL		: in std_logic;
--	Schreibsteuersignale der Pipelineregister zur WB-Stufe
		DPA_WB_LOAD_REG_EN		: in std_logic;
		DPA_WB_RES_REG_EN		: in std_logic;
		DPA_WB_CC_REG_EN		: in std_logic;
--	Steuersignale und Adressen der Register-Schreibports
		DPA_WB_REF_W_PORT_A_EN 		: in std_logic;
		DPA_WB_REF_W_PORT_B_EN 		: in std_logic;
--	[B,A]	
		DPA_WB_REF_W_PORTS_ADDR 	: in std_logic_vector(9 downto 0);
--	Priorisiertes Steuersignal fuer Schreibzugriffe auf das PSR-Modul
		DPA_WB_PSR_EN			: in std_logic;
--	Alle anderen Steuersignal in einem Vektor vereinigt	
		DPA_WB_PSR_CTRL			: in PSR_CTRL_TYPE;
--	Steuerung für das Instruktions-Adressregister
		DPA_WB_IAR_MUX_CTRL		: in std_logic;
		DPA_WB_IAR_LOAD			: in std_logic;

		DPA_WB_FBRANCH_MUX_CTRL		: in std_logic

	);
		
end entity ArmDataPath;		
architecture structure of ArmDataPath is

--------------------------------------------------------------------------------
--	Komponentendeklarationen
--------------------------------------------------------------------------------
	component ArmInstructionAddressRegister 
	port(
		IAR_CLK 		: in std_logic;
		IAR_RST 		: in std_logic;
		IAR_INC			: in std_logic;
		IAR_LOAD 		: in std_logic;
		IAR_REVOKE		: in std_logic;
		IAR_UPDATE_HB		: in std_logic;
		IAR_HISTORY_ID		: in std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
		IAR_ADDR_IN 		: in std_logic_vector(31 downto 2);
		IAR_ADDR_OUT 		: out std_logic_vector(31 downto 2);
		IAR_NEXT_ADDR_OUT 	: out std_logic_vector(31 downto 2)
	);
	end component ArmInstructionAddressRegister;

	component ArmProgramStatusRegister
	port(
		PSR_CLK 		: in std_logic;
		PSR_RST 		: in std_logic;
		PSR_ENABLE 		: in std_logic;
		PSR_EXCEPTION_ENTRY 	: in std_logic;
		PSR_EXCEPTION_RETURN 	: in std_logic;
		PSR_SET_CC 		: in std_logic;
		PSR_WRITE_SPSR 		: in std_logic;
		PSR_XPSR_IN 		: in std_logic_vector(31 downto 0);
		PSR_CC_IN 		: in std_logic_vector(3 downto 0);
		PSR_MODE_IN 		: in std_logic_vector(4 downto 0);
		PSR_MASK 		: in std_logic_vector(3 downto 0);          
		PSR_CPSR_OUT 		: out std_logic_vector(31 downto 0);
		PSR_SPSR_OUT 		: out std_logic_vector(31 downto 0)
		);
	end component ArmProgramStatusRegister;

	component ArmRegfile
	port(
		REF_CLK 		: in std_logic;
		REF_RST 		: in std_logic;
		REF_W_PORT_A_ENABLE 	: in std_logic;
		REF_W_PORT_B_ENABLE 	: in std_logic;	
		REF_W_PORT_PC_ENABLE 	: in std_logic;
		REF_W_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
		REF_W_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);
		REF_R_PORT_A_ADDR 	: in std_logic_vector(4 downto 0);
		REF_R_PORT_B_ADDR 	: in std_logic_vector(4 downto 0);
		REF_R_PORT_C_ADDR 	: in std_logic_vector(4 downto 0);
		REF_W_PORT_A_DATA 	: in std_logic_vector(31 downto 0);
		REF_W_PORT_B_DATA 	: in std_logic_vector(31 downto 0);
		REF_W_PORT_PC_DATA 	: in std_logic_vector(31 downto 0);
		REF_R_PORT_A_DATA 	: out std_logic_vector(31 downto 0);
		REF_R_PORT_B_DATA 	: out std_logic_vector(31 downto 0);
		REF_R_PORT_C_DATA 	: out std_logic_vector(31 downto 0)
	);
	end component ArmRegfile;

--------------------------------------------------------------------------------
--	CLK, RST, EN werden aktuell nicht verwendet, Vorbereitung
--	auf die Verwendung eines gepipelineten Multiplizierers	
--------------------------------------------------------------------------------
	component ArmMultiplier
	port(
		MUL_OP1		: in std_logic_vector(31 downto 0);
		MUL_OP2		: in std_logic_vector(31 downto 0);          
		MUL_RES		: out std_logic_vector(31 downto 0)
		);
	end component ArmMultiplier;

	component ArmDataReplication
	port(
		DRP_INPUT	: in std_logic_vector(31 downto 0);
		DRP_DMAS	: in std_logic_vector(1 downto 0);          
		DRP_OUTPUT	: out std_logic_vector(31 downto 0)
		);
	end component ArmDataReplication;

	component ArmShifter
	port(
		SHIFT_OPERAND	: in std_logic_vector(31 downto 0);
		SHIFT_AMOUNT	: in std_logic_vector(7 downto 0);
		SHIFT_TYPE_IN	: in std_logic_vector(1 downto 0);
		SHIFT_C_IN	: in std_logic;
		SHIFT_RRX	: in std_logic;          
		SHIFT_RESULT	: out std_logic_vector(31 downto 0);
		SHIFT_C_OUT	: out std_logic
		);
	end component ArmShifter;

	component ArmWordManipulation
	port(
		WMP_WORD_IN	: in std_logic_vector(31 downto 0);
		WMP_ADDRESS	: in std_logic_vector(1 downto 0);
		WMP_DMAS	: in std_logic_vector(1 downto 0);
		WMP_SIGNED	: in std_logic;          
		WMP_WORD_OUT	: out std_logic_vector(31 downto 0)
		);
	end component ArmWordManipulation;

	component ArmALU
	port(
		ALU_OP1		: in std_logic_vector(31 downto 0);
		ALU_OP2		: in std_logic_vector(31 downto 0);
		ALU_CTRL	: in std_logic_vector(3 downto 0);
		ALU_CC_IN	: in std_logic_vector(1 downto 0);          
		ALU_RES		: out std_logic_vector(31 downto 0);
		ALU_CC_OUT	: out std_logic_vector(3 downto 0)
		);
	end component ArmALU;

--------------------------------------------------------------------------------
--	Signale
--	Neben der Deklaration von Fliessbandregistern und Multiplexern
--	werden zahlreiche Signale angelegt, die im Wesentlichen
--	den Modul-Ports entsprechen, aber z.B. zusaetzlich mit DPA_ENABLE
--	verundet sind.
--------------------------------------------------------------------------------

--	Pipelineregister
	signal EX_OPA_REG, EX_OPB_REG, EX_OPC_REG	: std_logic_vector(31 downto 0) 	:= (others => '0');
	signal EX_SHIFT_REG 				: std_logic_vector(7 downto 0) 		:= (others => '0');
	signal MEM_DATA_REG, MEM_ADDR_REG, MEM_RES_REG	: std_logic_vector(31 downto 0) 	:= (others => '0');
	signal MEM_CC_REG				: std_logic_vector(3 downto 0) 		:= (others => '0');
	signal WB_LOAD_REG, WB_RES_REG			: std_logic_vector(31 downto 0) 	:= (others => '0');
	signal WB_CC_REG				: std_logic_vector(3 downto 0) 		:= (others => '0');

--	Ausgänge des Registerfiles
	signal REF_R_PORT_A_DATA			: std_logic_vector(31 downto 0);
	signal REF_R_PORT_B_DATA			: std_logic_vector(31 downto 0);
	signal REF_R_PORT_C_DATA			: std_logic_vector(31 downto 0);

--	Steuersignale des Instruktions-Adressregisters	
	signal IF_IAR_INC, WB_IAR_LOAD			: std_logic := '0'; 
	signal IF_IAR_UPDATE_HB				: std_logic := '0';

--	Ausgänge des Adressregisters	
	signal IF_IAR_ADDR_OUT				: std_logic_vector(31 downto 2);
	signal IF_IAR_NEXT_ADDR_OUT			: std_logic_vector(31 downto 2);

--	Hilfssignal für die Bildung des PC-Dateneingangs	
	signal IF_REF_PORT_PC_DATA			: std_logic_vector(31 downto 0);

--	Multiplexer der Decodestufe
	signal ID_OPB_MUX 				: std_logic_vector(31 downto 0);
	signal ID_SHIFT_MUX				: std_logic_vector(7 downto 0);

--	Hilfssignal fuer das Registerspeicher-Reset
	signal ID_REF_RST				: std_logic;

--	Multiplexer der Executestufe	
	signal EX_OPA_MUX, EX_OPB_MUX, EX_OPC_MUX 	: std_logic_vector(31 downto 0);
	signal EX_SHIFT_MUX				: std_logic_vector(7 downto 0);
	signal EX_CC_MUX 				: std_logic_vector(3 downto 0);
	signal EX_DAR_MUX				: std_logic_vector(31 downto 0);
	signal EX_PSR_CC_MUX				: std_logic_vector(3 downto 0);
	signal EX_NZ_ALU_BYPASS_MUX			: std_logic_vector(1 downto 0);
--------------------------------------------------------------------------------
--	Signale und Multiplexer in der EX-Stufe zur Auswahl von OPA_REG, CPSR
--	oder SPSR als Datum auf dem OPA-Pfad.	
--------------------------------------------------------------------------------
	signal EX_OPA_PSR_MUX	: std_logic_vector(31 downto 0);
	signal EX_PSR_MUX	: std_logic_vector(31 downto 0);
	signal EX_CPSR, EX_SPSR : std_logic_vector(31 downto 0);

--	Diverse Verbindungen der Executestufe
	signal EX_ALU_RES				: std_logic_vector(31 downto 0);
	signal EX_SHIFT_C_OUT				: std_logic;
	signal EX_ALU_CC_IN				: std_logic_vector(1 downto 0);
	signal EX_ALU_CC_OUT				: std_logic_vector(3 downto 0);
	signal EX_DRP_OUTPUT				: std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------
--	Schattenregister und Multiplexer sowie zugehoerige Steuersignale um 
--	das Basisregister von Speicherzugriffen bei einem Abort restaurieren
--	zu koennen.
--------------------------------------------------------------------------------
	signal MEM_BASE_REG				: std_logic_vector(31 downto 0) := (others => '0');
	signal MEM_BASE_MUX				: std_logic_vector(31 downto 0);

--------------------------------------------------------------------------------
--	Multiplexer zum gesteuerten Maskieren der beiden niederwertigen
--	Daten-Adressbits.
--------------------------------------------------------------------------------
	signal MEM_TRUNC_MUX				: std_logic_vector(1 downto 0)	:= "00";

--------------------------------------------------------------------------------
--	Multiplexer, um Bits 31:28 vom Datenbus in den CC-Pfad einzuspeisen.
--	Wird benoetigt fuer einen speziellen Fall der MRS-Instruktion, der 
--	den Condition-Code aktualisiert.	
--------------------------------------------------------------------------------
	signal MEM_CC_MUX				: std_logic_vector(3 downto 0);

--------------------------------------------------------------------------------
--	Um 4 inkrementierter Inhalt des Adress-Registers, bildet mit
--	EX_DAR_MUX einen Adress-Inkrementierer fuer LDM/STM-Instruktionen.
--------------------------------------------------------------------------------
	signal MEM_ADDR_INCREMENTED			: std_logic_vector(31 downto 0) := (others => '0');

--	Zusätzliche Verbindungssignale und Multiplexer der Memorystufe
	signal MEM_WMP_WORD_OUT				: std_logic_vector(31 downto 0);


--	Multiplexer und Steuersignale der Write Back Stufe
	signal WB_IAR_MUX				: std_logic_vector(31 downto 2);
	signal WB_IAR_ADDR_IN				: std_logic_vector(31 downto 2);
	signal WB_PSR_EN				: std_logic;

--	Aliase zur vereinfachten Beschreibung einiger Bypass-Multiplexer
	alias DPA_EX_OPA_MUX_CTRL : std_logic_vector(1 downto 0) is DPA_EX_OPX_MUX_CTRLS(1 downto 0);
	alias DPA_EX_OPB_MUX_CTRL : std_logic_vector(1 downto 0) is DPA_EX_OPX_MUX_CTRLS(3 downto 2);
	alias DPA_EX_OPC_MUX_CTRL : std_logic_vector(1 downto 0) is DPA_EX_OPX_MUX_CTRLS(5 downto 4);

begin
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	(Instruction) Fetch-Stufe 
--------------------------------------------------------------------------------

	IF_IAR_INC		<= DPA_ENABLE and DPA_IF_IAR_INC;
	WB_IAR_LOAD		<= DPA_ENABLE and DPA_WB_IAR_LOAD;
	IF_IAR_UPDATE_HB	<= DPA_ENABLE and DPA_IF_IAR_UPDATE_HB;
	ArmInstructionAddressRegister_Instance : ArmInstructionAddressRegister 
	port map(
		IAR_CLK 		=> DPA_CLK,
		IAR_RST 		=> DPA_RST,
		IAR_INC			=> IF_IAR_INC,
		IAR_LOAD 		=> WB_IAR_LOAD,
		IAR_REVOKE		=> DPA_ID_IAR_REVOKE,		
		IAR_UPDATE_HB		=> IF_IAR_UPDATE_HB,
		IAR_HISTORY_ID		=> DPA_ID_IAR_HISTORY_ID,
		IAR_ADDR_IN 		=> WB_IAR_ADDR_IN,
		IAR_ADDR_OUT 		=> IF_IAR_ADDR_OUT,
		IAR_NEXT_ADDR_OUT 	=> IF_IAR_NEXT_ADDR_OUT
	);

	DPA_IF_IA	<= IF_IAR_ADDR_OUT;

--------------------------------------------------------------------------------
--	(Instruction) Decode-Stufe
----------------------------------------------------------------------------------

--	Erweitern von IAR_NEXT_ADDR auf 32 Bit	
	IF_REF_PORT_PC_DATA <= IF_IAR_NEXT_ADDR_OUT & "00";

----------------------------------------------------------------------------------
--	Reset des Registerspeichers per Konfigurationsoption aktivieren/
--	deaktivieren. Fuer einen Registerspeicher auf Distributed RAM-Basis darf
--	Reset nicht verwendet werden.	
----------------------------------------------------------------------------------
	ID_REF_RST	<= DPA_RST when USE_OPTIONAL_RESET else '0';

	Regfile_Instance : ArmRegfile
       	port map(
		REF_CLK 		=> DPA_INV_CLK,
		REF_RST 		=> ID_REF_RST,
		REF_W_PORT_A_ENABLE 	=> DPA_WB_REF_W_PORT_A_EN,
		REF_W_PORT_B_ENABLE 	=> DPA_WB_REF_W_PORT_B_EN,
		REF_W_PORT_PC_ENABLE 	=> DPA_ENABLE, --'1'
		REF_W_PORT_A_ADDR 	=> DPA_WB_REF_W_PORTS_ADDR(4 downto 0),
		REF_W_PORT_B_ADDR 	=> DPA_WB_REF_W_PORTS_ADDR(9 downto 5),
		REF_R_PORT_A_ADDR 	=> DPA_ID_REF_R_PORTS_ADDR(4 downto 0),
		REF_R_PORT_B_ADDR 	=> DPA_ID_REF_R_PORTS_ADDR(9 downto 5),
		REF_R_PORT_C_ADDR 	=> DPA_ID_REF_R_PORTS_ADDR(14 downto 10),
		REF_W_PORT_A_DATA 	=> WB_RES_REG,
		REF_W_PORT_B_DATA 	=> WB_LOAD_REG,
		REF_W_PORT_PC_DATA 	=> IF_REF_PORT_PC_DATA,
		REF_R_PORT_A_DATA 	=> REF_R_PORT_A_DATA,
		REF_R_PORT_B_DATA 	=> REF_R_PORT_B_DATA,
		REF_R_PORT_C_DATA 	=> REF_R_PORT_C_DATA
	);

--	Zugriffe auf PSR von Datenpfad-Enable abhaengig machen
	WB_PSR_EN	<= DPA_WB_PSR_EN and DPA_ENABLE;

 	ArmProgramStatusRegister_Instance : ArmProgramStatusRegister
       	port map(
		PSR_CLK 		=> DPA_CLK,
		PSR_RST 		=> DPA_RST,
		PSR_ENABLE 		=> WB_PSR_EN,
		PSR_EXCEPTION_ENTRY 	=> DPA_WB_PSR_CTRL.EXC_ENTRY,
		PSR_EXCEPTION_RETURN 	=> DPA_WB_PSR_CTRL.EXC_RETURN,
		PSR_SET_CC 		=> DPA_WB_PSR_CTRL.SET_CC,
		PSR_WRITE_SPSR 		=> DPA_WB_PSR_CTRL.WRITE_SPSR,
		PSR_XPSR_IN 		=> WB_RES_REG,
		PSR_CC_IN 		=> WB_CC_REG,
		PSR_MODE_IN 		=> DPA_WB_PSR_CTRL.MODE,
		PSR_CPSR_OUT 		=> EX_CPSR,
		PSR_SPSR_OUT 		=> EX_SPSR,
 		PSR_MASK 		=> DPA_WB_PSR_CTRL.MASK	
	);

--------------------------------------------------------------------------------
--	In den CPSR-Vektor den durch Bypaesse aktualisierten Condition-Code
--	einbauen und das dadurch entstandene Signal an den Kontrollpfad
--	weitergeben.	
--------------------------------------------------------------------------------
	DPA_EX_CPSR	<= EX_CC_MUX & EX_CPSR(27 downto 0);

--	Operandenmultiplexer der Decodestufe
	ID_OPB_MUX	<= DPA_ID_IMMEDIATE 	when DPA_ID_OPB_MUX_CTRL = '1' else REF_R_PORT_B_DATA;
	ID_SHIFT_MUX	<= ("00" & DPA_ID_SHIFT_AMOUNT) when DPA_ID_SHIFT_MUX_CTRL = '0' else REF_R_PORT_C_DATA(7 downto 0);

--	Zielregister der Decode/Quellregister des Executestufe setzen
	SET_ID_EX_REGS : process(DPA_CLK)is
	begin
		if DPA_CLK'event and DPA_CLK = '1' then
			if DPA_RST = '1' and USE_OPTIONAL_RESET then
				EX_OPA_REG	<= (others => '0');
				EX_OPB_REG	<= (others => '0');
				EX_OPC_REG	<= (others => '0');
				EX_SHIFT_REG	<= (others => '0');

			else
				EX_OPA_REG	<= EX_OPA_REG;
				EX_OPB_REG	<= EX_OPB_REG;
				EX_OPC_REG	<= EX_OPC_REG;
				EX_SHIFT_REG	<= EX_SHIFT_REG;

				if DPA_ENABLE = '1' then
					if DPA_EX_OPA_REG_EN = '1' then
						EX_OPA_REG <= REF_R_PORT_A_DATA;
					end if;
					if DPA_EX_OPB_REG_EN = '1' then
						EX_OPB_REG <= ID_OPB_MUX;
					end if;
					if DPA_EX_OPC_REG_EN = '1' then
						EX_OPC_REG <= REF_R_PORT_C_DATA;
					end if;
					if DPA_EX_SHIFT_REG_EN = '1' then
						EX_SHIFT_REG <= ID_SHIFT_MUX;
					end if;					
				end if;	
			end if;
		end if;
	end process SET_ID_EX_REGS;

--------------------------------------------------------------------------------
--	Execute-Stufe
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	Beginn Aufgabe 1
--  Integration von
--      ArmALU
--      ArmShifter
-- 		ArmMultiplier
--------------------------------------------------------------------------------

	computation : block is
	signal ALU_OP2: std_logic_vector(31 downto 0);
	signal MUL_RES: std_logic_vector(31 downto 0);
	signal SHIFT_RES: std_logic_vector(31 downto 0);
	begin
	ArmALU_Instance : ArmALU 
	PORT MAP(
		ALU_OP1 	=> EX_OPA_MUX,
		ALU_OP2 	=> ALU_OP2,
		ALU_RES 	=> EX_ALU_RES,
		ALU_CTRL 	=> DPA_EX_ALU_CTRL,
		ALU_CC_IN 	=> EX_ALU_CC_IN(1 downto 0),
		ALU_CC_OUT 	=> EX_ALU_CC_OUT 
	);

	ArmMultiplier_Instance: ArmMultiplier
       	port map(
		MUL_OP1 	=> EX_OPC_MUX,
		MUL_OP2 	=> EX_OPB_MUX,
		MUL_RES 	=> MUL_RES
	);

	ArmShifter_Instance: ArmShifter
	PORT MAP(
		SHIFT_OPERAND 	=> EX_OPB_MUX,
		SHIFT_AMOUNT 	=> EX_SHIFT_MUX,
		SHIFT_TYPE_IN 	=> DPA_EX_SHIFT_TYPE,
		SHIFT_C_IN 	=> EX_CC_MUX(1),
		SHIFT_RRX 	=> DPA_EX_SHIFT_RRX,
		SHIFT_RESULT 	=> SHIFT_RES,
		SHIFT_C_OUT 	=> EX_SHIFT_C_OUT
	);
	
	ALU_OP2 <= SHIFT_RES when DPA_EX_OPB_ALU_MUX_CTRL = '0' else
		   MUL_RES					      ;
	
	end block computation;


--------------------------------------------------------------------------------
--	Ende Aufgabe 1
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	Beginn Aufgabe 2
--	Zur Steuerung der Multiplexer dienen die ALIAS-Signale 
--		DPA_EX_OPA_MUX_CTRL,
--		DPA_EX_OPB_MUX_CTRL,
--		DPA_EX_OPC_MUX_CTRL
--	sowie die Steuersignale
--		DPA_EX_SHIFT_MUX_CTRL,
--		DPA_EX_CC_MUX_CTRL
--------------------------------------------------------------------------------
	
--	Operanden-Eingangsmultiplexer (Bypass-Multiplexer)
	EX_OPA_MUX <= EX_OPA_PSR_MUX	when DPA_EX_OPA_MUX_CTRL = "00" else 
		      MEM_RES_REG when DPA_EX_OPA_MUX_CTRL = "01" else
		      WB_RES_REG when DPA_EX_OPA_MUX_CTRL = "10" else
		      WB_LOAD_REG;

	EX_OPB_MUX <= EX_OPB_REG when DPA_EX_OPB_MUX_CTRL = "00" else 
		      MEM_RES_REG when DPA_EX_OPB_MUX_CTRL = "01" else
		      WB_RES_REG when DPA_EX_OPB_MUX_CTRL = "10" else
		      WB_LOAD_REG;

	EX_OPC_MUX <= EX_OPC_REG when DPA_EX_OPC_MUX_CTRL = "00" else 
		      MEM_RES_REG when DPA_EX_OPC_MUX_CTRL = "01" else
		      WB_RES_REG when DPA_EX_OPC_MUX_CTRL = "10" else
		      WB_LOAD_REG;

	EX_SHIFT_MUX <= EX_SHIFT_REG when DPA_EX_SHIFT_MUX_CTRL = "00" else 
		      MEM_RES_REG(7 downto 0) when DPA_EX_SHIFT_MUX_CTRL = "01" else
		      WB_RES_REG (7 downto 0) when DPA_EX_SHIFT_MUX_CTRL = "10" else
		      WB_LOAD_REG(7 downto 0); 	

	EX_CC_MUX <=  EX_CPSR(31 downto 28) when DPA_EX_CC_MUX_CTRL = "00"else 
		      MEM_CC_REG when DPA_EX_CC_MUX_CTRL = "01" else
		      WB_CC_REG ;
		      

--------------------------------------------------------------------------------
--	Ende Aufgabe 2
--------------------------------------------------------------------------------

--	Auswahl zwischen CPSR und SPSR in der EX-Stufe	
	EX_PSR_MUX	<=	EX_CPSR	when DPA_EX_PSR_MUX_CTRL = '0' else
	       			EX_SPSR;

--	Auswahl zwischen OPA und CPSR/SPSR in der EX-Stufe	
	EX_OPA_PSR_MUX	<=	EX_OPA_REG when DPA_EX_OPA_PSR_MUX_CTRL = '0' else 
	   			EX_PSR_MUX;


	EX_DAR_MUX		<=	MEM_ADDR_INCREMENTED	when DPA_EX_DAR_INC = '1'	else 
					EX_ALU_RES		when DPA_EX_DAR_MUX_CTRL = '0'	else
		       			EX_OPA_MUX;

--------------------------------------------------------------------------------
--	Beim Kopieren der Statusregisters in ein Benutzerregister kann der
--	zwischenzeitlich aktualisierte Condition-Code eingebaut werden.
--	Auf diese Weise muessen keine Wartetakte vor der Ausfuehrung einer
--	MRS-Instruktion vorgesehen werden.
--------------------------------------------------------------------------------
	EX_PSR_CC_MUX		<=	EX_ALU_RES(31 downto 28)when DPA_EX_PSR_CC_MUX_CTRL = '0' else
			  		EX_CC_MUX;

--------------------------------------------------------------------------------
--	Multiplikationsoperationen aktualisieren ggf. N- und Z-Bit, lassen
--	aber C und V unangetastet. Da jede Multiplikation auch die ALU
--	durchlaeuft, koennen C und V der ALU nicht verwendet werden, sondern
--	muessen extern wieder aus dem CC-Mutliplexer gewonnen werden.
-- 	Das Steuersignal ist mit dem für die Seletion des 2. ALU Eingangs identisch.
--------------------------------------------------------------------------------
	EX_NZ_ALU_BYPASS_MUX 	<= 	EX_ALU_CC_OUT(1 downto 0) when DPA_EX_OPB_ALU_MUX_CTRL = '0' else
				 	EX_CC_MUX(1 downto 0);
				   	


	ArmDataReplication_Instance : ArmDataReplication
       	PORT MAP(
		DRP_INPUT 	=> EX_OPC_MUX,
		DRP_DMAS 	=> DPA_EX_DRP_DMAS,
		DRP_OUTPUT 	=> EX_DRP_OUTPUT 
	);

--------------------------------------------------------------------------------
--	Der Condition-Code kann durch den Shifter im C-Bit veraendert worden
--	sein, daher wird der C-Ausgang des Shifters mit dem V-Bit neu
--	zusammengesetzt. N und Z werden durch die ALU immer neu gebildet.
--------------------------------------------------------------------------------
	EX_ALU_CC_IN <= EX_SHIFT_C_OUT & EX_CC_MUX(0);


	MEM_ADDR_INCREMENTED	<=	std_logic_vector(unsigned(MEM_ADDR_REG) + 4);
	
--	EX-Ausgangsregister aktualisieren
	SET_EX_MEM_REGS : process(DPA_CLK)IS
	begin
		if DPA_CLK'event and DPA_CLK = '1' then
			if DPA_RST = '1' and USE_OPTIONAL_RESET then
				MEM_DATA_REG	<= (others => '0');
				MEM_RES_REG	<= (others => '0');
				MEM_CC_REG	<= (others => '0');
				MEM_BASE_REG	<= (others => '0');
				MEM_ADDR_REG	<= (others => '0');
			else
				MEM_DATA_REG	<= MEM_DATA_REG;
				MEM_RES_REG	<= MEM_RES_REG;
				MEM_CC_REG	<= MEM_CC_REG;
				MEM_BASE_REG	<= MEM_BASE_REG;
				MEM_ADDR_REG	<= MEM_ADDR_REG;
				if(DPA_ENABLE = '1')then
					if DPA_MEM_DATA_REG_EN = '1' then
						MEM_DATA_REG <= EX_DRP_OUTPUT;	
					end if;       	
					if DPA_MEM_RES_REG_EN = '1' then
						MEM_RES_REG <= EX_PSR_CC_MUX & EX_ALU_RES(27 downto 0);
					end if;       	
					if DPA_MEM_CC_REG_EN = '1' then
						MEM_CC_REG <= EX_ALU_CC_OUT(3 downto 2) & EX_NZ_ALU_BYPASS_MUX;
					end if; 	
					if DPA_MEM_BASE_REG_EN = '1' then
						MEM_BASE_REG <= EX_OPA_MUX;
					end if;
					if DPA_EX_DAR_EN = '1' then
						MEM_ADDR_REG <= EX_DAR_MUX;
					end if;
				end if;	
			end if;
		end if;
	end process SET_EX_MEM_REGS;

--------------------------------------------------------------------------------
--	Memory-Stufe
--------------------------------------------------------------------------------

	DPA_MEM_DDOUT	<= MEM_DATA_REG;

	MEM_TRUNC_MUX	<= MEM_ADDR_REG(1 downto 0) when DPA_MEM_TRUNCATE_ADDR = '0' else "00";
--------------------------------------------------------------------------------
--	Erzeugen der Speicher-Zugriffsadresse mit bedarfsweise maskierten 
--	Adressbits 1:0.
--------------------------------------------------------------------------------
	DPA_MEM_DA	<= MEM_ADDR_REG(31 downto 2) & MEM_TRUNC_MUX;

	ArmWordManipulation_Instance : ArmWordManipulation
       	port map(
		WMP_WORD_IN 	=> DPA_MEM_DDIN,
		WMP_ADDRESS 	=> MEM_TRUNC_MUX,
		WMP_DMAS 	=> DPA_MEM_WMP_DMAS,
		WMP_SIGNED 	=> DPA_MEM_WMP_SIGNED,
		WMP_WORD_OUT 	=> MEM_WMP_WORD_OUT
	);


--------------------------------------------------------------------------------
--	Multiplexer zum Einbringen des Schattenregisterinhalts in den 
--	RES-Pfad bei Data Aborts.	
--------------------------------------------------------------------------------
	MEM_BASE_MUX	<= MEM_RES_REG when DPA_MEM_BASE_MUX_CTRL = '0' else MEM_BASE_REG;
--------------------------------------------------------------------------------
--	Neu fuer Coprozessorinstruktionen die den CC im PSR aktualisieren.
--	Die Wortmanipulationseinheit kann umgangen werden, weil vom Coprozessor
--	immer Worte uebertragen werden.
--------------------------------------------------------------------------------
	MEM_CC_MUX	<= MEM_CC_REG when DPA_MEM_CC_MUX_CTRL = '0' else DPA_MEM_DDIN(31 downto 28);

--	MEM-Ausgangsregister setzen
	SET_MEM_WB_REGS : process(DPA_CLK)IS
	begin
		if DPA_CLK'event and DPA_CLK = '1' then
			if DPA_RST = '1' and USE_OPTIONAL_RESET then
				WB_LOAD_REG	<= (others => '0');
				WB_RES_REG	<= (others => '0');
				WB_CC_REG	<= (others => '0');
			else
				WB_LOAD_REG	<= WB_LOAD_REG;
				WB_RES_REG	<= WB_RES_REG;
				WB_CC_REG	<= WB_CC_REG;
				if DPA_ENABLE = '1' then
					if DPA_WB_LOAD_REG_EN = '1' then
						WB_LOAD_REG <= MEM_WMP_WORD_OUT;
					end if;
					if DPA_WB_RES_REG_EN = '1' then
						WB_RES_REG <= MEM_BASE_MUX;
					end if;
					if DPA_WB_CC_REG_EN = '1' then
						WB_CC_REG <= MEM_CC_MUX;
					end if;
				end if;
			end if;
		end if;
	end process SET_MEM_WB_REGS;

--------------------------------------------------------------------------------
--	Writeback-Stufe
--------------------------------------------------------------------------------

	WB_IAR_MUX	<= 	WB_RES_REG(31 downto 2) when DPA_WB_IAR_MUX_CTRL = '0' else
				WB_LOAD_REG(31 downto 2);
	
--------------------------------------------------------------------------------
--	Quelle fuer Sprungadressen in der WB-Stufe im HWPR.
--	Das Sprungziel entspricht einem Ergebnis oder einem Speicherdatum,
--	das die WB-Stufe durchlaeuft.	
--------------------------------------------------------------------------------
	GEN_WITHOUT_FAST_BRANCH_MUX : if not USE_FAST_BRANCH generate
	begin
		WB_IAR_ADDR_IN		<= WB_IAR_MUX;
	end generate GEN_WITHOUT_FAST_BRANCH_MUX;

--------------------------------------------------------------------------------
--	Variante des Prozessors mit der Unterstuetzung vorgezogener 
--	Spruenge aus der EX-Stufe, entweder mit zusaetzlichem
--	dedizierten Addierer zur Adressberechnung oder unter Nutzung
--	der ALU zur Adressberechnung. Defacto bringt die Nutzung
--	eines zusaetzlichen Addierers aktuell keinen Vorteil, das Vorziehen
--	von Spruengen aus der WB- in die EX-Stufe verringert die Latenz
--	der unterstuetzten Befehle um zwei Takte.
--------------------------------------------------------------------------------
	GEN_WITH_FAST_BRANCH_MUX : if USE_FAST_BRANCH generate
		signal WB_FBRANCH_MUX	: std_logic_vector(31 downto 2);
		signal 	BRANCH_ADDER	: std_logic_vector(31 downto 2);
	begin
		BRANCH_ADDER		<= std_logic_vector(unsigned(EX_OPA_MUX(31 downto 2))	+	unsigned(EX_OPB_MUX(31 downto 2)))
		    					when USE_DEDICATED_BRANCH_ADDER else EX_ALU_RES(31 downto 2);
		WB_FBRANCH_MUX		<= WB_IAR_MUX when DPA_WB_FBRANCH_MUX_CTRL = '0' else BRANCH_ADDER;
		WB_IAR_ADDR_IN		<= WB_FBRANCH_MUX;
	end generate GEN_WITH_FAST_BRANCH_MUX;

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--	Tests und Signale für die Simulation
--------------------------------------------------------------------------------
-- synthesis translate_off
	AGP_EX_OPA_REG	<= EX_OPA_REG;		
	AGP_EX_OPB_REG	<= EX_OPB_REG;		
	AGP_EX_OPC_REG	<= EX_OPC_REG;		
	AGP_MEM_DATA_REG<= MEM_DATA_REG;		
	AGP_MEM_ADDR_REG<= MEM_ADDR_REG;
	AGP_MEM_RES_REG	<= MEM_RES_REG;		
	AGP_MEM_CC_REG	<= MEM_CC_REG;		
	AGP_WB_LOAD_REG	<= WB_LOAD_REG;		
	AGP_WB_RES_REG	<= WB_RES_REG;		
	AGP_WB_CC_REG	<= WB_CC_REG;	
	AGP_EX_OPA_MUX	<= EX_OPA_MUX;
	AGP_EX_OPB_MUX	<= EX_OPB_MUX;
	AGP_EX_OPC_MUX	<= EX_OPC_MUX;
	AGP_EX_CC_MUX	<= EX_CC_MUX;
-- synthesis translate_on
-------------------------------------------------------------------------------

end architecture structure;
