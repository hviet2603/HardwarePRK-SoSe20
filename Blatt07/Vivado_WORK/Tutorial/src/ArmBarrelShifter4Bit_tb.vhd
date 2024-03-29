library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.TB_TOOLS.all;

entity ArmBarrelShifter4Bit_TB is
end ArmBarrelShifter4Bit_TB;

architecture testbench of ArmBarrelShifter4Bit_TB is
	component ArmBarrelShifter
	generic (
		OPERAND_WIDTH : integer := 4;	
		SHIFTER_DEPTH : integer := 2
	);
	port(	
		OPERAND	: in std_logic_vector(3 downto 0);
		MUX_CTRL 	: in std_logic_vector(1 downto 0);
    		AMOUNT 	: in std_logic_vector(1 downto 0);	
    		ARITH_SHIFT	: in std_logic; 
    		C_IN 		: in std_logic;
           	DATA_OUT 	: out std_logic_vector(3 downto 0);	
    		C_OUT 		: out std_logic
	); 
	end component ArmBarrelShifter;
	-- Signals
	signal OPERAND: std_logic_vector(3 downto 0);
	signal MUX_CTRL: std_logic_vector(1 downto 0);
	signal AMOUNT: std_logic_vector(1 downto 0);
	signal ARITH_SHIFT: std_logic;
	signal C_IN: std_logic;
	signal DATA_OUT: std_logic_vector(3 downto 0);
	signal C_OUT: std_logic;
	-- Counter
	signal i: integer;
	signal j: integer;
	-- Testcases
	signal NR_OF_ERRORS: integer := 0;
	signal ERRORS_IN_TEST_CASE: integer;
	type DATA is array (0 to 24) of std_logic_vector(3 downto 0);
	type CARRY is array (0 to 24) of std_logic; 
	signal DATA_REF: DATA := (
		"1001","1001","1001","1001",		-- NOTHING	
		"1001","0010","0100","1000",		-- SLL
		"1001","0100","0010","0001",		-- SRL
		"1001","1100","1110","1111",		-- SRA
		"1001","1100","0110","0011",		-- ROR
		"1001","0111","0111","0000","0000"	-- NOTHING
	);
	signal CARRY_BIT: CARRY := (
		'0', '0', '1', '0',
		'1', '1', '0', '0',
		'0', '1', '0', '0',
		'0', '1', '0', '0',
		'1', '1', '0', '0',
		'1', '1', '1', '0', '0'
	);
begin
--	Unit under Test
	UUT: ArmBarrelShifter port map (
		OPERAND 	=> OPERAND,
		MUX_CTRL 	=> MUX_CTRL,
		AMOUNT 	=> AMOUNT,
		ARITH_SHIFT 	=> ARITH_SHIFT,
		C_IN 		=> C_IN,
		DATA_OUT 	=> DATA_OUT,
		C_OUT		=> C_OUT
	);

--	Generate Input

	GEN_OPERAND: process 
	begin
		OPERAND <= "1001";
		wait for 210 ns;
		OPERAND <= "0111";
		wait for 20 ns;
		OPERAND <= "0000";
		wait;
	end process GEN_OPERAND;

	GEN_MUX_CTRL: process  
	begin
		MUX_CTRL <= "00";
		wait for 40 ns;
		MUX_CTRL <= "01";
		wait for 40 ns;
		MUX_CTRL <= "10";
		wait for 80 ns;
		MUX_CTRL <= "11";
		wait for 40 ns;
		MUX_CTRL <= "00";
		wait;
	end process GEN_MUX_CTRL;
	
	GEN_AMOUNT: process
	begin
		for i in 0 to 4 loop
			AMOUNT <= "00";
			wait for 10 ns;
			AMOUNT <= "01";
			wait for 10 ns;
			AMOUNT <= "10";
			wait for 10 ns;
			AMOUNT <= "11";
			wait for 10 ns;
		end loop;
		AMOUNT <= "00";
		wait for 10 ns;
		AMOUNT <= "10";
		wait for 20 ns;
		AMOUNT <= "11";
		wait for 10 ns;
		AMOUNT <= "00";
		wait;
	end process GEN_AMOUNT;
	
	GEN_C_IN: process 
	begin 
		C_IN <= '0';
		wait for 20 ns;
		C_IN <= '1';
		wait for 10 ns;
		C_IN <= '0';
		wait for 10 ns;
		C_IN <= '1';
		wait for 10 ns;
		C_IN <= '0';
		wait for 50 ns;
		C_IN <= '1';
		wait for 10 ns;
		C_IN <= '0';
		wait for 50 ns;
		C_IN <= '1';
		wait for 10 ns;
		C_IN <= '0';
		wait for 30 ns;
		C_IN <= '1';
		wait for 30 ns;
		C_IN <= '0';
		wait;
	end process GEN_C_IN;
	
	GEN_ARITH_SHIFT: process
	begin
		ARITH_SHIFT <= '0';
		wait for 120 ns;
		ARITH_SHIFT <= '1';
		wait for 40 ns;
		ARITH_SHIFT <= '0';
		wait;
	end process GEN_ARITH_SHIFT;	
	
--	TESTBENCH
	tb: process

	begin
		for j in 0 to 24 loop
			ERRORS_IN_TEST_CASE <= 0;
			wait for 5 ns;
			report "Test " & integer'image(j+1) & ": OPERAND = " & SLV_TO_STRING(OPERAND) & " | MUX_CTRL = " & SLV_TO_STRING(MUX_CTRL) 
				& " | AMOUNT = " & integer'image(to_integer(unsigned(AMOUNT))) & " | ARITH_SHIFT = " & SL_TO_STRING(ARITH_SHIFT) 
				& " | C_IN = " & SL_TO_STRING(C_IN);
			if (DATA_OUT /= DATA_REF(j)) then
				report "DATA_OUT ist falsch";
				report "Erwartetes DATA_OUT: " & SLV_TO_STRING(DATA_REF(j));
				report "Aktuelles DATA_OUT: " & SLV_TO_STRING(DATA_OUT);
				ERRORS_IN_TEST_CASE <= ERRORS_IN_TEST_CASE + 1;
			end if;
			if (C_OUT /= CARRY_BIT(j)) then
				report "C_OUT ist falsch";
				report "Erwartetes C_OUT: " & SL_TO_STRING(CARRY_BIT(j));
				report "Aktuelles C_OUT: " & SL_TO_STRING(C_OUT);
				ERRORS_IN_TEST_CASE <= ERRORS_IN_TEST_CASE + 1;
			end if;
			NR_OF_ERRORS <= NR_OF_ERRORS + ERRORS_IN_TEST_CASE;
			wait for 5 ns;
		end loop;
		
		if (NR_OF_ERRORS = 0) then 
			report "Funktiontest bestanden."; 
		else 
			report "Funktiontest nicht bestanden: " & integer'image(NR_OF_ERRORS) & " Fehler.";		
		end if;

		report SEPARATOR_LINE;	
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait;
	end process tb;
		
end architecture testbench; 
