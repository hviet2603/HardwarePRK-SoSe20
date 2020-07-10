--------------------------------------------------------------------------------
--	Testbench zum Test des Instruktionsadressregisters und der Bypass-
--	multiplexer im Datenpfad.
--------------------------------------------------------------------------------
--	Datum:		08.06.2010
--	Version:	1.0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library modelsim_lib;
use modelsim_lib.util.all;

library work;
use work.ArmTypes.all;
use work.ArmConfiguration.all;
use work.ArmGlobalProbes.all;
use work.TB_Tools.SEPARATOR_LINE;
use work.TB_Tools.TAB_CHAR;

entity ArmDataPath_tb_vhd is
end entity ArmDataPath_tb_vhd;

architecture behavior of ArmDataPath_tb_vhd is 

	-- Component Declaration for the Unit Under Test (UUT)
	component ArmDataPath
	port(
		DPA_CLK : in std_logic;
		DPA_INV_CLK : in std_logic;
		DPA_RST : in std_logic;
		DPA_ENABLE : in std_logic;
		DPA_IF_IAR_INC : in std_logic;
		DPA_IF_IAR_UPDATE_HB : in std_logic;
		DPA_ID_IAR_REVOKE : in std_logic;
		DPA_ID_IAR_HISTORY_ID : in std_logic_vector(2 downto 0);
		DPA_ID_REF_R_PORTS_ADDR : in std_logic_vector(14 downto 0);
		DPA_ID_IMMEDIATE : in std_logic_vector(31 downto 0);
		DPA_ID_SHIFT_AMOUNT : in std_logic_vector(5 downto 0);
		DPA_ID_OPB_MUX_CTRL : in std_logic;
		DPA_ID_SHIFT_MUX_CTRL : in std_logic;
		DPA_EX_PSR_MUX_CTRL : in std_logic;
		DPA_EX_OPA_REG_EN : in std_logic;
		DPA_EX_OPB_REG_EN : in std_logic;
		DPA_EX_OPC_REG_EN : in std_logic;
		DPA_EX_SHIFT_REG_EN : in std_logic;
		DPA_EX_OPX_MUX_CTRLS : in std_logic_vector(5 downto 0);
		DPA_EX_SHIFT_MUX_CTRL : in std_logic_vector(1 downto 0);
		DPA_EX_CC_MUX_CTRL : in std_logic_vector(1 downto 0);
		DPA_EX_OPB_ALU_MUX_CTRL : in std_logic;
		DPA_EX_PSR_CC_MUX_CTRL : in std_logic;
		DPA_EX_OPA_PSR_MUX_CTRL : in std_logic;
		DPA_EX_SHIFT_TYPE : in std_logic_vector(1 downto 0);
		DPA_EX_SHIFT_RRX : in std_logic;
		DPA_EX_ALU_CTRL : in std_logic_vector(3 downto 0);
		DPA_EX_DRP_DMAS : in std_logic_vector(1 downto 0);
		DPA_EX_DAR_EN : in std_logic;
		DPA_EX_DAR_MUX_CTRL : in std_logic;
		DPA_EX_DAR_inC : in std_logic;
		DPA_MEM_DATA_REG_EN : in std_logic;
		DPA_MEM_RES_REG_EN : in std_logic;
		DPA_MEM_CC_REG_EN : in std_logic;
		DPA_MEM_BASE_REG_EN : in std_logic;
		DPA_MEM_BASE_MUX_CTRL : in std_logic;
		DPA_MEM_DDIN : in std_logic_vector(31 downto 0);
		DPA_MEM_WMP_DMAS : in std_logic_vector(1 downto 0);
		DPA_MEM_WMP_SIGNED : in std_logic;
		DPA_MEM_TRUNCATE_ADDR : in std_logic;
		DPA_MEM_CC_MUX_CTRL : in std_logic;
		DPA_WB_LOAD_REG_EN : in std_logic;
		DPA_WB_RES_REG_EN : in std_logic;
		DPA_WB_CC_REG_EN : in std_logic;
		DPA_WB_REF_W_PORT_A_EN : in std_logic;
		DPA_WB_REF_W_PORT_B_EN : in std_logic;
		DPA_WB_REF_W_PORTS_ADDR : in std_logic_vector(9 downto 0);
		DPA_WB_PSR_EN : in std_logic;
		DPA_WB_PSR_CTRL : in PSR_CTRL_TYPE;
		DPA_WB_IAR_MUX_CTRL : in std_logic;
		DPA_WB_IAR_LOAD : in std_logic;
		DPA_WB_FBRANCH_MUX_CTRL : in std_logic;          
		DPA_IF_IA : out std_logic_vector(31 downto 2);
		DPA_EX_CPSR : out std_logic_vector(31 downto 0);
		DPA_MEM_DA : out std_logic_vector(31 downto 0);
		DPA_MEM_DDOUT : out std_logic_vector(31 downto 0)
		);
	end component ArmDataPath;

