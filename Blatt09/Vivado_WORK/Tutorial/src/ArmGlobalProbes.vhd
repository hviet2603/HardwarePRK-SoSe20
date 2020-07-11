--------------------------------------------------------------------------------
--	Gesamelte Testsignale aus Submodulen des ARM-SoC zur
--	Verwendung in Test Benches
--------------------------------------------------------------------------------
--	Datum:		03.05.2010
--	Version:	0.92
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.armtypes.all;

package ArmGlobalProbes is

--	synthesis translate_off
--------------------------------------------------------------------------------
--	interne Signale des Registerfiles, getrennt
--	nach Betriebsmodi (veraltet)
--------------------------------------------------------------------------------
	signal AGP_R0	: std_logic_vector(31 downto 0);
	signal AGP_R1	: std_logic_vector(31 downto 0);
	signal AGP_R2	: std_logic_vector(31 downto 0);
	signal AGP_R3	: std_logic_vector(31 downto 0);
	signal AGP_R4	: std_logic_vector(31 downto 0);
	signal AGP_R5	: std_logic_vector(31 downto 0);
	signal AGP_R6	: std_logic_vector(31 downto 0);
	signal AGP_R7	: std_logic_vector(31 downto 0);
	signal AGP_R8	: std_logic_vector(31 downto 0);
	signal AGP_R9	: std_logic_vector(31 downto 0);
	signal AGP_R10	: std_logic_vector(31 downto 0);
	signal AGP_R11	: std_logic_vector(31 downto 0);
	signal AGP_R12	: std_logic_vector(31 downto 0);
	signal AGP_R13	: std_logic_vector(31 downto 0);
	signal AGP_R14	: std_logic_vector(31 downto 0);
	signal AGP_R15	: std_logic_vector(31 downto 0);

	signal AGP_R8_FIQ	: std_logic_vector(31 downto 0);
	signal AGP_R9_FIQ	: std_logic_vector(31 downto 0);
	signal AGP_R10_FIQ	: std_logic_vector(31 downto 0);
	signal AGP_R11_FIQ	: std_logic_vector(31 downto 0);
	signal AGP_R12_FIQ	: std_logic_vector(31 downto 0);
	signal AGP_R13_FIQ	: std_logic_vector(31 downto 0);
	signal AGP_R14_FIQ	: std_logic_vector(31 downto 0);

	signal AGP_R13_IRQ	: std_logic_vector(31 downto 0);
	signal AGP_R14_IRQ	: std_logic_vector(31 downto 0);

	signal AGP_R13_SVC	: std_logic_vector(31 downto 0);
	signal AGP_R14_SVC	: std_logic_vector(31 downto 0);

	signal AGP_R13_ABT	: std_logic_vector(31 downto 0);
	signal AGP_R14_ABT	: std_logic_vector(31 downto 0);

	signal AGP_R13_UND	: std_logic_vector(31 downto 0);
	signal AGP_R14_UND	: std_logic_vector(31 downto 0);

--	Probesignale des Registerspeichers mit flachem Adressraum
	signal AGP_PHY_R0	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R1	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R2	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R3	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R4	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R5	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R6	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R7	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R8	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R9	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R10	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R11	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R12	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R13	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R14	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R15	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R16	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R17	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R18	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R19	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R20	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R21	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R22	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R23	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R24	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R25	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R26	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R27	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R28	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R29	: std_logic_vector(31 downto 0);
	signal AGP_PHY_R30	: std_logic_vector(31 downto 0);
	signal AGP_PHY_PC	: std_logic_vector(31 downto 0);

-- 	SystemController
	signal AGP_CLK, AGP_INV_CLK : std_logic;
	signal AGP_CLK_LOCK : std_logic;

--	Signale des Datenpfades
	signal AGP_EX_OPA_REG	: std_logic_vector(31 downto 0);
	signal AGP_EX_OPB_REG	: std_logic_vector(31 downto 0);
	signal AGP_EX_OPC_REG	: std_logic_vector(31 downto 0);
	signal AGP_EX_CC_REG	: std_logic_vector(3 downto 0);
	signal AGP_MEM_DATA_REG	: std_logic_vector(31 downto 0);
	signal AGP_MEM_ADDR_REG : std_logic_vector(31 downto 0);
	signal AGP_MEM_RES_REG	: std_logic_vector(31 downto 0);
	signal AGP_MEM_CC_REG	: std_logic_vector(3 downto 0);
	signal AGP_WB_LOAD_REG	: std_logic_vector(31 downto 0);
	signal AGP_WB_RES_REG	: std_logic_vector(31 downto 0);
	signal AGP_WB_CC_REG	: std_logic_vector(3 downto 0);
	signal AGP_EX_OPA_MUX	: std_logic_vector(31 downto 0);
	signal AGP_EX_OPB_MUX	: std_logic_vector(31 downto 0);
	signal AGP_EX_OPC_MUX	: std_logic_vector(31 downto 0);
	signal AGP_EX_CC_MUX	: std_logic_vector(3 downto 0);

