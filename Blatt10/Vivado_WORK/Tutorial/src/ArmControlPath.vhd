--------------------------------------------------------------------------------
--	Kontrollpfad des Arm Kerns
--------------------------------------------------------------------------------
--	Datum:	05.07.10
--	Version: 0.95
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.all;
use work.ArmGlobalProbes.all;
use work.ArmConfiguration.all;
use work.ArmRegAddressTranslation.all;

--------------------------------------------------------------------------------
--	Simulationsmodelle fuer fehlerhaft implementierte Module
--------------------------------------------------------------------------------
library ARM_SIM_LIB;
--	use ARM_SIM_LIB.ArmRegisterBitAdder;
--	use ARM_SIM_LIB.ArmLdmStmNextAddress;
--	use ARM_SIM_LIB.ArmCoarseInstructionDecoder;
--	use ARM_SIM_LIB.ArmBypassCtrl;
--	use ARM_SIM_LIB.ArmArithInstructionCtrl;
--------------------------------------------------------------------------------

entity ArmControlPath is
port(
	CPA_CLK				: in std_logic;
	CPA_RST				: in std_logic;
	CPA_IRQ				: in std_logic;
	CPA_FIQ				: in std_logic;
	CPA_WAIT			: in std_logic;
	CPA_IF_ID			: in std_logic_vector(31 downto 0);
	CPA_IF_IABORT			: in std_logic;
	CPA_IF_IEN			: out std_logic;
 	CPA_IF_IBE			: in std_logic;
	CPA_IF_FETCH			: out std_logic;
	CPA_IF_IMODE			: out std_logic_vector(4 downto 0);
	CPA_IF_IAR_INC			: out std_logic;
	CPA_IF_IAR_UPDATE_HB		: out std_logic;
	CPA_MEM_DnRW			: out std_logic;
	CPA_MEM_DEN			: out std_logic;
	CPA_MEM_DABORT			: in std_logic;
	CPA_MEM_DBE			: in std_logic;
	CPA_MEM_DMAS			: out std_logic_vector(1 downto 0);
	CPA_MEM_DMODE			: out std_logic_vector(4 downto 0);

	CPA_EX_CPSR			: in std_logic_vector(31 downto 0);
	CPA_DPA_ENABLE			: out std_logic;
	CPA_ID_IAR_REVOKE		: out std_logic;
	CPA_ID_IAR_HISTORY_ID		: out std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
	CPA_ID_REF_R_PORTS_ADDR 	: out std_logic_vector(14 downto 0);
	CPA_ID_IMMEDIATE		: out std_logic_vector(31 downto 0);
	CPA_ID_SHIFT_AMOUNT		: out std_logic_vector(5 downto 0);
	CPA_ID_OPB_MUX_CTRL 		: out std_logic;
	CPA_ID_SHIFT_MUX_CTRL		: out std_logic;
	CPA_ID_CHS			: in std_logic_vector(1 downto 0);

	CPA_EX_OPA_PSR_MUX_CTRL		: out std_logic;
	CPA_EX_PSR_MUX_CTRL		: out std_logic;
	CPA_EX_OPX_MUX_CTRLS		: out std_logic_vector(5 downto 0);
	CPA_EX_CC_MUX_CTRL		: out std_logic_vector(1 downto 0);
	CPA_EX_SHIFT_MUX_CTRL		: out std_logic_vector(1 downto 0);

	CPA_EX_OPB_ALU_MUX_CTRL		: out std_logic;
	CPA_EX_PSR_CC_MUX_CTRL		: out std_logic;
	CPA_EX_DAR_MUX_CTRL		: out std_logic;

	CPA_EX_SHIFT_TYPE		: out std_logic_vector(1 downto 0);
	CPA_EX_SHIFT_RRX		: out std_logic;
	CPA_EX_ALU_CTRL			: out std_logic_vector(3 downto 0);
	CPA_EX_DRP_DMAS			: out std_logic_vector(1 downto 0);
	CPA_EX_DAR_EN			: out std_logic;
	CPA_EX_DAR_INC			: out std_logic;

	CPA_EX_PASS			: out std_logic;

	CPA_MEM_DATA_REG_EN		: out std_logic;
	CPA_MEM_RES_REG_EN		: out std_logic;
	CPA_MEM_CC_REG_EN		: out std_logic;
	CPA_MEM_BASE_MUX_CTRL		: out std_logic;	
	CPA_MEM_BASE_REG_EN		: out std_logic;	
	CPA_MEM_TRUNCATE_ADDR		: out std_logic;
	CPA_MEM_WMP_SIGNED		: out std_logic;
	CPA_MEM_CC_MUX_CTRL		: out std_logic;
	CPA_MEM_PASS			: out std_logic;

	CPA_WB_REF_W_PORT_A_EN		: out std_logic;
	CPA_WB_REF_W_PORT_B_EN		: out std_logic;
	CPA_WB_REF_W_PORTS_ADDR		: out std_logic_vector(9 downto 0);
	CPA_WB_LOAD_REG_EN		: out std_logic; 	
	CPA_WB_RES_REG_EN		: out std_logic;	
	CPA_WB_CC_REG_EN		: out std_logic; 	
	CPA_WB_PSR_EN			: out std_logic;		
	CPA_WB_PSR_CTRL			: out PSR_CTRL_TYPE;
	CPA_WB_IAR_MUX_CTRL		: out std_logic;	
	CPA_WB_FBRANCH_MUX_CTRL		: out std_logic;
	CPA_WB_IAR_LOAD			: out std_logic
    );
end ArmControlPath;

architecture behave of ArmControlPath is

--	Komponentendeklaration

	component ArmLdmStmNextAddress
	port(
		SYS_RST			: in std_logic;
		SYS_CLK			: in std_logic;
		LNA_LOAD_REGLIST	: in std_logic;
		LNA_HOLD_VALUE		: in std_logic;
		LNA_REGLIST		: in std_logic_vector(15 downto 0);          
		LNA_ADDRESS		: out std_logic_vector(3 downto 0);
		LNA_CURRENT_REGLIST_REG	: out std_logic_vector(15 downto 0)
		);
	end component ArmLdmStmNextAddress;

	component ArmCoarseInstructionDecoder
	port(
		CID_INSTRUCTION		: in std_logic_vector(31 downto 0);          
		CID_DECODED_VECTOR	: out std_logic_vector(15 downto 0)
		);
	end component ArmCoarseInstructionDecoder;

	component ArmCopDecoder
		port(
			ACD_INSTRUCTION_BITS	: in std_logic_vector(8 downto 0);
			ACD_INSTRUCTION_TYPE	: out std_logic_vector(2 downto 0)
		    );
	end component ArmCopDecoder;	

	

	component ArmConditionCheck
	port(
		CDC_CONDITION_FIELD	: in std_logic_vector(3 downto 0);
		CDC_CONDITION_CODE	: in std_logic_vector(3 downto 0);          
		CDC_CONDITION_MET	: out std_logic
		);
	end component ArmConditionCheck;

	component ArmShiftRecoder
	port(
		SRC_OPERAND_2		: IN std_logic_vector(11 downto 5);
		SRC_OPERAND_2_TYPE	: IN std_logic_vector(1 downto 0);
		SRC_SHIFT_AMOUNT	: out std_logic_vector(5 downto 0);
		SRC_SHIFT_TYPE		: out std_logic_vector(1 downto 0);
		SRC_SHIFT_RRX		: out std_logic;
		SRC_USE_OPC		: out std_logic
		);
	end component ArmShiftRecoder;


	component ArmRegisterBitAdder
	port(
		RBA_REGLIST		: in std_logic_vector(15 downto 0);          
		RBA_NR_OF_REGS		: out std_logic_vector(4 downto 0)
		);
	end component ArmRegisterBitAdder;

	component ArmBypassCtrl
	port(	
--------------------------------------------------------------------------------	
--	Sollten die Operanden in den Eingangsregistern gehalten werden, z.B.
--	fuer eine sinnvolle Loesung von Load-Use-Konflikten (besser als aktuell)
--	dann muessen die Steuersignale der EX-Eingangsregister ausgewertet
--	werden
--------------------------------------------------------------------------------	
--		ABC_INST0_OPA_PSR_MUX_CTRL	: in std_logic;
--		ABC_INST0_OPB_MUX_CTRL		: in std_logic;
--		ABC_INST0_SHIFT_MUX_CTRL	: in std_logic;
		ABC_INST0_R_PORT_A_ADDR		: in std_logic_vector(4 downto 0);
		ABC_INST0_R_PORT_B_ADDR		: in std_logic_vector(4 downto 0);
		ABC_INST0_R_PORT_C_ADDR		: in std_logic_vector(4 downto 0);
		ABC_INST1_W_PORT_A_ADDR		: in std_logic_vector(4 downto 0);
		ABC_INST1_W_PORT_B_ADDR		: in std_logic_vector(4 downto 0);
		ABC_INST2_W_PORT_A_ADDR		: in std_logic_vector(4 downto 0);
		ABC_INST2_W_PORT_B_ADDR		: in std_logic_vector(4 downto 0);
		ABC_INST1_W_PORT_A_EN		: in std_logic;
		ABC_INST1_W_PORT_B_EN		: in std_logic;
		ABC_INST2_W_PORT_A_EN		: in std_logic;
		ABC_INST2_W_PORT_B_EN		: in std_logic;
		ABC_INST1_WB_PSR_EN		: in std_logic;
		ABC_INST1_WB_PSR_SET_CC		: in std_logic;
		ABC_INST2_WB_PSR_EN		: in std_logic;
		ABC_INST2_WB_PSR_SET_CC		: in std_logic;          
		ABC_INST0_REGS_USED		: in std_logic_vector(2 downto 0);
		ABC_INST0_SHIFT_REG_USED	: in std_logic;
		ABC_INST0_OPA_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_INST0_OPB_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_INST0_OPC_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_INST0_SHIFT_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_INST0_CC_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_LOAD_USE_CONFLICT		: out std_logic
		);
	end component ArmBypassCtrl;

	component ArmArithInstructionCtrl
	port(
		AIC_DECODED_VECTOR		: in std_logic_vector(15 downto 0);
		AIC_INSTRUCTION			: in std_logic_vector(31 downto 0);

		AIC_IF_IAR_INC			: out std_logic;
		AIC_ID_R_PORT_A_ADDR		: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_B_ADDR		: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_C_ADDR		: out std_logic_vector(3 downto 0);
		AIC_ID_REGS_USED		: out std_logic_vector(2 downto 0);
		AIC_ID_IMMEDIATE		: out std_logic_vector(31 downto 0);
		AIC_ID_OPB_MUX_CTRL		: out std_logic;
		AIC_EX_ALU_CTRL			: out std_logic_vector(3 downto 0);
		AIC_MEM_RES_REG_EN		: out std_logic;
		AIC_MEM_CC_REG_EN		: out std_logic;
		AIC_WB_CC_REG_EN		: out std_logic;
		AIC_WB_W_PORT_A_ADDR		: out std_logic_vector(3 downto 0);
		AIC_WB_W_PORT_A_EN		: out std_logic;	
		AIC_WB_RES_REG_EN		: out std_logic;		
		AIC_WB_IAR_LOAD			: out std_logic;
		AIC_WB_PSR_EN			: out std_logic;
		AIC_WB_PSR_ER			: out std_logic;
		AIC_WB_PSR_SET_CC		: out std_logic;
		AIC_WB_IAR_MUX_CTRL		: out std_logic;
		AIC_DELAY			: out std_logic_vector(1 downto 0);	
		AIC_ARM_NEXT_STATE		: out ARM_STATE_TYPE

		);
	end component ArmArithInstructionCtrl;

--------------------------------------------------------------------------------
--	Urspruenglich konnten Signale fuer Exceptiontypen priorisiert
--	werden, die spezielle Art der Steuerung tut dies jedoch
--	fuer Data Abort, SWI und Undefined durch ihre Struktur bereits
--	selbststaendig. Die Entsprechenden Komponenten des Filters
--	sind daher auskommentiert
--------------------------------------------------------------------------------
-- 	COMPONENT ArmExceptionPrioritization
-- 	PORT(
-- 		EXP_FIQ_IN	: in std_logic;
-- 		EXP_IRQ_IN	: in std_logic;
-- 		EXP_PABORT_IN	: in std_logic;
-- 		EXP_FIQ_OUT 	: out std_logic;
-- 		EXP_IRQ_OUT	: out std_logic;
-- 		EXP_PABORT_OUT	: out std_logic
-- 		);
-- 	END COMPONENT;

	COMPONENT ArmDelayShiftRegister
	generic(DSR_WIDTH : natural range 2 to 16 := 3);
	PORT(
		DSR_CLK		: in std_logic;
		DSR_RST		: in std_logic;
		DSR_WAIT	: in std_logic;
		DSR_SET		: in std_logic;          
		DSR_OUT		: out std_logic
		);
	end component ArmDelayShiftRegister;

	-- Buffer zur Aufnahme der Registeradresse die auf die Basis 
	-- eines Speicherzugriffs verweist um diese bei einem DABORT
	-- wiederherstellen zu koennen
	component ArmRamBuffer
	generic(
		ARB_ADDR_WIDTH : natural range 1 to 4 := 3;
		ARB_DATA_WIDTH : natural range 1 to 64 := 32
	       );
	port(
		ARB_CLK		: in std_logic;
		ARB_WRITE_EN	: in std_logic;
		ARB_ADDR	: in std_logic_vector(ARB_ADDR_WIDTH-1 downto 0);
		ARB_DATA_IN	: in std_logic_vector(ARB_DATA_WIDTH-1 downto 0);
		ARB_DATA_OUT	: out std_logic_vector(ARB_DATA_WIDTH-1 downto 0)
	    );
	end component ArmRamBuffer;

	signal ID_REGS_USED		: std_logic_vector(2 downto 0);

	signal ID_MODE_MUX		: MODE := USER;
	signal IF_ARB_ADDR		: std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0)	:= (others => '0');
	signal WB_ARB_DATA_OUT		: std_logic_vector(4 downto 0)				:= (others => '0');	
	signal ID_BASE_REGADDRESS_MAPPED : std_logic_vector(4 downto 0)				:= (others => '0');
	signal MEM_DABORT_FILTERED	: std_logic						:= '0';
	signal MEM_MEM_DEN		: std_logic						:= '0';
	
	signal ARM_STATE, ARM_NEXT_STATE			: ARM_STATE_TYPE		:= STATE_FETCH;
	signal IF_LDMSTM_MUX_CTRL				: std_logic			:= '0';
	signal IF_LDMSTM_MUX					: std_logic_vector(15 downto 0)	:= (others => '0');
	signal MAIN_DELAY, MAIN_DELAY_REG 			: natural range 0 to 3		:= 0;
--	Steuersignale der FIQ/IRQ-Maskierung (registerbasiert)
	SIGNAL ID_MASK_FIQ, ID_MASK_IRQ				: std_logic			:= '0';
	SIGNAL ID_FIQ_MASK, ID_IRQ_MASK				: std_logic			:= '0';
--	weitere Exception-Steuersignale und Register
	SIGNAL ID_INSTRUCTION_REG, ID_OLD_INSTRUCTION_REG	: std_logic_vector(31 downto 0) := (others => '0');
	signal ID_HOLD_OLD_INSTRUCTION_REG			: std_logic			:= '0';
	SIGNAL ID_IABORT_REG					: std_logic			:= '0';
	SIGNAL CID_DECODED_VECTOR				: COARSE_DECODE_TYPE		:= CD_UNDEFINED;
--	IF_IAR_INC_REG wird aktuell nicht verwendet
	SIGNAL IF_IAR_INC					: std_logic			:= '0';
--	Interrupts werden erst registriert und dann verwendet um das Interruptsignal zu Beginn eines Taktes sicher zur Verfügung zu haben 
--	Alle anderen externen Exceptionsignale sind ebenso registiert
	SIGNAL ID_FIQ, ID_FIQ_REG, ID_IRQ, ID_IRQ_REG		: std_logic			:= '0';
	signal ID_DABORT_REG					: std_logic 			:= '0';
--	Steuersignale, die noch in der Decodestufe verwendet werden und neben
--	Ausgängen von ArmControlPath noch weitere Komponenten steuern
	signal	ID_REF_R_PORTS_ADDR				: std_logic_vector(14 downto 0) := (others => '0');
-- 	signal	ID_OPA_MUX_CTRL					: std_logic			:= '0';
	signal	ID_OPB_MUX_CTRL					: std_logic			:= '0';
	signal	ID_SHIFT_MUX_CTRL 				: std_logic			:= '0';
	signal	ID_LOAD_USE_CONFLICT				: std_logic			:= '0';
--	Signal, durch das ein NOP in die Pipeline eingefuegt wird
-- 	signal ID_STOPP_DECODE					: std_logic 			:= '0';
	signal ID_IMMEDIATE 					: std_logic_vector(31 downto 0) := (others => '0');
	signal ID_DPA_ENABLE					: std_logic			:= '0';
 	signal ID_SHIFT_AMOUNT					: std_logic_vector(5 downto 0);
--	Pipelineregister der Speicherzugriffssteuerung
	SIGNAL ID_MEM_DnRW, ID_MEM_DEN 				: std_logic 			:= '0';
--	SIGNAL ID_MEM_DMAS : STD_LOGIC_VECTOR(1 downto 0);
	SIGNAL EX_MEM_DnRW_REG, EX_MEM_DEN_REG, MEM_MEM_DnRW_REG, MEM_MEM_DEN_REG : std_logic;
--	SIGNAL EX_MEM_DMAS_REG, MEM_MEM_DMAS_REG : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
	signal EX_OPX_MUX_CTRLS					: EX_CTRL_SIG_6VEC_TYPE	:= (others => (others => '0'));
	signal MEM_DMAS						: MEM_CTRL_SIG_2VEC_TYPE := (others => DMAS_WORD);
--	Pipelineregister der Rückschreibadressen
	signal WB_REF_W_PORTS_ADDR				: WB_CTRL_SIG_10VEC_TYPE := (others => (others => '0'));
--	Pipelineregister der Rueckschreib-Enables	
	SIGNAL ID_REF_W_PORT_A_EN, ID_REF_W_PORT_B_EN		: std_logic			:= '0';	
	SIGNAL EX_REF_W_PORT_A_EN_REG, EX_REF_W_PORT_B_EN_REG, MEM_REF_W_PORT_A_EN_REG, MEM_REF_W_PORT_B_EN_REG, WB_REF_W_PORT_A_EN_REG, WB_REF_W_PORT_B_EN_REG : STD_LOGIC := '0';
--	Pipelineregister für die Multiplexer der Executestufe
	signal 	ID_EX_CC_MUX_CTRL,ID_EX_SHIFT_MUX_CTRL 		: std_logic_vector(1 downto 0) := "00";		
	signal 	EX_EX_SHIFT_MUX_CTRL_REG,EX_EX_CC_MUX_CTRL_REG	: std_logic_vector(1 downto 0) := "00";
	SIGNAL 	ID_EX_OPB_ALU_MUX_CTRL, ID_EX_PSR_CC_MUX_CTRL, 
		ID_EX_DAR_MUX_CTRL 	: std_logic	:= '0';
	SIGNAL 	EX_EX_OPB_ALU_MUX_CTRL_REG, EX_EX_PSR_CC_MUX_CTRL_REG, 
		EX_EX_DAR_MUX_CTRL_REG : std_logic := '0';
	signal EX_SHIFT_EX_CTRL					: EX_SHIFT_EX_CTRL_TYPE		:= (others => (SH_LSL,'0'));
	signal MEM_WMP_CTRL					: MEM_CTRL_SIG_TYPE := (others => '0');	
	signal MEM_TRUNCATE_ADDR				: MEM_CTRL_SIG_TYPE := (others => '0');	
--	Pipelineregister für Steuersignale der verarbeitenden Komponenten der EX-STufe
-- 	SIGNAL ID_EX_SHIFT_TYPE, EX_EX_SHIFT_TYPE_REG		: STD_LOGIC_VECTOR(1 downto 0) := "00";
-- 	SIGNAL ID_EX_SHIFT_RRX, EX_EX_SHIFT_RRX_REG		: STD_LOGIC := '0';
	SIGNAL ID_EX_ALU_CTRL, EX_EX_ALU_CTRL_REG		: std_logic_vector(3 downto 0) := "0000";
--	Pipelineregister für die Steuersignale der MEM-Stufe
	SIGNAL ID_MEM_DATA_REG_EN, EX_MEM_DATA_REG_EN_REG	: std_logic			:= '0';
	SIGNAL ID_MEM_RES_REG_EN, EX_MEM_RES_REG_EN_REG		: std_logic			:= '0';
	SIGNAL ID_MEM_CC_REG_EN, EX_MEM_CC_REG_EN_REG		: std_logic			:= '0';
	SIGNAL ID_MEM_DAR_EN, EX_MEM_DAR_EN_REG			: std_logic			:= '0';
	SIGNAL ID_MEM_DAR_INC, EX_MEM_DAR_INC_REG		: std_logic			:= '0';
	signal ID_MEM_BASE_REG_EN, EX_MEM_BASE_REG_EN_REG	: std_logic 			:= '0';
--	Pipelineregister für die Steuersignale der WB-Stufe
--	SIGNAL ID_WB_USER_REGS, EX_WB_USER_REGS_REG, MEM_WB_USER_REGS_REG, WB_WB_USER_REGS_REG : STD_LOGIC;
	SIGNAL ID_WB_LOAD_REG_EN, EX_WB_LOAD_REG_EN_REG, MEM_WB_LOAD_REG_EN_REG : std_logic	:= '0';
	SIGNAL ID_WB_RES_REG_EN, EX_WB_RES_REG_EN_REG, MEM_WB_RES_REG_EN_REG : std_logic	:= '0';
	SIGNAL ID_WB_CC_REG_EN, EX_WB_CC_REG_EN_REG, MEM_WB_CC_REG_EN_REG : std_logic		:= '0';
	SIGNAL ID_WB_PSR_EN, EX_WB_PSR_EN_REG, MEM_WB_PSR_EN_REG, WB_WB_PSR_EN_REG		: std_logic := '0';
	SIGNAL ID_WB_IAR_LOAD, EX_WB_IAR_LOAD_REG, MEM_WB_IAR_LOAD_REG, WB_WB_IAR_LOAD_REG	: std_logic := '0';
	SIGNAL ID_WB_IAR_MUX_CTRL, EX_WB_IAR_MUX_CTRL_REG, MEM_WB_IAR_MUX_CTRL_REG, WB_WB_IAR_MUX_CTRL_REG : std_logic := '0';
--	Vollstaendig priorisierte und maskierte Exceptionsignale
	SIGNAL ID_FIQ_FILTERED					: std_logic; 
	SIGNAL ID_IRQ_FILTERED, ID_PABORT_FILTERED		: std_logic; 