--	Durch Signal_Spy getriebene Werte aus dem Datenpfad
	signal OPA_BYPASS_MUX_OUT : std_logic_vector(31 downto 0);
	signal OPB_BYPASS_MUX_OUT : std_logic_vector(31 downto 0);
	signal OPC_BYPASS_MUX_OUT : std_logic_vector(31 downto 0);
	signal SHIFT_BYPASS_MUX_OUT : std_logic_vector(7 downto 0);
	signal CC_BYPASS_MUX_OUT : std_logic_vector(3 downto 0);

	--Inputs
	signal DPA_CLK :  std_logic := '0';
	signal DPA_INV_CLK :  std_logic := '0';
	signal DPA_RST :  std_logic := '0';
	signal DPA_ENABLE :  std_logic := '0';
	signal DPA_IF_IAR_INC :  std_logic := '0';
	signal DPA_IF_IAR_UPDATE_HB :  std_logic := '0';
	signal DPA_ID_IAR_REVOKE :  std_logic := '0';
	signal DPA_ID_OPB_MUX_CTRL :  std_logic := '0';
	signal DPA_ID_SHIFT_MUX_CTRL :  std_logic := '0';
--	signal DPA_EX_PSR_MUX_CTRL :  std_logic := '0';
	signal DPA_EX_OPA_REG_EN :  std_logic := '0';
	signal DPA_EX_OPB_REG_EN :  std_logic := '0';
	signal DPA_EX_OPC_REG_EN :  std_logic := '0';
	signal DPA_EX_SHIFT_REG_EN :  std_logic := '0';
--	signal DPA_EX_OPB_ALU_MUX_CTRL :  std_logic := '0';
--	signal DPA_EX_PSR_CC_MUX_CTRL :  std_logic := '0';
--	signal DPA_EX_OPA_PSR_MUX_CTRL :  std_logic := '0';
--	signal DPA_EX_SHIFT_RRX :  std_logic := '0';
--	signal DPA_EX_DAR_EN :  std_logic := '0';
--	signal DPA_EX_DAR_MUX_CTRL :  std_logic := '0';
--	signal DPA_EX_DAR_inC :  std_logic := '0';
	signal DPA_MEM_DATA_REG_EN :  std_logic := '0';
	signal DPA_MEM_RES_REG_EN :  std_logic := '0';
	signal DPA_MEM_CC_REG_EN :  std_logic := '0';
--	signal DPA_MEM_BASE_REG_EN :  std_logic := '0';
--	signal DPA_MEM_BASE_MUX_CTRL :  std_logic := '0';
--	signal DPA_MEM_WMP_SIGNED :  std_logic := '0';
--	signal DPA_MEM_TRUNCATE_ADDR :  std_logic := '0';
	signal DPA_MEM_CC_MUX_CTRL :  std_logic := '0';
	signal DPA_WB_LOAD_REG_EN :  std_logic := '0';
	signal DPA_WB_RES_REG_EN :  std_logic := '0';
	signal DPA_WB_CC_REG_EN :  std_logic := '0';
--	signal DPA_WB_REF_W_PORT_A_EN :  std_logic := '0';
--	signal DPA_WB_REF_W_PORT_B_EN :  std_logic := '0';
--	signal DPA_WB_PSR_EN :  std_logic := '0';
	signal DPA_WB_PSR_CTRL :  PSR_CTRL_TYPE;
	signal DPA_WB_IAR_MUX_CTRL :  std_logic := '0';
	signal DPA_WB_IAR_LOAD :  std_logic := '0';
	signal DPA_WB_FBRANCH_MUX_CTRL :  std_logic := '0';
	signal DPA_ID_IAR_HISTORY_ID :  std_logic_vector(2 downto 0) := (others=>'0');
--	signal DPA_ID_REF_R_PORTS_ADDR :  std_logic_vector(14 downto 0) := (others=>'0');
	signal DPA_ID_IMMEDIATE :  std_logic_vector(31 downto 0) := (others=>'0');
	signal DPA_ID_SHIFT_AMOUNT :  std_logic_vector(5 downto 0) := (others=>'0');
	signal DPA_EX_OPX_MUX_CTRLS :  std_logic_vector(5 downto 0) := (others=>'0');
	signal DPA_EX_SHIFT_MUX_CTRL :  std_logic_vector(1 downto 0) := (others=>'0');
	signal DPA_EX_CC_MUX_CTRL :  std_logic_vector(1 downto 0) := (others=>'0');
