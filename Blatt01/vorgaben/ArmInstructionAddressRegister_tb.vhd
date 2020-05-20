--------------------------------------------------------------------------------
--	Testbench zum Test des Instruktionsadressregisters
--------------------------------------------------------------------------------
--	Datum:		29.10.2013
--	Version:	0.1
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.INSTRUCTION_ID_WIDTH;
use work.ArmConfiguration.ARM_SYS_CLK_PERIOD;
use work.TB_Tools.SEPARATOR_LINE;
use work.TB_Tools.TAB_CHAR;

--- Kais Edit
-- Diese Bibliothek wird anscheinend gar nicht benutzt und wird nun aukommentiert
-- da sie die Moeglichkeit nimmt, es mit dem Vivado Simulator zu testen
--library modelsim_lib;
--use modelsim_lib.util.all;

entity ArmInstructionAddressRegister_tb is
end entity ArmInstructionAddressRegister_tb;

architecture behavior of ArmInstructionAddressRegister_tb is

component ArmInstructionAddressRegister is
	port(
		IAR_CLK 	: in std_logic;
		IAR_RST 	: in std_logic;
		IAR_INC		: in std_logic;
		IAR_LOAD 	: in std_logic;
		IAR_REVOKE	: in std_logic;
		IAR_UPDATE_HB	: in std_logic;
		IAR_HISTORY_ID	: in std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
		IAR_ADDR_IN 	: in std_logic_vector(31 downto 2);
		IAR_ADDR_OUT 	: out std_logic_vector(31 downto 2);
		IAR_NEXT_ADDR_OUT : out std_logic_vector(31 downto 2)
	    );

end component ArmInstructionAddressRegister;

-- Inputs
signal IAR_CLK 	:  std_logic := '0';
signal IAR_RST 	:  std_logic;
signal IAR_INC		:  std_logic;
signal IAR_LOAD 	:  std_logic;
signal IAR_REVOKE	:  std_logic;
signal IAR_UPDATE_HB	:  std_logic;
signal IAR_HISTORY_ID	:  std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
signal IAR_ADDR_IN 	:  std_logic_vector(31 downto 2);

-- Outputs
signal IAR_ADDR_OUT 	:  std_logic_vector(31 downto 2);
signal IAR_NEXT_ADDR_OUT :  std_logic_vector(31 downto 2);


-- Locals
constant NR_OF_TESTCASES	: natural := 5;
signal SIMULATION_RUNNING	: boolean := true;
signal ADDRESS_INTEGER: integer := 0;
signal NEXT_ADDRESS_INTEGER: integer := 0;
signal TESTCASE			: natural := 1;
signal EXTENDED_ADDR_OUT, EXTENDED_NEXT_ADDR_OUT	: std_logic_vector(31 downto 0);
signal WB_RES_REG : std_logic_vector (31 downto 0) := (others => '0');

begin

	-- Instantiate the Unit Under Test (UUT)
	uut : ArmInstructionAddressRegister port map (
		IAR_CLK => IAR_CLK,
		IAR_RST => IAR_RST,
		IAR_INC => IAR_INC,
		IAR_LOAD => IAR_LOAD,
		IAR_REVOKE => IAR_REVOKE,
		IAR_UPDATE_HB => IAR_UPDATE_HB,
		IAR_HISTORY_ID => IAR_HISTORY_ID,
		IAR_ADDR_IN => IAR_ADDR_IN,
		IAR_ADDR_OUT => IAR_ADDR_OUT,
		IAR_NEXT_ADDR_OUT => IAR_NEXT_ADDR_OUT
	);

	IAR_CLK <= not IAR_CLK after ARM_SYS_CLK_PERIOD/2 when SIMULATION_RUNNING else '0';
	IAR_RST <= '0', '1' after (ARM_SYS_CLK_PERIOD*1.75), '0' after (ARM_SYS_CLK_PERIOD*4.25);
	ADDRESS_INTEGER	<= to_integer(unsigned(IAR_ADDR_OUT));
	NEXT_ADDRESS_INTEGER <= to_integer(unsigned(IAR_NEXT_ADDR_OUT)); -- maybe extennsion to 32 bit required
	EXTENDED_ADDR_OUT		<= IAR_ADDR_OUT & "00";
	EXTENDED_NEXT_ADDR_OUT		<= IAR_NEXT_ADDR_OUT & "00";

	IAR_ADDR_IN <= WB_RES_REG(31 downto 2);

	tb : process
		type ERRORS_IN_TESTCASES_TYPE is array(1 to NR_OF_TESTCASES) of natural;
		variable TESTCASE_NR : integer := 1;
		variable ERRORS_IN_TESTCASE	: natural := 0;
		variable ERRORS_IN_TESTCASES 	: ERRORS_IN_TESTCASES_TYPE := (others => 0);
		variable POINTS_IAR : natural := 0;

		procedure SYNC_HIGH_DELAY(THIS_DELAY: in real) is
		begin
			wait until IAR_CLK'event and IAR_CLK = '1';
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
		IAR_INC <= '0';
		IAR_LOAD <= '0';
		IAR_REVOKE <= '0';
		IAR_UPDATE_HB <= '0';
		IAR_HISTORY_ID <= (others => '0');
		WB_RES_REG <= X"22222222";


		wait for ARM_SYS_CLK_PERIOD*10.25;