--	Neue Signale fuer die Verarbeitung von Coprozessorinstruktionen
	signal ID_COP_INSTRUCTION_BITS				: std_logic_vector(8 downto 0)		:= (others => '0');
	signal ID_COP_INSTRUCTION_TYPE				: COPROCESSOR_INSTRUCTION_TYPE;

--	Steuersignal und Pufferregister zum aktivieren des Instruktionsspeichers
--	Das Signal sollte aus Zeitgründen registriert sein.
	SIGNAL IF_IEN, IF_IEN_REG				: std_logic			:= '0';
--	Zweites Steuersignal zur Übernahme der gelesenen Instruktion in das Instruktionsregister
--	Sinnvollerweise sollte dieses Steuersignal nicht gepuffert sein und kann daher nicht
--	mit dem zum Aktivieren des Speicher identisch gewählt werden
	SIGNAL IF_FETCH_INSTRUCTION				: std_logic;
	signal IF_UPDATE_HISTORY_BUFFERS			: std_logic;

	SIGNAL LNA_CURRENT_REGLIST_REG				: std_logic_vector(15 downto 0)		:= (others => '0');
	SIGNAL RBA_NR_OF_REGS					: std_logic_vector(4 downto 0);
	signal ID_FILTERED_EXCEPTIONS 				: std_logic_vector(2 downto 0);

-- 	SIGNAL SRC_SHIFT_AMOUNT 				: STD_LOGIC_VECTOR(5 downto 0);
-- 	SIGNAL SRC_SHIFT_TYPE 					: SHIFT_TYPE;
-- 	SIGNAL SRC_SHIFT_RRX 					: STD_LOGIC;
-- 	SIGNAL SRC_USE_OPC 					: STD_LOGIC;
	signal SRC_SHIFT_CTRL					: SHIFT_CTRL_TYPE;
	SIGNAL SRC_OPERAND_2_TYPE				: OPERAND_2_TYPE;

--	ID_CONDIGITION_FIELD entspricht den vier Bedingungsbits einer Instruktion
--	Für Einzyklenbefehle kann immer umittelbar das Bedingungsfeld auf das Signal gegeben werden, das dann mit der nächsten Taktflanke ein Bedingungsregister für die Executestufe setzt. Dort werden alle Schreib- und Speichersteuerleitungen für die Execute- und alle nachfolgenden Stufen invalidiert.
--	Bei mehrzyklenbefehlen entspricht ID_CONDITION_FIELD so lange dem Register EX_CONDITION_FIELD_REG (das seinen Wert also hält), bis der nächste Befehl dekodiert wird.
	SIGNAL ID_CONDITION_FIELD, EX_CONDITION_FIELD_REG	: std_logic_vector(3 downto 0)	:= "0000";
	SIGNAL CDC_CONDITION_MET				: std_logic			:= '0';
	SIGNAL ID_LNA_LOAD_REGLIST, ID_LNA_HOLD_VALUE 		: std_logic			:= '0';
	SIGNAL ID_LNA_ADDRESS 					: std_logic_vector(3 downto 0)	:= "0000";

--	Signale fuer den Einbau einer zusaetzlichen Komponente fuer die Reaktion auf Arithmetische Instruktionen, die Registeradressen 
--	sind als Adressen vor der Abbildung auf 31 Register zu verstehen und daher nur 4 Bit breit
	signal	AIC_IF_IAR_INC					: std_logic;
	signal	AIC_ID_R_PORT_A_ADDR				: std_logic_vector(3 downto 0);
	signal	AIC_ID_R_PORT_B_ADDR				: std_logic_vector(3 downto 0);
	signal	AIC_ID_R_PORT_C_ADDR				: std_logic_vector(3 downto 0);
	signal	AIC_ID_IMMEDIATE				: std_logic_vector(31 downto 0);
	signal AIC_ID_REGS_USED					: std_logic_vector(2 downto 0);
	signal	AIC_ID_OPB_MUX_CTRL				: std_logic;
	signal	AIC_EX_ALU_CTRL					: std_logic_vector(3 downto 0);
	signal	AIC_WB_W_PORT_A_ADDR				: std_logic_vector(3 downto 0);
	signal	AIC_WB_W_PORT_A_EN				: std_logic;
	signal	AIC_MEM_RES_REG_EN				: std_logic;
	signal 	AIC_MEM_CC_REG_EN				: std_logic;
	signal  AIC_WB_CC_REG_EN				: std_logic;
	signal	AIC_WB_RES_REG_EN				:  std_logic;
	signal	AIC_WB_PSR_EN					: std_logic;
	signal  AIC_WB_PSR_ER					: std_logic;
	signal	AIC_WB_PSR_SET_CC				: std_logic;
	signal  AIC_WB_IAR_MUX_CTRL				: std_logic;	
	signal  AIC_WB_IAR_LOAD					: std_logic;
	signal	AIC_DELAY					: std_logic_vector(1 downto 0);
	signal	AIC_ARM_NEXT_STATE				: ARM_STATE_TYPE;

--	Durch CDC_CONDITION_MET gefilterte Steuersignale
	signal EX_REF_W_PORT_A_EN_REG_MET, EX_REF_W_PORT_B_EN_REG_MET, EX_MEM_DEN_REG_MET,
	EX_MEM_DnRW_REG_MET, EX_WB_LOAD_REG_EN_REG_MET, --EX_WB_USER_REGS_REG_MET, 
	EX_WB_RES_REG_EN_REG_MET, EX_WB_CC_REG_EN_REG_MET, EX_WB_PSR_EN_REG_MET, EX_WB_IAR_LOAD_REG_MET : std_logic;

--	Neue Steuersignale fuer die Wartefunktion
	signal ID_LNA_HOLD_VALUE_WAIT_MASKED			: std_logic;

--	Register/Signale fuer die Erzeugung der Instruktions-ID
--	signal	INSTRUCTION_ID_SRC_REG	: std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
	signal	IF_INST_ID_SRC_MUX, ID_INST_ID_PASS_MUX, WB_INST_ID_ABORT_MUX : std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
	signal IF_INSTRUCTION_ID_REGISTER_INC			: std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
	signal IF_INST_ID_SRC_MUX_CTRL,	ID_INST_ID_PASS_MUX_CTRL, WB_INST_ID_ABORT_MUX_CTRL : std_logic;
	signal INSTRUCTION_ID_REGISTER				: INSTRUCTION_ID_REGISTER_TYPE := (others => (others => '0'));
	signal CPA_EX_PASS_REG					: EX_CTRL_SIG_TYPE := "00";
-- 	Dieses Signal wird nur verwendet, wenn auch ein Coprozessor vorhanden ist
	signal MEM_CC_MUX_CTRL_REG				: MEM_CTRL_SIG_TYPE := "000";
	signal EX_FBRANCH_MUX_CTRL				: EX_CTRL_SIG_TYPE := "00";
	signal WB_PSR_CTRL					: WB_PSR_CTRL_TYPE := (others => (EXC_ENTRY => '0',EXC_RETURN => '0', SET_CC => '0', WRITE_SPSR => '0', MASK => "0000", MODE => SUPERVISOR));
	signal EX_OPA_PSR_MUX_CTRL,EX_PSR_MUX_CTRL		: EX_CTRL_SIG_TYPE := "00";		

	signal IRQ_FIQ_IABORT					: std_logic;

-- 	Leseports C,B,A: die meisten Instruktionen verwenden nicht permanent
-- 	alle 3 Leseports. Damit keine sinnlosen Load-Use-Konflikte angezeigt
-- 	werden, muss eine Markierung existiern, welche gelesenen Registerinhalte
-- 	wirklich verwendet werden.
begin

--------------------------------------------------------------------------------
--	Instanzen von Hilfskomponenten
--------------------------------------------------------------------------------
	
	
	ID_BASE_REGADDRESS_MAPPED	<= GET_INTERNAL_ADDRESS(ID_INSTRUCTION_REG(19 downto 16),ID_MODE_MUX,'0');
	
	CPA_BASE_ADDR_BUFFER : ArmRamBuffer
	generic map(
		ARB_ADDR_WIDTH => INSTRUCTION_ID_WIDTH,
		ARB_DATA_WIDTH => 5 --Abgebildete Registeradresse
	)
	port map(
		ARB_CLK		=> CPA_CLK,
		ARB_WRITE_EN	=> IF_UPDATE_HISTORY_BUFFERS, --IF_FETCH_INSTRUCTION,
		ARB_ADDR	=> IF_ARB_ADDR,	-- kann nicht einfach das ID-Register sein weil beim ABORT umgeschaltet werden muss
		-- mit dieser Zuweisung wird die Registeradresse des Basisregisters der Instruktion
		-- in den Speicher verschoben, die bereits in der Decodestufe ist. Funktioniert weil mit dem
		-- ersten Takt der aktuellen Instruktion bereits die naechste Instruktion gefetcht wird (immer), selbst
		-- eine LDM-Instruktion die Pipeline lange blockiert ist ihre Basisregisteradresse daher bereits in den Puffer verschoben
		ARB_DATA_IN	=> ID_BASE_REGADDRESS_MAPPED, --ID_INSTRUCTION_REG(19 downto 16),
		ARB_DATA_OUT	=> WB_ARB_DATA_OUT
	);


	Inst_ArmArithInstructionCtrl: ArmArithInstructionCtrl port map(
		AIC_DECODED_VECTOR 	=> CID_DECODED_VECTOR,
		AIC_INSTRUCTION 	=> ID_INSTRUCTION_REG,
		AIC_IF_IAR_INC		=> AIC_IF_IAR_INC ,
		AIC_ID_R_PORT_A_ADDR	=> AIC_ID_R_PORT_A_ADDR ,
		AIC_ID_R_PORT_B_ADDR	=> AIC_ID_R_PORT_B_ADDR ,
		AIC_ID_R_PORT_C_ADDR	=> AIC_ID_R_PORT_C_ADDR ,
		AIC_ID_REGS_USED	=> AIC_ID_REGS_USED ,
		AIC_ID_IMMEDIATE	=> AIC_ID_IMMEDIATE ,
		AIC_ID_OPB_MUX_CTRL	=> AIC_ID_OPB_MUX_CTRL ,
		AIC_EX_ALU_CTRL		=> AIC_EX_ALU_CTRL ,
		AIC_MEM_RES_REG_EN	=> AIC_MEM_RES_REG_EN ,
		AIC_MEM_CC_REG_EN	=> AIC_MEM_CC_REG_EN ,
		AIC_WB_W_PORT_A_ADDR	=> AIC_WB_W_PORT_A_ADDR ,
		AIC_WB_W_PORT_A_EN	=> AIC_WB_W_PORT_A_EN ,
		AIC_WB_RES_REG_EN	=> AIC_WB_RES_REG_EN ,
		AIC_WB_CC_REG_EN	=> AIC_WB_CC_REG_EN ,
		AIC_WB_IAR_LOAD		=> AIC_WB_IAR_LOAD ,
		AIC_WB_PSR_EN		=> AIC_WB_PSR_EN ,
		AIC_WB_PSR_ER		=> AIC_WB_PSR_ER ,
		AIC_WB_PSR_SET_CC	=> AIC_WB_PSR_SET_CC ,
		AIC_WB_IAR_MUX_CTRL	=> AIC_WB_IAR_MUX_CTRL ,
		AIC_DELAY		=> AIC_DELAY ,
		AIC_ARM_NEXT_STATE	=> AIC_ARM_NEXT_STATE 
	);



--------------------------------------------------------------------------------
--	Steuersignale für die Fetchstufe
--------------------------------------------------------------------------------
--	Beachte: Die Steuersignale für dem Instruktionsbus sind immer registriert,
--	werden also erst einen Takt nach dem setzen wirksam!
--	Etwas außer der Reihe wird hier auch ein Register für das PC-Inkrementsignal realisiert
--	CPA_IF_IEN <= IF_FETCH_INSTRUCTION_REG;
	CPA_IF_IEN <= IF_IEN_REG;
	CPA_IF_IAR_INC <= IF_IAR_INC;
	CPA_IF_FETCH <= IF_FETCH_INSTRUCTION;

-- 	Am Instruktionsbus muss ein Betriebsmodus praesentiert werden. Sofern nach einem
-- 	Moduswechsel das naechste Fetch bis zur Aktualisierung des PSR verzoegert wird,
-- 	kann dazu der PSR-Modusausgang direkt verwendet werden. Zum Beschleunigen 
-- 	der Ausnahmebehandlung wird der Modusausgang hier an den Multiplexer angeschlossen, 
-- 	der den laufenden Moduswechsel in der Pipeline widerspiegelt.
	CPA_IF_IMODE	<= ID_MODE_MUX;

	-- Das maskieren mit dem DABORT sorgt ggf. dafuer dass die History Buffer kleiner
	-- sein koennen, erhoeht aber die Signallaufzeit der Buffer-Steuersignale signifikant.
	-- Wenn diese Entscheidung zeitkritisch sein sollte kann MEM_DABORT_FILTERED aus
	-- der Zuweisung wieder entfernt werden
	IF_UPDATE_HISTORY_BUFFERS <= IF_FETCH_INSTRUCTION and not MEM_DABORT_FILTERED;

	IF_INSTRUCTION_ID_REGISTER_INC <= std_logic_vector(unsigned(INSTRUCTION_ID_REGISTER(0)) + 1);
	IF_INST_ID_SRC_MUX_CTRL <= IF_FETCH_INSTRUCTION;
	IF_INST_ID_SRC_MUX	<= IF_INSTRUCTION_ID_REGISTER_INC when IF_INST_ID_SRC_MUX_CTRL = '1' else INSTRUCTION_ID_REGISTER(0);
	CPA_IF_IAR_UPDATE_HB    <= IF_UPDATE_HISTORY_BUFFERS;--IF_FETCH_INSTRUCTION;

	-- Im Takt nach der Abgebrochenen Instruktion wird die Basisadresse wiederhergestellt, dazu muss das entsprechende
	-- ID-Register am Ende der MEM-Stufe als Adresse fuer das Auslesen des zugehörigen Eintrags im Basispuffer dienen
	-- Waehrend dieses Takts beginnt die FSM, den Abort zu bearbeiten und Fetcht keine weitere Instruktion
	IF_ARB_ADDR		<= INSTRUCTION_ID_REGISTER(0) when ID_DABORT_REG = '0' else INSTRUCTION_ID_REGISTER(3);
	-- Registerschreiben
	SET_IF_ID_REGS : process(CPA_CLK)is
	begin
		if CPA_CLK'event and CPA_CLK = '1' then
			if CPA_RST = '1' then
				ID_INSTRUCTION_REG 	<= (others => '0');
				ID_IABORT_REG		<= '0';
				-- Gleich im ersten Takt Instruktionsspeicher adressieren
				IF_IEN_REG 		<= '1';
				ID_FIQ_REG		<= '0';
				ID_IRQ_REG		<= '0';
				
				INSTRUCTION_ID_REGISTER(0)<= (others => '0');
			else
				ID_INSTRUCTION_REG 	<= ID_INSTRUCTION_REG;
				ID_IABORT_REG	   	<= ID_IABORT_REG;
				IF_IEN_REG		<= IF_IEN_REG;
				ID_FIQ_REG		<= ID_FIQ_REG;
				ID_IRQ_REG		<= ID_IRQ_REG;


				INSTRUCTION_ID_REGISTER(0) <= INSTRUCTION_ID_REGISTER(0); 				

				if CPA_WAIT = '0' then
					INSTRUCTION_ID_REGISTER(0) <= IF_INST_ID_SRC_MUX;
				-- In Wartezyklen wird der Speicher weiter aktiv angesteuert, wenn sich
--				der Inhalt des Instruktionsregisters nicht aendert bleibt dies genau so,
--				das Maskieren mit nWAIT ist also vermutlich ueberfluessig
					IF_IEN_REG 		<= IF_IEN;
--				Das Inkrementieren wird bereits im Datenpfad direkt am IAR maskiert, 
--				muss dies hier noch einmal sein?
--				Ich sehe keinen unmittelbaren Grund, die Interruptsignale
--				mit nWAIT zu maskieren, werde es aber dennoch vorlaeufig so handhaben
--				um den Prozessorkern _vollstaendig_ anzuhalten
					ID_FIQ_REG		<= CPA_FIQ;
					ID_IRQ_REG		<= CPA_IRQ;
				end if;

				if IF_FETCH_INSTRUCTION = '1' and CPA_IF_IBE = '1' and CPA_WAIT = '0' then
					ID_INSTRUCTION_REG <= CPA_IF_ID;
					ID_IABORT_REG 	   <= CPA_IF_IABORT;
				end if;				
			end if;
		end if;
	END PROCESS SET_IF_ID_REGS;

--------------------------------------------------------------------------------
--	Steuersignale für die Decodestufe
--	Beim Dekodieren erzeugte Steuersignale, die unmittelbar auf die
--	Executestufe wirken, werden hier nicht aufgeführt sondern stattdessen
--	direkt in der steuernden Statemachine zugewiesen
--------------------------------------------------------------------------------

--	Die Delayshiftregister muessen nWAIT nicht beruecksichtigen, sofern sichergestellt ist,
--	dass wahrend des Wartens permanent die gleichen Maskierungssteuersignale gesetzt werden
	ArmDelayShiftRegister_FIQ: ArmDelayShiftRegister
	generic map(DSR_WIDTH => 3)
       	port map(
		DSR_CLK => CPA_CLK,
		DSR_RST => CPA_RST,
		DSR_WAIT=> CPA_WAIT,
		DSR_SET => ID_MASK_FIQ, --evtl. zusaetzlich mit nWAIT maskieren
		DSR_OUT => ID_FIQ_MASK
	);
	ArmDelayShiftRegister_IRQ: ArmDelayShiftRegister
	generic map(DSR_WIDTH => 3)
       	port map(
		DSR_CLK => CPA_CLK,
		DSR_RST => CPA_RST,
		DSR_WAIT=> CPA_WAIT,
		DSR_SET => ID_MASK_IRQ, --evtl. zusaetzlich mit nWAIT maskieren
		DSR_OUT => ID_IRQ_MASK
	);

	ID_COP_INSTRUCTION_BITS	<= ID_INSTRUCTION_REG(27 downto 20) & ID_INSTRUCTION_REG(4);

	COP_INSTRUCTION_DECODER	: ArmCopDecoder
	port map(
		ACD_INSTRUCTION_BITS	=>	ID_COP_INSTRUCTION_BITS,
		ACD_INSTRUCTION_TYPE	=>	ID_COP_INSTRUCTION_TYPE
	);

	ID_FIQ <= ID_FIQ_REG and not (CPA_EX_CPSR(6) or ID_FIQ_MASK);
	ID_IRQ <= ID_IRQ_REG and not (CPA_EX_CPSR(7) or ID_IRQ_MASK);
	IRQ_FIQ_IABORT <= ID_FIQ or ID_IRQ or ID_IABORT_REG;

-- 	Der Aufbau der Steuerung macht es nicht mehr notwendig, die 
-- 	zahlreichen Unterbrechungssignale in einem eigenen Modul
-- 	zu priorisieren. Die verbliebene Priorisierung zwischen
-- 	FIQ,IRO und PABORT kann hier direkt im Quellcode erfolgen.
-- 	Pruefen: ist auch dies durch die Struktur der Steuerung bereits
-- 	ueberfluessig geworden?

	ID_FIQ_FILTERED			<= ID_FIQ;
	ID_IRQ_FILTERED 		<= ID_IRQ and (not ID_FIQ);
	ID_PABORT_FILTERED 		<= ID_IABORT_REG and (not ID_FIQ) and (not ID_IRQ); 
	ID_FILTERED_EXCEPTIONS		<= ID_FIQ_FILTERED & ID_IRQ_FILTERED & ID_PABORT_FILTERED;

	ArmCoarseInstructionDecoder_INSTANCE: ArmCoarseInstructionDecoder
	port map(
		CID_INSTRUCTION		=> ID_INSTRUCTION_REG,
		CID_DECODED_VECTOR	=> CID_DECODED_VECTOR
	);

--	Am beginn einer LDM/STM-Instruktion wird die darauf folgende Instruktion bereits 
--	in das ID_INSTRUCTION_REG geschrieben, ID_LNA_LAOD_REGLIST aber nicht aktualisiert.
--	Es kann sich um eine weitere LDM-Instruktion handeln. Daher muss ArmLdmStmNextAddress einmalig
--	aus ID_INSTRUCTION_REG aktualisiert werden, wenn eine LDM/STM-Instruktion abeschlossen wird.
	IF_LDMSTM_MUX <= CPA_IF_ID(15 downto 0) when IF_LDMSTM_MUX_CTRL = '0' else ID_INSTRUCTION_REG(15 downto 0);

--	Anpassung an Wartesignal: LOAD_REGLIST wird nicht maskiert, da das halten des alten Inhalts sinnlos ist
--	sofern das Ladesignal bereits gesetzt wurde.
--	HOLD_VALUE beruecksichtigt CPA_nWAIT um zu verhindern, dass der aktuelle Inhalt ueberschrieben wird
--	(ausser, und dann zurecht, durch ein LOAD)

	ID_LNA_HOLD_VALUE_WAIT_MASKED <= CPA_WAIT or ID_LNA_HOLD_VALUE;
	ArmLdmStmNextAddress_INSTANCE: ArmLdmStmNextAddress
	port map(
		SYS_RST 		=> CPA_RST,
		SYS_CLK 		=> CPA_CLK,
		LNA_LOAD_REGLIST 	=> ID_LNA_LOAD_REGLIST,
		LNA_HOLD_VALUE 		=> ID_LNA_HOLD_VALUE_WAIT_MASKED,--ID_LNA_HOLD_VALUE,
		--Es wird permanent ein Teil der Daten auf dem Bus gelesen,
--		nur bei Erkennen einer LDM/STM-Instruktion wird der Wert nicht
--		vom Bus aktualisiert
		LNA_REGLIST 		=> IF_LDMSTM_MUX,
		LNA_ADDRESS 		=> ID_LNA_ADDRESS,
		--Ausgang mit den verbleibenden Zugriffsbits 
--		zur Errechnung der ausbleibenden Zugriffszahl
		LNA_CURRENT_REGLIST_REG => LNA_CURRENT_REGLIST_REG
	);

	ArmRegisterBitAdder_Instance: ArmRegisterBitAdder
	PORT MAP(
		RBA_REGLIST => LNA_CURRENT_REGLIST_REG,
		RBA_NR_OF_REGS => RBA_NR_OF_REGS 
	);