--	signal DPA_EX_SHIFT_TYPE :  std_logic_vector(1 downto 0) := (others=>'0');
--	signal DPA_EX_ALU_CTRL :  std_logic_vector(3 downto 0) := (others=>'0');
--	signal DPA_EX_DRP_DMAS :  std_logic_vector(1 downto 0) := (others=>'0');
	signal DPA_MEM_DDin :  std_logic_vector(31 downto 0) := (others=>'0');
	signal DPA_MEM_WMP_DMAS :  std_logic_vector(1 downto 0) := (others=>'0');
--	signal DPA_WB_REF_W_PORTS_ADDR :  std_logic_vector(9 downto 0) := (others=>'0');

	--Outputs
	signal DPA_IF_IA :  std_logic_vector(31 downto 2);
--	signal DPA_EX_CPSR :  std_logic_vector(31 downto 0);
	signal DPA_MEM_DA :  std_logic_vector(31 downto 0);
	signal DPA_MEM_DDOUT :  std_logic_vector(31 downto 0);

	alias DPA_EX_OPA_MUX_CTRL : std_logic_vector(1 downto 0) is DPA_EX_OPX_MUX_CTRLS(1 downto 0);
	alias DPA_EX_OPB_MUX_CTRL : std_logic_vector(1 downto 0) is DPA_EX_OPX_MUX_CTRLS(3 downto 2);
	alias DPA_EX_OPC_MUX_CTRL : std_logic_vector(1 downto 0) is DPA_EX_OPX_MUX_CTRLS(5 downto 4);



	constant NR_OF_TESTCASES	: natural := 10;
	signal SIMULATION_RUNNING	: boolean := true;
	signal TESTCASE			: natural := 1;
	signal NEXT_ADDR_OUT		: std_logic_vector(31 downto 2);
	signal EXTENDED_ADDR_OUT, EXTENDED_NEXT_ADDR_OUT	: std_logic_vector(31 downto 0);
	signal ADDRESS_INTEGER: integer := 0;
	signal NEXT_ADDRESS_INTEGER: integer := 0;

	
