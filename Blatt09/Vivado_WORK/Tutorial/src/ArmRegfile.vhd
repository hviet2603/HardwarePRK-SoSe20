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
use ieee.numeric_std.all;


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
    type reg_array is array (0 to 30) of std_logic_vector(31 downto 0);
    signal reg: reg_array;    
begin
		
--------------------------------------------------------------------------------
--	Zuweisungen interner Signale an globale Signale zu Testzwecken
--	Weisen Sie dem Testsignal jeweils den Registerinhalt des Registers
--	mit der passenden physischen Adresse zu, also z.B.
--	AGP_PHY_R0 	<= Registerspeicher an Adresse/Index "00000"/0
--------------------------------------------------------------------------------

-- synthesis translate_off	
	AGP_PHY_R0	<= reg(0);
	AGP_PHY_R1	<= reg(1);
	AGP_PHY_R2	<= reg(2);
	AGP_PHY_R3	<= reg(3);
	AGP_PHY_R4	<= reg(4);
	AGP_PHY_R5	<= reg(5);
	AGP_PHY_R6	<= reg(6);
	AGP_PHY_R7	<= reg(7);
	AGP_PHY_R8	<= reg(8);
	AGP_PHY_R9	<= reg(9);
	AGP_PHY_R10	<= reg(10);
	AGP_PHY_R11	<= reg(11);
	AGP_PHY_R12	<= reg(12);
	AGP_PHY_R13	<= reg(13);
	AGP_PHY_R14	<= reg(14);
	AGP_PHY_R15	<= reg(15);
	AGP_PHY_R16	<= reg(16);
	AGP_PHY_R17	<= reg(17);
	AGP_PHY_R18	<= reg(18);
	AGP_PHY_R19	<= reg(19);
	AGP_PHY_R20	<= reg(20);
	AGP_PHY_R21	<= reg(21);
	AGP_PHY_R22	<= reg(22);
	AGP_PHY_R23	<= reg(23);
	AGP_PHY_R24	<= reg(24);
	AGP_PHY_R25	<= reg(25);
	AGP_PHY_R26	<= reg(26);
	AGP_PHY_R27	<= reg(27);
	AGP_PHY_R28	<= reg(28);
	AGP_PHY_R29	<= reg(29);
	AGP_PHY_R30	<= reg(30);
-- synthesis translate_on	

-- reset and write ports
    WRITE: process(REF_CLK) is
    begin
        if (rising_edge(REF_CLK)) then
            if (REF_RST = '1') then 
                reg <= (others => (others => '0'));
            else
                if (REF_W_PORT_PC_ENABLE ='1') then
                    reg (15) <= REF_W_PORT_PC_DATA;
                end if;
                if (REF_W_PORT_B_ENABLE ='1') then
                    reg(to_integer(unsigned(REF_W_PORT_B_ADDR))) <= REF_W_PORT_B_DATA;
                end if;
                if (REF_W_PORT_A_ENABLE = '1') then
                    reg(to_integer(unsigned(REF_W_PORT_A_ADDR))) <= REF_W_PORT_A_DATA;
                end if;
            end if;
        end if;
    end process WRITE;

   
-- Read ports
    REF_R_PORT_A_DATA <= reg(to_integer(unsigned(REF_R_PORT_A_ADDR)));
    REF_R_PORT_B_DATA <= reg(to_integer(unsigned(REF_R_PORT_B_ADDR)));
    REF_R_PORT_C_DATA <= reg(to_integer(unsigned(REF_R_PORT_C_ADDR)));

end architecture behave;

