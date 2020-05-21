--------------------------------------------------------------------------------
--	Testbench fuer den ArmRAMB_4kx8 
--	
--------------------------------------------------------------------------------
--	Datum:		02.05.2013
--	Version:	1.00
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

library work;
use work.ArmConfiguration.ARM_SYS_CLK_PERIOD;
use work.tb_tools.SLV_TO_STRING;
use work.tb_tools.SEPARATOR_LINE;
use work.tb_tools.GET_RANDOM_SLV_ISIM;

entity ArmRAMB_4kx8_tb is
end entity ArmRAMB_4kx8_tb;

architecture behavioral of ArmRAMB_4kx8_tb is

	component ArmRAMB_4kx8 is
		generic (WIDTH : positive := 8;
				 SIZE  : positive := 4096);	
		port (RAM_CLK : in std_logic;
			ADDRA : in  std_logic_vector(integer(ceil(log2(real(SIZE))))-1 downto 0);
			DOA   : out std_logic_vector(WIDTH-1 downto 0);
			ENA	  : in  std_logic;
			ADDRB : in  std_logic_vector(integer(ceil(log2(real(SIZE))))-1 downto 0);
			DIB   : in  std_logic_vector(WIDTH-1 downto 0);
			DOB   : out std_logic_vector(WIDTH-1 downto 0);
			ENB	  : in  std_logic;
			WEB   : in  std_logic);
	end component ArmRAMB_4kx8;

	constant WIDTH : positive := 8;
	constant SIZE  : positive := 4096;	

	signal RAM_CLK : std_logic := '0';
	signal ADDRA : std_logic_vector(integer(ceil(log2(real(SIZE))))-1 downto 0) := (others => '0');
	signal DOA : std_logic_vector(WIDTH-1 downto 0);
	signal ENA : std_logic := '0';
	signal ADDRB : std_logic_vector(integer(ceil(log2(real(SIZE))))-1 downto 0) := (others => '0');
	signal DIB : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
	signal DOB : std_logic_vector(WIDTH-1 downto 0);
	signal ENB : std_logic := '0';
	signal WEB : std_logic := '0';


begin

	dut : ArmRAMB_4kx8 generic map (WIDTH,SIZE)
		port map (
		RAM_CLK => RAM_CLK,
		ADDRA => ADDRA,
		DOA => DOA,
--		DOA => open,
		ENA => ENA,
		ADDRB => ADDRB,
		DIB => DIB,
		DOB => DOB,
		ENB => ENB,
		WEB => WEB
	);