begin

	-- Instantiate the Unit Under Test (UUT)
	uut: ArmDataPath port map(
		DPA_CLK => DPA_CLK,
		DPA_INV_CLK => DPA_INV_CLK,
		DPA_RST => DPA_RST,
		DPA_ENABLE => DPA_ENABLE,
		DPA_IF_IA => DPA_IF_IA,
		DPA_IF_IAR_INC => DPA_IF_IAR_inC,
		DPA_IF_IAR_UPDATE_HB => DPA_IF_IAR_UPDATE_HB,
		DPA_ID_IAR_REVOKE => DPA_ID_IAR_REVOKE,
		DPA_ID_IAR_HISTORY_ID => DPA_ID_IAR_HISTORY_ID,
		DPA_ID_REF_R_PORTS_ADDR => (others => '0'),
		DPA_ID_IMMEDIATE => DPA_ID_IMMEDIATE,
		DPA_ID_SHIFT_AMOUNT => DPA_ID_SHIFT_AMOUNT,
		DPA_ID_OPB_MUX_CTRL => DPA_ID_OPB_MUX_CTRL,
		DPA_ID_SHIFT_MUX_CTRL => DPA_ID_SHIFT_MUX_CTRL,
		DPA_EX_PSR_MUX_CTRL => '0',
		DPA_EX_CPSR => open,
		DPA_EX_OPA_REG_EN => DPA_EX_OPA_REG_EN,
		DPA_EX_OPB_REG_EN => DPA_EX_OPB_REG_EN,
		DPA_EX_OPC_REG_EN => DPA_EX_OPC_REG_EN,
		DPA_EX_SHIFT_REG_EN => DPA_EX_SHIFT_REG_EN,
		DPA_EX_OPX_MUX_CTRLS => DPA_EX_OPX_MUX_CTRLS,
		DPA_EX_SHIFT_MUX_CTRL => DPA_EX_SHIFT_MUX_CTRL,
		DPA_EX_CC_MUX_CTRL => DPA_EX_CC_MUX_CTRL,
		DPA_EX_OPB_ALU_MUX_CTRL => '0',
		DPA_EX_PSR_CC_MUX_CTRL => '0',
		DPA_EX_OPA_PSR_MUX_CTRL => '0',
		DPA_EX_SHIFT_TYPE => "00",
		DPA_EX_SHIFT_RRX => '0',
		DPA_EX_ALU_CTRL => "0000",
		DPA_EX_DRP_DMAS => DMAS_WORD,
		DPA_EX_DAR_EN => '0',--DPA_EX_DAR_EN,
		DPA_EX_DAR_MUX_CTRL => '0',--DPA_EX_DAR_MUX_CTRL,
		DPA_EX_DAR_inC => '0',--DPA_EX_DAR_inC,
		DPA_MEM_DATA_REG_EN => DPA_MEM_DATA_REG_EN,
		DPA_MEM_RES_REG_EN => DPA_MEM_RES_REG_EN,
		DPA_MEM_CC_REG_EN => DPA_MEM_CC_REG_EN,
		DPA_MEM_BASE_REG_EN => '0',--DPA_MEM_BASE_REG_EN,
		DPA_MEM_BASE_MUX_CTRL => '0',--DPA_MEM_BASE_MUX_CTRL,
		DPA_MEM_DA => DPA_MEM_DA,
		DPA_MEM_DDOUT => DPA_MEM_DDOUT,
		DPA_MEM_DDIN => DPA_MEM_DDIN,
		DPA_MEM_WMP_DMAS => DPA_MEM_WMP_DMAS,
		DPA_MEM_WMP_SIGNED => '0',--DPA_MEM_WMP_SIGNED,
		DPA_MEM_TRUNCATE_ADDR => '0',--DPA_MEM_TRUNCATE_ADDR,
		DPA_MEM_CC_MUX_CTRL => DPA_MEM_CC_MUX_CTRL,
		DPA_WB_LOAD_REG_EN => DPA_WB_LOAD_REG_EN,
		DPA_WB_RES_REG_EN => DPA_WB_RES_REG_EN,
		DPA_WB_CC_REG_EN => DPA_WB_CC_REG_EN,
		DPA_WB_REF_W_PORT_A_EN => '0',--DPA_WB_REF_W_PORT_A_EN,
		DPA_WB_REF_W_PORT_B_EN => '0',--DPA_WB_REF_W_PORT_B_EN,
		DPA_WB_REF_W_PORTS_ADDR => (others => '0'),--DPA_WB_REF_W_PORTS_ADDR,
		DPA_WB_PSR_EN => '0',--DPA_WB_PSR_EN,
		DPA_WB_PSR_CTRL => DPA_WB_PSR_CTRL,
		DPA_WB_IAR_MUX_CTRL => DPA_WB_IAR_MUX_CTRL,
		DPA_WB_IAR_LOAD => DPA_WB_IAR_LOAD,
		DPA_WB_FBRANCH_MUX_CTRL => DPA_WB_FBRANCH_MUX_CTRL
	);

	DPA_CLK				<= not DPA_CLK after ARM_SYS_CLK_PERIOD/2 when SIMULATION_RUNNING else '0';
	DPA_INV_CLK			<= not DPA_CLK;
	EXTENDED_ADDR_OUT		<= DPA_IF_IA & "00";
	EXTENDED_NEXT_ADDR_OUT		<= NEXT_ADDR_OUT & "00";
	ADDRESS_INTEGER			<= to_integer(unsigned(DPA_IF_IA));
	NEXT_ADDRESS_INTEGER		<= to_integer(unsigned(NEXT_ADDR_OUT));
	init_spies : process
	begin
		init_signal_spy("uut/EX_OPA_MUX","OPA_BYPASS_MUX_OUT",1,-1);
		init_signal_spy("uut/EX_OPB_MUX","OPB_BYPASS_MUX_OUT",1,-1);
		init_signal_spy("uut/EX_OPC_MUX","OPC_BYPASS_MUX_OUT",1,-1);
		init_signal_spy("uut/EX_SHIFT_MUX","SHIFT_BYPASS_MUX_OUT",1,-1);
		init_signal_spy("uut/EX_CC_MUX","CC_BYPASS_MUX_OUT",1,-1);
		init_signal_spy("uut/IF_IAR_NEXT_ADDR_OUT","NEXT_ADDR_OUT",1,-1);
		wait;
	end process init_spies;

	tb : process

		type ERRORS_IN_TESTCASES_TYPE is array(1 to NR_OF_TESTCASES) of natural;
		variable TESTCASE_NR		: integer := 1;
		variable ERRORS_IN_TESTCASES 	: ERRORS_IN_TESTCASES_TYPE := (others => 0);
		variable POINTS_IAR,POINTS_BYPASS : natural := 0;
		variable ERRORS_IN_TESTCASE	: natural := 0;
		

		procedure SYNC_HIGH_DELAY(THIS_DELAY: in real) is
		begin
			wait until DPA_CLK'event and DPA_CLK = '1';
			wait for (ARM_SYS_CLK_PERIOD*THIS_DELAY);
		end procedure SYNC_HIGH_DELAY;

		procedure EVAL(THIS_TESTCASE : inout natural range 1 to NR_OF_TESTCASES; THIS_ERRORS : inout natural; THIS_ERRORS_ARRAY : inout ERRORS_IN_TESTCASES_TYPE) is
		begin
			if THIS_ERRORS > 0 then
				report "Fehler in Testcase " & integer'image(THIS_TESTCASE) severity error;
				report "Fehler in Testcase " & integer'image(THIS_TESTCASE) severity note;
				THIS_ERRORS_ARRAY(THIS_TESTCASE) := THIS_ERRORS;
			else
				report "Testcase " & integer'image(THIS_TESTCASE) & " korrekt." severity note;
				THIS_ERRORS_ARRAY(THIS_TESTCASE) := 0;
			end if;
			if THIS_TESTCASE < NR_OF_TESTCASES then THIS_TESTCASE := THIS_TESTCASE + 1; end if;
			THIS_ERRORS := 0;
			TESTCASE <= THIS_TESTCASE;
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
		end procedure EVAL;
	begin
		DPA_WB_PSR_CTRL.EXC_ENTRY	<= '0';
		DPA_WB_PSR_CTRL.EXC_RETURN	<= '0';
		DPA_WB_PSR_CTRL.SET_CC		<= '0';
		DPA_WB_PSR_CTRL.WRITE_SPSR	<= '0';
		DPA_WB_PSR_CTRL.MASK 		<= "0000";
		DPA_WB_PSR_CTRL.MODE 		<= SUPERVISOR;

		DPA_RST <= '0', '1' after (ARM_SYS_CLK_PERIOD*1.75), '0' after (ARM_SYS_CLK_PERIOD*4.25);
		SIMULATION_RUNNING <= true;
		wait for ARM_SYS_CLK_PERIOD*10.25;	