--------------------------------------------------------------------------------
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des Instruktionsadressregisters, 0 nach Reset und halten des Initialwertes";
		IAR_INC <= '0';
		IAR_LOAD <= '0';
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
		IAR_INC		<= '1';
		IAR_LOAD		<= '0';
		IAR_REVOKE	<= '0';
		IAR_UPDATE_HB	<= '0';
		IAR_HISTORY_ID	<= "000";
		WB_RES_REG <= X"7fff7000";
		wait until IAR_CLK'event and IAR_CLK = '0';
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
		SYNC_HIGH_DELAY(0.25);
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;

--------------------------------------------------------------------------------
		report "Testcase : " & integer'image(TESTCASE_NR) & ": Test des Instruktionsadressregisters, laden";
		IAR_LOAD		<= '1';
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
		IAR_INC		<= '1';
		IAR_LOAD	<= '1';
		WB_RES_REG <= X"0000aaac";
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
		IAR_INC		<= '0';
		IAR_LOAD		<= '1';
		IAR_REVOKE	<= '0';
		IAR_UPDATE_HB	<= '1';

		IAR_HISTORY_ID	<= "000";
		WB_RES_REG <= X"0000bbbc";
		SYNC_HIGH_DELAY(0.25);

		IAR_HISTORY_ID	<= "001";
		WB_RES_REG <= X"0000cccc";
		SYNC_HIGH_DELAY(0.25);

		IAR_HISTORY_ID	<= "010";
		WB_RES_REG <= X"0000dddc";
		SYNC_HIGH_DELAY(0.25);

		IAR_HISTORY_ID	<= "011";
		WB_RES_REG <= X"0000eeec";
		SYNC_HIGH_DELAY(0.25);

		IAR_HISTORY_ID	<= "100";
		WB_RES_REG <= X"0000fffc";
		SYNC_HIGH_DELAY(0.25);
		IAR_UPDATE_HB	<= '0';
		IAR_LOAD		<= '0';
		IAR_REVOKE	<= '1';

		IAR_HISTORY_ID	<= "000";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000aaac")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 000.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;

		IAR_HISTORY_ID	<= "001";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000bbbc")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 001.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;

		IAR_HISTORY_ID	<= "010";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000cccc")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 010.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;

		IAR_HISTORY_ID	<= "011";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000dddc")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 011.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;

		IAR_HISTORY_ID	<= "100";
		wait for ARM_SYS_CLK_PERIOD * 0.3;
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000eeec")then
			report "IAR_NEXT_ADDR_OUT nicht korrekt fuer HISTORY_ID = 100.";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		IAR_HISTORY_ID	<= "000";
		SYNC_HIGH_DELAY(0.25);
		if(EXTENDED_NEXT_ADDR_OUT /= X"0000aaac")then
			report "Eintrag im History Buffer wurde trotz DPA_IF_IAR_UPDATE_HB = 0 geaendert";
			ERRORS_IN_TESTCASE := ERRORS_IN_TESTCASE + 1;
		end if;
		EVAL(TESTCASE_NR, ERRORS_IN_TESTCASE, ERRORS_IN_TESTCASES);
		report SEPARATOR_LINE;

--------------------------------------------------------------------------------
		SIMULATION_RUNNING <= false;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "...Simulation beendet";
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;

		POINTS_IAR := 3;
		for i in 1 to NR_OF_TESTCASES loop
			report "Testcase " & integer'image(i) & ": " & integer'image(ERRORS_IN_TESTCASES(i)) & " Fehler";
			if((ERRORS_IN_TESTCASES(i) > 0) and (POINTS_IAR > 0))then
				POINTS_IAR := POINTS_IAR - 1;
			end if;
		end loop;
		report SEPARATOR_LINE;
		report "Errechnung der Punkte:";
		report TAB_CHAR & "1 Punkt Abzug pro fehlerhaftem Testcase, minimal 0 Punkte, maximal 3 Punkte";
		report "erzielte Punkte:";
			report TAB_CHAR & "IAR: " & integer'image(POINTS_IAR) & "/3 Punkte";
			report TAB_CHAR & "Gesamt: " & integer'image(POINTS_IAR) & "/3 Punkte";
		if (POINTS_IAR = 3 ) then
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
