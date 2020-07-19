--------------------------------------------------------------------------------
--	Steuerung der 5 Bypassmultiplexer der Execute-Stufe, zeigt einen
--	Load-Use-Konflikt an, wenn Bypaesse zur Loesung des Konflikts
--	nicht geeignet sind.
--------------------------------------------------------------------------------
--	Datum:		??.??.2014
--	Version:	?.??
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ArmBypassCtrl is
--------------------------------------------------------------------------------
--	Bedeutung von INST0, INST1, INST2: drei gleichzeitig in der Pipeline
--	befindliche Instruktionen.
--	INST0: Instruktion in der Instruction Decode-Stufe
--	INST1: Instruktion in der Execute-Stufe
--     	INST2: Instruktion in der Memory-Stufe	
--------------------------------------------------------------------------------
	port(	
--	Leseadressen der drei zu lesenden Operanden der ID-Stufe (INST0)	
		ABC_INST0_R_PORT_A_ADDR	: in std_logic_vector(4 downto 0);
		ABC_INST0_R_PORT_B_ADDR	: in std_logic_vector(4 downto 0);
		ABC_INST0_R_PORT_C_ADDR	: in std_logic_vector(4 downto 0);
--	Register-Schreibadressen der unmittelbar vorhergehenden Instruktion
		ABC_INST1_W_PORT_A_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST1_W_PORT_B_ADDR : in std_logic_vector(4 downto 0);
--	Register-Schreibadressen der vor INST1 decodierten Instruktion (INST2)
		ABC_INST2_W_PORT_A_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST2_W_PORT_B_ADDR : in std_logic_vector(4 downto 0);
--	Registerspeicher-Write-Enable-Signale der vorhergehenden Instruktion (INST1)
		ABC_INST1_W_PORT_A_EN	: in std_logic;
		ABC_INST1_W_PORT_B_EN	: in std_logic;
--	Registerspeicher-Write-Enable-Signale der vorletzten Instruktion (INST2)
		ABC_INST2_W_PORT_A_EN	: in std_logic;
		ABC_INST2_W_PORT_B_EN	: in std_logic;
--	Steuersignale fuer Statusregisterzugriffe von Instruktion INST1
		ABC_INST1_WB_PSR_EN	: in std_logic;
		ABC_INST1_WB_PSR_SET_CC : in std_logic;
--	Steuersignale fuer Statusregisterzugriffe von Instruktion INST2
		ABC_INST2_WB_PSR_EN	: in std_logic;
		ABC_INST2_WB_PSR_SET_CC : in std_logic;
--------------------------------------------------------------------------------
--	Informationen darueber, welche Registeroperanden (C|B|A) INST0 wirklich
--	verwendet.
--------------------------------------------------------------------------------
		ABC_INST0_REGS_USED	: in std_logic_vector(2 downto 0); --CBA
--------------------------------------------------------------------------------
--	Angabe, ob die Operationsweite des Shifters aus einem Register gelesen
--	wird.	
--------------------------------------------------------------------------------
		ABC_INST0_SHIFT_REG_USED : in std_logic;
--------------------------------------------------------------------------------
--	Erzeugte Steuersignale der Bypassmultiplexer sowie Anzeige eines
--	nicht durch Bypaesse zu loesenden Load-Use-Konflikts
--------------------------------------------------------------------------------
		ABC_INST0_OPA_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_INST0_OPB_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_INST0_OPC_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_INST0_SHIFT_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_INST0_CC_BYPASS_MUX_CTRL	: out std_logic_vector(1 downto 0);
		ABC_LOAD_USE_CONFLICT 		: out std_logic
	);
end entity ArmBypassCtrl;

architecture behave of ArmBypassCtrl is

--	Aliase fuer die Verkuerzung der Leseadressen von Instruktion 0
	alias ADDR_A0 : std_logic_vector(4 downto 0) is ABC_INST0_R_PORT_A_ADDR;
	alias ADDR_B0 : std_logic_vector(4 downto 0) is ABC_INST0_R_PORT_B_ADDR;
	alias ADDR_C0 : std_logic_vector(4 downto 0) is ABC_INST0_R_PORT_C_ADDR;

--	Aliase fuer die Verkuerzung der Schreibadressen von Instruktion 1
	alias ADDR_A1 : std_logic_vector(4 downto 0) is ABC_INST1_W_PORT_A_ADDR;
	alias ADDR_B1 : std_logic_vector(4 downto 0) is ABC_INST1_W_PORT_B_ADDR;

--	Aliase fuer die Verkuerzung der Schreibadressen von Instruktion 2
	alias ADDR_A2 : std_logic_vector(4 downto 0) is ABC_INST2_W_PORT_A_ADDR;
	alias ADDR_B2 : std_logic_vector(4 downto 0) is ABC_INST2_W_PORT_B_ADDR;

--	Aliase fuer beide Registerspeicher Write-Enable-Signale von Instruktion 1
	alias WEN_A1 : std_logic is ABC_INST1_W_PORT_A_EN;
	alias WEN_B1 : std_logic is ABC_INST1_W_PORT_B_EN;

--	Aliase fuer beide Registerspeicher Write-Enable-Signale von Instruktion 2
	alias WEN_A2 : std_logic is ABC_INST2_W_PORT_A_EN;
	alias WEN_B2 : std_logic is ABC_INST2_W_PORT_B_EN;