--	Wo moeglich, Register von aussen initialisieren
		DPA_ENABLE		<= '1';
		DPA_EX_OPA_REG_EN	<= '1';
		DPA_EX_OPB_REG_EN	<= '1';
		DPA_EX_OPC_REG_EN	<= '1';
		DPA_EX_SHIFT_REG_EN	<= '1';
		DPA_MEM_RES_REG_EN	<= '1';
		DPA_MEM_CC_REG_EN	<= '1';
		DPA_WB_LOAD_REG_EN	<= '1';
		DPA_WB_RES_REG_EN	<= '1';
		DPA_WB_CC_REG_EN	<= '1';
		
--	OPB_REg und SHIFT_REG koennen durch Direktoperanden initialisiert werden		
		DPA_ID_OPB_MUX_CTRL	<= '1';
		DPA_ID_SHIFT_MUX_CTRL	<= '0';
--	Initial alle Bypassmultiplexer in den Modus zum Durchleiten von Operanden schalten
		DPA_EX_OPA_MUX_CTRL	<= "00";
		DPA_EX_OPB_MUX_CTRL	<= "00";
		DPA_EX_OPC_MUX_CTRL	<= "00";
		DPA_EX_SHIFT_MUX_CTRL	<= "00";
		DPA_EX_CC_MUX_CTRL	<= "00";

		DPA_MEM_WMP_DMAS 	<= DMAS_WORD;

--	Im ersten Takt LOAD_REG initialisieren
		DPA_MEM_CC_MUX_CTRL	<= '0';
		DPA_ID_IMMEDIATE	<= X"bbbbbbbb";
		DPA_ID_SHIFT_AMOUNT	<= "00" & X"d";
		DPA_MEM_DDIN		<= X"33333333";	
		signal_force("uut/EX_OPA_REG","16#aaaaaaaa",0 ns,freeze, -1 ms,1);
		signal_force("uut/EX_OPC_REG","16#cccccccc",0 ns,freeze, -1 ms,1);
		signal_force("uut/EX_SHIFT_REG","16#dd",0 ns,freeze, -1 ms,1);
		signal_force("uut/MEM_RES_REG","16#11111111",0 ns,freeze, -1 ms,1);
		signal_force("uut/WB_RES_REG","16#22222222",0 ns,freeze, -1 ms,1);
		signal_force("uut/MEM_CC_REG","16#4",0 ns,freeze, -1 ms,1);
		signal_force("uut/WB_CC_REG","16#5",0 ns,freeze, -1 ms,1);
		signal_force("uut/EX_CPSR","16#60000000",0 ns,freeze, -1 ms,1);
		SYNC_HIGH_DELAY(0.25);