--	DOA <= (others => '0');

	RAM_CLK <= not(RAM_CLK) after ARM_SYS_CLK_PERIOD/2;

	test : process
		function check_mem_line (
			VAL: in std_logic_vector;
			REF: in std_logic_vector; 
			POS : in integer;
			C_PORT: in character;
			ERRORS: in natural 
		) return natural is
			variable RESULT : natural := 0;
		begin
			assert VAL'length = REF'length report "Bereiche von Parametern A und B verschieden";
			RESULT := ERRORS;
			if VAL /= REF then
				RESULT := RESULT + 1;
				if ERRORS < 10 then 	
					report "Port "& C_PORT & ": MEM["& integer'image(POS) & "] = " & SLV_TO_STRING(VAL) & "; erwartet wurde " & SLV_TO_STRING(REF);
				end if;
			end if;
			return RESULT;
		end function check_mem_line;

		procedure eval_testcase (
			NO : in positive;
			ERRORS : in natural) is
		begin
			if ERRORS /= 0 then 
				report "Testcase " & integer'image(NO) & " nicht bestanden!";
			else 
				report "Testcase " & integer'image(NO) & " bestanden!";
			end if;
			report SEPARATOR_LINE;
			report SEPARATOR_LINE;
		end procedure eval_testcase;
			
		type	REFERENCE_MEMORY_TYPE is array (0 to SIZE-1) of std_logic_vector(WIDTH-1 downto 0);
		variable REF_MEMORY			: REFERENCE_MEMORY_TYPE := (others => (others => 'U'));

		constant NR_OF_TESTCASES : positive := 4;

		type ERROR_IN_TESTCASES_TYPE is array (1 to NR_OF_TESTCASES) of natural;
		variable NO_OF_ERRORS : ERROR_IN_TESTCASES_TYPE := (others => 0);

		variable CURRENT_TESTCASE : positive := 1;

		variable DATA_STIMULUS : std_logic_vector (WIDTH-1 downto 0);

		-- DEBUG
		--variable i : integer := 0;

	begin

		wait for 100 ns;
	
		report "Testcase " & integer'image(CURRENT_TESTCASE) &
				" : ENA = ENB '1', Auslesen des gesamten Speichers ueber beide Ports, Inhalt sollte others => 'U' sein";
		report SEPARATOR_LINE;
		for i in REF_MEMORY'range loop
			-- Port A
			ADDRA <= std_logic_vector(to_unsigned(i,ADDRA'length));
			ENA <= '1';
			wait for ARM_SYS_CLK_PERIOD;
			ADDRA <= std_logic_vector(to_unsigned(0,ADDRA'length));
			ENA <= '0';
			NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(i),DOA,i,'A',NO_OF_ERRORS(CURRENT_TESTCASE));
			wait for ARM_SYS_CLK_PERIOD;
			-- Port B
			ADDRB <= std_logic_vector(to_unsigned(i,ADDRB'length));
			ENB <= '1';
			wait for ARM_SYS_CLK_PERIOD;
			ADDRB <= std_logic_vector(to_unsigned(0,ADDRB'length));
			ENB <= '0';
			NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(i),DOB,i,'B',NO_OF_ERRORS(CURRENT_TESTCASE));
			wait for ARM_SYS_CLK_PERIOD;
		end loop;
		eval_testcase(NO => CURRENT_TESTCASE, ERRORS => NO_OF_ERRORS(CURRENT_TESTCASE));

		CURRENT_TESTCASE := CURRENT_TESTCASE + 1;

		report "Testcase " & integer'image(CURRENT_TESTCASE) &
				" : ENA = ENB = '1', WEB = '1': Beschreiben des gesamten Speichers";
		report SEPARATOR_LINE;
		for i in REF_MEMORY'range loop
			ENB <= '1';
			WEB <= '1';
			ADDRB <= std_logic_vector(to_unsigned(i,ADDRB'length));
			GET_RANDOM_SLV_ISIM(DATA_STIMULUS);
			DIB <= DATA_STIMULUS;
			REF_MEMORY(i) := DATA_STIMULUS;
			wait for ARM_SYS_CLK_PERIOD;
			ENB <= '0';
			WEB <= '0';
			wait for ARM_SYS_CLK_PERIOD;
		end loop;
		report " ENA = ENB = '1', WEB = '0': Auslesen des gesamten Speichers über beide Ports";
		for i in REF_MEMORY'range loop
			-- Port A
			ADDRA <= std_logic_vector(to_unsigned(i,ADDRA'length));
			ENA <= '1';
			wait for ARM_SYS_CLK_PERIOD;
			NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(i),DOA,i,'A',NO_OF_ERRORS(CURRENT_TESTCASE));
			wait for ARM_SYS_CLK_PERIOD;
			ADDRA <= std_logic_vector(to_unsigned(0,ADDRA'length));
			ENA <= '0';
			wait for ARM_SYS_CLK_PERIOD;
			-- Port B
			ADDRB <= std_logic_vector(to_unsigned(REF_MEMORY'high-i,ADDRB'length));
			ENB <= '1';
			wait for ARM_SYS_CLK_PERIOD;
			NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(REF_MEMORY'high-i),DOB,REF_MEMORY'high-i,'B',NO_OF_ERRORS(CURRENT_TESTCASE));
			wait for ARM_SYS_CLK_PERIOD;
			ADDRB <= std_logic_vector(to_unsigned(0,ADDRB'length));
			ENB <= '0';
			wait for ARM_SYS_CLK_PERIOD;
		end loop;
		eval_testcase(NO => CURRENT_TESTCASE, ERRORS => NO_OF_ERRORS(CURRENT_TESTCASE));
	
		CURRENT_TESTCASE := CURRENT_TESTCASE + 1;
		report "Testcase " & integer'image(CURRENT_TESTCASE) &
			" : halten der Adresse wenn EN auf 0 gesetzt wird";
		for i in REF_MEMORY'range loop
			ADDRA <= std_logic_vector(to_unsigned(i,ADDRA'length));
			ENA <= '1';
			wait for ARM_SYS_CLK_PERIOD;
			ENA <= '0';
			for j in i to REF_MEMORY'high loop
				NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(i),DOA,i,'A',NO_OF_ERRORS(CURRENT_TESTCASE));
				wait for ARM_SYS_CLK_PERIOD;
			end loop;
			ADDRB <= std_logic_vector(to_unsigned(REF_MEMORY'high-i,ADDRB'length));
			ENB <= '1';
			wait for ARM_SYS_CLK_PERIOD;
			ENB <= '0';
			for j in REF_MEMORY'high-i downto 0 loop
				NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(REF_MEMORY'high-i),DOB,REF_MEMORY'high-i,'B',NO_OF_ERRORS(CURRENT_TESTCASE));
				wait for ARM_SYS_CLK_PERIOD;
			end loop;
		end loop;
		eval_testcase(NO => CURRENT_TESTCASE, ERRORS => NO_OF_ERRORS(CURRENT_TESTCASE));

		CURRENT_TESTCASE := CURRENT_TESTCASE + 1;
		report "Testcase " & integer'image(CURRENT_TESTCASE) &
			" : simultan Lesen und Schreiben";
		ENB <= '1';
		ENA <= '1';
		for i in REF_MEMORY'range loop
			ADDRB <= std_logic_vector(to_unsigned(i,ADDRB'length));
			wait for ARM_SYS_CLK_PERIOD;
			ADDRA <= std_logic_vector(to_unsigned(REF_MEMORY'high-i,ADDRA'length));
			WEB <= '1';
			GET_RANDOM_SLV_ISIM(DATA_STIMULUS); 
			DIB <= DATA_STIMULUS;
			NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(i),DOB,i,'B',NO_OF_ERRORS(CURRENT_TESTCASE)); -- old value
			wait for ARM_SYS_CLK_PERIOD;
			WEB <= '0';
			NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(REF_MEMORY'high-i),DOA,REF_MEMORY'high-i,'A',NO_OF_ERRORS(CURRENT_TESTCASE));
			NO_OF_ERRORS(CURRENT_TESTCASE) := check_mem_line(REF_MEMORY(i),DOB,i,'B',NO_OF_ERRORS(CURRENT_TESTCASE));
			REF_MEMORY(i) := DATA_STIMULUS;
			wait for ARM_SYS_CLK_PERIOD;
		end loop;
		ENB <= '0';
		ENA <= '0';
		eval_testcase(NO => CURRENT_TESTCASE, ERRORS => NO_OF_ERRORS(CURRENT_TESTCASE));

		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report "Auswertung: ";
		for i in NO_OF_ERRORS'range loop
			report "Testcase "&integer'image(i)&" : "&integer'image(NO_OF_ERRORS(i))&" Fehler";
		end loop;
		
		
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait; -- will wait forever

	end process test;

end architecture behavioral;

