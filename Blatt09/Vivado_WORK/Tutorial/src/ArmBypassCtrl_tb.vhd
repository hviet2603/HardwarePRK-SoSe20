--------------------------------------------------------------------------------
--	Testbench der Bypasssteuerung	
--------------------------------------------------------------------------------
--	Datum:		23.06.2010
--	Version:	1.00
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.TB_TOOLS.all;
use work.ArmConfiguration.all;


entity ArmBypassCtrl_tb is
end entity ArmBypassCtrl_tb;

architecture behavior of ArmBypassCtrl_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
	component ArmBypassCtrl
	port(	
		ABC_INST0_R_PORT_A_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST0_R_PORT_B_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST0_R_PORT_C_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST1_W_PORT_A_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST1_W_PORT_B_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST2_W_PORT_A_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST2_W_PORT_B_ADDR : in std_logic_vector(4 downto 0);
		ABC_INST1_W_PORT_A_EN	: in std_logic;
		ABC_INST1_W_PORT_B_EN	: in std_logic;
		ABC_INST2_W_PORT_A_EN	: in std_logic;
		ABC_INST2_W_PORT_B_EN	: in std_logic;	
		ABC_INST1_WB_PSR_EN	: in std_logic;
		ABC_INST1_WB_PSR_SET_CC : in std_logic;
		ABC_INST2_WB_PSR_EN	: in std_logic;
		ABC_INST2_WB_PSR_SET_CC : in std_logic;          
		ABC_INST0_REGS_USED	: in std_logic_vector(2 downto 0);
		ABC_INST0_SHIFT_REG_USED       : in std_logic;
		ABC_INST0_OPA_BYPASS_MUX_CTRL   : out std_logic_vector(1 downto 0);
		ABC_INST0_OPB_BYPASS_MUX_CTRL   : out std_logic_vector(1 downto 0);
		ABC_INST0_OPC_BYPASS_MUX_CTRL   : out std_logic_vector(1 downto 0);
		ABC_INST0_SHIFT_BYPASS_MUX_CTRL : out std_logic_vector(1 downto 0);
		ABC_INST0_CC_BYPASS_MUX_CTRL    : out std_logic_vector(1 downto 0);
		ABC_LOAD_USE_CONFLICT           : out std_logic
		);
	END COMPONENT;


	signal ABC_INST1_W_PORT_A_EN   :  std_logic := '0';
	signal ABC_INST1_W_PORT_B_EN   :  std_logic := '0';
	signal ABC_INST2_W_PORT_A_EN   :  std_logic := '0';
	signal ABC_INST2_W_PORT_B_EN   :  std_logic := '0';
	signal ABC_INST1_WB_PSR_EN     :  std_logic := '0';
	signal ABC_INST1_WB_PSR_SET_CC :  std_logic := '0';
	signal ABC_INST2_WB_PSR_EN     :  std_logic := '0';
	signal ABC_INST2_WB_PSR_SET_CC :  std_logic := '0';
	signal ABC_INST0_R_PORT_A_ADDR :  std_logic_vector(4 downto 0) := (others=>'0');
	signal ABC_INST0_R_PORT_B_ADDR :  std_logic_vector(4 downto 0) := (others=>'0');
	signal ABC_INST0_R_PORT_C_ADDR :  std_logic_vector(4 downto 0) := (others=>'0');
	signal ABC_INST1_W_PORT_A_ADDR :  std_logic_vector(4 downto 0) := (others=>'0');
	signal ABC_INST1_W_PORT_B_ADDR :  std_logic_vector(4 downto 0) := (others=>'0');
	signal ABC_INST2_W_PORT_A_ADDR :  std_logic_vector(4 downto 0) := (others=>'0');
	signal ABC_INST2_W_PORT_B_ADDR :  std_logic_vector(4 downto 0) := (others=>'0');
	signal ABC_INST0_REGS_USED     : std_logic_vector(2 downto 0) := "000";
	signal ABC_INST0_SHIFT_REG_USED :std_logic := '0';

	--Outputs
	signal ABC_INST0_OPA_BYPASS_MUX_CTRL   :  std_logic_vector(1 downto 0);
	signal ABC_INST0_OPB_BYPASS_MUX_CTRL   :  std_logic_vector(1 downto 0);
	signal ABC_INST0_OPC_BYPASS_MUX_CTRL   :  std_logic_vector(1 downto 0);
	signal ABC_INST0_SHIFT_BYPASS_MUX_CTRL :  std_logic_vector(1 downto 0);
	signal ABC_INST0_CC_BYPASS_MUX_CTRL    :  std_logic_vector(1 downto 0);
	signal ABC_LOAD_USE_CONFLICT           :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: ArmBypassCtrl PORT MAP(
		ABC_INST0_R_PORT_A_ADDR		=> ABC_INST0_R_PORT_A_ADDR,
		ABC_INST0_R_PORT_B_ADDR		=> ABC_INST0_R_PORT_B_ADDR,
		ABC_INST0_R_PORT_C_ADDR		=> ABC_INST0_R_PORT_C_ADDR,
		ABC_INST1_W_PORT_A_ADDR		=> ABC_INST1_W_PORT_A_ADDR,
		ABC_INST1_W_PORT_B_ADDR		=> ABC_INST1_W_PORT_B_ADDR,
		ABC_INST2_W_PORT_A_ADDR		=> ABC_INST2_W_PORT_A_ADDR,
		ABC_INST2_W_PORT_B_ADDR		=> ABC_INST2_W_PORT_B_ADDR,
		ABC_INST1_W_PORT_A_EN		=> ABC_INST1_W_PORT_A_EN,
		ABC_INST1_W_PORT_B_EN		=> ABC_INST1_W_PORT_B_EN,
		ABC_INST2_W_PORT_A_EN		=> ABC_INST2_W_PORT_A_EN,
		ABC_INST2_W_PORT_B_EN		=> ABC_INST2_W_PORT_B_EN,
		ABC_INST1_WB_PSR_EN		=> ABC_INST1_WB_PSR_EN,
		ABC_INST1_WB_PSR_SET_CC		=> ABC_INST1_WB_PSR_SET_CC,
		ABC_INST2_WB_PSR_EN		=> ABC_INST2_WB_PSR_EN,
		ABC_INST2_WB_PSR_SET_CC		=> ABC_INST2_WB_PSR_SET_CC,
		ABC_INST0_REGS_USED 		=> ABC_INST0_REGS_USED,
		ABC_INST0_SHIFT_REG_USED	=> ABC_INST0_SHIFT_REG_USED,
		ABC_INST0_OPA_BYPASS_MUX_CTRL	=> ABC_INST0_OPA_BYPASS_MUX_CTRL,
		ABC_INST0_OPB_BYPASS_MUX_CTRL	=> ABC_INST0_OPB_BYPASS_MUX_CTRL,
		ABC_INST0_OPC_BYPASS_MUX_CTRL	=> ABC_INST0_OPC_BYPASS_MUX_CTRL,
		ABC_INST0_SHIFT_BYPASS_MUX_CTRL	=> ABC_INST0_SHIFT_BYPASS_MUX_CTRL,
		ABC_INST0_CC_BYPASS_MUX_CTRL	=> ABC_INST0_CC_BYPASS_MUX_CTRL,
		ABC_LOAD_USE_CONFLICT		=> ABC_LOAD_USE_CONFLICT
	);

	tb : process
		type INST0_ADDR_TYPE is array(2 downto 0) of std_logic_vector(4 downto 0); --CBA
		type INST1_ADDR_TYPE is array(1 downto 0) of std_logic_vector(4 downto 0); --BA
		type EXPECTED_MUX_TYPE is array(4 downto 0) of std_logic_vector(1 downto 0); --CC,SHIFT,CBA
		variable EXPECTED_MUX : EXPECTED_MUX_TYPE := ("00","00","00","00","00");
		variable GOT_MUX : EXPECTED_MUX_TYPE;
		variable IS_CONFLICT, EXPECTED_CONFLICT : std_logic := '0';
		variable V_INST0_REGS_USED	: std_logic_vector(3 downto 0) := "0000"; --SHIFT,CBA