--	Alle Registeraenderungen ausser durch signal_force erzwungene unterbinden		
		DPA_ENABLE	<= '0';
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPA_REG_EN	<= '0';
		DPA_EX_OPB_REG_EN	<= '0';
		DPA_EX_OPC_REG_EN	<= '0';
		DPA_EX_SHIFT_REG_EN	<= '0';
		DPA_MEM_RES_REG_EN	<= '0';
		DPA_MEM_CC_REG_EN	<= '0';
		DPA_WB_LOAD_REG_EN	<= '0';
		DPA_WB_RES_REG_EN	<= '0';
		DPA_WB_CC_REG_EN	<= '0';
		
		report SEPARATOR_LINE;	
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des OPA-Bypassmultiplexers";
		DPA_EX_OPA_MUX_CTRL <= "00";
		SYNC_HIGH_DELAY(0.25);
		if(OPA_BYPASS_MUX_OUT /= X"aaaaaaaa")then
			report "DPA_EX_OPA_MUX_CTRL = 00; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPA_MUX_CTRL <= "01";
		SYNC_HIGH_DELAY(0.25);
		if(OPA_BYPASS_MUX_OUT /= X"11111111")then
			report "DPA_EX_OPA_MUX_CTRL = 01; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPA_MUX_CTRL <= "10";
		SYNC_HIGH_DELAY(0.25);
		if(OPA_BYPASS_MUX_OUT /= X"22222222")then
			report "DPA_EX_OPA_MUX_CTRL = 10; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPA_MUX_CTRL <= "11";
		SYNC_HIGH_DELAY(0.25);
		if(OPA_BYPASS_MUX_OUT /= X"33333333")then
			report "DPA_EX_OPA_MUX_CTRL = 11; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPA_MUX_CTRL <= "00";
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des OPB-Bypassmultiplexers";
		DPA_EX_OPB_MUX_CTRL <= "00";
		SYNC_HIGH_DELAY(0.25);
		if(OPB_BYPASS_MUX_OUT /= X"bbbbbbbb")then
			report "DPA_EX_OPB_MUX_CTRL = 00; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPB_MUX_CTRL <= "01";
		SYNC_HIGH_DELAY(0.25);
		if(OPB_BYPASS_MUX_OUT /= X"11111111")then
			report "DPA_EX_OPB_MUX_CTRL = 01; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPB_MUX_CTRL <= "10";
		SYNC_HIGH_DELAY(0.25);
		if(OPB_BYPASS_MUX_OUT /= X"22222222")then
			report "DPA_EX_OPB_MUX_CTRL = 10; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPB_MUX_CTRL <= "11";
		SYNC_HIGH_DELAY(0.25);
		if(OPB_BYPASS_MUX_OUT /= X"33333333")then
			report "DPA_EX_OPB_MUX_CTRL = 11; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPB_MUX_CTRL <= "00";
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des OPC-Bypassmultiplexers";
		DPA_EX_OPC_MUX_CTRL <= "00";
		SYNC_HIGH_DELAY(0.25);
		if(OPC_BYPASS_MUX_OUT /= X"cccccccc")then
			report "DPA_EX_OPC_MUX_CTRL = 00; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPC_MUX_CTRL <= "01";
		SYNC_HIGH_DELAY(0.25);
		if(OPC_BYPASS_MUX_OUT /= X"11111111")then
			report "DPA_EX_OPC_MUX_CTRL = 01; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPC_MUX_CTRL <= "10";
		SYNC_HIGH_DELAY(0.25);
		if(OPC_BYPASS_MUX_OUT /= X"22222222")then
			report "DPA_EX_OPC_MUX_CTRL = 10; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPC_MUX_CTRL <= "11";
		SYNC_HIGH_DELAY(0.25);
		if(OPC_BYPASS_MUX_OUT /= X"33333333")then
			report "DPA_EX_OPC_MUX_CTRL = 11; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_OPC_MUX_CTRL <= "00";
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des SHIFT-Bypassmultiplexers";
		DPA_EX_SHIFT_MUX_CTRL <= "00";
		SYNC_HIGH_DELAY(0.25);
		if(SHIFT_BYPASS_MUX_OUT /= X"dd")then
			report "DPA_EX_SHIFT_MUX_CTRL = 00; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_SHIFT_MUX_CTRL <= "01";
		SYNC_HIGH_DELAY(0.25);
		if(SHIFT_BYPASS_MUX_OUT /= X"11")then
			report "DPA_EX_SHIFT_MUX_CTRL = 01; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_SHIFT_MUX_CTRL <= "10";
		SYNC_HIGH_DELAY(0.25);
		if(SHIFT_BYPASS_MUX_OUT /= X"22")then
			report "DPA_EX_SHIFT_MUX_CTRL = 10; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_SHIFT_MUX_CTRL <= "11";
		SYNC_HIGH_DELAY(0.25);
		if(SHIFT_BYPASS_MUX_OUT /= X"33")then
			report "DPA_EX_SHIFT_MUX_CTRL = 11; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_SHIFT_MUX_CTRL <= "00";
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des CC-Bypassmultiplexers";
		DPA_EX_CC_MUX_CTRL <= "00";
		SYNC_HIGH_DELAY(0.25);
		if(CC_BYPASS_MUX_OUT /= X"6")then
			report "DPA_EX_CC_MUX_CTRL = 00; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_CC_MUX_CTRL <= "01";
		SYNC_HIGH_DELAY(0.25);
		if(CC_BYPASS_MUX_OUT /= X"4")then
			report "DPA_EX_CC_MUX_CTRL = 01; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_CC_MUX_CTRL <= "10";
		SYNC_HIGH_DELAY(0.25);
		if(CC_BYPASS_MUX_OUT /= X"5")then
			report "DPA_EX_CC_MUX_CTRL = 10; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_CC_MUX_CTRL <= "11";
		SYNC_HIGH_DELAY(0.25);
		if(CC_BYPASS_MUX_OUT /= X"5")then
			report "DPA_EX_CC_MUX_CTRL = 11; Wert des Bypassmultiplexers entspricht nicht dem Erwartungswert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		DPA_EX_CC_MUX_CTRL <= "00";
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des Instruktionsadressregisters, 0 nach Reset und halten des Initialwertes";
		DPA_ENABLE		<= '1';
		DPA_IF_IAR_INC		<= '0';
		DPA_WB_IAR_LOAD		<= '0';
		if(ADDRESS_INTEGER /= 0)then
			report "Instruktionsadresse unerwartet nicht null";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		if(NEXT_ADDRESS_INTEGER /= 1)then
			report "IAR_NEXT_ADDR_OUT entspricht nicht der inkrementierten Instruktionsadresse.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		if(ADDRESS_INTEGER /= 0)then
			report "Instruktionsadresse unerwartet nicht null";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		if(NEXT_ADDRESS_INTEGER /= 1)then
			report "IAR_NEXT_ADDR_OUT entspricht nicht der inkrementierten Instruktionsadresse.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des Instruktionsadressregisters, inkrementieren";
		DPA_IF_IAR_INC		<= '1';
		DPA_WB_IAR_LOAD		<= '0';
		DPA_ID_IAR_REVOKE	<= '0';
		DPA_IF_IAR_UPDATE_HB	<= '0';
		DPA_WB_IAR_MUX_CTRL	<= '0';
		DPA_ID_IAR_HISTORY_ID	<= "000";
		signal_force("uut/WB_RES_REG","16#7fff7000",0 ns,freeze, -1 ms,1);
		wait until DPA_CLK'event and DPA_CLK = '0';
		wait for ARM_SYS_CLK_PERIOD*0.25;
		if(ADDRESS_INTEGER /= 0)then
			report "Instruktionsadresse nach fallender Systemtaktflanke unerwartet nicht 0, evtl. erfolgen Schreibzugriffe auf der falschen Flanke.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		if(ADDRESS_INTEGER /= 1)then
			report "Instruktionsadresse nicht korrekt inkrementiert";
			report "Erwartungswert: 1";
		      	report "Gelesen: "& integer'image(ADDRESS_INTEGER);	
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		if(NEXT_ADDRESS_INTEGER /= 2)then
			report "IAR_NEXT_ADDR_OUT entspricht nicht der inkrementierten Instruktionsadresse.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		if(ADDRESS_INTEGER /= 2)then
			report "Instruktionsadresse nicht korrekt inkrementiert";
			report "Erwartungswert: 2";
		      	report "Gelesen: "& integer'image(ADDRESS_INTEGER);	
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		if(NEXT_ADDRESS_INTEGER /= 3)then
			report "IAR_NEXT_ADDR_OUT entspricht nicht der inkrementierten Instruktionsadresse.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		DPA_IF_IAR_INC		<= '0';
		SYNC_HIGH_DELAY(0.25);
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des Instruktionsadressregisters, laden";
		DPA_IF_IAR_INC		<= '0';
		DPA_WB_IAR_LOAD		<= '1';
		SYNC_HIGH_DELAY(0.25);
		if(EXTENDED_ADDR_OUT /= X"7fff7000")then
			report "Instruktionsadresse nicht korrekt geladen.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		if(EXTENDED_NEXT_ADDR_OUT /= X"7fff7004")then
			report "IAR_NEXT_ADDR_OUT entspricht nicht der inkrementierten Instruktionsadresse.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des Instruktionsadressregisters, gleichzeitiges Inkrementieren und Laden, Laden ist priorisiert.";
		DPA_IF_IAR_INC		<= '1';
		DPA_WB_IAR_LOAD		<= '1';
		signal_force("uut/WB_RES_REG","16#0000aaac",0 ns,freeze, -1 ms,1);
		SYNC_HIGH_DELAY(0.25);
		if(EXTENDED_ADDR_OUT /= X"0000aaac")then
			report "Instruktionsadresse nicht korrekt geladen.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		SYNC_HIGH_DELAY(0.25);
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des Instruktionsadressregisters, Puffern und Rekonstruieren von Adressen. Schreibzugriffe erfolgen synchron, lesen mit IAR_REVOKE = 1 und verschiedenen Werten fuer HISTORY_ID erfolgt asynchron";
		DPA_IF_IAR_INC		<= '0';
		DPA_WB_IAR_LOAD		<= '1';
		DPA_ID_IAR_REVOKE	<= '0';
		DPA_IF_IAR_UPDATE_HB	<= '1';

		DPA_ID_IAR_HISTORY_ID	<= "000";
		signal_force("uut/WB_RES_REG","16#0000bbbc",0 ns,freeze, -1 ms,1);
		SYNC_HIGH_DELAY(0.25);

		DPA_ID_IAR_HISTORY_ID	<= "001";
		signal_force("uut/WB_RES_REG","16#0000cccc",0 ns,freeze, -1 ms,1);
		SYNC_HIGH_DELAY(0.25);

		DPA_ID_IAR_HISTORY_ID	<= "010";
		signal_force("uut/WB_RES_REG","16#0000dddc",0 ns,freeze, -1 ms,1);
		SYNC_HIGH_DELAY(0.25);

		DPA_ID_IAR_HISTORY_ID	<= "011";
		signal_force("uut/WB_RES_REG","16#0000eeec",0 ns,freeze, -1 ms,1);
		SYNC_HIGH_DELAY(0.25);

		DPA_ID_IAR_HISTORY_ID	<= "100";
		signal_force("uut/WB_RES_REG","16#0000fffc",0 ns,freeze, -1 ms,1);
		SYNC_HIGH_DELAY(0.25);
		DPA_IF_IAR_UPDATE_HB	<= '0';
		DPA_WB_IAR_LOAD		<= '0';
		DPA_ID_IAR_REVOKE	<= '1';

		DPA_ID_IAR_HISTORY_ID	<= "000";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000aaac")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 000.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;

		DPA_ID_IAR_HISTORY_ID	<= "001";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000bbbc")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 001.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;

		DPA_ID_IAR_HISTORY_ID	<= "010";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000cccc")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 010.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;

		DPA_ID_IAR_HISTORY_ID	<= "011";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000dddc")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 011.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;

		DPA_ID_IAR_HISTORY_ID	<= "100";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000eeec")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 100.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		DPA_ID_IAR_HISTORY_ID	<= "000";
		SYNC_HIGH_DELAY(0.25);
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000aaac")then
			report "Eintrag im History Buffer wurde trotz DPA_IF_IAR_UPDATE_HB = 0 geaendert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		DPA_ENABLE <= '0';
		report SEPARATOR_LINE;	