-- 	Bypasssteuerung fuer die Verwendung des korrekten
-- 	neuen Modus unmittelbar nach dem ersten Takt des 
-- 	Ausnahmebehandlung.
-- 	Der Bypass ermoeglicht nur die Verwendung
-- 	eines neuen Betriebsmodus der durch die Signale
-- 	PSR_EN und PSR_EXCEPTION_ENTRY verursacht wird, um die Wartezeit
-- 	nach dem ersten Takt zu verkurzen. Exception Return und
-- 	direkte Schreibzugriffe auf das Statusregister werden
-- 	nocht nicht beruecksichtigt
 	EXCEPTION_MODE_BYPASS : process(WB_PSR_CTRL(1).EXC_ENTRY, WB_PSR_CTRL(2).EXC_ENTRY, WB_PSR_CTRL(3).EXC_ENTRY,
					WB_PSR_CTRL(1).MODE, WB_PSR_CTRL(2).MODE, WB_PSR_CTRL(3).MODE,
					EX_WB_PSR_EN_REG_MET,MEM_WB_PSR_EN_REG,WB_WB_PSR_EN_REG, CPA_EX_CPSR(4 downto 0))is
-- 		variable ENTRY2,ENTRY3	: std_logic := '0';
	begin
		if (EX_WB_PSR_EN_REG_MET and WB_PSR_CTRL(1).EXC_ENTRY)= '1' then 
			ID_MODE_MUX	<= WB_PSR_CTRL(1).MODE;
		elsif (MEM_WB_PSR_EN_REG and WB_PSR_CTRL(2).EXC_ENTRY)= '1' then 
			ID_MODE_MUX	<= WB_PSR_CTRL(2).MODE;
		elsif (WB_WB_PSR_EN_REG and WB_PSR_CTRL(3).EXC_ENTRY)= '1' then 
			ID_MODE_MUX	<= WB_PSR_CTRL(3).MODE;
		else
			ID_MODE_MUX	<= CPA_EX_CPSR(4 downto 0);
		end if;
	end process EXCEPTION_MODE_BYPASS;
--------------------------------------------------------------------------------
--	Sicherstellen, dass keine Bypaessen geschaltet werden koennen
--	wenn der History Buffer verwendet wird
--	Wenn das nicht automatisch sicher ist, kann
--	IAR_REVOKE als zusaetzliches Steuersignal 
--	verwendet werden
--------------------------------------------------------------------------------

	Inst_ArmBypassCtrl: ArmBypassCtrl
       	port map(
--		ABC_INST0_OPA_PSR_MUX_CTRL	=> EX_OPA_PSR_MUX_CTRL(0),
--		ABC_INST0_OPB_MUX_CTRL		=> ID_OPB_MUX_CTRL,
--		ABC_INST0_SHIFT_MUX_CTRL	 => ID_SHIFT_MUX_CTRL,
		ABC_INST0_R_PORT_A_ADDR 	=> ID_REF_R_PORTS_ADDR(4 downto 0),
		ABC_INST0_R_PORT_B_ADDR 	=> ID_REF_R_PORTS_ADDR(9 downto 5),
		ABC_INST0_R_PORT_C_ADDR 	=> ID_REF_R_PORTS_ADDR(14 downto 10),

		ABC_INST1_W_PORT_A_ADDR 	=> WB_REF_W_PORTS_ADDR(1)(4 downto 0),
		ABC_INST1_W_PORT_B_ADDR 	=> WB_REF_W_PORTS_ADDR(1)(9 downto 5),
		ABC_INST2_W_PORT_A_ADDR 	=> WB_REF_W_PORTS_ADDR(2)(4 downto 0),
		ABC_INST2_W_PORT_B_ADDR 	=> WB_REF_W_PORTS_ADDR(2)(9 downto 5),
		ABC_INST1_W_PORT_A_EN		=> EX_REF_W_PORT_A_EN_REG_MET,
		ABC_INST1_W_PORT_B_EN		=> EX_REF_W_PORT_B_EN_REG_MET,
		ABC_INST2_W_PORT_A_EN		=> MEM_REF_W_PORT_A_EN_REG,
		ABC_INST2_W_PORT_B_EN		=> MEM_REF_W_PORT_B_EN_REG,
		ABC_INST1_WB_PSR_EN		=> EX_WB_PSR_EN_REG_MET,
		ABC_INST1_WB_PSR_SET_CC		=> WB_PSR_CTRL(1).SET_CC,
		ABC_INST2_WB_PSR_EN		=>  MEM_WB_PSR_EN_REG,
		ABC_INST2_WB_PSR_SET_CC		=> WB_PSR_CTRL(2).SET_CC,
		ABC_INST0_REGS_USED		=> ID_REGS_USED,
		ABC_INST0_SHIFT_REG_USED	=> ID_SHIFT_MUX_CTRL,
		ABC_INST0_OPA_BYPASS_MUX_CTRL	=> EX_OPX_MUX_CTRLS(0)(1 downto 0),--ID_EX_OPA_MUX_CTRL,
		ABC_INST0_OPB_BYPASS_MUX_CTRL	=> EX_OPX_MUX_CTRLS(0)(3 downto 2),--ID_EX_OPB_MUX_CTRL,
		ABC_INST0_OPC_BYPASS_MUX_CTRL	=> EX_OPX_MUX_CTRLS(0)(5 downto 4),--ID_EX_OPC_MUX_CTRL,
		ABC_INST0_SHIFT_BYPASS_MUX_CTRL	=> ID_EX_SHIFT_MUX_CTRL,
		ABC_INST0_CC_BYPASS_MUX_CTRL	=> ID_EX_CC_MUX_CTRL,
		ABC_LOAD_USE_CONFLICT		=> ID_LOAD_USE_CONFLICT
	);

	CPA_ID_REF_R_PORTS_ADDR	 <= ID_REF_R_PORTS_ADDR;
	CPA_ID_OPB_MUX_CTRL	 <= ID_OPB_MUX_CTRL;
	CPA_ID_SHIFT_MUX_CTRL	 <= ID_SHIFT_MUX_CTRL;
	CPA_ID_SHIFT_AMOUNT	 <= ID_SHIFT_AMOUNT;
	CPA_ID_IMMEDIATE	 <= ID_IMMEDIATE;
	CPA_DPA_ENABLE		 <= ID_DPA_ENABLE;
	
--	Bestimmung von SRC_OPERAND_2_TYPE
	with CID_DECODED_VECTOR select
		SRC_OPERAND_2_TYPE <= OP2_IMMEDIATE 		when CD_ARITH_IMMEDIATE,
				      OP2_IMMEDIATE 		when CD_MSR_IMMEDIATE,
				      OP2_REGISTER 		when CD_LOAD_STORE_UNSIGNED_REGISTER,
				      OP2_REGISTER 		when CD_ARITH_REGISTER,
				      OP2_REGISTER		when CD_MSR_REGISTER,	--kodiert wie ein LSL mit Weite 0
				      OP2_REGISTER_REGISTER 	when CD_ARITH_REGISTER_REGISTER,
				      OP2_NO_SHIFTER_OPERAND 	when others;

	ArmShiftRecoder_Instance: ArmShiftRecoder
	port map(
		SRC_OPERAND_2 		=> ID_INSTRUCTION_REG(11 downto 5),
		SRC_OPERAND_2_TYPE 	=> SRC_OPERAND_2_TYPE,
		SRC_SHIFT_AMOUNT 	=> SRC_SHIFT_CTRL.SHIFT_CTRL_AMOUNT,--SRC_SHIFT_AMOUNT,
		SRC_SHIFT_TYPE 		=> SRC_SHIFT_CTRL.SHIFT_CTRL_TYPE,--SRC_SHIFT_TYPE,
		SRC_SHIFT_RRX 		=> SRC_SHIFT_CTRL.SHIFT_CTRL_RRX,--SRC_SHIFT_RRX,
		-- Unmittelbares Setzen des Multiplexersteuersignales des EX-Stufe geht nicht 
--		noch anzupassen:
		SRC_USE_OPC 		=> SRC_SHIFT_CTRL.SHIFT_CTRL_OPC--SRC_USE_OPC
	);

	-- Dieses Steuersignal ist relativ komplex zu erzeugen da es unmittelbar von der Prozessorsteuerung
	-- abhaengt. Wenn immer eine neue, vorher gefetchte Instruktion neu bearbeitet wird, muss dieses
        -- Signal einmal auf 1 gesetzt werden, in den folgenden Takten (so sie zur gleichen Instruktion gehoeren)
	-- wird die gleiche ID verwendet. Derzeit wird das Signal immer genau dann gesetzt, wenn die
	-- Steuerung im Zustand STATE_DECODE ist.	
	ID_INST_ID_PASS_MUX	<= INSTRUCTION_ID_REGISTER(0) when ID_INST_ID_PASS_MUX_CTRL = '1' else INSTRUCTION_ID_REGISTER(1);

	-- Registerschreiben
	-- Ergeaenzung um CPA_nWAIT
	SET_ID_EX_REGS : process(CPA_CLK)is
	begin
		if CPA_CLK'event and CPA_CLK = '1' then
			--if CPA_RST = '1' then
--				Nach einem Reset befinden sich keine sinnvollen Werte in der Pipeline
--				Grundsaetzlich sollte NV im Bedingungsfeld aber alle
--				relevanten Steuersignale im naechsten Takt loeschen
-- 				EX_CONDITION_FIELD_REG		<= NV;			
-- 				EX_WB_PSR_EN_REG		<= '0';
-- 				EX_WB_IAR_LOAD_REG		<= '0';
-- 				INSTRUCTION_ID_REGISTER(1)	<= (others => '0');
-- 				CPA_EX_PASS_REG(1)		<= '0';
			--else
				INSTRUCTION_ID_REGISTER(1)	<= INSTRUCTION_ID_REGISTER(1); 
				if CPA_WAIT = '0' then
					INSTRUCTION_ID_REGISTER(1) <= ID_INST_ID_PASS_MUX;
					MEM_CC_MUX_CTRL_REG(1) <= MEM_CC_MUX_CTRL_REG(0);	
--				Evtl. den IF-Then-Else-Zweig umbauen, so dass alle davon eigentlich
--				nicht beruehrten Signale ausserhalb stehen statt implizit gespeichert
--				zu werden
				if false then --ID_STOPP_DECODE = '1' then
					-- Alle Steuersignale, die dauerhafte Wirkung entfalten auf 0 setzen
					-- und so ein NOP in die Pipeline schreiben
					-- Wenn das Bedingungsfeld erhalten bleibt, kann waehrend der Wartetakte
--					in WAIT_TO_FETCH und WAIT_TO_DECODE ueberprueft werden, ob das verbleiben in diesen
--					Zustaenden wirklich sinnvoll ist
					EX_MEM_DnRW_REG		<= '0';
					EX_MEM_DEN_REG 		<= '0';
					EX_REF_W_PORT_A_EN_REG	<= '0';
					EX_REF_W_PORT_B_EN_REG	<= '0';
--					EX_WB_USER_REGS_REG	<= '0'; 
					EX_WB_LOAD_REG_EN_REG	<= '0';
					EX_WB_PSR_EN_REG	<= '0';
					EX_WB_IAR_LOAD_REG	<= '0';
					CPA_EX_PASS_REG(1)	<= '0';
					EX_FBRANCH_MUX_CTRL(1)	<= '0';				
					EX_CONDITION_FIELD_REG <= EX_CONDITION_FIELD_REG;			
				else
					EX_CONDITION_FIELD_REG		<= ID_CONDITION_FIELD;			
					EX_OPX_MUX_CTRLS(1)		<= EX_OPX_MUX_CTRLS(0);
					EX_EX_SHIFT_MUX_CTRL_REG	<= ID_EX_SHIFT_MUX_CTRL;
					EX_EX_CC_MUX_CTRL_REG		<= ID_EX_CC_MUX_CTRL;
					EX_EX_OPB_ALU_MUX_CTRL_REG	<= ID_EX_OPB_ALU_MUX_CTRL;
					EX_EX_PSR_CC_MUX_CTRL_REG	<= ID_EX_PSR_CC_MUX_CTRL;
					EX_EX_DAR_MUX_CTRL_REG		<= ID_EX_DAR_MUX_CTRL;
-- 					EX_EX_SHIFT_TYPE_REG		<= ID_EX_SHIFT_TYPE;
-- 					EX_EX_SHIFT_RRX_REG		<= ID_EX_SHIFT_RRX;
					EX_SHIFT_EX_CTRL(1)		<= EX_SHIFT_EX_CTRL(0);
					EX_EX_ALU_CTRL_REG		<= ID_EX_ALU_CTRL;
					CPA_EX_PASS_REG(1)		<= CPA_EX_PASS_REG(0);
					EX_FBRANCH_MUX_CTRL(1)		<= EX_FBRANCH_MUX_CTRL(0);
					EX_MEM_DATA_REG_EN_REG		<= ID_MEM_DATA_REG_EN; 
					EX_MEM_RES_REG_EN_REG		<= ID_MEM_RES_REG_EN; 
					EX_MEM_CC_REG_EN_REG		<= ID_MEM_CC_REG_EN; 
					EX_MEM_BASE_REG_EN_REG		<= ID_MEM_BASE_REG_EN;
					-- EX_MEM_DAR_EN_REG evtl. mit 0 setzen
					EX_MEM_DAR_EN_REG		<= ID_MEM_DAR_EN; 
					EX_MEM_DAR_INC_REG		<= ID_MEM_DAR_INC; 
				       	MEM_WMP_CTRL(1)			<= MEM_WMP_CTRL(0);	
					EX_MEM_DnRW_REG			<= ID_MEM_DnRW;
					EX_MEM_DEN_REG			<= ID_MEM_DEN;
					MEM_DMAS(1)			<= MEM_DMAS(0);
					MEM_TRUNCATE_ADDR(1)		<= MEM_TRUNCATE_ADDR(0);
					WB_REF_W_PORTS_ADDR(1)		<= WB_REF_W_PORTS_ADDR(0);
					EX_REF_W_PORT_A_EN_REG		<= ID_REF_W_PORT_A_EN;
					EX_REF_W_PORT_B_EN_REG		<= ID_REF_W_PORT_B_EN;
					EX_WB_LOAD_REG_EN_REG		<= ID_WB_LOAD_REG_EN;
					EX_WB_RES_REG_EN_REG		<= ID_WB_RES_REG_EN;
					EX_WB_CC_REG_EN_REG		<= ID_WB_CC_REG_EN;
					EX_WB_PSR_EN_REG		<= ID_WB_PSR_EN;
					WB_PSR_CTRL(1)			<= WB_PSR_CTRL(0);
					EX_WB_IAR_MUX_CTRL_REG		<= ID_WB_IAR_MUX_CTRL;
					EX_WB_IAR_LOAD_REG		<= ID_WB_IAR_LOAD;
					EX_OPA_PSR_MUX_CTRL(1)		<= EX_OPA_PSR_MUX_CTRL(0);
					EX_PSR_MUX_CTRL(1)		<= EX_PSR_MUX_CTRL(0);
				end if;
			end if; -- if CPA_nWAIT = '1'
			--end if;
			if CPA_RST = '1' then
--				Nach einem Reset befinden sich keine sinnvollen Werte in der Pipeline
--				Grundsaetzlich sollte NV im Bedingungsfeld aber alle
--				relevanten Steuersignale im naechsten Takt loeschen
				EX_CONDITION_FIELD_REG		<= NV;			
				EX_WB_PSR_EN_REG		<= '0';
				EX_WB_IAR_LOAD_REG		<= '0';
				INSTRUCTION_ID_REGISTER(1)	<= (others => '0');
				CPA_EX_PASS_REG(1)		<= '0';
			end if;	
		end if;
	end process SET_ID_EX_REGS;

--------------------------------------------------------------------------------
--	Steuersignale für die Executestufe
--------------------------------------------------------------------------------
--	Die Steuersignale in der EX-Stufe dürfen unabhängig von CDC_CONDITION_FIELD_REG
--	gesetzt werden, da sie ohne Ablegen der Ergebnisse in Pipelineregistern wirkungslos sind
	CPA_EX_OPX_MUX_CTRLS <= EX_OPX_MUX_CTRLS(1);--EX_EX_OPC_MUX_CTRL_REG & EX_EX_OPB_MUX_CTRL_REG & EX_EX_OPA_MUX_CTRL_REG;
	CPA_EX_SHIFT_MUX_CTRL <= EX_EX_SHIFT_MUX_CTRL_REG;
	CPA_EX_CC_MUX_CTRL <= EX_EX_CC_MUX_CTRL_REG;

	CPA_EX_OPB_ALU_MUX_CTRL		<= EX_EX_OPB_ALU_MUX_CTRL_REG;
	CPA_EX_PSR_CC_MUX_CTRL 		<= EX_EX_PSR_CC_MUX_CTRL_REG;
	CPA_EX_DAR_MUX_CTRL 		<=EX_EX_DAR_MUX_CTRL_REG;

	CPA_EX_SHIFT_TYPE		<= EX_SHIFT_EX_CTRL(1).SHIFT_EX_CTRL_TYPE;--EX_EX_SHIFT_TYPE_REG;
	CPA_EX_SHIFT_RRX		<= EX_SHIFT_EX_CTRL(1).SHIFT_EX_CTRL_RRX;--EX_EX_SHIFT_RRX_REG;
	CPA_EX_ALU_CTRL			<= EX_EX_ALU_CTRL_REG;
	CPA_EX_DRP_DMAS			<= MEM_DMAS(1);
	-- Der Instruktion in der EX-Stufe des Coprozessors signalisieren, dass sie 
	-- ausgefuehrt werden darf
	CPA_EX_PASS			<= CPA_EX_PASS_REG(1) and CDC_CONDITION_MET;

	CPA_EX_OPA_PSR_MUX_CTRL		<= EX_OPA_PSR_MUX_CTRL(1);
	CPA_EX_PSR_MUX_CTRL		<= EX_PSR_MUX_CTRL(1);

	ArmConditionCheck_Instance: ArmConditionCheck
	port map(
		CDC_CONDITION_FIELD 	=> EX_CONDITION_FIELD_REG,
		CDC_CONDITION_CODE 	=> CPA_EX_CPSR(31 downto 28),--CPA_EX_CC,
		CDC_CONDITION_MET 	=> CDC_CONDITION_MET
	);

	CPA_MEM_DATA_REG_EN	<= EX_MEM_DATA_REG_EN_REG;
	CPA_MEM_RES_REG_EN	<= EX_MEM_RES_REG_EN_REG;
	CPA_MEM_CC_REG_EN	<= EX_MEM_CC_REG_EN_REG;

	--Neu, steuert, ob eine Instruktion das Basisregister neu Beschreiben darf
	-- In der aktuellen Loesung kopiert eine Instruktion den Inhalt des Registers im Takt mit einem Data Abort
	-- nach WB_RES_REG, woraus er anschliessend in den Registerspeicher geschrieben wird, eine nachfolgende
	-- Instruktion darf den Inhalt von MEM_BASE_REG daher unbedingt aendern, obwohl sie natuerlich keine Wirkung
	-- auf den sichtbaren Prozessorzustand hat
	CPA_MEM_BASE_REG_EN	<= EX_MEM_BASE_REG_EN_REG;
--	CPA_MEM_BASE_REG_EN	<= '0' when CDC_CONDITION_MET = '0' or (CPA_MEM_DABORT = '1' and MEM_MEM_DEN = '1' and ENABLE_DATA_ABORT) else EX_MEM_BASE_REG_EN_REG;



	-- Neue durch CONDITION_MET beeinflusste Signale, die vorher im Prozess direkt gesetzt worden sind, ggf.
	-- sind die Signale auch vom DABORT-Register abhaengig weil ein Data Abort auf nachfolgende Instruktionen
	-- wirkt als ob diese nicht ausgefuehrt wuerde
	EX_REF_W_PORT_A_EN_REG_MET	<= EX_REF_W_PORT_A_EN_REG and CDC_CONDITION_MET and not ID_DABORT_REG;
	EX_REF_W_PORT_B_EN_REG_MET	<= EX_REF_W_PORT_B_EN_REG and CDC_CONDITION_MET and not ID_DABORT_REG; 
--	Es koennte sinnvoll sein, das DEN-Signal bereits hier mit MEM_DABORT_FILTERED zu maskieren, das fuehrt
--	zu keiner weiteren Verzoegerung (weil in der MEM-Stufe gleichzeitig aehnliches stattfindet) und so 
--	sicher verhindert wird, dass DEN auch nur kurz an ist, dafuer steht es freuher im naechsten Takt
--	zur Verfuegugn
	EX_MEM_DEN_REG_MET 		<= EX_MEM_DEN_REG and CDC_CONDITION_MET and (not (ID_DABORT_REG or MEM_DABORT_FILTERED));
-- Das Signal ist im Prinzip von DEN abhaengig und muss daher nicht nochmal extra gefiltert werden
	EX_MEM_DnRW_REG_MET		<= EX_MEM_DnRW_REG;-- and CDC_CONDITION_MET and not ID_DABORT_REG; 
--	EX_WB_USER_REGS_REG_MET		<= EX_WB_USER_REGS_REG and CDC_CONDITION_MET and not ID_DABORT_REG;	       
	EX_WB_LOAD_REG_EN_REG_MET	<= EX_WB_LOAD_REG_EN_REG and CDC_CONDITION_MET and not ID_DABORT_REG;
	-- Veraendern den sichtbaren Prozessorzustand nicht und muessen daher nicht maskiert werden
	EX_WB_RES_REG_EN_REG_MET	<= EX_WB_RES_REG_EN_REG; --and CDC_CONDITION_MET and not ID_DABORT_REG;
	EX_WB_CC_REG_EN_REG_MET		<= EX_WB_CC_REG_EN_REG; --and CDC_CONDITION_MET and not ID_DABORT_REG;
	EX_WB_PSR_EN_REG_MET		<= EX_WB_PSR_EN_REG and CDC_CONDITION_MET and not ID_DABORT_REG;
	-- Wenn Fast Branch verwendet wird, darf das Load-Signal eines Sprungs nicht die WB-Stufe nicht erreichen, weil es bereits in der EX-Stufe wirkt
	EX_WB_IAR_LOAD_REG_MET		<= '1' when EX_WB_IAR_LOAD_REG = '1' and CDC_CONDITION_MET='1' and ID_DABORT_REG = '0' and (EX_FBRANCH_MUX_CTRL(1) = '0' or (not USE_FAST_BRANCH)) else '0';

	CPA_EX_DAR_EN		<= EX_MEM_DAR_EN_REG; 
	CPA_EX_DAR_INC		<= EX_MEM_DAR_INC_REG;

	-- Registerschreiben
	SET_EX_MEM_REGS : process(CPA_CLK)IS
	begin
		if CPA_CLK'event AND CPA_CLK = '1' then