--		variable V_INST0_SHIFT_USED	: std_logic_vector(0 downto 0) := "0";
		variable V_INST0_ADDR : INST0_ADDR_TYPE := ("00001","00010","00011");
		variable V_INST1_ADDR : INST1_ADDR_TYPE := ("01110","01100");
		variable V_INST2_ADDR : INST1_ADDR_TYPE := ("01110","01100");
		variable V_INST1_WEN : std_logic_vector(1 downto 0) := "00"; --BA
		variable V_INST2_WEN : std_logic_vector(1 downto 0) := "00"; --BA
		variable V_INST1_REG_CTRL : std_logic_vector(1 downto 0) := "00";--WB_PSR_EN,WB_PSR_SET_CC
		variable V_INST2_REG_CTRL : std_logic_vector(1 downto 0) := "00"; --WB_PSR_EN, WB_PSR_SET_CC


		procedure SET_SIGNALS is
		begin
			ABC_INST1_W_PORT_B_EN <= V_INST1_WEN(1); ABC_INST1_W_PORT_A_EN <= V_INST1_WEN(0); 
			ABC_INST2_W_PORT_B_EN <= V_INST2_WEN(1); ABC_INST2_W_PORT_A_EN <= V_INST2_WEN(0); 
			ABC_INST0_R_PORT_C_ADDR <= V_INST0_ADDR(2);ABC_INST0_R_PORT_B_ADDR <= V_INST0_ADDR(1);ABC_INST0_R_PORT_A_ADDR <= V_INST0_ADDR(0);
			ABC_INST1_W_PORT_B_ADDR <= V_INST1_ADDR(1);ABC_INST1_W_PORT_A_ADDR <= V_INST1_ADDR(0);
			ABC_INST2_W_PORT_B_ADDR <= V_INST2_ADDR(1);ABC_INST2_W_PORT_A_ADDR <= V_INST2_ADDR(0);
			ABC_INST1_WB_PSR_EN  <= V_INST1_REG_CTRL(1); ABC_INST1_WB_PSR_SET_CC  <= V_INST1_REG_CTRL(0);
			ABC_INST2_WB_PSR_EN  <= V_INST2_REG_CTRL(1); ABC_INST2_WB_PSR_SET_CC  <= V_INST2_REG_CTRL(0);
			ABC_INST0_REGS_USED <= V_INST0_REGS_USED(2 downto 0);
			ABC_INST0_SHIFT_REG_USED <= V_INST0_REGS_USED(3);
		end procedure SET_SIGNALS;

		procedure GET_SIGNALS is
		begin
			GOT_MUX := (ABC_INST0_CC_BYPASS_MUX_CTRL,ABC_INST0_SHIFT_BYPASS_MUX_CTRL, ABC_INST0_OPC_BYPASS_MUX_CTRL,ABC_INST0_OPB_BYPASS_MUX_CTRL,ABC_INST0_OPA_BYPASS_MUX_CTRL);
			IS_CONFLICT := ABC_LOAD_USE_CONFLICT;
		end procedure GET_SIGNALS;