--	Signale des Kontrollpfades
	signal AGP_INSTRUCTION_REG	: std_logic_vector(31 downto 0);
	signal AGP_DECODED_INSTRUCTION	: std_logic_vector(15 downto 0);
	signal AGP_REF_R_PORT_A_ADDR	: std_logic_vector(3 downto 0);
	signal AGP_REF_R_PORT_B_ADDR	: std_logic_vector(3 downto 0);
	signal AGP_REF_R_PORT_C_ADDR	: std_logic_vector(3 downto 0);

	signal AGP_OPA_BYPASS_MUX_CTRL	: std_logic_vector(1 downto 0);
	signal AGP_OPB_BYPASS_MUX_CTRL	: std_logic_vector(1 downto 0);
	signal AGP_OPC_BYPASS_MUX_CTRL	: std_logic_vector(1 downto 0);
	signal AGP_CC_BYPASS_MUX_CTRL	: std_logic_vector(1 downto 0);

	signal AGP_CONDITION_MET	: STD_LOGIC;
	signal AGP_REF_W_PORT_A_EN	: STD_LOGIC;
	signal AGP_REF_W_PORT_B_EN	: STD_LOGIC;
	signal AGP_CURRENT_REGLIST	: std_logic_vector(15 downto 0);
	signal AGP_NR_OF_REGS		: std_logic_vector(4 downto 0);

	signal AGP_I_ADDRESS		: std_logic_vector(31 downto 0);
	signal AGP_D_ADDRESS		: std_logic_vector(31 downto 0);
	signal AGP_IMODE : MODE;
	signal AGP_DMODE : MODE;
	signal AGP_FETCH_INSTRUCTION : std_logic;
	signal AGP_LOAD_USE_CONFLICT : std_logic;
	signal AGP_FIQ_FILTERED	: std_logic;
	signal AGP_IRQ_FILTERED : std_logic;
	signal AGP_PABORT_FILTERED : std_logic;
	signal AGP_ARM_STATE		: ARM_STATE_TYPE;

-- 	ArmTop
	signal AGP_CS_MEM, AGP_CS_RS232, AGP_CS_AST, AGP_CS_GIO, AGP_CS_AMC : std_logic;
	signal AGP_IBUS_IBE, AGP_DBUS_DBE : std_logic;

	signal AGP_INST_ID_REGISTER	: INSTRUCTION_ID_REGISTER_TYPE;
	signal AGP_IAR_HISTORY_BUFFER	: IAR_HISTORY_BUFFER_TYPE;
	signal AGP_IAR_HB_CAM		: IAR_HB_CAM_TYPE;

	type string_indexed_by_mode is array(31 downto 0) of string(10 downto 1);
	constant MODE_to_String : string_indexed_by_mode :=
		(16 => "USER      ", 17 => "FIQ       ", 18 => "IRQ       ", 19 => "SUPERVISOR", 23 => "ABORT     ", 27 => "UNDEFINED ", 31 => "SYSTEM    ", others => "unknown   ");

	function TRANSLATE_MODE_CODE(MODE_CODE: MODE) return string;
	signal AGP_IMODE_TEXT, AGP_DMODE_TEXT : string(10 downto 1);

--	synthesis translate_on
end package ArmGlobalProbes;	

package body ArmGlobalProbes is
	function TRANSLATE_MODE_CODE(MODE_CODE : MODE) return string is
		variable CODE_TEXT : string(10 downto 1);
	begin
		case MODE_CODE is
			when USER 	=> CODE_TEXT := "USER      "; 
			when FIQ 	=> CODE_TEXT := "FIQ       "; 
			when IRQ 	=> CODE_TEXT := "IRQ       "; 
			when SUPERVISOR => CODE_TEXT := "SUPERVISOR"; 
			when ABORT 	=> CODE_TEXT := "ABORT     "; 
			when UNDEFINED	=> CODE_TEXT := "UNDEFINED "; 
			when SYSTEM	=> CODE_TEXT := "SYSTEM    "; 
			when others	=> CODE_TEXT := "unknown   ";
		end case;
		return CODE_TEXT;
	end function TRANSLATE_MODE_CODE;

end package body ArmGlobalProbes;
