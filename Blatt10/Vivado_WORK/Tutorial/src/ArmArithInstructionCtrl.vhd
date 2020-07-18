--------------------------------------------------------------------------------
-- 	Teilsteuerung Arithmetisch-logischer Instruktionen im Kontrollpfad
--	des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2014
--	Version:	?.?
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

entity ArmArithInstructionCtrl is
	port(
		AIC_DECODED_VECTOR	: in std_logic_vector(15 downto 0);
		AIC_INSTRUCTION		: in std_logic_vector(31 downto 0);
		AIC_IF_IAR_INC		: out std_logic;
		AIC_ID_R_PORT_A_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_B_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_R_PORT_C_ADDR	: out std_logic_vector(3 downto 0);
		AIC_ID_REGS_USED	: out std_logic_vector(2 downto 0);
		AIC_ID_IMMEDIATE	: out std_logic_vector(31 downto 0);	
		AIC_ID_OPB_MUX_CTRL	: out std_logic;
		AIC_EX_ALU_CTRL		: out std_logic_vector(3 downto 0);
		AIC_MEM_RES_REG_EN	: out std_logic;
		AIC_MEM_CC_REG_EN	: out std_logic;
		AIC_WB_RES_REG_EN	: out std_logic;
		AIC_WB_CC_REG_EN	: out std_logic;	
		AIC_WB_W_PORT_A_ADDR	: out std_logic_vector(3 downto 0);
		AIC_WB_W_PORT_A_EN	: out std_logic;	
		AIC_WB_IAR_MUX_CTRL	: out std_logic;
		AIC_WB_IAR_LOAD		: out std_logic;
		AIC_WB_PSR_EN		: out std_logic;
		AIC_WB_PSR_SET_CC	: out std_logic;
		AIC_WB_PSR_ER		: out std_logic;
		AIC_DELAY		: out std_logic_vector(1 downto 0);
--------------------------------------------------------------------------------
--	Verwendung eines Typs aus ArmTypes weil die Codierung der Zustaende 
--	nicht vorgegeben ist.
--------------------------------------------------------------------------------
		AIC_ARM_NEXT_STATE	: out ARM_STATE_TYPE
	    );
end entity ArmArithInstructionCtrl;

architecture behave of ArmArithInstructionCtrl is

signal opcode: std_logic_vector(3 downto 0);
signal Rn_reg: std_logic_vector(3 downto 0);
signal Rd_reg: std_logic_vector(3 downto 0);
signal Rs_reg: std_logic_vector(3 downto 0);
signal Rm_reg: std_logic_vector(3 downto 0);
signal operand_2: std_logic_vector(11 downto 0);
signal immediate: std_logic_vector(7 downto 0);

signal branch: std_logic;
signal s_bit: std_logic;
signal test_or_compare_instr: std_logic;

begin

-- Setup
opcode <= AIC_INSTRUCTION(24 downto 21);
Rn_reg <= AIC_INSTRUCTION(19 downto 16);
Rd_reg <= AIC_INSTRUCTION(15 downto 12);
Rs_reg <= AIC_INSTRUCTION(11 downto 8);
Rm_reg <= AIC_INSTRUCTION(3 downto 0);
operand_2 <= AIC_INSTRUCTION(11 downto 0);
immediate <= AIC_INSTRUCTION(7 downto 0);

branch <= '1' when Rd_reg = PC; -- PC: R15 "1111", defined in ArmTypes
s_bit <= AIC_INSTRUCTION(20);
test_or_compare_instr <= '1' when instruction_opcode = OP_TST or instruction_opcode = OP_TEQ or instruction_opcode = OP_CMP or instruction_opcode = OP_CMN else
			  '0'																	     ;

-- Instruction Decode - ReadPort A: read from Rn 
AIC_ID_R_PORT_A_ADDR <= Rn_reg;

-- Instruction Decode - ReadPort B: read from Rm/ Use Immediate
AIC_ID_R_PORT_B_ADDR <= Rm_reg;
AIC_ID_IMMEDIATE <= x"000000" & immediate;
AIC_ID_OPB_MUX_CTRL <= '0' when AIC_DECODED_VECTOR = CD_ARITH_REGISTER else 
			'1'                                                 ; --CD_ARITH_IMMEDIATE
			
-- Instruction Decode - ReadPort C: read from Rs
AIC_ID_R_PORT_C_ADDR <= Rs_reg;

-- Write Back - WritePort A: write to Rd
AIC_WB_W_PORT_A_ADDR <= Rd_reg;

-- ALU_CTRL = opcode
AIC_EX_ALU_CTRL <= opcode;

-- set used register
AIC_ID_REGS_USED <=  "001" when AIC_DECODED_VECTOR = CD_ARITH_IMMEDIATE         else  -- OpA
                     "011" when AIC_DECODED_VECTOR = CD_ARITH_REGISTER          else  -- OpB, OpA
                     "111" when AIC_DECODED_VECTOR = CD_ARITH_REGISTER_REGISTER else  -- OpC, OpB, OpA              
                     "000"                                                          ;
                     
-- 
AIC_MEM_RES_REG_EN <= '1' when not test_or_compare_instr else 
                      '0'				       ;
AIC_WB_RES_REG_EN <= '1' when not test_or_compare_instr else 
                     '0'                                    ;
AIC_WB_W_PORT_A_EN <= '1' when not test_or_compare_instr else
                      '0'                                    ;
         





end architecture behave;
