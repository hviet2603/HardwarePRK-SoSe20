--------------------------------------------------------------------------------
--	Prozessorkern des ARM-SoC
--------------------------------------------------------------------------------
--	Datum:		04.07.2010
--	Version:	1.01
--------------------------------------------------------------------------------
--	Aenderungen:
--	DPA_ENABLE hinzugefuegt, dass CPA_DPA_ENABLE und CORE_nWAIT fuer das
--	stoppen des Datenpfades beruecksichtigt, Wartesignale koennen
--	mit der globalen Konstanten DISABLE_BUS_nWAIT fest auf 1 gesetzt werden.
--	Anmerkung: die Verwendung eines gemeinsamen Wartesignals ist
--	eher ungluecklich, da selbst dann, wenn nur auf eine neue Instruktion
--	gewartet wird, die Beendigung laufender Instruktionen unterbrochen ist.

-- 	Einfuehrung eines zweiten Modusausgangs
-- 	Aufgrund der STRT, LDRT usw. Instruktionen muss fuer Datenzugriffe
-- 	ein eigener Modusausgang existieren. Ausserdem ist zukuenftig
-- 	darauf zu achten, dass beim Wechsel des Betriebsmodus schon waehrend
-- 	des ersten Fetch der korrekte neue Modus angezeigt wird.
--	Aus Konsistenzgruenden (alle Steuersignale highaktiv) das Wartesignal
--	nWait in Wait umbenannt und die Funktionsweise entsprechend umgekehrt.

--	Code eines NoC-Coprozessors entfernt, da er im HWPR nicht verwendet
--	wird.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.all;
use work.ArmConfiguration.all;
use work.ArmGlobalProbes.all;

entity ArmCore is
    Port (
	CORE_CLK 	: in  std_logic;
    	CORE_INV_CLK	: in std_logic;
	CORE_RST 	: in  std_logic;
--	weitere Steuersignale
    	CORE_WAIT 	: in std_logic;
--    	Instruktionsbus
    	CORE_IBE	: in std_logic;
    	CORE_IEN	: out std_logic;
	CORE_IA 	: out std_logic_vector(31 downto 2);
	CORE_ID 	: in std_logic_vector(31 downto 0);
	CORE_IABORT 	: in std_logic;			
--    	Datenbus
	CORE_DA 	: out std_logic_vector(31 downto 0);
	CORE_DDOUT 	: out std_logic_vector(31 downto 0);
	CORE_DDIN 	: in std_logic_vector(31 downto 0);
    	CORE_DMAS	: out std_logic_vector(1 downto 0);
    	CORE_DnRW	: out std_logic;
    	CORE_DABORT	: in std_logic;
    	CORE_DEN	: out std_logic;
    	CORE_DBE	: in std_logic;
--    	Interruptschnittstelle
	CORE_FIQ	: in std_logic;
    	CORE_IRQ	: in std_logic;
--	Modusausgaenge von Instruktions- und Datenbus
	CORE_IMODE	: out std_logic_vector(4 downto 0);
	CORE_DMODE	: out std_logic_vector(4 downto 0)
   );
end entity ArmCore;

architecture BEHAVE of ArmCore is

	signal CORE_WAIT_MODIFIED		: std_logic;