--------------------------------------------------------------------------------			
		SIMULATION_RUNNING <= false;
		report SEPARATOR_LINE;	
		report SEPARATOR_LINE;	
		report "...Simulation beendet";
		report SEPARATOR_LINE;	
		report SEPARATOR_LINE;

		POINTS_BYPASS := 6;
		POINTS_IAR := 3;
		for i in 1 to NR_OF_TESTCASES loop
			report "Testcase " & integer'image(i) & ": " & integer'image(ERRORS_IN_TESTCASES(i)) & " Fehler";
			if(i<6)then
				if(ERRORS_IN_TESTCASES(i) > POINTS_BYPASS)then
					POINTS_BYPASS := 0;
				else	
					POINTS_BYPASS := POINTS_BYPASS - ERRORS_IN_TESTCASES(i);
				end if;
			else	
				if((ERRORS_IN_TESTCASES(i) > 0) and (POINTS_IAR > 0))then
					POINTS_IAR := POINTS_IAR - 1;
				end if;
			end if;
		end loop;
		report SEPARATOR_LINE;
		report "Errechnung der Punkte:";
		report TAB_CHAR & "In Testcases 1-5: 1 Punkt Abzug pro fehlerhafter Verbindung, minimal 0 Punkte, maximal 6 Punkte";
		report TAB_CHAR & "In Testcases 6-10: 1 Punkt Abzug pro fehlerhaftem Testcase, minimal 0 Punkte, maximal 3 Punkte";
		report "erzielte Punkte:";
			report TAB_CHAR & "IAR: " & integer'image(POINTS_IAR) & "/3 Punkte";
			report TAB_CHAR & "BYPASS: " & integer'image(POINTS_BYPASS) & "/6 Punkte";
			report TAB_CHAR & "Gesamt: " & integer'image(POINTS_BYPASS + POINTS_IAR) & "/9 Punkte";
		if (POINTS_BYPASS + POINTS_IAR = 9 ) then
			report "Funktionstest bestanden" severity note;
		else
			report "Funktionstest nicht bestanden" severity error;
			report "Funktionstest nicht bestanden" severity note;
		end if;

		report SEPARATOR_LINE;	
		report SEPARATOR_LINE;
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait; -- will wait forever
	end process tb;

end architecture behavior;