-- 			if CPA_RST = '1' then
-- 				MEM_REF_W_PORT_A_EN_REG <= '0';
-- 				MEM_REF_W_PORT_B_EN_REG <= '0';
-- 				MEM_MEM_DEN_REG <= '0';
-- --				MEM_WB_USER_REGS_REG	<= '0'; 
-- 				MEM_WB_LOAD_REG_EN_REG	<= '0';
-- 				MEM_WB_PSR_EN_REG	<= '0';
-- 				MEM_WB_IAR_LOAD_REG	<= '0';
-- 			else
				INSTRUCTION_ID_REGISTER(2) <= INSTRUCTION_ID_REGISTER(2); 

				if CPA_WAIT = '0' then
					INSTRUCTION_ID_REGISTER(2)<= INSTRUCTION_ID_REGISTER(1); 
					WB_REF_W_PORTS_ADDR(2)	<= WB_REF_W_PORTS_ADDR(1);
					MEM_DMAS(2)		<= MEM_DMAS(1);
					MEM_REF_W_PORT_A_EN_REG <= EX_REF_W_PORT_A_EN_REG_MET;
					MEM_REF_W_PORT_B_EN_REG <= EX_REF_W_PORT_B_EN_REG_MET;
					MEM_MEM_DEN_REG 	<= EX_MEM_DEN_REG_MET;
					MEM_MEM_DnRW_REG 	<= EX_MEM_DnRW_REG_MET;
				       	MEM_WMP_CTRL(2)		<= MEM_WMP_CTRL(1);	
					MEM_CC_MUX_CTRL_REG(2)	<= MEM_CC_MUX_CTRL_REG(1);	
					MEM_TRUNCATE_ADDR(2)	<= MEM_TRUNCATE_ADDR(1);
					MEM_WB_LOAD_REG_EN_REG	<= EX_WB_LOAD_REG_EN_REG_MET;
					MEM_WB_RES_REG_EN_REG	<= EX_WB_RES_REG_EN_REG_MET;
					MEM_WB_CC_REG_EN_REG	<= EX_WB_CC_REG_EN_REG_MET;	
					MEM_WB_PSR_EN_REG	<= EX_WB_PSR_EN_REG_MET;
					MEM_WB_IAR_LOAD_REG	<= EX_WB_IAR_LOAD_REG_MET;
					WB_PSR_CTRL(2)		<= WB_PSR_CTRL(1);
					MEM_WB_IAR_MUX_CTRL_REG	<= EX_WB_IAR_MUX_CTRL_REG;
				end if;
-- 			end if;
			if CPA_RST = '1' then
				MEM_REF_W_PORT_A_EN_REG <= '0';
				MEM_REF_W_PORT_B_EN_REG <= '0';
				MEM_MEM_DEN_REG		<= '0';
				MEM_WB_LOAD_REG_EN_REG	<= '0';
				MEM_WB_PSR_EN_REG	<= '0';
				MEM_WB_IAR_LOAD_REG	<= '0';
			end if;	

		end if;
	end process SET_EX_MEM_REGS;


--------------------------------------------------------------------------------
--	Steuersignale für die Memorystufe (Wirksam in der Memorystufe)
--	10.09.09: Ergaenzung: MEM_DnRW_REG verundet mit MEM_DEN_REG, da sonst schreibzugriffe
--	bei nicht ausgefuehrten Speicherzugriffen autreten koennen. Alternativ kann auch 
--	das DnRW-Signal beim Speichern in das EX/MEM-Register auf 0 gesetzt werden
--	06.10.09: MEM_DEN und MEM_DnRW werden zusaetzlich durch ID_DABORT_REG maskiert,
--	da auf einen ABORT kein weiterer Speicherzugriff folgen darf, der Abort
--	aber erst behandelt wird wenn die verursachende Instruktion in der WB-Stufe ist

--	Hier noch zu ergaenzen:	die Steuersignale zur WB-Stufe muessen geloescht werden
--	wenn ein Abort aufgetreten ist
--------------------------------------------------------------------------------
-- 	Im Prinzip ist diese Maskierung ueberfluessig da nur mit DEN wirklich auf Speicher zugegriffen wird (wird das aber im Speichersubsystem nicht kontrolliert
--	verhindert das Maskieren von DnRW versehentliche Schreibzugriffe)
	CPA_MEM_DnRW	<= MEM_MEM_DnRW_REG and MEM_MEM_DEN_REG and (not ID_DABORT_REG);-- when CPA_MEM_DBE = '1' else 'Z';
--	ID_DABORT_REG darf hier nur weggelassen werden wenn bereits in der EX-Stufe mit MEM_DABORT_FILTERED maskiert wurde
	MEM_MEM_DEN	<= MEM_MEM_DEN_REG;-- and (not ID_DABORT_REG);
	CPA_MEM_DEN	<= MEM_MEM_DEN;
	CPA_MEM_DMAS	<= MEM_DMAS(2);--MEM_MEM_DMAS_REG;-- when CPA_MEM_DBE = '1' else "ZZ";

--	Das angehaengte DABORT_FILTERED soll verhindern dass im extremfall Metawerte aus dem Speichersubsystem (in dem eine falsche 
--	Adresse angesprochen wurde und evtl. kein Treiber aktiv ist) in den Prozessorkern gelangen
	-- Neu: DEN wird nicht mehr abgefragt
	CPA_WB_LOAD_REG_EN 	<= MEM_WB_LOAD_REG_EN_REG and (not ID_DABORT_REG) and (not MEM_DABORT_FILTERED) and CPA_MEM_DBE;

	-- wenn beim Speicherzugriff ein Abort auftritt, wird der in einem Schattenregister
	-- stehende Basisregisterinhalt nach WB_RES_REG kopiert und im naechsten Takt 
	-- in den Registerspeicher geschrieben
	CPA_WB_RES_REG_EN	<= MEM_WB_RES_REG_EN_REG or MEM_DABORT_FILTERED;
	-- schaltet bei Aborts unmittelbar das Schattenregister auf WB_RES_REG durch
	CPA_MEM_BASE_MUX_CTRL	<= MEM_DABORT_FILTERED;

	CPA_WB_CC_REG_EN 	<= MEM_WB_CC_REG_EN_REG;
	 
-- 	CPA_MEM_WMP_BYTE	<= MEM_DMAS(2)(1) nor MEM_DMAS(2)(0);--MEM_WMP_CTRL(2).WMP_BYTE;
-- 	CPA_MEM_WMP_HW		<= (not MEM_DMAS(2)(1)) and MEM_DMAS(2)(0);--MEM_WMP_CTRL(2).WMP_HW;
	CPA_MEM_WMP_SIGNED	<= MEM_WMP_CTRL(2);

	CPA_MEM_CC_MUX_CTRL	<= MEM_CC_MUX_CTRL_REG(2);	
--	Hinweise fuer eine zukuenftige Korrektur:
--	Der Datenpfad treibt die Datenleitungen des Datenausgang, sobald der Prozessor einen
--	Speicherzugriff durchfuehrt (DEN und DBE = 1). Bei Lesezugriffen ist es nicht sinnvoll,
--	das so zu handhaben

	-- Bestimmte Load/Store-Instruktionen koennen mit der Speichersicht des 
-- 	User-Modus arbeiten. PSR_CTRL.MODE wird hier zweckentfremdet, eine Instruktion
-- 	schreibt USER da rein, gleichzeitig wird PSR_EN aber nicht gesetzt. Damit wird
-- 	weder das CPSR manipuliert noch der Modusbypass geschaltet. 
-- 	Ueblicherweise erhaelt PSR_CTRL(0) in der Decode-Stufe den aktuellen
--  	Betriebsmodus aus dem CPSR, so dass CPA_MEM_DMODE zuverlaessig den Modus
-- 	anzeigt der gueltig war als die Load/Store-Instruktion die Decodestufe
-- 	passiert hat.
-- 	Hinweis: 
 	CPA_MEM_DMODE	<= WB_PSR_CTRL(2).MODE;

--	Abortsignal wird nur entgegengenommen, wenn im gleichen Takt ein Speicherzugriff stattfindet, erkennbar am MEM_DEN-Signal
--	In dieser Variante muss garantiert sein, dass auf das Abortsignal unmittelbar reagiert wird (in der Steuerung gegenueber allen anderen
--	Bedingungen ausser Reset priorisiert), denn sonst geht das Abortsignal sofort wieder verloren. Ausserdem muessen alle Steuersignale hinter
--	dem Speicherzugriff unmittelbar geloescht werden	
-- 	MEM_DBE wird hier auch geprueft. Wirklicher Multimasterbetrieb am Datenbus ist nicht vorgesehen, so dass das
-- 	nicht unbedingt notwendig ist. Ein schneller Weg zum Multimasterbetrieb wuerde darin bestehen,
-- 	das WAIT-Signal des Kerns zu setzten, wenn (DEN and not DBE) = '1', also der Bus belegt ist. Das muss
-- 	dann aber in ARM_CORE realisiert werden und nicht im Kontrollpfad.
	MEM_DABORT_FILTERED <= '1' when MEM_MEM_DEN='1' and CPA_MEM_DABORT='1' and ENABLE_DATA_ABORT and CPA_MEM_DBE = '1' else '0';

	CPA_MEM_TRUNCATE_ADDR	<= MEM_TRUNCATE_ADDR(2);

	-- Registerschreiben
	SET_MEM_WB_REGS : process(CPA_CLK)IS
	begin
		if CPA_CLK'event and CPA_CLK = '1' then
			if CPA_RST = '1' then
				ID_DABORT_REG <= '0';
				WB_REF_W_PORT_A_EN_REG	<= '0';
				WB_REF_W_PORT_B_EN_REG	<= '0';
--				WB_WB_USER_REGS_REG	<= '0';
				WB_WB_PSR_EN_REG	<= '0';
				WB_WB_IAR_LOAD_REG	<= '0';
			else
				INSTRUCTION_ID_REGISTER(3) <= INSTRUCTION_ID_REGISTER(3); 
				if CPA_WAIT = '0' then					
					INSTRUCTION_ID_REGISTER(3) <= INSTRUCTION_ID_REGISTER(2);
				-- Uebergangsloesung um DABORTS schnell loeschen zu koennen
						
					ID_DABORT_REG	<= MEM_DABORT_FILTERED;
					WB_REF_W_PORTS_ADDR(3)	<= WB_REF_W_PORTS_ADDR(2);
--					einige der Signale muessen noch mit dem DABORT gefiltert werden, da dies
--					nicht geschehen ist, waehrend sie in der EX-Stufe waren 
--					(nur die Signale, die sich jetzt gleichzeitig in der EX-Stufe befinden
--					werden mit ID_DABORT_REG maskiert)
					WB_REF_W_PORT_A_EN_REG <= MEM_REF_W_PORT_A_EN_REG and (not ID_DABORT_REG);
					WB_REF_W_PORT_B_EN_REG <= MEM_REF_W_PORT_B_EN_REG and (not ID_DABORT_REG);

--					WB_WB_USER_REGS_REG	<= MEM_WB_USER_REGS_REG and (not ID_DABORT_REG);
					WB_WB_PSR_EN_REG	<= MEM_WB_PSR_EN_REG and (not ID_DABORT_REG);
					WB_PSR_CTRL(3)		<= WB_PSR_CTRL(2);
					WB_WB_IAR_MUX_CTRL_REG	<= MEM_WB_IAR_MUX_CTRL_REG;
					WB_WB_IAR_LOAD_REG	<= MEM_WB_IAR_LOAD_REG and (not ID_DABORT_REG);
				end if;
			end if;
		end if;
	end process SET_MEM_WB_REGS;
--------------------------------------------------------------------------------
--	Steuersignale für die Writebackstufe
--	Ergaenzung: alle Enablesignale sind zusaetzlich
--	durch das im letzten Takt eingetretene Abortsignal maskiert weil
--	der Zugriff auf Prozessorregister nicht durchgefuehrt werden darf
--	In der WB-Stufe wurde ein ID-Register hinzugefuegt, dass 
--	jeweils die ID der letzten Instruktion aufnimmt, die ein DABORT
--	verursacht hat
--------------------------------------------------------------------------------
--	wenn ein Data Abort eingetreten ist wird im naechsten Takt automatisch das Basisregister rekonstruiert, dazu
--	wird die A-Adresse aus dem CPA_BASE_ADDR_BUFFER rekonstruiert und das A_EN-Signal aktiviert
	CPA_WB_REF_W_PORTS_ADDR(4 downto 0)	<= WB_REF_W_PORTS_ADDR(3)(4 downto 0) when ID_DABORT_REG = '0' else WB_ARB_DATA_OUT;
	CPA_WB_REF_W_PORTS_ADDR(9 downto 5)	<= WB_REF_W_PORTS_ADDR(3)(9 downto 5);
	CPA_WB_REF_W_PORT_A_EN			<= WB_REF_W_PORT_A_EN_REG or ID_DABORT_REG; --Damit automatisch ein Schreibzugriff stattfindet bei Data Abort
	CPA_WB_REF_W_PORT_B_EN			<= WB_REF_W_PORT_B_EN_REG and not ID_DABORT_REG;
--	Neu: ID_DABORT_REG geht auch an Coprocessoren um eine evtl. laufende Instruktion abzubrechen
	CPA_MEM_PASS			<= not ID_DABORT_REG;

	CPA_WB_PSR_EN			<= WB_WB_PSR_EN_REG and not ID_DABORT_REG;
	CPA_WB_PSR_CTRL			<= WB_PSR_CTRL(3);
	CPA_WB_IAR_MUX_CTRL		<= WB_WB_IAR_MUX_CTRL_REG;
	
--	Das Load-Signal der WB-Stufe kann auch durch vorgezogene Spruenge aus der EX-Stufe gesetzt werden, der Test auf 
--	ID_DABORT_REG ist vermultich ueberfluessig, schadet aber auch nicht wirklich
--	Das Steuersignal fuer den zusaetzlichen Quellenmultiplexer schneller Spruenge wirkt hier auch auf das Ladesignal
	CPA_WB_IAR_LOAD			<= '1' when (WB_WB_IAR_LOAD_REG='1' or (EX_FBRANCH_MUX_CTRL(1)='1' and USE_FAST_BRANCH and CDC_CONDITION_MET = '1'))  and ID_DABORT_REG = '0' else '0';
	-- Fast Branch wirkt auf die WB-Stufe, das Steuersignal kommt jedoch aus der EX-Stufe
	CPA_WB_FBRANCH_MUX_CTRL		<= EX_FBRANCH_MUX_CTRL(1) and CDC_CONDITION_MET when USE_FAST_BRANCH else '0';
--------------------------------------------------------------------------------
--	neu:
--	Das letzte ID-Register nimmt im Fall eines Data-Abort die ID der verursachenden Instruktion auf und haelt sonst
--	den bisherigen Inhalt. Das Register liegt eigentlich ganz hinten in der Pipeline, kann funktional aber der ID-Stufe
--	zugeschrieben werden 
	WB_INST_ID_ABORT_MUX_CTRL	<= ID_DABORT_REG;
	WB_INST_ID_ABORT_MUX		<= INSTRUCTION_ID_REGISTER(3) when WB_INST_ID_ABORT_MUX_CTRL = '1' else INSTRUCTION_ID_REGISTER(4);
--------------------------------------------------------------------------------

	process(CPA_CLK)is
	begin
		if CPA_CLK'event and CPA_CLK = '1' then
			if CPA_RST = '1' then
				INSTRUCTION_ID_REGISTER(4) <= (others => '0');
			else
				if CPA_WAIT = '0' then
					INSTRUCTION_ID_REGISTER(4) <= WB_INST_ID_ABORT_MUX; 
				else
					INSTRUCTION_ID_REGISTER(4) <= INSTRUCTION_ID_REGISTER(4);
				end if;
			end if;
		end if;
	end process;
--	Process zum Testen der Zahlreichen Ausnahme für nicht erlaubt 
--	oder spezifizierte Angaben in Instruktionen, muss noch ergaenzt werden
	CHECK_INSTRUCTION_CONSTRAINTS : process(CID_DECODED_VECTOR)IS
	begin
		null;
	end process CHECK_INSTRUCTION_CONSTRAINTS;