--	Signale vom Datenpfad zum Kontrollpfad
	signal CPA_DPA_ENABLE			: std_logic;
	signal CPA_WAIT				: std_logic;
	
	signal CPA_IF_IEN			: std_logic;
	signal CPA_IF_IAR_INC			: std_logic;
	signal CPA_IF_IAR_UPDATE_HB		: std_logic;
	signal CPA_IF_FETCH			: std_logic;
	signal CPA_ID_IAR_REVOKE		: std_logic;
	signal CPA_ID_IAR_HISTORY_ID		: std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
	signal CPA_ID_REF_R_PORTS_ADDR		: std_logic_vector(14 downto 0);
	signal CPA_ID_IMMEDIATE			: std_logic_vector(31 downto 0);
	signal CPA_ID_SHIFT_AMOUNT		: std_logic_vector(5 downto 0);
	signal CPA_ID_OPB_MUX_CTRL 		: std_logic;
	signal CPA_ID_SHIFT_MUX_CTRL 		: std_logic;
	signal CPA_ID_CHS			: COPROCESSOR_HANDSHAKE_TYPE;

	signal CPA_EX_OPX_MUX_CTRLS		: std_logic_vector(5 downto 0);
	signal CPA_EX_SHIFT_MUX_CTRL 		: std_logic_vector(1 downto 0); 
	signal CPA_EX_CC_MUX_CTRL		: std_logic_vector(1 downto 0);

	signal CPA_EX_OPB_ALU_MUX_CTRL		: std_logic;
	signal CPA_EX_PSR_CC_MUX_CTRL		: std_logic;
	signal CPA_EX_DAR_MUX_CTRL		: std_logic;

	signal CPA_EX_SHIFT_TYPE		: std_logic_vector(1 downto 0);
	signal CPA_EX_SHIFT_RRX			: std_logic;
	signal CPA_EX_ALU_CTRL			: std_logic_vector(3 downto 0);
	signal CPA_EX_DRP_DMAS			: std_logic_vector(1 downto 0);
	signal CPA_EX_PASS			: std_logic;
	signal CPA_EX_DAR_EN			: std_logic;
	signal CPA_EX_DAR_INC			: std_logic;

	signal CPA_MEM_DATA_REG_EN		: std_logic;
	signal CPA_MEM_RES_REG_EN		: std_logic;
	signal CPA_MEM_CC_REG_EN		: std_logic;
	signal CPA_MEM_BASE_MUX_CTRL		: std_logic;
	signal CPA_MEM_BASE_REG_EN		: std_logic;
	signal CPA_MEM_WMP_SIGNED		: std_logic;
	signal CPA_MEM_TRUNCATE_ADDR		: std_logic;
	signal CPA_MEM_CC_MUX_CTRL		: std_logic;
	signal CPA_MEM_PASS			: std_logic;

	signal CPA_WB_REF_W_PORT_A_EN		: std_logic;
	signal CPA_WB_REF_W_PORT_B_EN		: std_logic;
	signal CPA_WB_REF_W_PORTS_ADDR		: std_logic_vector(9 downto 0);
	signal CPA_WB_LOAD_REG_EN		: std_logic; 	
	signal CPA_WB_RES_REG_EN		: std_logic;	
	signal CPA_WB_CC_REG_EN			: std_logic; 	
	signal CPA_WB_PSR_EN			: std_logic;		
	signal CPA_WB_IAR_MUX_CTRL		: std_logic;	
	signal CPA_WB_IAR_LOAD			: std_logic;		
	signal CPA_WB_PSR_CTRL			: PSR_CTRL_TYPE;
	signal CPA_WB_FBRANCH_MUX_CTRL		: std_logic;
	
	signal DPA_ENABLE			: std_logic;
	signal DPA_IF_IA			: std_logic_vector(31 downto 2);

	signal DPA_MEM_DDOUT, DPA_MEM_DDIN	: std_logic_vector(31 downto 0);
	signal DPA_MEM_DA			: std_logic_vector(31 downto 0);
	signal CPA_MEM_DnRW			: std_logic;
	signal CPA_MEM_DMAS 			: std_logic_vector(1 downto 0);
	signal CPA_MEM_DEN			: std_logic;
	signal CORE_IMODE_SIG, CORE_DMODE_SIG : MODE;

	signal CPA_EX_CPSR			: std_logic_vector(31 downto 0);
	signal CPA_EX_OPA_PSR_MUX_CTRL		: std_logic;
	signal CPA_EX_PSR_MUX_CTRL		: std_logic;
begin


	CORE_IEN	<= CPA_IF_IEN;
	CORE_IMODE	<= CORE_IMODE_SIG;
	CORE_DMODE	<= CORE_DMODE_SIG;

	DPA_MEM_DDIN	<= CORE_DDIN;
	CORE_DDOUT	<= DPA_MEM_DDOUT when CORE_DBE = '1' else (others => 'Z');
	CPA_ID_CHS	<= CHS_ABSENT;

	CORE_WAIT_MODIFIED <=  CORE_WAIT or (CPA_MEM_DEN and not CORE_DBE) or (CPA_IF_IEN and not CORE_IBE);

	DPA_ENABLE	<= '1' when DISABLE_BUS_WAIT else (CPA_DPA_ENABLE and (not CORE_WAIT_MODIFIED));
	CPA_WAIT	<= '0' when DISABLE_BUS_WAIT else CORE_WAIT_MODIFIED;