--	Aliase fuer PSR-Steuersignale von Instruktion 1
	alias PSR_EN_1 : std_logic is ABC_INST1_WB_PSR_EN;
	alias PSR_SET_CC_1 : std_logic is ABC_INST1_WB_PSR_SET_CC;

--	Aliase fuer PSR-Steuersignale von Instruktion 2
	alias PSR_EN_2 : std_logic is ABC_INST2_WB_PSR_EN;
	alias PSR_SET_CC_2 : std_logic is ABC_INST2_WB_PSR_SET_CC;

--	Vergleich von R_A_ADDR mit den 4 Write-Adressen vorheriger Instruktionen
	signal A0_equal_A1 : boolean;
	signal A0_equal_B1 : boolean;
	signal A0_equal_A2 : boolean;
	signal A0_equal_B2 : boolean;

--	Vergleich von R_B_ADDR mit den 4 Write-Adressen vorheriger Instruktionen
	signal B0_equal_A1 : boolean;
	signal B0_equal_B1 : boolean;
	signal B0_equal_A2 : boolean;
	signal B0_equal_B2 : boolean;

--	Vergleich von R_C_ADDR mit den 4 Write-Adressen vorheriger Instruktionen
	signal C0_equal_A1 : boolean;
	signal C0_equal_B1 : boolean;
	signal C0_equal_A2 : boolean;
	signal C0_equal_B2 : boolean;

	signal REN_A0, REN_B0, REN_C0:std_logic;
begin

	A0_equal_A1 <= true when ADDR_A0 = ADDR_A1 else false;
	A0_equal_B1 <= true when ADDR_A0 = ADDR_B1 else false;
	A0_equal_A2 <= true when ADDR_A0 = ADDR_A2 else false;
	A0_equal_B2 <= true when ADDR_A0 = ADDR_B2 else false;

	B0_equal_A1 <= true when ADDR_B0 = ADDR_A1 else false;
	B0_equal_B1 <= true when ADDR_B0 = ADDR_B1 else false;
	B0_equal_A2 <= true when ADDR_B0 = ADDR_A2 else false;
	B0_equal_B2 <= true when ADDR_B0 = ADDR_B2 else false;

	C0_equal_A1 <= true when ADDR_C0 = ADDR_A1 else false;
	C0_equal_B1 <= true when ADDR_C0 = ADDR_B1 else false;
	C0_equal_A2 <= true when ADDR_C0 = ADDR_A2 else false;
	C0_equal_B2 <= true when ADDR_C0 = ADDR_B2 else false;	

	
	REN_A0 <= ABC_INST0_REGS_USED(0);
	REN_B0 <= ABC_INST0_REGS_USED(1);
	REN_C0 <= ABC_INST0_REGS_USED(2);

	ABC_INST0_OPA_BYPASS_MUX_CTRL <= "01" when A0_equal_A1 and REN_A0 = '1' and WEN_A1 = '1' else --MEM_RES
					 "10" when A0_equal_A2 and REN_A0 = '1' and WEN_A2 = '1' else --WB_RES
					 "11" when A0_equal_B2 and REN_A0 = '1' and WEN_B2 = '1' else --WB_LOAD
					 "00";

	ABC_INST0_OPB_BYPASS_MUX_CTRL <= "01" when B0_equal_A1 and REN_B0 = '1' and WEN_A1 = '1' else --MEM_RES
					 "10" when B0_equal_A2 and REN_B0 = '1' and WEN_A2 = '1' else --WB_RES
					 "11" when B0_equal_B2 and REN_B0 = '1' and WEN_B2 = '1' else --WB_LOAD
					 "00";

	ABC_INST0_OPC_BYPASS_MUX_CTRL <= "01" when C0_equal_A1 and REN_C0 = '1' and WEN_A1 = '1' else --MEM_RES
					 "10" when C0_equal_A2 and REN_C0 = '1' and WEN_A2 = '1' else --WB_RES
					 "11" when C0_equal_B2 and REN_C0 = '1' and WEN_B2 = '1' else --WB_LOAD
					 "00";

	ABC_LOAD_USE_CONFLICT <= '1' when A0_equal_B1 and not A0_equal_A1 and WEN_B1 = '1' and REN_A0 = '1' else
				 '1' when B0_equal_B1 and WEN_B1 = '1' and not B0_equal_A1 and REN_B0 = '1' else
				 '1' when C0_equal_B1 and WEN_B1 = '1' and not C0_equal_A1 and REN_C0 = '1' else
				 '0';


	--shift: fast mit ABC_INST0_OPC_BYPASS_MUX_CTRL identisch.....ABC_INST0_SHIFT_REG_USED: ob die Schiebeweite wirklich aus Registerport C stammt oder ein Direktoperand ist. 
	ABC_INST0_SHIFT_BYPASS_MUX_CTRL <= "01" when C0_equal_A1 and REN_C0 = '1' and WEN_A1 = '1' and ABC_INST0_SHIFT_REG_USED = '1' else
					   "10" when C0_equal_A2 and REN_C0 = '1' and WEN_A2 = '1' and ABC_INST0_SHIFT_REG_USED = '1' else
					   "11" when C0_equal_B2 and REN_C0 = '1' and WEN_B2 = '1' and ABC_INST0_SHIFT_REG_USED = '1' else
					   "00";


	ABC_INST0_CC_BYPASS_MUX_CTRL <= "01" when PSR_SET_CC_1 = '1' and PSR_EN_1 = '1' else
					"10" when PSR_SET_CC_2 = '1' and PSR_EN_2 = '1' else
					"00";

	


end architecture behave;