--------------------------------------------------------------------------------
--	Hauptsteuerung in Form einer Statemachine 
--	Zwei-Prozess-Variante, Synchronisation und Zustandsübergang in einem
--	sequentiellen Prozess, Erzeugung der "Ausgangs-" (d.h. Steuer-) Signale 
--	und des Folgezustands in einem kombinatorischen Prozess. 
--	Achtung: alle Signale, die nicht unmittelbar
--	auf die Decodestufe wirken sollen, müssen zusätzlich registriert werden.
--	Ergaenzung: Uebernahme eines neuen Zustands beruecksichtigt CPA_nWAIT,
--	diese Loesung ist aber suboptimal da Beispielsweise Wartezustaende
--	nicht mehr heruntergezaehlt werden, obwohl der Prozessorkern wartet	
--------------------------------------------------------------------------------
	ARM_MAIN_CTRL_FSM	: process(CPA_CLK)IS
	begin
		if CPA_CLK'event AND CPA_CLK = '1' then
			if CPA_RST = '1' then
				ARM_STATE <= STATE_FETCH; --statt reset
			else
				if CPA_WAIT = '0' then
					ARM_STATE <= ARM_NEXT_STATE;
				end if;	
			end if;	
		end if;	
	end process ARM_MAIN_CTRL_FSM;

	SET_MAIN_DELAY_REG : process(CPA_CLK)is
	begin
		if CPA_CLK'event AND CPA_CLK = '1' then
			if CPA_RST = '1' then
				MAIN_DELAY_REG <= 0;
				ID_OLD_INSTRUCTION_REG <= (others => '0');
			else
				MAIN_DELAY_REG 		<= MAIN_DELAY_REG;
				ID_OLD_INSTRUCTION_REG	<= ID_OLD_INSTRUCTION_REG;

				if CPA_WAIT = '0' then
					MAIN_DELAY_REG <= MAIN_DELAY;
					if ID_HOLD_OLD_INSTRUCTION_REG = '0' then
						ID_OLD_INSTRUCTION_REG <= ID_INSTRUCTION_REG;
					else
						ID_OLD_INSTRUCTION_REG <= ID_OLD_INSTRUCTION_REG;
					end if;	
				end if;
			end if;	
		end if;
	end process SET_MAIN_DELAY_REG;

	-- Das nWAIT-Signal spielt hier keine Rolle, da (fast) alle Register direkt angehalten werden, die Steuerung in mehreren 
	-- Takten hintereinander also das gleiche tut. Effizienter aber ungleich komplizierter waere es, geeignete Reaktionen auf
	-- Wartesignale unmittelbar in die Steuerung einzubauen
	ARM_MAIN_CTRL_SIGNALS : process(
		ARM_STATE,		-- aktueller Zustand
		MAIN_DELAY_REG,		-- aktueller Wert eines Wartezyklus
		CID_DECODED_VECTOR,	-- ermittelte Instruktionsgruppe
		ID_INSTRUCTION_REG,	-- aktueller Instruktionsvektor
		ID_OLD_INSTRUCTION_REG,	-- Vektor der letzten geholten Instru.
		EX_CONDITION_FIELD_REG,	-- Bedingungsfeld der Instruktion in
					-- der EX-Stufe um diese erhalten
 					-- zu koennen.

-- 	Angabe, ob die Instruktion, ob die Instruktion in der EX-Stufe
-- 	ihre Bedingung erfuellt hat (davon haengt der naechste Zustand
-- 	einer Mehrzykleninstruktion ab.
		CDC_CONDITION_MET,	
-- 	Angabe, ob die Instruktionen in der ID- und EX-Stufe in einem
-- 	Load/Use-Konflikt stehen	
		ID_LOAD_USE_CONFLICT,
-- 	Naechste Registeradresse und noch in der Registerliste gesetzte Bits
-- 	der LDM/STM-Instruktionen	
				
		RBA_NR_OF_REGS,
		ID_LNA_ADDRESS,
		SRC_SHIFT_CTRL, 
		IRQ_FIQ_IABORT,		
		ID_FILTERED_EXCEPTIONS,
		ID_MODE_MUX,
		IF_INSTRUCTION_ID_REGISTER_INC, 
		INSTRUCTION_ID_REGISTER,
		ID_DABORT_REG,
		ID_COP_INSTRUCTION_TYPE,
		CPA_ID_CHS,
		EX_FBRANCH_MUX_CTRL(1),
		AIC_ID_REGS_USED,

--------------------------------------------------------------------------------
-- 	Signale eines Moduls, dass die Steuerung von arithmetisch-logische
--	Instruktionen realisiert. Das Herausnehmen dieses Teils ist fuer
--	eine Lehrveranstaltunge geschehen, so dass fuer einen einzigen
-- 	Instruktionstyp und ohne Kenntniss der uebrigen Steuerung das korrekte
-- 	Setzen einiger Steuersignale geuebt werden kann.
--------------------------------------------------------------------------------
	AIC_IF_IAR_INC, AIC_ID_R_PORT_A_ADDR, AIC_ID_R_PORT_B_ADDR,
	AIC_ID_R_PORT_C_ADDR , AIC_ID_IMMEDIATE, AIC_ID_OPB_MUX_CTRL,
	AIC_EX_ALU_CTRL, AIC_MEM_RES_REG_EN, AIC_MEM_CC_REG_EN ,
	AIC_WB_CC_REG_EN, AIC_WB_W_PORT_A_ADDR, AIC_WB_W_PORT_A_EN,
	AIC_WB_RES_REG_EN, AIC_WB_IAR_LOAD, AIC_WB_PSR_EN,
	AIC_WB_PSR_ER, AIC_WB_PSR_SET_CC, AIC_WB_IAR_MUX_CTRL,
	AIC_DELAY, AIC_ARM_NEXT_STATE,
	MAIN_DELAY --Kais Edit: Was missing in List				
	)is
--		VARIABLE MAIN_DELAY : natural := 0;
--		Nützliche Abkürzungen für einige Bits des Befehlsvektors				
		alias P : std_logic is ID_INSTRUCTION_REG(24);
		alias U : std_logic is ID_INSTRUCTION_REG(23);
--		B und R sind Alias für das selbe Bit
		alias B : std_logic is ID_INSTRUCTION_REG(22);
		alias R : std_logic is ID_INSTRUCTION_REG(22);
		alias W : std_logic is ID_INSTRUCTION_REG(21);
		alias W_OLD : std_logic is ID_OLD_INSTRUCTION_REG(21);
		alias S_LDM_OLD : std_logic is ID_OLD_INSTRUCTION_REG(22);
		alias L : std_logic is ID_INSTRUCTION_REG(20);
		alias L_OLD : std_logic is ID_OLD_INSTRUCTION_REG(20);
		alias LINK_BIT : std_logic is ID_INSTRUCTION_REG(24);
		alias S : std_logic is ID_INSTRUCTION_REG(20);
		alias SH : std_logic_vector(1 downto 0) is ID_INSTRUCTION_REG(6 downto 5);
		
		variable V_LOCAL_UNDEFINED : std_logic := '0';
		variable V_ID_IMMEDIATE : std_logic_vector(31 downto 0);
		variable V_ID_CONDITION : std_logic_vector(3 downto 0);
		variable V_ID_LNA_LOAD_REGLIST : std_logic;
		variable V_ID_LNA_HOLD_VALUE : std_logic;
		variable V_ID_HOLD_OLD_INSTRUCTION_REG : std_logic := '0';
		variable V_ID_MASK_FIQ, V_ID_MASK_IRQ : std_logic := '0';
		variable V_IF_LDMSTM_MUX_CTRL : std_logic := '0';
		variable V_DPA_ENABLE : std_logic;
		variable V_RPA_ADDR, V_RPB_ADDR, V_RPC_ADDR : std_logic_vector(3 downto 0);
		variable V_ID_USER_REGS	: std_logic_vector(2 downto 0); --C,B,A

		variable V_ID_IAR_REVOKE	: std_logic;
		variable V_ID_IAR_HISTORY_ID	: std_logic_vector(INSTRUCTION_ID_WIDTH -1 downto 0);
		variable V_ID_INST_ID_PASS_MUX_CTRL : std_logic := '0';

		variable V_WPA_ADDR, V_WPB_ADDR : std_logic_vector(3 downto 0);
		variable V_IEN : std_logic;
		variable V_FETCH_INST	: std_logic;
		variable V_WPA_EN, V_WPB_EN : std_logic;
       	variable V_IAR_INC : std_logic;
		variable V_EX_PSR_MUX_CTRL : std_logic;
		variable V_OPA_MCTRL, V_OPB_MCTRL, V_OPC_MCTRL, V_CC_MCTRL : std_logic_vector(1 downto 0);
		variable V_OPB_ALU_MCTRL, V_PSR_CC_MCTRL, V_DAR_MCTRL: std_logic; 
		variable V_SHIFT_CTRL	: SHIFT_CTRL_TYPE := ("000000",SH_LSL,'0','0');
		variable V_ALU_CTRL	: std_logic_vector(3 downto 0); --OPCODE_DATA
		variable V_MEM_DATA_REG_EN, V_MEM_RES_REG_EN, 
			 V_MEM_CC_REG_EN, V_MEM_DAR_EN, 
			 V_MEM_DAR_INC, 
			 V_MEM_WMP_SIGNED	: std_logic;
		variable V_MEM_BASE_REG_EN : std_logic;

		variable V_MEM_DnRW, V_MEM_DEN : std_logic;
		variable V_MEM_DMAS : std_logic_vector(1 downto 0);
		variable V_ID_OPB_MUX_CTRL, 
			V_EX_OPA_PSR_MUX_CTRL : std_logic;
		variable V_EX_BRANCH_MCTRL	: std_logic := '0';

		variable	V_WB_USER_REGS : std_logic_vector(1 downto 0); --B,A
		variable 	V_WB_LOAD_REG_EN, 
				V_WB_RES_REG_EN, 
				V_WB_CC_REG_EN : std_logic;
		variable	V_WB_PSR_EN, 
				V_WB_PSR_EE, 
				V_WB_PSR_ER, 
				V_WB_PSR_WRITE_SPSR,
				V_WB_PSR_SET_CC : std_logic;
		variable	V_WB_PSR_MASK	: std_logic_vector(3 downto 0);
		variable	V_WB_PSR_MODE	: MODE;
		variable	V_WB_IAR_MUX_CTRL : std_logic;
		variable	V_WB_IAR_LOAD : std_logic;

		variable	V_BRANCH_SIGN_BYTE : std_logic_vector(5 downto 0);
		variable 	V_EX_PASS_REG : std_logic:= '0';
		variable	V_MEM_CC_MUX_CTRL_REG : std_logic;
		variable 	V_WB_ADDR_MODE : MODE := USER;
		variable	V_IGNORE_LU_CONFLICT : boolean := false;
		variable	V_ADDR_USED : ARR3_OF_BOOLEAN := (false,false,false); --C,B,A
		variable	V_TRUNCATE_ADDR : std_logic;
-- synthesis translate_off
				
-- synthesis translate_on		
	begin
-- 		Kennzeichnung, welche Registerspeicher-Leseports (C,B,A) in
-- 		der Instruktion tatsaechlich verwendet werden. Die Korrekte
-- 		Kennzeichnung ist nur in Zustaenden notwendig, in denen 
-- 		ein konfliktbedingter Pipelinestall auftreten kann.
		V_ADDR_USED := (true,true,true);
--		ARM_RETURN_STATE <= STATE_RESET;
		--ARM_NEXT_STATE <= STATE_DECODE;
		
--		Veraenderung durch Fast Branch: nur noch 6 Bit ergaenen und den Direktoperanden um zwei
--		abschliessende Nullen ergaenzen
		V_BRANCH_SIGN_BYTE := 	ID_INSTRUCTION_REG(23) & ID_INSTRUCTION_REG(23) & ID_INSTRUCTION_REG(23) & 
					ID_INSTRUCTION_REG(23) & ID_INSTRUCTION_REG(23) & ID_INSTRUCTION_REG(23);-- & 
--					ID_INSTRUCTION_REG(23) & ID_INSTRUCTION_REG(23);

--		V_LOCAL_UNDEFINED := '0';
		-- Defaultwert fuer die den Modus der WB-Rueckschreibadresse ist
-- 		der aktuell am Moduseingang anliegende Wert. Im Takt nach dem Absetzen 
-- 		von Steuersignalen, die den Modus aendern (Eintritt in eine Exception)
-- 		wird wenigstens einmal ein abweichender Wert verwendet.
		V_WB_ADDR_MODE	:= ID_MODE_MUX;
-- 		V_WB_ADDR_MODE	:= EX_NEW_MODE(1);
-- 		Steuersignal, dass den neuen WB-Modus fuer wenigstens
-- 		den naechsten Takt festlegt, im Defaultfall
-- 		bleibt der Wert in EX_NEW_MODE erhalten
-- 		V_WB_ADDR_NEXT_MODE	:= EX_NEW_MODE(1);
		V_EX_PASS_REG := '0';
		
					
		V_IF_LDMSTM_MUX_CTRL := '0';
		V_ID_IMMEDIATE	:= (others => '0');
		V_ID_CONDITION	:= EX_CONDITION_FIELD_REG; --Der Wert wird für Mehrzyklenbefehle gehalten
		V_ID_LNA_LOAD_REGLIST := '1'; --Die Registerliste für LDM/STM wird immer vorauseilend aktualisiert
		V_ID_LNA_HOLD_VALUE := '1';
		V_ID_HOLD_OLD_INSTRUCTION_REG := '0';
		V_ID_MASK_FIQ := '0';
		V_ID_MASK_IRQ := '0';

		V_ID_IAR_REVOKE	:= '0';
--		Im Normalbetrieb entspricht die zu speichernde ID der ID, die der
--		Instruktion im Kontrollpfad zugewiesen wird. Nur im Fall von
--		IAR_REVOKE wird als ID die ID des ABORT-Verursachenden Befehls uebermittelt
		V_ID_IAR_HISTORY_ID := IF_INSTRUCTION_ID_REGISTER_INC;	--IF_INST_ID_SRC_MUX;
		V_ID_INST_ID_PASS_MUX_CTRL := '0';

		V_DPA_ENABLE	:= '1';
		V_RPA_ADDR 	:= ID_INSTRUCTION_REG(19 downto 16);
		V_RPB_ADDR 	:= ID_INSTRUCTION_REG( 3 downto  0);
		V_RPC_ADDR 	:= ID_INSTRUCTION_REG(11 downto  8);
		V_ID_USER_REGS 	:= "000";
		V_FETCH_INST 	:= '0';
		V_IEN		:= '0';
		V_WPA_ADDR 	:= ID_INSTRUCTION_REG(15 downto 12);--"0000"; 
		V_WPB_ADDR 	:= ID_INSTRUCTION_REG(15 downto 12);--"0000"; 
		V_WPA_EN 	:= '0';
		V_WPB_EN 	:= '0';
		V_IAR_INC 	:= '0';
		V_EX_PSR_MUX_CTRL 	:= '0';
		V_MEM_DnRW 	:= '0'; 
		V_MEM_DEN 	:= '0'; 
		V_MEM_DMAS 	:= DMAS_WORD;
-- 		Umschalten zwischen Registeroperand oder PSR-Inhalt
		V_EX_OPA_PSR_MUX_CTRL := '0'; 
		V_ID_OPB_MUX_CTRL := '0';
		V_OPA_MCTRL 	:= "00"; 
		V_OPB_MCTRL 	:= "00"; 
		V_OPC_MCTRL	:= "00";
		V_CC_MCTRL 	:= "00";
		V_OPB_ALU_MCTRL := '0'; 
		V_PSR_CC_MCTRL 	:= '0';
		V_DAR_MCTRL 	:= '0';
		V_ALU_CTRL	:= OP_MOV;
 		V_SHIFT_CTRL	:= ("000000",SH_LSL,'0','0');
		V_EX_BRANCH_MCTRL	:= '0';

		V_MEM_DATA_REG_EN 	:= '0'; 
		V_MEM_RES_REG_EN 	:= '0'; 
		V_MEM_CC_REG_EN 	:= '0'; 
		V_MEM_BASE_REG_EN	:= '0';
		V_MEM_DAR_EN 		:= '0';
		V_MEM_DAR_INC 		:= '0'; 
		V_MEM_WMP_SIGNED 	:= '0';
		V_MEM_CC_MUX_CTRL_REG	:= '0';
		V_WB_USER_REGS		:= "00";
		V_WB_LOAD_REG_EN 	:= '0';
		V_WB_RES_REG_EN 	:= '0';
		V_WB_CC_REG_EN 		:= '0';
		V_WB_PSR_EN 		:= '0';
		V_WB_PSR_ER 		:= '0';
		V_WB_PSR_EE 		:= '0';
		V_WB_PSR_WRITE_SPSR	:= '0';
		V_WB_PSR_SET_CC		:= '0';
		V_WB_PSR_MASK		:= "0000";
		V_WB_PSR_MODE		:= ID_MODE_MUX;--CPA_ID_MODE;
		V_WB_IAR_MUX_CTRL	:= '0';
		V_WB_IAR_LOAD		:= '0';
		MAIN_DELAY		<= MAIN_DELAY_REG;
-- 		ID_STOPP_DECODE <= '0';
		V_IGNORE_LU_CONFLICT := true;
		ARM_NEXT_STATE <= STATE_DECODE;
		V_TRUNCATE_ADDR		:= '0';

--------------------------------------------------------------------------------
--		Sammlung aller durch den Gruppendecoder noch nicht abgefangender Fälle, in denen 
--		ein Instruktionsvektor als undefined behandelt werden muss.
--		Derzeit betroffen: Multiplikationen die weder MUL noch MLA sind
--		sowie Signed Immediate/ Signed Register Storeinstruktionenen mit gesetztem S-Bit.
--------------------------------------------------------------------------------

		if ARM_STATE = STATE_DECODE then
			if CID_DECODED_VECTOR = CD_MULTIPLY then
				if ID_INSTRUCTION_REG(23 downto 21) = OP_MUL or ID_INSTRUCTION_REG(23 downto 21) = OP_MLA then
					V_LOCAL_UNDEFINED := '0';
				else	
					V_LOCAL_UNDEFINED := '1';
				end if;	
			elsif (CID_DECODED_VECTOR = CD_LOAD_STORE_SIGNED_IMMEDIATE) or (CID_DECODED_VECTOR = CD_LOAD_STORE_SIGNED_REGISTER) then
				if L = '0' and ID_INSTRUCTION_REG(6) = '1' then				
					V_LOCAL_UNDEFINED := '1';
				else
					V_LOCAL_UNDEFINED := '0';
				end if;
			else
				V_LOCAL_UNDEFINED := '0';
			end if;
		else
			V_LOCAL_UNDEFINED := '0';
		end if;
--		Das Data Abort ist allen anderen Zustaenden gegenueber priorisiert, ein Reset
--		wirkt natuerlich noch staerker direkt ueber die RST-Eingaenge der Register.
--		STATE_RESET kann zwar technisch im prinzip nicht gleichzeitig mit einem
--		Data Abort eintreten, es schadet aber auch nicht, dass so zu realisieren
-- 		Der Data Abort darf dann nicht sofort bedient werden, wenn der Automat gerade in der zweiten Stufe der Interruptbearbeitung
-- 		ist, mehr noch: zuerst muss noch der PC korrekt auf die Interruptbehandlungsroutine zeigen, erst dann
-- 		darf der Data Abort behandelt werden
		if ID_DABORT_REG = '1' and ENABLE_DATA_ABORT then
			V_IGNORE_LU_CONFLICT := true;
			ARM_NEXT_STATE <= STATE_DABORT;
			-- Die folgende Instruktion wird keinesfalls ausgefuehrt und der Eintrag
			-- im History Buffer soll nicht ueberschrieben werden, daher auch kein FETCH
			-- auf keinen Fall ein Fetch durchfuehren!
			V_FETCH_INST := '0';	V_IEN := '0'; V_IAR_INC := '0';
			-- Es wird ein Sprung an den ABORT-Vector durchgefuehrt und der Betriebsmodus
			-- gewechselt, in STATE_DABORT erfolgt dann das sichern der Ruecksprungadresse,
			-- naemlich die zur ID gehoerende Basisadresse + 8
			V_ID_OPB_MUX_CTRL := '1';
			V_ALU_CTRL := OP_MOV;
			V_MEM_RES_REG_EN := '1';
			V_WB_RES_REG_EN := '1';
			V_WB_IAR_MUX_CTRL := '0';
			V_WB_IAR_LOAD := '1';
			V_WB_PSR_EN := '1';
			V_WB_PSR_EE := '1';
			V_ID_CONDITION := AL;
			V_ID_IMMEDIATE := VCR_DATA_ABORT;
			V_WB_PSR_MODE := ABORT;
			V_ID_MASK_FIQ := '0';
			V_ID_MASK_IRQ := '0';
			if USE_FAST_BRANCH and not USE_DEDICATED_BRANCH_ADDER then
-- 				Wenn der ALU-Ausgang benutzt wird, kann schon in der EX-Stufe
-- 				ins IAR geschrieben werden
				V_EX_BRANCH_MCTRL := '1';
			end if;	
		else

		case ARM_STATE is
-- 	Der Speicher wird nach dem Reset unmittelbar aktiviert, in STATE_FETCH
-- 	ist bereits eine Instruktion zu uebernehmen und die Speicheraktivierung im
-- 	darauf folgenden Takt vorzubereiten.
-- 	Der PC wird zu diesem Zweck inkrementiert und eine 1 in das IEN-Register
-- 	geschrieben.	
			when STATE_FETCH =>
				V_IGNORE_LU_CONFLICT := true;
				V_FETCH_INST := '1';	--Instruktion übernehmen
				V_IEN := '1' ;		--Speicher auch im nächsten Takt aktivieren
				V_IAR_INC := '1';	-- PC inkrementieren
				ARM_NEXT_STATE <= STATE_DECODE;	

-- 	STATE_DABORT entspricht weitgehend STATE_LINK, aber die Ruecksprungadresse
-- 	wird anders behandelt.
-- 	V_ID_IAR_HISTORY_ID erhaelt die ID der ABORT-verursachenden Instruktion.
-- 	DABORT kann nicht bedingt sein, CONDITION_MET ist daher ohne Bedeutung.	
-- 	Werden schnelle Spruenge verwendet, kann im naechsten Takt bereits wieder gefetcht werden.
			when STATE_DABORT =>
				V_IGNORE_LU_CONFLICT := true;
				V_ID_CONDITION := AL;				
				V_ID_OPB_MUX_CTRL := '1';
				V_ID_IMMEDIATE := X"00000004"; -- entweder 8 oder 4 + Linksshift
				V_ID_IAR_HISTORY_ID := INSTRUCTION_ID_REGISTER(INSTRUCTION_ID_REGISTER'right);
				V_ID_IAR_REVOKE := '1';
				V_RPA_ADDR := "1111";
				V_WPA_ADDR := "1110";
				V_WPA_EN := '1';
				V_SHIFT_CTRL := (O"01",SH_LSL,'0','0');
				V_ALU_CTRL := OP_ADD;
				V_MEM_RES_REG_EN := '1';
				V_WB_RES_REG_EN := '1';
				if EX_FBRANCH_MUX_CTRL(1)= '1' and USE_FAST_BRANCH and not USE_DEDICATED_BRANCH_ADDER then
					MAIN_DELAY	<= 0;	ARM_NEXT_STATE	<= STATE_FETCH;	V_IEN := '1';
				else	
					MAIN_DELAY	<= 1;	ARM_NEXT_STATE <= STATE_WAIT_TO_FETCH;	V_IEN := '0';
				end if;	

-- 	Zustand zum Sichern von Ruecksprungadressen bei BL-Instruktionen und den meisten Ausnahmebehandlungen (UNDEFINED,SWI)			
-- 	In allen Fällen muss 4 vom PC subtrahiert und das Ergbnis nach	R14 geschrieben werden.
-- 	Wenn schnelle Spruenge verwendet werden, muss im naechsten Takt bereits wieder eine Instruktion
-- 	gefetcht werden. Die Ruecksprungadresse ist zu diesem Zeitpunkt noch in der Pipeline und wird bei 
-- 	Bedarf durch Forwarding zur Verfuegung gestellt.
-- 	BL- und SWI-Instruktionen sind bedingt, so dass CONDITION_MET ausgewertet werden muss.
-- 	Wird die Bedingung nicht erfuellt, muss im Zustand DECODE fortgefahren werden.
 			when STATE_LINK =>
				V_IGNORE_LU_CONFLICT := true;
				MAIN_DELAY <= 1; -- Ggf. 2 Wartetakte in STATE_WAIT_TO_FETCH
				V_RPA_ADDR := "1111";
				V_WPA_ADDR := "1110";
				V_WPA_EN := '1';				
				V_ID_IMMEDIATE := X"00000004";
				V_ID_OPB_MUX_CTRL := '1';
				V_ALU_CTRL := OP_SUB;
				V_MEM_RES_REG_EN := '1';
				V_WB_RES_REG_EN := '1';
-- 	Falls im naechsten Takt die naechste Instruktion dekodiert wird, muss diese
-- 	PC + 8 ihrer Adresse sehen, der PC also inkrementiert werden.
-- 	Falls der naechste Takt ein Wartetakt ist schadet das Inkrementieren
-- 	auch nicht weil gleichzeitig oder anschliessend ein Sprung die Adresse
-- 	ueberschreibt.	
-- 	Aktuell wird der PC bei eintritt eines Interrupts oder eines Prefetch Abort
-- 	nicht mehr inkrementiert. Das koennte auch anders geloest werden.
				V_IAR_INC := '1'; --Damit die naechste Instruktion auch wieder PC+8 sieht
				if CDC_CONDITION_MET = '1' then
					V_ID_CONDITION := AL;
					if EX_FBRANCH_MUX_CTRL(1) = '1' and USE_FAST_BRANCH then
						ARM_NEXT_STATE <= STATE_FETCH;
						V_IEN := '1';
					else
						ARM_NEXT_STATE <= STATE_WAIT_TO_FETCH;
						V_IEN := '0';
					end if;	
				else
					V_ID_CONDITION := NV;
					ARM_NEXT_STATE <= STATE_DECODE;
					V_FETCH_INST := '0';
					V_IEN := '1';
				end if;

--------------------------------------------------------------------------------
-- 	Der normale Zunstand bei der Ausfuehrung sequentieller Ein-Zyklen-
-- 	Instruktionen. Wenn die FSM in diesem Zustand ist, wird eine neue
-- 	Instruktion (oder Exception) erstmals bearbeitet, ihre ID daher dem Rest
-- 	der Pipeline weitergegeben.
-- 	Fuer FIQ und IRQ ist das nicht ganz richtig, da die Excpetion nichts mit
-- 	der neuen Instruktion zu tun hat, da diese aber keinesfalls ausgefuehrt
-- 	wird, spielt diese Abweichung von der Regel keine Rolle, die
-- 	Instruktionen der Exception uebernehmen	die ID der verdraengten
-- 	Instruktion.
			when STATE_DECODE =>
-- 	Wann immer eine Instruktion (auch ein Interrupt) erstmals in den Zustand
-- 	DECODE eintritt wird eine neue ID in die Pipeline uebernommen die dann
-- 	die Steuersignale der verschiedenen Stufen einer Instruktion
-- 	zuordnet. Mehrzykleninstruktionen verwenden in jedem Takt die selbe ID.

				V_ID_INST_ID_PASS_MUX_CTRL := '1';
--	Interrupts verdraengen die eigentlich zu dekodierende Instruktion, Prefetch
-- 	Aborts werden hier ebenso behandelt.
-- 	SWI und UNDEFINED werden dagegen in eigenen Abschnitten wie regulaere Instruktionen
-- 	bearbeitet.
-- 	Diese Ausnahmen verweigen, ob die naechste Instruktion gefetcht wird, spielt
-- 	keine Rolle.
-- 	Der PC wird erst im naechsten Takt gesichert, so dass er hier nicht mehr
-- 	inkrementiert werden sollte. Alternativ muss diese Aenderung im naechsten Takt
-- 	kompensiert werden indem 8 statt 4 vom PC in STATE_LINK abgezogen wird.
-- 	Der Eintritt in die Ausnahmebehandlung kann einen schnellen Sprung
-- 	nutzen sofern _nicht_ der dedizierte Branch-Adder sondern die ALU
-- 	zur Errechnung des Sprungziels verwendet wird. Hintergrund:
-- 	Das Sprungziel ist ein Direktoperand. Dieser muesste im Branch-Adder
-- 	mit 0 addiert werden, die 0 steht aber nirgendwo zur Verfuegung
-- 	(Notiz: sofern die neue physische Pseude-Registeradresse 31, die sonst
-- 	nicht benoetigt wird, immer 0 enthaelt, konnte man die verwenden.)

--	welches der Ausnahmesignale gesetzt ist, spielt 
-- 	hier erstmal keine Rolle und wird spaeter im Zweig beruecksichtigt.
--        Durch den Verzicht auf die _FILTERED-Signale an dieser Stelle kann eine Dekodierebene 
-- 	eingespart werden.       
				if IRQ_FIQ_IABORT = '1' then
-- 				if (ID_FIQ_FILTERED OR ID_IRQ_FILTERED OR ID_PABORT_FILTERED) = '1' then
					V_IGNORE_LU_CONFLICT := true;
					V_ID_CONDITION := AL;
					V_ADDR_USED := (false,true,false);
					V_IEN := '0';
					V_IAR_INC := '0';
					V_ID_OPB_MUX_CTRL := '1';
					V_ALU_CTRL := OP_MOV;
					V_MEM_RES_REG_EN := '1';
					V_WB_RES_REG_EN := '1';
					V_WB_IAR_MUX_CTRL := '0';
					V_WB_IAR_LOAD := '1';
					V_WB_PSR_EN := '1';
					V_WB_PSR_EE := '1';
					ARM_NEXT_STATE <= STATE_LINK; 
					if USE_FAST_BRANCH and (not USE_DEDICATED_BRANCH_ADDER) then
						V_EX_BRANCH_MCTRL := '1';
					else
						V_EX_BRANCH_MCTRL := '0';
					end if;
					case ID_FILTERED_EXCEPTIONS is
						when "100" =>
							--FIQ
							V_ID_IMMEDIATE := VCR_FIQ;
							V_WB_PSR_MODE := FIQ;	
							V_ID_MASK_FIQ := '1';
							V_ID_MASK_IRQ := '0';
						when "010" =>
							--IRQ
							V_ID_IMMEDIATE := VCR_IRQ;
							V_WB_PSR_MODE := IRQ;	
							V_ID_MASK_FIQ := '0';
							V_ID_MASK_IRQ := '1';
						when others =>
							--PABORT
							V_ID_IMMEDIATE := VCR_PREFETCH_ABORT;
							V_WB_PSR_MODE := ABORT;	
							V_ID_MASK_FIQ := '0';
							V_ID_MASK_IRQ := '0';
					end case;
				else
				ARM_NEXT_STATE <= STATE_DECODE;
--				Im Zuge der Dekodierung eines neuen Befehls wird auch der Bedingungscode für
--				die bedingte Ausführung vom neuen Befehl übernommen
				V_ID_CONDITION := ID_INSTRUCTION_REG(31 downto 28);
				V_IEN := '1'; 
				V_FETCH_INST := '1'; -- Aktuell auf dem Speicherbus liegenden Befehl uebernehmen
				V_IGNORE_LU_CONFLICT := false;
				V_IAR_INC := '1'; 

--				Reaktion auf den aktuell in der Decodestufe befindlichen Befehl
				case CID_DECODED_VECTOR is
					when CD_COPROCESSOR =>
						V_EX_PASS_REG := '1'; 
						ARM_NEXT_STATE <= STATE_DECODE;
						V_IEN := '1';
						V_IAR_INC := '1';
						V_FETCH_INST := '1';
						V_ID_CONDITION := ID_INSTRUCTION_REG(31 downto 28);

						case ID_COP_INSTRUCTION_TYPE is
							when CIT_CDP =>
-- 	Waehrend eine Coprocessorinstruktion laeuft hat der ARM-Kern nichts zu tun
								V_IGNORE_LU_CONFLICT := true;
							when CIT_MRC =>
-- 								Move to ARM Register from Coprocessor
								V_IGNORE_LU_CONFLICT := true;
-- 	Bei Zugriff auf den CC einen Leertakt einfuegen weil der erste CC-Bypass sonst nicht mehr stimmt.
-- 	Das Problem gilt allgemein, daher wird immer ein Leertakt eingefuegt und das Verhalten spaeter konkretisiert
-- 	Fuer diesen einen Takt wird der CC-Multiplexer pauschal anders	beschaltet
-- 								V_MEM_CC_MUX_CTRL_REG := '1';
								V_WB_LOAD_REG_EN := '1';
								V_WB_CC_REG_EN := '1';
--								V_WPB_ADDR hat den Defaultwert von ID_INSTRUCTION_REG(15 downto 12)
								if ID_INSTRUCTION_REG(15 downto 12) = R15 then
									V_WPB_EN := '0';
									V_WB_PSR_EN := '1';
									V_WB_PSR_SET_CC := '1';
								else
									V_WPB_EN := '1';
									V_WB_PSR_EN := '0';
									V_WB_PSR_SET_CC := '0';

								end if;
								ARM_NEXT_STATE <= STATE_WAIT_TO_DECODE;
--	Im naechsten Takt wartet der ARM-Kern, daher wird aktuell weder das IAR inkrementiert noch im
-- 	naechsten Takt der Speicher aktiviert
								V_IEN := '0';
								V_IAR_INC := '0';
								V_FETCH_INST := '1';
								MAIN_DELAY <= 0;

							when CIT_MCR =>
-- 								Move to Coprocessor from ARM Register
								V_ADDR_USED := (true,false,false);
								V_RPC_ADDR := ID_INSTRUCTION_REG(15 downto 12);
								V_MEM_DATA_REG_EN := '1';
								-- DMAS hat den Defaultwert
								-- DEN wird absichtlich nicht aktiviert
							when CIT_LDC|CIT_STC =>
								-- Rn muss gelesen und ggf. unmittelbar
								-- zurueckgeschrieben werden,
								-- Aborts werden durch das BASE_REG automatisch behandelt
								V_MEM_DAR_EN := '1';
								V_MEM_BASE_REG_EN := '1';
								V_ADDR_USED := (false,false,true);
								V_RPA_ADDR := ID_INSTRUCTION_REG(19 downto 16);
								V_WPA_ADDR := ID_INSTRUCTION_REG(19 downto 16);
								V_WPA_EN := W;	
								V_MEM_DEN := '1';
--								Der Datenpfad wird komplett durchgeschaltet
--								und ggf. das veraenderte Basisregister zurueckgeschrieben
								V_MEM_RES_REG_EN := '1';
								V_WB_RES_REG_EN := '1';
								V_MEM_DnRW := not L;
								V_ID_OPB_MUX_CTRL := '1'; --Immediate durchschalten
								V_ID_IMMEDIATE := X"000000" & ID_INSTRUCTION_REG(7 downto 0);
-- 								V_SHIFT_AMOUNT := O"02"; --Immediate auf Wortgroesse Schieben
								V_SHIFT_CTRL := (O"02",SH_LSL,'0','0');
								V_TRUNCATE_ADDR := '1';
								if U = '0' then
									V_ALU_CTRL := OP_SUB;
								else
									V_ALU_CTRL := OP_ADD;
								end if;
								if P = '0' then
									V_DAR_MCTRL := '1';	
								else
									V_DAR_MCTRL := '0';
								end if;
								
								-- Fuer CHS=GO
								-- Wechsel in einen weiteren Zustand in dem ausschlieslich
								-- das DAR inkrementiert und DnRW korrekt gesetzt und der Speicher
								-- aktiv gehalten wird
								
--							when CIT_STC =>
							when others =>
--							CIT_NON sollte hier irrelevant sein weil
--							damit sowieso CD_UNDEFINED erzeugt wird	
						end case;

						case CPA_ID_CHS is
							when CHS_WAIT =>
--	In Decode bleiben und NOP in die Pipeline schreiben, PC nicht inkrementieren
								V_IGNORE_LU_CONFLICT := true;
								V_ID_CONDITION := NV;	
								ARM_NEXT_STATE <= STATE_DECODE;
								V_IEN := '1';
								V_IAR_INC := '0';
								V_FETCH_INST := '0';
							when CHS_GO =>
								ARM_NEXT_STATE <= STATE_LDC;
							when CHS_LAST => 
								-- Durch CIT_LDC|CIT_STC schon beschrieben, Wechsel nach Decode
							when others =>
--								CHS_ABSENT wo es nicht auftreten sollte,
--								entspricht einer UNDEFINED-Exception
-- 								Es wird kein Konflikttraechtiges Register gelesen
								V_IGNORE_LU_CONFLICT := true;
								V_ID_CONDITION := ID_INSTRUCTION_REG(31 downto 28);
								V_FETCH_INST := '1';
								V_IEN := '0';
								V_IAR_INC := '0';
								ARM_NEXT_STATE <= STATE_LINK;
								V_ID_OPB_MUX_CTRL := '1';
								V_ALU_CTRL := OP_MOV;
								V_MEM_RES_REG_EN := '1';
								V_WB_RES_REG_EN := '1';
								V_WB_IAR_MUX_CTRL := '0';
								V_WB_IAR_LOAD := '1';
								V_WB_PSR_EN := '1';
								V_WB_PSR_EE := '1';
								V_ID_IMMEDIATE := VCR_UNDEFINED;
								V_WB_PSR_MODE := UNDEFINED;					
						end case;
					
-- 	B- oder BL-Instruktion
-- 	Beide verzweigen in einen weiteren Zustand, so dass im naechsten Takt 
-- 	der Speicher nicht aktiviert werden muss. Dieses Verhalten ist verbesserungs-
-- 	beduerftig.
					when CD_BRANCH =>
--	Operand A ist der PC, Operand B ein Immediate						
						V_ADDR_USED		:= (false,false,true);
						V_IGNORE_LU_CONFLICT := true;
						V_IEN := '0';
						V_FETCH_INST := '1';
-- 	Inkrementiert wird in STATE_WAIT_TO_FETCH oder STATE_LINK
						V_IAR_INC := '0';
-- 	B und BL verwenden nicht den Shifter zum anpassen des Immediats damit der Branch-Adder verwendet
-- 	werden kann. Der Offset wird rechts um zwei Nullen ergaenzt	
						V_ID_IMMEDIATE := V_BRANCH_SIGN_BYTE & ID_INSTRUCTION_REG(23 downto 0) & "00";
						V_ID_OPB_MUX_CTRL := '1'; --Immediate verwenden
						V_EX_OPA_PSR_MUX_CTRL := '0'; --PC verwenden (steht auf PC + 8 des Befehls)
						V_RPA_ADDR := "1111"; 	  --PC lesen
-- 						V_SHIFT_AMOUNT := O"00"; V_SHIFT_TYPE := SH_LSL; V_SHIFT_RRX := '0';
						V_ALU_CTRL := OP_ADD;
						V_SHIFT_CTRL := (O"00",SH_LSL,'0','0');
						V_MEM_RES_REG_EN := '1';
						V_WB_RES_REG_EN := '1';
						V_WB_IAR_LOAD := '1';
						V_EX_BRANCH_MCTRL := '1';
						if LINK_BIT = '1' then --Branch with Link
							ARM_NEXT_STATE <= STATE_LINK;
						else
							ARM_NEXT_STATE <= STATE_WAIT_TO_FETCH;
--	3 Takte, bis das Sprungziel im Adressregister steht. Im letzten Wartetakt
--	mmüssen die Kontrollsignale für Speicher und PC gesetzt werden, anschließend
--	ist ein Sprung nach Fetch notwendig und dann nach Decode
--	2,1,0 in Zustand STATE_WAIT_TO_FETCH, also _3_ Wartetakte, im 4. Takt wird
-- 	die naechste Instruktion entgegengenommen.
							if USE_FAST_BRANCH then
								MAIN_DELAY <= 0;
							else
								MAIN_DELAY <= 2;
							end if;
						end if;

-- 	Im ersten Takt dieser Instruktionen werden alle Steuersignale 
-- 	fuer die Basis der Adressberechnung erzeugt. Ggf. ist vor
-- 	dem ersten Speicherzugriff noch ein Inkrement des DAR notwendig,
-- 	dies geschieht aber waehrend die Daten fuer den ersten Speicherzugriff
-- 	die EX-Stufe durchlaufen und benoetigt daher keinen zusaetzlichen
-- 	Takt.
-- 	Am Ende der LDM-Instruktionsbehandlung muss der LDM-Dekoder mit dem 
-- 	unteren Halbwort des Instruktionsregisters aktualisiert werden	
-- 	dazu ist IF_LDMSTM_MUX_CTRL auf 1 zu setzen
-- 	Eine leere Registerliste wird nicht gesonderte behandelt.
-- 	Die Basisadresse kann bereits in das Datenadressregister kopiert werden, hier wird immer
-- 	der aktuelle Betriebsmodus verwendet.
-- 	Die Menge der zu kopierenden Daten ist bereits bekannt, so dass die Anfangsadresse und die 
-- 	Rückschreibadresse bereits berechnet werden können
-- 	Basis- oder Rückschreibadresse hängen immer von der Zahl der
-- 	in der Registerliste gesetzten Bits ab.	
-- 	Die aktualisierte Basisadresse wird nach MEM_RES_REG geschrieben aber nicht unbedingt
-- 	sofort weitergereicht und in den Registerspeicher geschrieben.

-- 	Nachdenken: stimmt das so, dass bei einigen Adressierungsarten
-- 	bereits der erste Zugriff erfolgt aber die Registerliste gleich bleibt.
-- 	Und was ist bei nur einem Bit in der Registerliste?
-- 	Passt: in dem Fall wird die Registerliste um eins
-- 	verringert. Im Zustand LDM wird auch geprueft, ob evtl.
-- 	gar kein Wort mehr zu uebertragen ist, dann findet
-- 	ggf. nur noch das Rueckschreiben der Basisadresse statt.

-- 	Aenderung: in diesem Zustand findet gar kein Speicherzugriff mehr
-- 	statt. So koennen die diversen Spezialfaelle
-- 	vollstaendig in einem eigenen Zustand behandelt werden. Insbesondere
-- 	ein Problem ist beispielsweise ein LDM mit nur dem PC!	
--	Bei zwei der Adressierungsarten muss die erste Zugriffsadresse
--	vor dem Speicherzugriff noch einmal inkrementiert werden.
--	MAIN_DELAY transportiert diese Information						
					when CD_LOAD_STORE_MULTIPLE =>
						V_ADDR_USED		:= (false,false,true);
-- 						V_TRUNCATE_ADDR		:= '1';
						V_MEM_BASE_REG_EN	:= '1'; 
						MAIN_DELAY		<= 0;						
						V_FETCH_INST		:= '1';
						V_IEN			:= '0';
						V_IAR_INC		:= '0';
						ARM_NEXT_STATE		<= STATE_LDM;
						V_ID_LNA_LOAD_REGLIST	:= '0'; --Registerliste erhalten
						V_ID_LNA_HOLD_VALUE	:= '1';
						V_IF_LDMSTM_MUX_CTRL	:= '0';
						V_RPA_ADDR		:= ID_INSTRUCTION_REG(19 downto 16);
-- 						V_RPC_ADDR		:= ID_LNA_ADDRESS;
-- 						V_WPB_ADDR		:= ID_LNA_ADDRESS;
						V_ID_IMMEDIATE		:= X"000000" & "000" & RBA_NR_OF_REGS;
						V_ID_OPB_MUX_CTRL	:= '1';
						V_SHIFT_CTRL		:= (O"02",SH_LSL,'0','0');
						V_MEM_DAR_EN		:= '1';
						V_MEM_DAR_INC		:= '0';
						V_MEM_RES_REG_EN	:= '1';
						V_MEM_DATA_REG_EN	:= '0';
						V_MEM_DnRW		:= '0';--NOT L;	
						V_MEM_DEN		:= '0';
						V_WB_LOAD_REG_EN	:= '0';

						case ID_INSTRUCTION_REG(24 downto 23) is
							when "00" =>
--								Postdekrement
--								Anfangsadresse = Rn - (4*NR_OF_REGS)+4
--								Rn* = Rn - (4* NR_OF_REGS)
--	Rn* zuerst berechnen, gleichzeitig nach DAR kopieren und dort
-- 	für einen Takt inkrementieren bevor der erste echte Zugriff stattfindet
								V_DAR_MCTRL	:= '0'; 
								V_ALU_CTRL	:= OP_SUB;
								MAIN_DELAY	<= 0;
-- 								V_WPB_EN := '0';
-- 								V_ID_LNA_HOLD_VALUE := '1';
							when "01" =>
--								Postinkrement
--								Anfangsadresse = Rn
--								Rn* = Rn + (4* NR_OF_REGS)
-- 								V_MEM_DEN := '1';
								V_DAR_MCTRL	:= '1';
								V_ALU_CTRL	:= OP_ADD;
								MAIN_DELAY	<= 1;
-- 								V_WB_LOAD_REG_EN := L; --Fuer Load bereits das erste Datum entgegennehmen
-- 								V_WPB_EN := L;
-- 								V_ID_LNA_HOLD_VALUE := '0';
							when "10" =>
--								Predekrement
--								Anfangsadresse = Rn - (4*NR_OF_REGS)
--								Rn* = Rn - (4* NR_OF_REGS)
--								Anfangsadresse und Rn* können gleichzeitig erzeugt werden
-- 								V_MEM_DEN := '1';
								V_DAR_MCTRL	:= '0'; --ALU auf das DA-Register
								V_ALU_CTRL	:= OP_SUB;
								MAIN_DELAY	<= 0;
-- 								V_WB_LOAD_REG_EN := L; --Fuer Load bereits das erste Datum entgegennehmen
-- 								V_WPB_EN := L;
-- 								V_ID_LNA_HOLD_VALUE := '0';
							when others =>
--								Preinkrement, wie postinkrement aber mit Zusatz fuer DAR
--								Anfangsadresse = Rn + 4
--								Rn* = Rn + (4* NR_OF_REGS)
-- 								V_MEM_DEN := '0';
								V_DAR_MCTRL := '1'; 	
								V_ALU_CTRL := OP_ADD;
								MAIN_DELAY	<= 0;
-- 								V_WB_LOAD_REG_EN := '0'; 
-- 								V_WPB_EN := '0';
-- 								V_ID_LNA_HOLD_VALUE := '1';
						end case;

-- 	UNSIGNED_IMMEDIATE wird im Shift Recoder so behandelt, dass kein Shift durchgefuehrt wird weshalb beide
-- 	Instruktionsarten direkt den Recoder verwenden koennen.
-- 	Die Unterscheidung beider Operationen hinsichtlich der Load-Use-Konflikte ist nicht unbedingt
-- 	notwendig. Die Bypasssteuerung erkennt an der Steuerung von ID_OPB_MUX ob ein direktoperand
-- 	vorliegt. Evtl. kann diese Abfrage aber zukuenftig entfernt werden wenn V_ADDR_USED konsequent
--	und richtig arbeitet. 	
-- 	Wie bei jeder Load/Store-Instruktion wird das Basisregister nach MEM_BASE_REG kopiert
					when CD_LOAD_STORE_UNSIGNED_IMMEDIATE | CD_LOAD_STORE_UNSIGNED_REGISTER =>
						V_MEM_BASE_REG_EN := '1'; 
						V_ID_IMMEDIATE := X"00000" & ID_INSTRUCTION_REG(11 downto 0);
						V_RPA_ADDR := ID_INSTRUCTION_REG(19 downto 16);
						V_RPB_ADDR := ID_INSTRUCTION_REG(3 downto 0);
						V_RPC_ADDR := ID_INSTRUCTION_REG(15 downto 12);
						V_WPA_ADDR := ID_INSTRUCTION_REG(19 downto 16);
						V_WPB_ADDR := ID_INSTRUCTION_REG(15 downto 12);
--	Write Back der Adresse oder Adressveränderung nach Speicherzugriff		
						V_WPA_EN := W or (not P);
						V_WB_IAR_MUX_CTRL := '1';
-- 	Verwendung von R15 als Rn ist nicht vorgesehen, insofern
-- 	muss ein dadurch beschriebener Sprung auch nicht vorgesehen werden.
						V_SHIFT_CTRL := SRC_SHIFT_CTRL;
						V_MEM_DAR_EN := '1'; --Wert laden
						V_MEM_DEN := '1';
						MAIN_DELAY <= 2; --falls das Laden einen Sprung verursacht
						V_MEM_RES_REG_EN := '1';
						V_WB_RES_REG_EN := '1';
						V_MEM_DATA_REG_EN := '1'; --Nur fuer Store interessant
						if CID_DECODED_VECTOR = CD_LOAD_STORE_UNSIGNED_IMMEDIATE then
							V_ID_OPB_MUX_CTRL := '1'; 
							V_ADDR_USED(1 downto 0) := (false,true);
						else
							V_ID_OPB_MUX_CTRL := '0'; 
							V_ADDR_USED(1 downto 0) := (true,true);
						end if;
						case ID_INSTRUCTION_REG(24 downto 23) is
							when "00" =>
--								Postdekrement
								V_DAR_MCTRL := '1'; --Operand1 auf das DA-Register
								V_ALU_CTRL := OP_SUB;
							when "01" =>
--								Postinkrement
								V_DAR_MCTRL := '1';
								V_ALU_CTRL := OP_ADD;
							when "10" =>
--								Predekrement
								V_DAR_MCTRL := '0'; --ALU auf das DA-Register
								V_ALU_CTRL := OP_SUB;
							when others =>
--								Preinkrement
								V_DAR_MCTRL := '0'; --ALU auf das DA-Register	
								V_ALU_CTRL := OP_ADD;
						end case;
						if ((not P) and W) = '1' then --P=0, W=1 => alternative Speichersicht im USER-Modus
							V_WB_PSR_MODE	:= USER;
						end if;
						if ID_INSTRUCTION_REG(22) = '1' then --Byte-Bit
							V_MEM_DMAS := DMAS_BYTE;					
							V_TRUNCATE_ADDR := '0';
						else	
							V_MEM_DMAS := DMAS_WORD;						
--	Beim Laden von Worten wird rotiert, beim Speichern die Adresse angepasst
							V_TRUNCATE_ADDR := not L;
						end if;	
						if L = '1' then
							V_ADDR_USED(2) := false;
							V_MEM_DnRW := '0';
							V_WPB_EN := '1';
							V_WB_LOAD_REG_EN := '1';
						else --Speichern
							V_ADDR_USED(2) := true;
							V_MEM_DnRW := '1';
							V_WPB_EN := '0';
							V_WB_LOAD_REG_EN := '0';
						end if;
						--IAR ggf. mit neuem Wert laden, Wartezeit nach Sprungbefehlen beachten
						if (L = '1' and ID_INSTRUCTION_REG(15 downto 12) = "1111") then
							ARM_NEXT_STATE <= STATE_WAIT_TO_FETCH;
							V_WB_IAR_LOAD := '1';
							V_IAR_INC := '0';		
						else
							ARM_NEXT_STATE <= STATE_DECODE;
							V_WB_IAR_LOAD := '0';
							V_IAR_INC := '1';		

						end if;

					when CD_LOAD_STORE_SIGNED_IMMEDIATE | CD_LOAD_STORE_SIGNED_REGISTER =>	
						V_MEM_BASE_REG_EN := '1'; 
						V_MEM_DAR_EN := '1';
						V_MEM_DEN := '1';
						V_MEM_DnRW := not L;
					    	MAIN_DELAY <= 2; --falls das Laden einen Sprung verursacht
						V_ID_IMMEDIATE := X"000000" & ID_INSTRUCTION_REG(11 downto 8) & ID_INSTRUCTION_REG(3 downto 0);
						V_RPA_ADDR := ID_INSTRUCTION_REG(19 downto 16);
						V_RPB_ADDR := ID_INSTRUCTION_REG(3 downto 0);
--						Je nach Operation ist Rd Quell- oder Zielregister
						V_RPC_ADDR := ID_INSTRUCTION_REG(15 downto 12);
						V_WPA_ADDR := ID_INSTRUCTION_REG(19 downto 16);
						V_WPB_ADDR := ID_INSTRUCTION_REG(15 downto 12);
						V_WPA_EN := W or (not P);
						V_WPB_EN := L;
-- 						Wenn gesprungen wird dann durch ein gelesenes Datum und nicht durch
-- 						das Rueckschreiben der modifizierten Basisadresse
						V_WB_IAR_MUX_CTRL := '1';
--						Write Back der Adresse oder Adressveränderung nach Speicherzugriff		
						V_MEM_RES_REG_EN := W or (not P);
						V_WB_RES_REG_EN := W or (not P);
						V_WB_LOAD_REG_EN := L;
--						Auswahl von Rm oder Immediate als Operand B
						if CID_DECODED_VECTOR = CD_LOAD_STORE_SIGNED_IMMEDIATE then
							V_ID_OPB_MUX_CTRL := '1'; 	
							V_ADDR_USED(1 downto 0) := (false,true);
						else
							V_ID_OPB_MUX_CTRL := '0'; 	
							V_ADDR_USED(1 downto 0) := (true,true);
						end if;
--						Anpassung des zu schreibenden/gelesenen Datums
						case ID_INSTRUCTION_REG(6 downto 5) is --SH
							when "11" =>	--signed halfword, nur beim Laden sinnvoll
								V_MEM_DMAS := DMAS_HWORD;
								V_MEM_WMP_SIGNED := '1';
							when "01" =>	--unsigned halfword
								V_MEM_DMAS := DMAS_HWORD;
								V_MEM_WMP_SIGNED := '0';
							when others => --"10" =>--signed byte, nur beim Laden sinnvoll
								V_MEM_DMAS := DMAS_BYTE;
								V_MEM_WMP_SIGNED := '1';
--	00 darf hier nicht auftreten, ist zur Optimierung mit 10 zusammengelegt
--							when others =>								
-- 								V_MEM_DMAS := DMAS_WORD;
-- 								V_MEM_WMP_SIGNED := '0';
						end case;						
						if L = '0' then --store
							V_ADDR_USED(2) := true;
							--signed store ist sinnlos, Bit 6 = S
--							V_LOCAL_UNDEFINED := ID_INSTRUCTION_REG(6);
						else --load
							V_ADDR_USED(2) := false;
--							V_LOCAL_UNDEFINED := '0';
						end if;	

						case ID_INSTRUCTION_REG(24 downto 23) is
							when "00" =>
--								Postdekrement
								V_DAR_MCTRL := '1'; --Operand1 auf das DA-Register
								V_ALU_CTRL := OP_SUB;
							when "01" =>
--								Postinkrement
								V_DAR_MCTRL := '1';
								V_ALU_CTRL := OP_ADD;
							when "10" =>
--								Predekrement
								V_DAR_MCTRL := '0'; --ALU auf das DA-Register
								V_ALU_CTRL := OP_SUB;
							when others =>
--								Preinkrement
								V_DAR_MCTRL := '0'; --ALU auf das DA-Register	
								V_ALU_CTRL := OP_ADD;
						end case;
					
						--IAR ggf. mit neuem Wert laden, Wartezeit nach Sprungbefehlen beachten
						if (L = '1' and ID_INSTRUCTION_REG(15 downto 12) = "1111") then
							ARM_NEXT_STATE <= STATE_WAIT_TO_FETCH;
							V_WB_IAR_LOAD := '1';
							V_IAR_INC := '0';		
						else	
							ARM_NEXT_STATE <= STATE_DECODE;
							V_WB_IAR_LOAD := '0';
							V_IAR_INC := '1';		
						end if;
							
					when CD_ARITH_IMMEDIATE | CD_ARITH_REGISTER | CD_ARITH_REGISTER_REGISTER =>
--						case CID_DECODED_VECTOR is
--							when CD_ARITH_IMMEDIATE => 
--								V_ADDR_USED := (false,false,true);
--							when CD_ARITH_REGISTER => 
--								V_ADDR_USED := (false,true,true);
--							when others => 
--								V_ADDR_USED := (true,true,true);
--						end case;	
						V_FETCH_INST	:= '1';					
						V_IAR_INC	:= AIC_IF_IAR_INC;
--						Neu, im naechsten Takt wird der Speicher aktiviert wenn
--						auch ein neuer Wert im PC steht
						V_IEN		:= AIC_IF_IAR_INC;
						V_RPA_ADDR	:= AIC_ID_R_PORT_A_ADDR;
						V_RPB_ADDR	:= AIC_ID_R_PORT_B_ADDR;
						V_RPC_ADDR	:= AIC_ID_R_PORT_C_ADDR;
						V_ID_IMMEDIATE	:= AIC_ID_IMMEDIATE;
						V_ID_OPB_MUX_CTRL	:= AIC_ID_OPB_MUX_CTRL;
						V_ALU_CTRL		:= AIC_EX_ALU_CTRL;
						V_MEM_RES_REG_EN	:=  AIC_MEM_RES_REG_EN;
						V_MEM_CC_REG_EN		:=  AIC_MEM_CC_REG_EN;
						V_WPA_ADDR		:= AIC_WB_W_PORT_A_ADDR;
						V_WPA_EN		:=  AIC_WB_W_PORT_A_EN;
						V_WB_RES_REG_EN		:=  AIC_WB_RES_REG_EN;
						V_WB_CC_REG_EN		:=  AIC_WB_CC_REG_EN;
						V_WB_IAR_LOAD		:= AIC_WB_IAR_LOAD;
						V_WB_PSR_EN		:= AIC_WB_PSR_EN;
						V_WB_PSR_ER		:= AIC_WB_PSR_ER;
						V_WB_PSR_SET_CC		:= AIC_WB_PSR_SET_CC;	
						V_WB_IAR_MUX_CTRL	:= AIC_WB_IAR_MUX_CTRL;
						ARM_NEXT_STATE		<= AIC_ARM_NEXT_STATE;
						MAIN_DELAY		<= to_integer(unsigned(AIC_DELAY));
						V_SHIFT_CTRL		:= SRC_SHIFT_CTRL;
						if(AIC_ID_REGS_USED(2) = '1')then
							V_ADDR_USED(2) := true;
						else
							V_ADDR_USED(2) := false;
						end if;
						if(AIC_ID_REGS_USED(1) = '1')then
							V_ADDR_USED(1) := true;
						else
							V_ADDR_USED(1) := false;
						end if;
						if(AIC_ID_REGS_USED(0) = '1')then
							V_ADDR_USED(0) := true;
						else
							V_ADDR_USED(0) := false;
						end if;
--				
-- 	Schreiben eines neuen Inhalts in das Statusregister, CPSR oder SPSR.
-- 	Die Pipeline wird angehalten, bis die Operation abgeschlossen ist (
-- 	die naechste Instruktion wird dekodiert, nachdem der Schreibzugriff
-- 	beendet wird). Die Veraenderungen durch MSR-Instruktionen werden 
-- 	aktuell nicht korrekt bebypasst, so dass das Dekodieren
-- 	der naechsten Instruktion nur verschraenkt mit dem Rueckschreiben
-- 	in das CPSR/SPSR geschehen kann, wenn sich dadurch der Betriebsmodus
-- 	nicht aendert.
-- 	Diese Instruktion wird noch im aktuellen Takt gefetcht.
-- 	Aenderung: Das ist so nicht ganz richtig. Wenn der Modus im SPSR
-- 	geaendert wird, muss die nachfolgende Instruktion bzgl. dieses neuen
-- 	Modus gefetcht werden. Ergo ist die naechste Instruktion erneut
-- 	zu fetchen sobald der Schreibzugriff durchgefuehrt wurde. 
-- 	Deshalb muss der Nachfolgezustand zumindest dann, oder der 
-- 	Einfachheit halber immer, STATE_WAIT_TO_FETCH sein.
-- 	Beide Formen der MSR-Instruktion koennen durch den Shift-Recoder
-- 	behandelt werden, die Instruktionsbits 11:8 bei MSR_REGISTER muessen
-- 	dann aber unbedingt "0000" sein.
					when CD_MSR_IMMEDIATE|CD_MSR_REGISTER =>
						V_FETCH_INST := '1';
						V_IEN := '0';
						V_IAR_INC := '0';						
						V_ID_IMMEDIATE := X"000000" & ID_INSTRUCTION_REG(7 downto 0);
						V_RPB_ADDR := ID_INSTRUCTION_REG(3 downto 0);
						V_ALU_CTRL := OP_MOV;
						V_SHIFT_CTRL := SRC_SHIFT_CTRL;
						V_MEM_RES_REG_EN := '1';
						V_WB_RES_REG_EN := '1';
						V_WB_PSR_EN := '1';
						V_WB_PSR_MASK := ID_INSTRUCTION_REG(19 downto 16);
						V_WB_PSR_WRITE_SPSR := R;
						if CID_DECODED_VECTOR = CD_MSR_IMMEDIATE then
							V_ID_OPB_MUX_CTRL := '1';
							V_ADDR_USED := (false,false,false);
						else
							V_ID_OPB_MUX_CTRL := '0';
							V_ADDR_USED := (false,true,false);
						end if;
						if R = '1' or ID_INSTRUCTION_REG(16) = '0' then 
-- 						Beliebiger Zugriff auf das SPSR oder Zugriff auf das 
-- 						CPSR bei dem der Modus nicht veraendert werden kann.
-- 						Naechste Instruktion dekodieren im Takt in dessen
-- 						erster Haelfte das Schreiben in das SPSR beendet wird
							ARM_NEXT_STATE <= STATE_WAIT_TO_DECODE;
 							MAIN_DELAY <= 1;
						else
							ARM_NEXT_STATE <= STATE_WAIT_TO_FETCH;
 							MAIN_DELAY <= 2;
						end if;					
-- 	Lesen des PSR. Der Inhalt wird durch den Operand A-Pfad gefuehrt
-- 	und durchlaeft deshalb auch die ALU. In der ALU ist eine neutrale
-- 	Operation mit einem Immediate (z.B. ORR 0) durchzufuehren.
					when CD_MRS =>	
						V_IGNORE_LU_CONFLICT := true;
						ARM_NEXT_STATE <= STATE_DECODE;					
 						V_ADDR_USED := (false,false,false);
						V_IEN := '1';
						V_IAR_INC := '1';
						V_FETCH_INST := '1';						
						V_EX_OPA_PSR_MUX_CTRL := '1'; -- (C/S)PSR als Operand A verwenden
						V_ID_IMMEDIATE := (others => '0');
						V_ALU_CTRL := OP_ORR;
						V_ID_OPB_MUX_CTRL := '1';
						V_EX_PSR_MUX_CTRL := R;
-- 	Wenn das CPSR gelesen wird muss der gegenwaertige Condition Code im Datenpfad eingebaut werden.					
						V_PSR_CC_MCTRL := not R;
						V_MEM_RES_REG_EN := '1';
						V_WB_RES_REG_EN := '1';
						V_WPA_ADDR := ID_INSTRUCTION_REG(15 downto 12);
						V_WPA_EN := '1';
-- 						Das laden des PSR nach R15 ist nicht spezifiziert.
-- 						Eine sicherere Implementierung koennte den Fall abfangen und das 
-- 						Schreiben ignorieren.
						-- aus der Operation ein NOP machen:
-- 						if ID_INSTRUCTION_REG(15 downto 12) = "1111" then
-- 							V_WPA_EN := '0';
-- 						else
-- 							V_WPA_EN := '1';
-- 						end if;							
						
					when CD_MULTIPLY =>
						ARM_NEXT_STATE	<= STATE_DECODE;
						MAIN_DELAY	<= 0;
						V_IAR_INC	:= '1';		
						V_RPA_ADDR	:= ID_INSTRUCTION_REG(15 downto 12);
						V_RPB_ADDR	:= ID_INSTRUCTION_REG(3 downto 0);
						V_RPC_ADDR	:= ID_INSTRUCTION_REG(11 downto 8);
						V_WPA_ADDR	:= ID_INSTRUCTION_REG(19 downto 16);
						V_WPA_EN	:= '1';
						V_OPB_ALU_MCTRL := '1'; --Multiplizierer auf ALU schalten
						V_MEM_RES_REG_EN:= '1';
						V_WB_RES_REG_EN := '1';
						V_MEM_CC_REG_EN := ID_INSTRUCTION_REG(20);
						V_WB_CC_REG_EN	:= ID_INSTRUCTION_REG(20);
						V_WB_PSR_EN 	:= ID_INSTRUCTION_REG(20);
						V_WB_PSR_SET_CC	:= ID_INSTRUCTION_REG(20);
--						Die 6 ungueltigen MUL-Codes aussortieren, muessen ebenfalls als UNDEFINED berücksichtigt werden
						if ID_INSTRUCTION_REG(23 downto 21) = OP_MLA then
							V_ADDR_USED := (true,true,true);
							V_ALU_CTRL := OP_ADD;
						elsif ID_INSTRUCTION_REG(23 downto 21) = OP_MUL then
							V_ALU_CTRL := OP_MOV;
							V_ADDR_USED := (true,true,false);
						else
							V_ALU_CTRL := OP_MOV;
							V_ADDR_USED := (false,false,false);
							-- die uebrigen Multiplikationsinstruktionen sind nicht implementiert
--							V_LOCAL_UNDEFINED := '1';

						end if;
--	Falls eine sicherere Implementierung gewuenscht ist und PC illegal als Zielregister angegeben wurde 
-- 						if ID_INSTRUCTION_REG(19 downto 16) = "1111" then
-- 							V_WPA_EN := '1';
-- 						end if;

-- 	Austausch von Register und Speicherinhalt in zwei Takten.					
-- 	Der Speicherzugriff in diesem Takt erfolgt lesend, Wortadressen werden nicht abgeschnitten.					
-- 	Reaktion: Bei Rn=Rm bzw. Rn=Rd sollten keine Probleme auftreten, die Instruktion
-- 	kann ausgeführt werden, da alle Register noch vor dem Rückschreiben eines Werte gelesen werden
-- 	Bei Rd = PC wird die Instruktion zum NOP
-- 	Das gelesene Datum wird in das Eingangsregister der WB-Stufe geschrieben jedoch
--	noch nicht in den Registerspeicher. Das Rueckschreiben darf erst im naechsten Takt
-- 	verursacht werden wenn sichergestellt ist, dass der zweite Speicherzugriff erfolgreich
-- 	war.
					when CD_SWAP =>
						ARM_NEXT_STATE	<= STATE_SWAP;
						V_IAR_INC	:= '0';	-- Swap benötigt immer mehrere Takte
						V_FETCH_INST	:= '1';	-- naechsten Befehl entgegennehmen
						V_IEN		:= '0';
						V_ADDR_USED	:= (false,false,true);
						V_TRUNCATE_ADDR	:= '0';
						V_RPA_ADDR	:= ID_INSTRUCTION_REG(19 downto 16);
						V_DAR_MCTRL	:= '1';
						V_MEM_DAR_EN	:= '1';
						V_MEM_DnRW	:= '0'; --Load
						V_MEM_DEN	:= '1';
						V_WB_LOAD_REG_EN	:= '1';
						V_MEM_BASE_REG_EN	:= '1';
						if B = '1' then --Bytezugriff
							V_MEM_DMAS	:= DMAS_BYTE;
						else
							V_MEM_DMAS	:= DMAS_WORD;
						end if;
-- 						Falls eine sicherere Implementierung fuer Rd=PC gewuenscht ist:
-- 						if ID_INSTRUCTION_REG(15 downto 12) = "1111" then
-- 							V_MEM_DEN := '0';
-- 							ARM_NEXT_STATE <= STATE_DECODE;
-- 						end if;

-- 	Zwei Ausnahmen die direkt durch eine Instruktion verursacht werden.					
-- 	SWI/UNDEFINED kann bedingt sein. Die naechste Instruktion noch gefetcht, der PC
-- 	aber nicht mehr inkrementiert damit beim Sichern der Ruecksprungadresse
-- 	der korrekte Wert sichtbar ist.
					when others => --CD_UNDEFINED|CD_SWI oder ein anderer Code=>
						V_IGNORE_LU_CONFLICT := true;
						V_FETCH_INST := '1';
						V_IEN := '0';
						V_IAR_INC := '0';
						V_ID_OPB_MUX_CTRL := '1';
						V_ALU_CTRL := OP_MOV;
						V_MEM_RES_REG_EN := '1';
						V_WB_RES_REG_EN := '1';
						V_WB_IAR_MUX_CTRL := '0';
						V_WB_IAR_LOAD := '1';
						V_WB_PSR_EN := '1';
						V_WB_PSR_EE := '1';
						ARM_NEXT_STATE <= STATE_LINK;
						if CID_DECODED_VECTOR = CD_SWI then
							V_ID_IMMEDIATE := VCR_SWI;
							V_WB_PSR_MODE := SUPERVISOR;
						else
							V_ID_IMMEDIATE := VCR_UNDEFINED;
							V_WB_PSR_MODE := UNDEFINED;
						end if;
						if USE_FAST_BRANCH and (not USE_DEDICATED_BRANCH_ADDER)then
							V_EX_BRANCH_MCTRL := '1';
						else
							V_EX_BRANCH_MCTRL := '0';
						end if;
				end case;  -- Decode Case

--	Verhalten, wenn eine der Anforderungen an die dekodierte Instruktion verletzt wurde, wechsel nach UNDEFINED
--	V_ID_INST_ID_PASS_MUX_CTRL bleibt bei '1' aus STATE_DECODE, die Instruktion ist fehlerhaft, 
--	die Behandlung uebernimmt die ID der Instruktion
--	Nur die tatsaechlich fuer den Zustand relevanten Steuersignale werden ggf. wieder geloescht				
				if V_LOCAL_UNDEFINED = '1' or (ID_LOAD_USE_CONFLICT = '1' and (not V_IGNORE_LU_CONFLICT)) then		
					V_IAR_INC := '0';
					if V_LOCAL_UNDEFINED = '1' then
						V_IGNORE_LU_CONFLICT := true;			
						ARM_NEXT_STATE <= STATE_LINK;
						V_FETCH_INST := '1';
						V_IEN := '0';
						V_MEM_DEN := '0';
-- 						V_IAR_INC := '0';
						V_ID_IMMEDIATE := VCR_UNDEFINED;
						V_WB_PSR_MODE := UNDEFINED;
						V_ID_OPB_MUX_CTRL := '1';
						V_EX_PASS_REG := '0';
						V_ALU_CTRL := OP_MOV;
						V_MEM_RES_REG_EN := '1';
						V_WB_RES_REG_EN := '1';
						V_WB_IAR_MUX_CTRL := '0';
						V_WB_IAR_LOAD := '1';
						V_WB_PSR_EN := '1';
						V_WB_PSR_EE := '1';
						V_WB_PSR_WRITE_SPSR := '0';
						V_WPA_EN := '0';
						V_WPB_EN := '0';
						if not USE_DEDICATED_BRANCH_ADDER then
							V_EX_BRANCH_MCTRL := '1';
						else
							V_EX_BRANCH_MCTRL := '0';
						end if;
					else --Reaktion auf Load/Use-Konflikt
						ARM_NEXT_STATE <= STATE_DECODE;
						V_IEN := '1';
						V_FETCH_INST := '0';
						V_ID_CONDITION := NV;
						V_ID_LNA_HOLD_VALUE := '1';
						V_ID_LNA_LOAD_REGLIST := '0';
					end if;	
				end if;
				end if; --STATE_DECODE


-- 	Zweiter Takt einer SWAP-Instruktion, Schreiben in den Speicher und Rueck-
-- 	schreiben des Zuvor aus dem Speicher gelesenen Datums.	
-- 	Die naechste Instruktion steht bereits im Instruktionsregister, so dass
-- 	nicht erneut gefetcht werden muss. PC muss allerdings fuer diese
-- 	naechste Instruktion inkrementiert werden.
-- 	Das Nichterfuellen der Instruktionsbedingung muss nicht
-- 	zusaetzlich behandelt werden, beide Zyklen der SWAP-Instruktion
-- 	laufen dann wirkungslos durch die Pipeline.
-- 	Die Bedingung wird aus ID_OLD_INSTRUCTION_REG rekonstruiert.			
			when STATE_SWAP =>
-- 				V_IGNORE_LU_CONFLICT	:= true;
				ARM_NEXT_STATE	<= STATE_DECODE;
				V_IAR_INC	:= '1';
				V_IEN		:= '1';
				V_FETCH_INST	:= '0';
				V_ID_CONDITION	:= ID_OLD_INSTRUCTION_REG(31 downto 28);
				V_RPC_ADDR	:= ID_OLD_INSTRUCTION_REG(3 downto 0);
				V_RPA_ADDR	:= ID_OLD_INSTRUCTION_REG(19 downto 16); --Rn
				V_DAR_MCTRL	:= '1'; --OPA unverändert ins DAR schreiben
--	Schreibzugriff abschließen, das Datum steht noch in WB_LOAD_REG
				V_WPB_ADDR	:= ID_OLD_INSTRUCTION_REG(15 downto 12);
				V_WPB_EN	:= '1';
				V_MEM_DAR_EN	:= '1';
				V_MEM_DATA_REG_EN := '1';
				V_MEM_DnRW	:= '1'; --Schreibzugriff
				V_MEM_DEN	:= '1';				
				if ID_OLD_INSTRUCTION_REG(22) = '1' then --B-Bit
					--B war gesetzt -> Byte schreiben
					V_MEM_DMAS	:= DMAS_BYTE;
					V_TRUNCATE_ADDR := '0';
				else
					--B war nicht gesetzt -> Wort schreiben
					V_MEM_DMAS	:= DMAS_WORD;
-- 					Adresse auf naechst niedrige Wortgrenze setzen
					V_TRUNCATE_ADDR := '1';
				end if;	

--	Wartezustand, Warten verursacht durch eine Verzweigung im Instruktions-
--	fluss. Verzweigt das Programm tatsächlich, muss ein neuer Befehl
--	gefetcht werden. Wird die Verzweigung nicht ausgeführt, muss der
--	noch im Instruktionsregister stehende Befehl dekodiert werden.
--	In Wartezustaenden muessen NOPs in die Pipeline eingebracht werden, Never
--	als Bedingung erledigt das automatisch
-- 	Sorgt aber auch dafuer, dass nach einem Wartetakt CONDITION_MET nicht mehr 1 ist
-- 	und der Zustand wieder verlassen wird. Die Defaultzuweisungen der FSM sollten aber
-- 	bereits die Wirkung eines NV haben
--	Aber: bleibt das Bedingungsfeld erhalten, kann getestet werden, ob die verzweigende
--	Instruktion tatsaechlich ausgefuehrt wird und damit weiter gewartet wird
--	Besser: explizit das Dekodieren stoppen und dabei das Bedingungsfeld erhalten
			when STATE_WAIT_TO_FETCH =>	
-- 				V_IGNORE_LU_CONFLICT := true;
				V_FETCH_INST		:= '0';
				V_IEN			:= '0';
				V_IAR_INC		:= '0'; 
				V_ID_LNA_LOAD_REGLIST	:= '0';				
				V_ID_CONDITION		:= AL;	
				if CDC_CONDITION_MET = '0' then
--	Die Instruktion, die das Warten ausgeloest hat wird nicht beendet, die naechste, bereits im Instruktionsregister
--	befindliche Instruktion kann dekodiert werden
					V_IEN		:= '1';
					V_IAR_INC	:= '1';
					ARM_NEXT_STATE	<= STATE_DECODE;
				else
					if MAIN_DELAY_REG = 0 then
						V_IEN		:= '1';
						V_IAR_INC	:= '0';--'1';
						ARM_NEXT_STATE	<= STATE_FETCH;
					else
						V_IEN		:= '0';
						V_IAR_INC	:= '0'; -- im nächsten Takt PC inkrementieren
						ARM_NEXT_STATE	<= STATE_WAIT_TO_FETCH;
						MAIN_DELAY	<= MAIN_DELAY_REG - 1;
					end if;	
				end if;
-- 	Wartezustand bis das Datum im Instruktionsregister dekodiert werden soll. 
-- 	Beim Wechsel in den Zustand wird der PC nicht inkrementiert. Das Inkrement
-- 	erfolgt beim Verlassen des Zustands.
-- 	Im ersten Wartetakt kann der Zustand verlassen werden wenn eine 
-- 	Instruktionsbedingung nicht erfuellt ist, danach wird der Zustand
-- 	gehalten bis ein Zaehler heruntergezaehlt hat.
		
			when STATE_WAIT_TO_DECODE =>
-- 				V_IGNORE_LU_CONFLICT	:= true;
				V_ID_CONDITION		:= AL;	
				V_FETCH_INST 		:= '0';
				V_ID_LNA_LOAD_REGLIST	:= '0';
				if MAIN_DELAY_REG = 0 OR CDC_CONDITION_MET = '0' then
					V_IEN		:= '1';
					V_IAR_INC	:= '1'; 
					ARM_NEXT_STATE	<= STATE_DECODE;					
				else
					V_IEN		:= '0';
					V_IAR_INC	:= '0'; 
					ARM_NEXT_STATE	<= STATE_WAIT_TO_DECODE;
					MAIN_DELAY	<= MAIN_DELAY_REG - 1;
				end if;	

			when STATE_LDM =>
-- 				V_IGNORE_LU_CONFLICT := true;
				V_TRUNCATE_ADDR		:= '1';
				ARM_NEXT_STATE		<= STATE_LDM;
				V_FETCH_INST		:= '0';
				V_IEN			:= '0';
				V_IAR_INC		:= '0';
				V_IF_LDMSTM_MUX_CTRL	:= '1'; --Registerliste mit dem Wert aus dem Instruktionsregister aktualisieren
				V_ID_CONDITION		:= ID_OLD_INSTRUCTION_REG(31 downto 28);
				V_ID_HOLD_OLD_INSTRUCTION_REG := '1';
				V_ID_LNA_LOAD_REGLIST	:= '0'; V_ID_LNA_HOLD_VALUE := '0';
				-- Adressregister permanent inkrementieren
				if MAIN_DELAY = 0 then 
					V_MEM_DAR_INC		:= '1';
					V_MEM_DAR_EN		:= '1';
				end if;
				MAIN_DELAY		<= 0;
				V_MEM_DEN		:= '1';
				V_MEM_DMAS		:= DMAS_WORD;
				-- Nur Rn wird, ggf. ueber Port A zurueckgeschrieben, ist immer der gleiche Teil der Instruktion
				V_WPA_ADDR		:= ID_OLD_INSTRUCTION_REG(19 downto 16);
				-- Das jeweils zu lesende Register (STM) ist durch die aktuelle Registerliste bestimmt
				V_RPC_ADDR		:= ID_LNA_ADDRESS;
				-- gleiches gilt für das jeweils zu schreibende Register (LDM)
				V_WPB_ADDR		:= ID_LNA_ADDRESS;
				V_MEM_DATA_REG_EN	:= '1';
				V_WB_IAR_MUX_CTRL	:= '1';
				V_WB_LOAD_REG_EN	:= '0';
				V_WPA_EN		:= '0';
				V_WPB_EN		:= '0';
				

--		Verhalten im Abbruchfall, tritt prinzipiell im ersten Takt in diesem Zustand auf
--		Es muss nach DECODE zurückgekehrt werden, gleichzeitig ist aber der LDM-Dekoder bereits
--		mit dem niederwertigen Halbwort des Instruktionsregister zu setzen
-- 		Die diversen Enablesignale muessen nicht explizit ausgeschaltet werden, da fuer
-- 		diesen Zyklus noch immer die selbe nicht erfuellte Bedingung gilt
-- 		und der Speicherzugriff daher zum NOP wird.		
				if CDC_CONDITION_MET = '0' then 
					ARM_NEXT_STATE		<= STATE_DECODE;				
					V_ID_LNA_LOAD_REGLIST	:= '1';
					V_IEN			:= '1';
					V_IAR_INC		:= '1';
				else
					if L_OLD = '1' then
						-- LDM
						V_MEM_DnRW	:= '0';
-- 						Register des USER-Modus: PC nicht in der Registerliste, S gesetzt, Verhalten bei gleichzeitig
-- 						spezifiziertem W-Bit ist nicht vorgegeben.
						if ID_OLD_INSTRUCTION_REG(15) = '0' and S_LDM_OLD = '1' then
							V_WB_USER_REGS := "10";							
						else
							V_WB_USER_REGS := "00";
						end if;	

						if RBA_NR_OF_REGS(4 downto 1) = "0000" then -- noch 0 oder 1 Wort zu laden
-- 	Nur wenn noch 1 Register zu laden ist, muss ein Wort
-- 	entgegengenommen werden.
-- 							Der Pfad der aktualisierten Basisadresse wird aktiviert, ggf.
-- 							wird sie aueber WPA in den Registerspeicher geschrieben.
							V_WB_RES_REG_EN := '1';
							V_WB_LOAD_REG_EN	:= RBA_NR_OF_REGS(0);
							V_WPB_EN		:= RBA_NR_OF_REGS(0);
							V_MEM_DEN		:= RBA_NR_OF_REGS(0);
-- 	Beim Verlassen des Zustandes den Registerliste im entsprechenden Modul aus dem Instruktionsregister
-- 	erneuern.	
							V_ID_LNA_LOAD_REGLIST	:= '1';
-- 	Im letzten Zyklus wird der aktualisierte Basiswert zurueckgeschrieben wenn das W-Bit der Instruktion
-- 	gesetzt ist. Das Verhalten bei gleichzeitig gesetztem S-Bit ist nicht spezifiziert, in dieser
-- 	Implementierung unterdrueckt dies ersteinmal das Rueckschreiben.	
--	WPA wird aktiviert wenn das W-Bit gesetzt ist und das S-Bit nicht gesetzt ist. Es wird genau dann trotzdem zurueckgeschrieben, wenn neben dem gesetzten S-Bit der PC in der Registerliste ist weil dann nicht die USER-Register verwendet werden.						
							V_WPA_EN		:= W_OLD and ((not S_LDM_OLD) or ID_OLD_INSTRUCTION_REG(15));

							if ID_OLD_INSTRUCTION_REG(15) = '1' then --PC wird als letztes Beschrieben -> Sprung
--	Sprung, ggf. auch Moduswechsel und Rueckschreiben der Basisadresse, keine Verwendung der Userregister
								ARM_NEXT_STATE	<= STATE_WAIT_TO_FETCH;
								V_WB_IAR_LOAD	:= '1';
								MAIN_DELAY	<= 2;
								if S_LDM_OLD = '1' then
--									Ruecksprung mit gesetztem S-Bit: Exception-Return
									V_WB_PSR_EN := '1'; V_WB_PSR_ER := '1';
								end if;
-- 	Nach der Spec kann folgende Unterscheidung weggelassen werden:
-- 								if ID_OLD_INSTRUCTION_REG(21) = '1' AND V_WPA_ADDR = R15 then	
--	Rueckschreiben dominiert und veruarsacht seinerseits einen sprung, IAR muss entsprechend aktualisiert werden
-- 									V_WB_RES_REG_EN := '1';
-- 									V_WPA_EN := '1';
-- 									V_WB_IAR_MUX_CTRL := '0';
-- 								elsif W_OLD = '1' then
--	Sprung und Rueckschreiben werden parallel durchgefuehrt, in das IAR wird das geladene Datum geschrieben, selbst wenn
-- 	R15 illegal als Rn mit Rueckschreiben verwendet wurde.
-- 									V_WPA_EN := '1';
-- 									V_WB_IAR_MUX_CTRL := '1'; --hier stand 0, ist falsch
-- 								else	
-- 									V_WB_IAR_MUX_CTRL := '1';
									
-- 								end if;	

							else
								ARM_NEXT_STATE <= STATE_DECODE; --STATE_WAIT_TO_DECODE;
								V_IEN := '1';
								V_IAR_INC := '1';
--	kein Sprung, einfach letztes Register beschreiben
--	R15 als Rn darf nicht verwendet werden und wird hier dazu führen, dass IAR und PC einen Takt lang
--	nicht synchron sind. Ein nachfolgender Sprungbefehl wird daher relativ zu Rn springen
-- 								if ID_OLD_INSTRUCTION_REG(22) = '1' then --S gesetzt
--	Schreiben in USER-Mode, nachfolgende Instruktionen müssen nicht mehr verzoegert werden, kein Rueckschreiben von Rn spezifiziert
-- 									V_WB_USER_REGS := "10";
-- 								else
-- 									V_WB_RES_REG_EN := W_OLD;
-- 									V_WPA_EN	:= W_OLD;							
-- 								end if;								
							end if;

						else
--						Noch mehr als ein Wort zu laden
							V_WB_LOAD_REG_EN := '1';
							V_WPB_EN := '1';
							ARM_NEXT_STATE <= STATE_LDM;
						end if;

-- 						if ID_OLD_INSTRUCTION_REG(22) = '1' and ID_OLD_INSTRUCTION_REG(15) = '0' and RBA_NR_OF_REGS /= "00000" then
-- 							-- es wird dann in die USER-Register geschrieben, wenn das S-Bit gesetzt ist, der PC
-- 							-- in dem Fall darf Rn nicht zurueckgeschrieben werden
-- 							MAIN_DELAY <= 2;
-- 							V_WB_USER_REGS := "10";
-- 							V_WPA_EN := '0';
-- 
-- 						end if;


					else
						--STM					
-- 						MEM_DATA_REG ist als Default oben schon aktiviert worden
						V_MEM_DnRW		:= '1';
						V_MEM_DEN		:= '1';
						if RBA_NR_OF_REGS(4 downto 1) = "0000" then -- noch 0 oder 1 Wort zu uebertragen
--	Noch ein Register zu speichern, Gelegenheit bei Bedarf das Rueckschreiben von Rn
--	einzuleiten, das die ganze Zeit in MEM_RES_REG gehalten worden ist.
							ARM_NEXT_STATE		<= STATE_DECODE;
							V_ID_LNA_LOAD_REGLIST	:= '1';
							V_IEN			:= '1';
							V_IAR_INC		:= '1';
							V_WB_RES_REG_EN		:= '1';
--	Ob der Speicher noch einmal aktiviert wird haengt davon ob, ob noch ein Datum zu
-- 	uebertragen oder nur die Basisadresse zurueckzuschreiben ist						
							V_MEM_DEN := RBA_NR_OF_REGS(0);
-- 	Rueckschreiben der modifizierten Basisadresse sofern im Befehl das W-Bit aber nicht das S-Bit gesetzt war						
							V_WPA_EN	:= W_OLD and not S_LDM_OLD;
						else
--	mehr als ein Register zu schreiben, das korrekte Register wird bereits gelesen, der Speicher ist
--	aktiv, DAR inkrementiert sowieso in jedem Takt
							ARM_NEXT_STATE <= STATE_LDM;								
						end if;

						if S_LDM_OLD = '1' then --S-Bit
--	Das Ueber Port C gelesene Datum bezieht sich auf die USER-Modus Register.
-- 	Das gleichzeitige Rueckschreiben der Basisadresse ist in der ISA
-- 	nicht vorgesehen und kann fuer eine sicherere Implementierung unterdrueckt werden.						
							V_ID_USER_REGS := "100";
-- 							V_WPA_EN := '0';
						end if;
					end if;				
					
				end if;

--	DAR wird inkrementiert bis CHS = LAST oder ein Abort auftritt,
--	vorausgesetzt CDC_CONDITION ist erfuellt.	
--	Im Datenpfad muessen keine weiteren Operationen neben dem Inkrement
--	des DAR durchgefuehrt werden
--	Die Speichersignale duerfen unbedingt gesetzt werden, ist ihre Bedingung
--	nicht erfuellt werden sie ohnehin invalidiert
			when STATE_LDC =>
-- 				V_IGNORE_LU_CONFLICT := true;
				V_TRUNCATE_ADDR	:= '1';
				V_IEN		:= '0';
				V_IAR_INC	:= '0';
				V_MEM_DnRW	:= not ID_OLD_INSTRUCTION_REG(20);
				V_MEM_DEN	:= '1';
				V_MEM_DAR_EN	:= '1';
				V_MEM_DAR_INC	:= '1';
				V_FETCH_INST	:= '0';
				V_EX_PASS_REG	:= '1';
				V_ID_HOLD_OLD_INSTRUCTION_REG := '1';
				V_ID_CONDITION := ID_OLD_INSTRUCTION_REG(31 downto 28);
				if CDC_CONDITION_MET='1' and (CPA_ID_CHS = CHS_GO) then
					ARM_NEXT_STATE	<= STATE_LDC;				
					V_IEN		:= '0';
				else -- Bedingung nicht erfuellt oder LAST/ABSENT/WAIT
					ARM_NEXT_STATE	<= STATE_DECODE;
					V_IEN		:= '1'; --Speicher im naechsten Takt wieder aktivieren
				end if;
			when others => 
				null;					
		end case;


	end if;

 
		IF_LDMSTM_MUX_CTRL		<= V_IF_LDMSTM_MUX_CTRL;
		ID_CONDITION_FIELD 		<= V_ID_CONDITION;
		ID_IMMEDIATE			<= V_ID_IMMEDIATE;
		ID_LNA_LOAD_REGLIST		<= V_ID_LNA_LOAD_REGLIST;
		ID_LNA_HOLD_VALUE		<= V_ID_LNA_HOLD_VALUE;
		ID_HOLD_OLD_INSTRUCTION_REG	<= V_ID_HOLD_OLD_INSTRUCTION_REG;
		ID_MASK_FIQ			<= V_ID_MASK_FIQ;
		ID_MASK_IRQ			<= V_ID_MASK_IRQ;
		ID_DPA_ENABLE			<= V_DPA_ENABLE;
		IF_FETCH_INSTRUCTION 		<= V_FETCH_INST;
		IF_IEN				<= V_IEN;

		ID_INST_ID_PASS_MUX_CTRL	<= V_ID_INST_ID_PASS_MUX_CTRL;

--		if USE_SPECIAL_ADDRESS_FOR_UNUSED_PORT then
--			ID_REF_R_PORTS_ADDR 		<=	GET_INTERNAL_ADDRESS(V_RPC_ADDR,ID_MODE_MUX,V_ID_USER_REGS(2),V_ADDR_USED(2)) & 
--				   				GET_INTERNAL_ADDRESS(V_RPB_ADDR,ID_MODE_MUX,V_ID_USER_REGS(1),V_ADDR_USED(1)) & 
--								GET_INTERNAL_ADDRESS(V_RPA_ADDR,ID_MODE_MUX,V_ID_USER_REGS(0),V_ADDR_USED(0));
--		else
--			ID_REF_R_PORTS_ADDR 		<=	GET_INTERNAL_ADDRESS(V_RPC_ADDR,ID_MODE_MUX,V_ID_USER_REGS(2),true) & 
--				   				GET_INTERNAL_ADDRESS(V_RPB_ADDR,ID_MODE_MUX,V_ID_USER_REGS(1),true) & 
--								GET_INTERNAL_ADDRESS(V_RPA_ADDR,ID_MODE_MUX,V_ID_USER_REGS(0),true);
--		end if;
		ID_REF_R_PORTS_ADDR 		<=	GET_INTERNAL_ADDRESS(V_RPC_ADDR,ID_MODE_MUX,V_ID_USER_REGS(2)) & 
							GET_INTERNAL_ADDRESS(V_RPB_ADDR,ID_MODE_MUX,V_ID_USER_REGS(1)) & 
							GET_INTERNAL_ADDRESS(V_RPA_ADDR,ID_MODE_MUX,V_ID_USER_REGS(0));
		ID_REGS_USED			<= boolToSl(V_ADDR_USED(2)) & boolToSl(V_ADDR_USED(1)) & boolToSL(V_ADDR_USED(0));
-- 		CPA_ID_PSR_READ_SPSR		<= V_EX_PSR_MUX_CTRL;
		
		CPA_ID_IAR_REVOKE		<= V_ID_IAR_REVOKE;
		CPA_ID_IAR_HISTORY_ID		<= V_ID_IAR_HISTORY_ID;
		ID_EX_OPB_ALU_MUX_CTRL 		<= V_OPB_ALU_MCTRL;
		ID_EX_PSR_CC_MUX_CTRL 		<= V_PSR_CC_MCTRL;
	       	ID_EX_DAR_MUX_CTRL 		<= V_DAR_MCTRL;

		ID_EX_ALU_CTRL 			<= V_ALU_CTRL;
		ID_SHIFT_AMOUNT			<= V_SHIFT_CTRL.SHIFT_CTRL_AMOUNT;
		EX_SHIFT_EX_CTRL(0)		<= (V_SHIFT_CTRL.SHIFT_CTRL_TYPE,V_SHIFT_CTRL.SHIFT_CTRL_RRX);
		ID_SHIFT_MUX_CTRL 		<= V_SHIFT_CTRL.SHIFT_CTRL_OPC;
		ID_EX_ALU_CTRL			<= V_ALU_CTRL;
		CPA_EX_PASS_REG(0)		<= V_EX_PASS_REG;
		EX_FBRANCH_MUX_CTRL(0)		<= V_EX_BRANCH_MCTRL;

		ID_MEM_DATA_REG_EN		<= V_MEM_DATA_REG_EN; 
		ID_MEM_RES_REG_EN		<= V_MEM_RES_REG_EN; 
		ID_MEM_CC_REG_EN		<= V_MEM_CC_REG_EN; 
		ID_MEM_BASE_REG_EN		<= V_MEM_BASE_REG_EN;
		ID_MEM_DAR_EN			<= V_MEM_DAR_EN;
		ID_MEM_DAR_INC			<= V_MEM_DAR_INC; 
		MEM_TRUNCATE_ADDR(0)		<= V_TRUNCATE_ADDR;
		MEM_WMP_CTRL(0)			<= V_MEM_WMP_SIGNED;
		MEM_CC_MUX_CTRL_REG(0)		<= V_MEM_CC_MUX_CTRL_REG;

		WB_REF_W_PORTS_ADDR(0)		<=	GET_INTERNAL_ADDRESS(V_WPB_ADDR,ID_MODE_MUX,V_WB_USER_REGS(1)) & 
			     				GET_INTERNAL_ADDRESS(V_WPA_ADDR,ID_MODE_MUX,V_WB_USER_REGS(0));
		ID_REF_W_PORT_A_EN 		<= V_WPA_EN;
		ID_REF_W_PORT_B_EN 		<= V_WPB_EN;
		IF_IAR_INC 			<= V_IAR_INC;
		ID_MEM_DnRW 			<= V_MEM_DnRW; 
		ID_MEM_DEN 			<= V_MEM_DEN; 
		MEM_DMAS(0) 			<= V_MEM_DMAS;
		ID_OPB_MUX_CTRL 		<= V_ID_OPB_MUX_CTRL;
		ID_WB_LOAD_REG_EN 		<= V_WB_LOAD_REG_EN;
		ID_WB_RES_REG_EN 		<= V_WB_RES_REG_EN;
		ID_WB_CC_REG_EN 		<= V_WB_CC_REG_EN;
		ID_WB_PSR_EN 			<= V_WB_PSR_EN;
		WB_PSR_CTRL(0)			<= (EXC_ENTRY => V_WB_PSR_EE, EXC_RETURN => V_WB_PSR_ER, SET_CC => V_WB_PSR_SET_CC, WRITE_SPSR => V_WB_PSR_WRITE_SPSR, MASK => V_WB_PSR_MASK, MODE => V_WB_PSR_MODE);
		ID_WB_IAR_MUX_CTRL		<= V_WB_IAR_MUX_CTRL;
		ID_WB_IAR_LOAD			<= V_WB_IAR_LOAD;
		EX_PSR_MUX_CTRL(0)		<= V_EX_PSR_MUX_CTRL;
		EX_OPA_PSR_MUX_CTRL(0)		<= V_EX_OPA_PSR_MUX_CTRL;
	end process ARM_MAIN_CTRL_SIGNALS;


--------------------------------------------------------------------------------
--	Tests und Signale für die Simulation
--------------------------------------------------------------------------------
-- synthesis translate_off

	AGP_REF_R_PORT_A_ADDR	<= ID_REF_R_PORTS_ADDR(3 downto 0);
	AGP_REF_R_PORT_B_ADDR	<= ID_REF_R_PORTS_ADDR(7 downto 4);
	AGP_REF_R_PORT_C_ADDR	<= ID_REF_R_PORTS_ADDR(11 downto 8);
	AGP_OPA_BYPASS_MUX_CTRL <= EX_OPX_MUX_CTRLS(1)(1 downto 0);
	AGP_OPB_BYPASS_MUX_CTRL <= EX_OPX_MUX_CTRLS(1)(3 downto 2);
	AGP_OPC_BYPASS_MUX_CTRL <= EX_OPX_MUX_CTRLS(1)(5 downto 4);
	AGP_CC_BYPASS_MUX_CTRL	<= ID_EX_CC_MUX_CTRL;
	AGP_INSTRUCTION_REG	<= ID_INSTRUCTION_REG;
	AGP_DECODED_INSTRUCTION <= CID_DECODED_VECTOR;
	AGP_CURRENT_REGLIST	<= LNA_CURRENT_REGLIST_REG;
	AGP_NR_OF_REGS		<= RBA_NR_OF_REGS;
	AGP_REF_W_PORT_A_EN	<= WB_REF_W_PORT_A_EN_REG;
	AGP_REF_W_PORT_B_EN	<= WB_REF_W_PORT_B_EN_REG;
	AGP_CONDITION_MET	<= CDC_CONDITION_MET;
	AGP_LOAD_USE_CONFLICT	<= ID_LOAD_USE_CONFLICT;
	AGP_FIQ_FILTERED	<= ID_FIQ_FILTERED;
	AGP_IRQ_FILTERED	<= ID_IRQ_FILTERED;
	AGP_PABORT_FILTERED	<= ID_PABORT_FILTERED;
	AGP_FETCH_INSTRUCTION	<= IF_FETCH_INSTRUCTION;
	AGP_INST_ID_REGISTER	<= INSTRUCTION_ID_REGISTER;

-- synthesis translate_on
--------------------------------------------------------------------------------


end architecture behave;
