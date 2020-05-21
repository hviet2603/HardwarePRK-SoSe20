------------------------------------------------------------------------------
--	Registerspeichers des ARM-SoC
------------------------------------------------------------------------------
--	Datum:		05.11.2013
--	Version:	0.1
------------------------------------------------------------------------------

library work;
use work.ArmTypes.all;
use work.ArmRegAddressTranslation.all;
use work.ArmGlobalProbes.all;
use work.ArmConfiguration.all;
library ieee;
use ieee.std_logic_1164.all;


entity ArmRegfile is
	Port ( REF_CLK 		: in std_logic;
	       REF_RST 		: in  std_logic;

	       REF_W_PORT_A_ENABLE	: in std_logic;
	       REF_W_PORT_B_ENABLE	: in std_logic;
	       REF_W_PORT_PC_ENABLE	: in std_logic;

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
end entity ArmRegfile;

architecture behave of ArmRegfile is

begin


		
--------------------------------------------------------------------------------
--	Zuweisungen interner Signale an globale Signale zu Testzwecken
--	Weisen Sie dem Testsignal jeweils den Registerinhalt des Registers
--	mit der passenden physischen Adresse zu, also z.B.
--	AGP_PHY_R0 	<= Registerspeicher an Adresse/Index "00000"/0
--------------------------------------------------------------------------------

-- synthesis translate_off	
	AGP_PHY_R0	<= <Register zur phy. Adresse 0>;
	AGP_PHY_R1	<= 
	AGP_PHY_R2	<=  
	AGP_PHY_R3	<= 
	AGP_PHY_R4	<= 
	AGP_PHY_R5	<= 
	AGP_PHY_R6	<= 
	AGP_PHY_R7	<=
	AGP_PHY_R8	<=
	AGP_PHY_R9	<=
	AGP_PHY_R10	<=
	AGP_PHY_R11	<=
	AGP_PHY_R12	<=
	AGP_PHY_R13	<=
	AGP_PHY_R14	<=
	AGP_PHY_R15	<=
	AGP_PHY_R16	<=
	AGP_PHY_R17	<=
	AGP_PHY_R18	<=
	AGP_PHY_R19	<=
	AGP_PHY_R20	<=
	AGP_PHY_R21	<=
	AGP_PHY_R22	<=
	AGP_PHY_R23	<=
	AGP_PHY_R24	<=
	AGP_PHY_R25	<=
	AGP_PHY_R26	<=
	AGP_PHY_R27	<=
	AGP_PHY_R28	<=
	AGP_PHY_R29	<=
	AGP_PHY_R30	<=
-- synthesis translate_on	

end architecture behave;