--	Prozessorkern treibt Bussignale nur, wenn er den Buszugriff hat	
	CORE_IA		<= DPA_IF_IA when CORE_IBE = '1' else (others => 'Z');
	CORE_DA		<= DPA_MEM_DA when CORE_DBE = '1' else (others => 'Z');
	CORE_DnRW	<= CPA_MEM_DnRW when CORE_DBE = '1' else 'Z';
	CORE_DMAS	<= CPA_MEM_DMAS when CORE_DBE = '1' else "ZZ";
	CORE_DEN	<= CPA_MEM_DEN;

	ArmControlPath: entity WORK.ArmControlPath(BEHAVE)
	port map(
		CPA_CLK				=> CORE_CLK,
		CPA_RST				=> CORE_RST,
		CPA_IRQ				=> CORE_IRQ,
		CPA_FIQ				=> CORE_FIQ,
		CPA_WAIT			=> CPA_WAIT,
		CPA_DPA_ENABLE			=> CPA_DPA_ENABLE,		
		CPA_IF_ID			=> CORE_ID,
		CPA_IF_IABORT			=> CORE_IABORT,
		CPA_IF_IEN			=> CPA_IF_IEN, 
		CPA_IF_IBE			=> CORE_IBE,
		CPA_IF_FETCH			=> CPA_IF_FETCH,
		CPA_IF_IMODE			=> CORE_IMODE_SIG,
		CPA_IF_IAR_INC			=> CPA_IF_IAR_INC,
		CPA_IF_IAR_UPDATE_HB		=> CPA_IF_IAR_UPDATE_HB,

		CPA_EX_CPSR			=> CPA_EX_CPSR,
		CPA_ID_IAR_REVOKE		=> CPA_ID_IAR_REVOKE,
		CPA_ID_IAR_HISTORY_ID		=> CPA_ID_IAR_HISTORY_ID,
		CPA_ID_REF_R_PORTS_ADDR 	=> CPA_ID_REF_R_PORTS_ADDR,		
		CPA_ID_IMMEDIATE		=> CPA_ID_IMMEDIATE,		
		CPA_ID_SHIFT_AMOUNT		=> CPA_ID_SHIFT_AMOUNT,		
		CPA_ID_OPB_MUX_CTRL 		=> CPA_ID_OPB_MUX_CTRL,		
		CPA_ID_SHIFT_MUX_CTRL 		=> CPA_ID_SHIFT_MUX_CTRL,		
		CPA_ID_CHS			=> CPA_ID_CHS,

		CPA_EX_OPA_PSR_MUX_CTRL		=> CPA_EX_OPA_PSR_MUX_CTRL,
		CPA_EX_PSR_MUX_CTRL		=> CPA_EX_PSR_MUX_CTRL,
		CPA_EX_OPX_MUX_CTRLS		=> CPA_EX_OPX_MUX_CTRLS,
		CPA_EX_SHIFT_MUX_CTRL		=> CPA_EX_SHIFT_MUX_CTRL,
		CPA_EX_CC_MUX_CTRL		=> CPA_EX_CC_MUX_CTRL,		

		CPA_EX_OPB_ALU_MUX_CTRL		=> CPA_EX_OPB_ALU_MUX_CTRL,		
		CPA_EX_PSR_CC_MUX_CTRL		=> CPA_EX_PSR_CC_MUX_CTRL,		
		CPA_EX_DAR_MUX_CTRL		=> CPA_EX_DAR_MUX_CTRL,		

		CPA_EX_SHIFT_TYPE		=> CPA_EX_SHIFT_TYPE,		
		CPA_EX_SHIFT_RRX		=> CPA_EX_SHIFT_RRX,		
		CPA_EX_ALU_CTRL			=> CPA_EX_ALU_CTRL,		
		CPA_EX_DRP_DMAS			=> CPA_EX_DRP_DMAS,		
		CPA_EX_DAR_EN			=> CPA_EX_DAR_EN,		
		CPA_EX_DAR_INC			=> CPA_EX_DAR_INC,		
		CPA_EX_PASS 			=> CPA_EX_PASS,

		CPA_MEM_DnRW			=> CPA_MEM_DnRW,
		CPA_MEM_DEN			=> CPA_MEM_DEN,
		CPA_MEM_DABORT			=> CORE_DABORT,
		CPA_MEM_DBE			=> CORE_DBE,
		CPA_MEM_DMAS			=> CPA_MEM_DMAS,
		CPA_MEM_DMODE			=> CORE_DMODE_SIG,
		CPA_MEM_PASS			=> CPA_MEM_PASS,
		CPA_MEM_DATA_REG_EN		=> CPA_MEM_DATA_REG_EN,		
		CPA_MEM_RES_REG_EN		=> CPA_MEM_RES_REG_EN,		
		CPA_MEM_CC_REG_EN		=> CPA_MEM_CC_REG_EN,		
		CPA_MEM_BASE_MUX_CTRL		=> CPA_MEM_BASE_MUX_CTRL,
		CPA_MEM_BASE_REG_EN		=> CPA_MEM_BASE_REG_EN,
		CPA_MEM_WMP_SIGNED		=> CPA_MEM_WMP_SIGNED,		
		CPA_MEM_TRUNCATE_ADDR		=> CPA_MEM_TRUNCATE_ADDR,
		CPA_MEM_CC_MUX_CTRL		=> CPA_MEM_CC_MUX_CTRL,

		CPA_WB_REF_W_PORT_A_EN		=> CPA_WB_REF_W_PORT_A_EN,		
		CPA_WB_REF_W_PORT_B_EN		=> CPA_WB_REF_W_PORT_B_EN,		
		CPA_WB_REF_W_PORTS_ADDR		=> CPA_WB_REF_W_PORTS_ADDR,		
		CPA_WB_LOAD_REG_EN		=> CPA_WB_LOAD_REG_EN,		
		CPA_WB_RES_REG_EN		=> CPA_WB_RES_REG_EN,		
		CPA_WB_CC_REG_EN		=> CPA_WB_CC_REG_EN,		
		CPA_WB_PSR_EN			=> CPA_WB_PSR_EN,		
		CPA_WB_PSR_CTRL			=> CPA_WB_PSR_CTRL,
		CPA_WB_IAR_MUX_CTRL		=> CPA_WB_IAR_MUX_CTRL,		
		CPA_WB_IAR_LOAD			=> CPA_WB_IAR_LOAD,
		CPA_WB_FBRANCH_MUX_CTRL		=> CPA_WB_FBRANCH_MUX_CTRL	
	);


	ArmDataPath: entity work.ArmDataPath(STRUCTURE) 
	port map(
		DPA_CLK 			=> CORE_CLK,
		DPA_INV_CLK			=> CORE_INV_CLK,
		DPA_RST 			=> CORE_RST,
		DPA_ENABLE			=> DPA_ENABLE,		
		DPA_IF_IAR_INC			=> CPA_IF_IAR_INC,
		DPA_IF_IAR_UPDATE_HB		=> CPA_IF_IAR_UPDATE_HB,
		DPA_IF_IA			=> DPA_IF_IA,
		DPA_ID_IAR_REVOKE		=> CPA_ID_IAR_REVOKE,
		DPA_ID_IAR_HISTORY_ID		=> CPA_ID_IAR_HISTORY_ID,
		DPA_ID_REF_R_PORTS_ADDR 	=> CPA_ID_REF_R_PORTS_ADDR,
		DPA_ID_IMMEDIATE		=> CPA_ID_IMMEDIATE,
		DPA_ID_SHIFT_AMOUNT		=> CPA_ID_SHIFT_AMOUNT,
		DPA_ID_OPB_MUX_CTRL 		=> CPA_ID_OPB_MUX_CTRL,
		DPA_ID_SHIFT_MUX_CTRL 		=> CPA_ID_SHIFT_MUX_CTRL,

		DPA_EX_CPSR			=> CPA_EX_CPSR,
		DPA_EX_OPA_REG_EN 		=> '1',--CPA_EX_OPA_REG_EN,
		DPA_EX_OPB_REG_EN 		=> '1',--CPA_EX_OPB_REG_EN,
		DPA_EX_OPC_REG_EN 		=> '1',--CPA_EX_OPC_REG_EN,		
		DPA_EX_SHIFT_REG_EN 		=> '1',
		DPA_EX_OPA_PSR_MUX_CTRL		=> CPA_EX_OPA_PSR_MUX_CTRL,
		DPA_EX_PSR_MUX_CTRL		=> CPA_EX_PSR_MUX_CTRL,

		DPA_EX_OPX_MUX_CTRLS		=> CPA_EX_OPX_MUX_CTRLS,
		DPA_EX_SHIFT_MUX_CTRL		=> CPA_EX_SHIFT_MUX_CTRL,
		DPA_EX_CC_MUX_CTRL		=> CPA_EX_CC_MUX_CTRL,

		DPA_EX_OPB_ALU_MUX_CTRL		=> CPA_EX_OPB_ALU_MUX_CTRL,
		DPA_EX_DAR_MUX_CTRL		=> CPA_EX_DAR_MUX_CTRL,
		DPA_EX_PSR_CC_MUX_CTRL		=> CPA_EX_PSR_CC_MUX_CTRL,

		DPA_EX_SHIFT_TYPE		=> CPA_EX_SHIFT_TYPE,
		DPA_EX_SHIFT_RRX		=> CPA_EX_SHIFT_RRX,
		DPA_EX_ALU_CTRL			=> CPA_EX_ALU_CTRL,
		DPA_EX_DRP_DMAS			=> CPA_EX_DRP_DMAS,
		DPA_EX_DAR_EN			=> CPA_EX_DAR_EN,
		DPA_EX_DAR_INC			=> CPA_EX_DAR_INC,

		DPA_MEM_DATA_REG_EN 		=> CPA_MEM_DATA_REG_EN,
		DPA_MEM_RES_REG_EN		=> CPA_MEM_RES_REG_EN,
		DPA_MEM_CC_REG_EN		=> CPA_MEM_CC_REG_EN,
		DPA_MEM_BASE_MUX_CTRL		=> CPA_MEM_BASE_MUX_CTRL,
		DPA_MEM_BASE_REG_EN		=> CPA_MEM_BASE_REG_EN,
		DPA_MEM_DA			=> DPA_MEM_DA,
		DPA_MEM_DDOUT			=> DPA_MEM_DDOUT,	
		DPA_MEM_DDIN			=> DPA_MEM_DDIN,	
		DPA_MEM_WMP_DMAS		=> CPA_MEM_DMAS,
		DPA_MEM_WMP_SIGNED		=> CPA_MEM_WMP_SIGNED,	
		DPA_MEM_TRUNCATE_ADDR		=> CPA_MEM_TRUNCATE_ADDR,
		DPA_MEM_CC_MUX_CTRL		=> CPA_MEM_CC_MUX_CTRL,

		DPA_WB_LOAD_REG_EN		=> CPA_WB_LOAD_REG_EN,
		DPA_WB_RES_REG_EN		=> CPA_WB_RES_REG_EN,
		DPA_WB_CC_REG_EN		=> CPA_WB_CC_REG_EN,

		DPA_WB_REF_W_PORT_A_EN 		=> CPA_WB_REF_W_PORT_A_EN,
		DPA_WB_REF_W_PORT_B_EN 		=> CPA_WB_REF_W_PORT_B_EN,
		DPA_WB_REF_W_PORTS_ADDR 	=> CPA_WB_REF_W_PORTS_ADDR,

		DPA_WB_PSR_EN			=> CPA_WB_PSR_EN,
		DPA_WB_PSR_CTRL			=> CPA_WB_PSR_CTRL,
		DPA_WB_IAR_MUX_CTRL		=> CPA_WB_IAR_MUX_CTRL,
		DPA_WB_IAR_LOAD			=> CPA_WB_IAR_LOAD,
		DPA_WB_FBRANCH_MUX_CTRL		=> CPA_WB_FBRANCH_MUX_CTRL	
	);

-- synthesis translate_off
	AGP_IMODE	<= CORE_IMODE_SIG;
	AGP_DMODE	<= CORE_DMODE_SIG;
	AGP_IMODE_TEXT	<= TRANSLATE_MODE_CODE(CORE_IMODE_SIG);
	AGP_DMODE_TEXT	<= TRANSLATE_MODE_CODE(CORE_DMODE_SIG);
-- synthesis translate_on	
end architecture behave;