--		constant NR_OF_TESTCASES : natural := 43;
--------------------------------------------------------------------------------
--	Grenze des Arrays zum protokollieren der Fehler, die tatsaechliche
--	Anzahl der Testcases kann niedriger liegen.		
--------------------------------------------------------------------------------
		constant MAX_NR_OF_TESTCASES : natural := 100;
		type ERRORS_IN_TESTCASES_TYPE is array(1 to MAX_NR_OF_TESTCASES) of natural;
		variable ERRORS_IN_TESTCASES : ERRORS_IN_TESTCASES_TYPE := (others => 0);
		
		variable NR_OF_ERRORS		: integer := 0;
		variable ERRORS_IN_TESTCASE	: integer := 0;
		variable TESTCASE_NR		: natural := 1;	
		variable POINTS			: natural := 6;
		variable ERRORS			: natural := 0;

		variable PART1,PART2,PART3,PART4,PART5,PART6,PART7 : natural := 0;
		variable PART1_ER, PART2_ER, PART3_ER, PART4_ER, PART5_ER, PART6_ER, PART7_ER : natural := 0;

		procedure INC_ERRORS is
		begin
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end procedure INC_ERRORS;

		procedure COMPARE_SIGNALS is
		begin
			
			if EXPECTED_MUX(0) /= GOT_MUX(0) then
				report "OPA_MUX_CTRL nicht korrekt";
				report "Erzeugt: " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(GOT_MUX(0));
				report "Erwartet: "& TAB_CHAR & SLV_TO_STRING(EXPECTED_MUX(0));
				INC_ERRORS;
			end if;	
			if EXPECTED_MUX(1) /= GOT_MUX(1) then
				report "OPB_MUX_CTRL nicht korrekt";
				report "Erzeugt: " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(GOT_MUX(1));
				report "Erwartet: "& TAB_CHAR & SLV_TO_STRING(EXPECTED_MUX(1));
				INC_ERRORS;
			end if;	
			if EXPECTED_MUX(2) /= GOT_MUX(2) then
				report "OPC_MUX_CTRL nicht korrekt";
				report "Erzeugt: " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(GOT_MUX(2));
				report "Erwartet: "& TAB_CHAR & SLV_TO_STRING(EXPECTED_MUX(2));
				INC_ERRORS;
			end if;
			if EXPECTED_MUX(3) /= GOT_MUX(3) then
				report "SHIFT_MUX_CTRL nicht korrekt";
				report "Erzeugt: " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(GOT_MUX(3));
				report "Erwartet: "& TAB_CHAR & SLV_TO_STRING(EXPECTED_MUX(3));
				INC_ERRORS;
			end if;	
			if EXPECTED_MUX(4) /= GOT_MUX(4) then
				report "CC_MUX_CTRL nicht korrekt";
				report "Erzeugt: " & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(GOT_MUX(4));
				report "Erwartet: "& TAB_CHAR & SLV_TO_STRING(EXPECTED_MUX(4));
				INC_ERRORS;
			end if;	
			if IS_CONFLICT /= EXPECTED_CONFLICT then
				report "Load-Use-Konflikt-Signal nicht korrekt";
				if IS_CONFLICT = '1' then report "Erzeugt: 1"; else report "Erzeugt: 0"; end if;
				if EXPECTED_CONFLICT = '1' then report "Erwartet: 1"; else report "Erwartet: 0"; end if;
				INC_ERRORS;
			end if;	

			if(EXPECTED_MUX(4) /= GOT_MUX(4) or EXPECTED_MUX(3) /= GOT_MUX(3) OR EXPECTED_MUX(2) /= GOT_MUX(2) OR EXPECTED_MUX(1) /= GOT_MUX(1) OR EXPECTED_MUX(0) /= GOT_MUX(0) OR IS_CONFLICT /= EXPECTED_CONFLICT)then
				--Ausgabe der Testwerte
				report "INST0_SHIFT_REG_USED : "& TAB_CHAR & TAB_CHAR & TAB_CHAR & SLV_TO_STRING(V_INST0_REGS_USED(3 downto 3));
				report "INST0_REGS_USED-Steuersignale (C|B|A) : " & TAB_CHAR & SLV_TO_STRING(V_INST0_REGS_USED(2) & V_INST0_REGS_USED(1) & V_INST0_REGS_USED(0));
				report "Leseadressen von Instruktion 0 (A|B|C): " & TAB_CHAR & SLV_TO_STRING(V_INST0_ADDR(0)) & " | " & SLV_TO_STRING(V_INST0_ADDR(1)) & " | " & SLV_TO_STRING(V_INST0_ADDR(2)); 
				report "Schreibadressen von Instruktion 1 (A|B) : " & TAB_CHAR & SLV_TO_STRING(V_INST1_ADDR(0)) & " | " & SLV_TO_STRING(V_INST1_ADDR(1));
				report "Schreibadressen von Instruktion 2 (A|B) : " & TAB_CHAR & SLV_TO_STRING(V_INST2_ADDR(0)) & " | " & SLV_TO_STRING(V_INST2_ADDR(1));
				report "Write Enable Signale von Instruktion 1 (A|B) : " & TAB_CHAR & SLV_TO_STRING(V_INST1_WEN(0 downto 0)) & " | " & SLV_TO_STRING(V_INST1_WEN(1 downto 1));
				report "Write Enable Signale von Instruktion 2 (A|B) : " & TAB_CHAR & SLV_TO_STRING(V_INST2_WEN(0 downto 0)) & " | " & SLV_TO_STRING(V_INST2_WEN(1 downto 1));
				report "PSR-Steuersignale von Instruktion 1 (EN|SET_CC) : " & SLV_TO_STRING(V_INST1_REG_CTRL(1 downto 1)) & " | " & SLV_TO_STRING(V_INST1_REG_CTRL(0 downto 0));
				report "PSR-Steuersignale von Instruktion 2 (EN|SET_CC) : " & SLV_TO_STRING(V_INST2_REG_CTRL(1 downto 1)) & " | " & SLV_TO_STRING(V_INST2_REG_CTRL(0 downto 0));
			end if;
		end procedure COMPARE_SIGNALS;

		procedure EVAL(THIS_TESTCASE : inout natural range 1 to MAX_NR_OF_TESTCASES; THIS_ERRORS : inout natural; THIS_ERRORS_ARRAY : inout ERRORS_IN_TESTCASES_TYPE) is
		begin
			if THIS_ERRORS > 0 then
				report "Fehler in Testcase " & integer'image(THIS_TESTCASE) severity error;
				report "Fehler in Testcase " & integer'image(THIS_TESTCASE) severity note;
				THIS_ERRORS_ARRAY(THIS_TESTCASE) := THIS_ERRORS;
			else
				report "Testcase " & integer'image(THIS_TESTCASE) & " korrekt" severity note;
				THIS_ERRORS_ARRAY(THIS_TESTCASE) := 0;
			end if;
			if THIS_TESTCASE < MAX_NR_OF_TESTCASES then THIS_TESTCASE := THIS_TESTCASE + 1; end if;
			THIS_ERRORS := 0;
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
		end procedure EVAL;
	begin

		wait for 100 ns;

--------------------------------------------------------------------------------
--	Testfaelle, in denen aus verschiedenen Gruenden die Bypassleitungen
--	nicht geschaltet werden.

--------------------------------------------------------------------------------
		report SEPARATOR_LINE;
		report "Gemischte Testfaelle ohne aktivierte Bypaesse:";
		report SEPARATOR_LINE;
--	Testcase 1: keine Bypaesse weil die vorhergehenden Instruktionen nicht schreiben	
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_REGS_USED := "0111";
		V_INST0_ADDR:=("00000","00000","00000"); V_INST1_ADDR:=("00000","00000"); V_INST2_ADDR:=("00000","00000");
		 V_INST1_WEN := "00"; V_INST2_WEN := "00"; V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Testcase 2: keine Bypaesse aufgrund voellig unterschiedlicher Adressen
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		 V_INST0_ADDR:=("10000","10001","10010"); V_INST1_ADDR:=("00011","00100"); V_INST2_ADDR:=("00101","00110"); V_INST1_WEN := "11"; V_INST2_WEN := "11"; 
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS;EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Testcase 2: keine Bypaesse trotz passender Adressen an A und B, weil A und B nicht aus dem Registerspeicher stammen	
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_REGS_USED := "0100";
		 V_INST0_ADDR:=("00000","01000","01001"); V_INST1_ADDR:=("01000","01001"); V_INST2_ADDR:=("01000","01001"); V_INST1_WEN := "11"; V_INST2_WEN := "11"; 
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS;EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	keine Bypaesse weil zwar die Verwendung von SHIFT ausgezeigt wird, nicht jedoch C	
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_REGS_USED := "1000";
		 V_INST0_ADDR:=("10001","01000","01001"); V_INST1_ADDR:=("10001","10001"); V_INST2_ADDR:=("01000","10001"); V_INST1_WEN := "11"; V_INST2_WEN := "11"; 
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS;EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);


--	keine Bypaesse, weil Ergebnisse nicht zurueckgeschrieben werden und die PSR_EN Signale nicht gesetzt sind
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_REGS_USED := "0111";
		V_INST0_ADDR:=("00000","00001","00010"); V_INST1_ADDR:=("00001","00010"); V_INST2_ADDR:=("00101","00110"); V_INST1_WEN := "00"; V_INST2_WEN := "00"; 
		V_INST1_REG_CTRL := "01"; V_INST2_REG_CTRL := "01";
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	keine Bypaesse, weil Ergebnisse nicht zurueckgeschrieben werden und die PSR_SET_CC Signale nicht gesetzt sind
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00010"); V_INST1_ADDR:=("00001","00010"); V_INST2_ADDR:=("00101","00110"); V_INST1_WEN := "00"; V_INST2_WEN := "00"; 
		V_INST1_REG_CTRL := "10"; V_INST2_REG_CTRL := "10";
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

		PART1 := TESTCASE_NR-1;

--------------------------------------------------------------------------------
--	Bypaesse fuer Operand A
		report SEPARATOR_LINE;
		report "Test der Bypaesse von Operand A:";
		report SEPARATOR_LINE;
		V_INST0_REGS_USED := "1111";
--	Identische Adresse mit INST1_A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","10010"); V_INST1_ADDR:=("01111","10010"); V_INST2_ADDR:=("00101","00110"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","00","01"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00010"); V_INST1_ADDR:=("01111","01110"); V_INST2_ADDR:=("01111","00010"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","00","10"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_B
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00010"); V_INST1_ADDR:=("01111","01110"); V_INST2_ADDR:=("00010","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","00","11"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_A und INST1_A, INST1_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00010"); V_INST1_ADDR:=("01111","00010"); V_INST2_ADDR:=("01111","00010"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11"; V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","00","01"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_B und INST2_A, INST2_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00010"); V_INST1_ADDR:=("01111","01110"); V_INST2_ADDR:=("00010","00010"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","00","10"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST1_A, INST2_B INST2_A, INST1_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","11111"); V_INST1_ADDR:=("01111","11111"); V_INST2_ADDR:=("11111","11111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","00","01"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST1_A und INST1_B, INST1_A ist priorisiert, kein Konflikt
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","10000"); V_INST1_ADDR:=("10000","10000"); V_INST2_ADDR:=("01111","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","00","01"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

		PART2 := TESTCASE_NR-1;
--------------------------------------------------------------------------------
--	Bypaesse fuer Operand B
		report SEPARATOR_LINE;
		report "Test der Bypaesse von Operand B:";
		report SEPARATOR_LINE;
		V_INST0_REGS_USED := "1111";
--	Identische Adresse mit INST1_A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("10000","10001","10000"); V_INST1_ADDR:=("01111","10001"); V_INST2_ADDR:=("11111","11111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","01","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("01111","00001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","10","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_B
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("00001","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","11","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_A und INST1_A, INST1_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00000"); V_INST1_ADDR:=("01111","00001"); V_INST2_ADDR:=("01111","00001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","01","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_B und INST2_A, INST2_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","11001","00000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("11001","11001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","10","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST1_A, INST2_B INST2_A, INST1_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00000"); V_INST1_ADDR:=("01111","00001"); V_INST2_ADDR:=("00001","00001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","01","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST1_A und INST1_B, INST1_A ist priorisiert, kein Konflikt
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00000","00001","00000"); V_INST1_ADDR:=("00001","00001"); V_INST2_ADDR:=("01111","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","00","01","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);
		
		PART3 := TESTCASE_NR-1;
--------------------------------------------------------------------------------
--	Bypaesse fuer Operand C
		report SEPARATOR_LINE;
		report "Test der Bypaesse von Operand C:";
		report SEPARATOR_LINE;
		V_INST0_REGS_USED := "0111";
--	Identische Adresse mit INST1_A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00100","00000","00000"); V_INST1_ADDR:=("01111","00100"); V_INST2_ADDR:=("01111","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","00","01","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00100","00000","00000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("01111","00100"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","10","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_B
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00100","00000","00000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("00100","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","11","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_A und INST1_A, INST1_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00100","00000","00000"); V_INST1_ADDR:=("01111","00100"); V_INST2_ADDR:=("01111","00100"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","01","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_B und INST2_A, INST2_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00100","00000","00000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("00100","00100"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","10","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST1_A, INST2_B INST2_A, INST1_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00100","00000","00000"); V_INST1_ADDR:=("01111","00100"); V_INST2_ADDR:=("00100","00100"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","01","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST1_A und INST1_B, INST1_A ist priorisiert, kein Konflikt
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("10100","00000","00000"); V_INST1_ADDR:=("10100","10100"); V_INST2_ADDR:=("01111","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","01","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

		PART4 := TESTCASE_NR-1;
--------------------------------------------------------------------------------

--	Bypaesse fuer Operand SHIFT
		report SEPARATOR_LINE;
		report "Test der Bypaesse von Operand SHIFT im Verbund mit Operand C:";
		report SEPARATOR_LINE;
		V_INST0_REGS_USED := "1100";
--	Identische Adresse von INST0_C mit INST1_A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00111","00000","00000"); V_INST1_ADDR:=("01111","00111"); V_INST2_ADDR:=("00000","00000"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00","01","01","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00100","00000","00000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("01111","00100"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "10","10","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_B
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("01100","10000","01000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("01100","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "11","11","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_A und INST1_A, INST1_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00110","00000","00000"); V_INST1_ADDR:=("01111","00110"); V_INST2_ADDR:=("01111","00110"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "01","01","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST2_B und INST2_A, INST2_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00101","00000","00000"); V_INST1_ADDR:=("01111","01111"); V_INST2_ADDR:=("00101","00101"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "10","10","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST1_A, INST2_B INST2_A, INST1_A ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("10101","00000","00000"); V_INST1_ADDR:=("01111","10101"); V_INST2_ADDR:=("10101","10101"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "01","01","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Identische Adresse mit INST1_A und INST1_B, INST1_A ist priorisiert, kein Konflikt
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("10100","00000","00000"); V_INST1_ADDR:=("10100","10100"); V_INST2_ADDR:=("01111","01111"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "01","01","00","00"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

		PART5 := TESTCASE_NR-1;

--------------------------------------------------------------------------------
--	Bypaesse fuer CC, gleichzeitig mehrere der uebrigen Bypassleitungen geschaltet
		report SEPARATOR_LINE;
		report "Test der Bypaesse des Condition-Code, gleichzeit Erzeugung gemischter weiterer Bypaesse";
		report SEPARATOR_LINE;
		V_INST0_REGS_USED := "0111";
--	INST1 aktualisiert CC
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("01010","01001","01000"); V_INST1_ADDR:=("00000","01010"); V_INST2_ADDR:=("01000","01001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "11"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("01", "00","01","10","11"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	INST2 aktualisiert CC
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("01010","01010","01010"); V_INST1_ADDR:=("00000","01010"); V_INST2_ADDR:=("01000","01001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "11";
		EXPECTED_MUX := ("10", "00","01","01","01"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	INST2 und INST1 aktualisiert CC, INST1 ist priorisiert
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("01100","01100","01100"); V_INST1_ADDR:=("00000","01010"); V_INST2_ADDR:=("01100","01001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "11"; V_INST2_REG_CTRL := "11";
		EXPECTED_MUX := ("01", "00","11","11","11"); EXPECTED_CONFLICT := '0';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

		PART6 := TESTCASE_NR-1;
--------------------------------------------------------------------------------
--	LOAD-USE-Konflikte
		report SEPARATOR_LINE;
		report "Test auf Erkennung von Load-Use-Konflikten";
		report SEPARATOR_LINE;

--	Konflikt an A
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("01010","01001","11000"); V_INST1_ADDR:=("11000","01111"); V_INST2_ADDR:=("01000","01001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","00","10","00"); EXPECTED_CONFLICT := '1';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Konflikt an B
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("01010","00110","01010"); V_INST1_ADDR:=("00110","01010"); V_INST2_ADDR:=("01000","01001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","01","00","01"); EXPECTED_CONFLICT := '1';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Konflikt an C
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00011","01100","01100"); V_INST1_ADDR:=("00011","01010"); V_INST2_ADDR:=("01100","01001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","00","11","11"); EXPECTED_CONFLICT := '1';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Konflikt durch SHIFT
		V_INST0_REGS_USED := "1111";
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("00011","01100","01100"); V_INST1_ADDR:=("00011","01010"); V_INST2_ADDR:=("01100","01001"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","00","11","11"); EXPECTED_CONFLICT := '1';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);

--	Konflikt an allen Operanden
		report "Testcase " & integer'image(TESTCASE_NR) & ": ";
		V_INST0_ADDR:=("01111","01111","01111"); V_INST1_ADDR:=("01111","00000"); V_INST2_ADDR:=("00000","01000"); 
		V_INST1_WEN := "11"; V_INST2_WEN := "11";  V_INST1_REG_CTRL := "00"; V_INST2_REG_CTRL := "00";
		EXPECTED_MUX := ("00", "00","00","00","00"); EXPECTED_CONFLICT := '1';
		SET_SIGNALS; wait for ARM_SYS_CLK_PERIOD; GET_SIGNALS; COMPARE_SIGNALS; EVAL(TESTCASE_NR,ERRORS_IN_TESTCASE,ERRORS_IN_TESTCASES);
	
		PART7 := TESTCASE_NR-1;

--------------------------------------------------------------------------------

		for i in 1 to PART1 loop
			if ERRORS_IN_TESTCASES(i) > 0 then PART1_ER := PART1_ER + 1; end if;
		end loop;
		report "Fehler in Abschnitt 1 (keine Bypaesse): " & integer'image(PART1_ER);

		for i in PART1+1 to PART2 loop
			if ERRORS_IN_TESTCASES(i) > 0 then PART2_ER := PART2_ER + 1; end if;
		end loop;
		report "Fehler in Abschnitt 2 (Operand A - Bypaesse): " & integer'image(PART2_ER);

		for i in PART2+1 to PART3 loop
			if ERRORS_IN_TESTCASES(i) > 0 then PART3_ER := PART3_ER + 1; end if;
		end loop;
		report "Fehler in Abschnitt 3 (Operand B - Bypaesse): " & integer'image(PART3_ER);

		for i in PART3+1 to PART4 loop
			if ERRORS_IN_TESTCASES(i) > 0 then PART4_ER := PART4_ER + 1; end if;
		end loop;
		report "Fehler in Abschnitt 4 (Operand C - Bypaesse): " & integer'image(PART4_ER);

		for i in PART4+1 to PART5 loop
			if ERRORS_IN_TESTCASES(i) > 0 then PART5_ER := PART5_ER + 1; end if;
		end loop;
		report "Fehler in Abschnitt 5 (SHIFT - Bypaesse): " & integer'image(PART5_ER);

		for i in PART5+1 to PART6 loop
			if ERRORS_IN_TESTCASES(i) > 0 then PART6_ER := PART6_ER + 1; end if;
		end loop;
		report "Fehler in Abschnitt 6 (CC - Bypaesse): " & integer'image(PART6_ER);

		for i in PART6+1 to PART7 loop
			if ERRORS_IN_TESTCASES(i) > 0 then PART7_ER := PART7_ER + 1; end if;
		end loop;
		report "Fehler in Abschnitt 7 (Load-Use-Konflikte): " & integer'image(PART7_ER);

		if (PART1_ER > 0) and (POINTS > 0) then POINTS := POINTS - 1; end if;
		if (PART2_ER > 0) and (POINTS > 0) then POINTS := POINTS - 1; end if;
		if (PART3_ER > 0) and (POINTS > 0) then POINTS := POINTS - 1; end if;
		if (PART4_ER > 0) and (POINTS > 0) then POINTS := POINTS - 1; end if;
		if (PART5_ER > 0) and (POINTS > 0) then POINTS := POINTS - 1; end if;
		if (PART6_ER > 0) and (POINTS > 0) then POINTS := POINTS - 1; end if;
		if (PART7_ER > 0) and (POINTS > 0) then POINTS := POINTS - 1; end if;


		report SEPARATOR_LINE;
			if POINTS = 6 then
				report "Funktionstest bestanden." severity note;
			else
				report "Funktionstest nicht bestanden." severity note;
				report "Funktionstest nicht bestanden." severity error;			
			end if;
			report "Punkte: " & integer'image(POINTS) & "/6";
		report SEPARATOR_LINE;
		report "Simulation beendet.";
		report SEPARATOR_LINE;
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait; -- will wait forever
	end process;

end architecture behavior;

