--------------------------------------------------------------------------------
-- 	Barrelshifter fuer LSL, LSR, ASR, ROR mit Shiftweiten von 0 bis 3 (oder 
--	generisch n-1) Bit. 
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
library work;
use work.MUX;
use ieee.numeric_std.all;
entity ArmBarrelShifter is
--------------------------------------------------------------------------------
--	Breite der Operanden (n) und die Zahl der notwendigen
--	Multiplexerstufen (m) um Shifts von 0 bis n-1 Stellen realisieren zu
--	koennen. Es muss gelten: ???
--------------------------------------------------------------------------------
	generic (OPERAND_WIDTH : integer := 32;	
		 SHIFTER_DEPTH : integer := 5  -- log_2(OPERAND_WIDTH)
	 );
	port (  OPERAND 	: in std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		MUX_CTRL 	: in std_logic_vector(1 downto 0);
    		AMOUNT 	: in std_logic_vector(SHIFTER_DEPTH-1 downto 0);	
    		ARITH_SHIFT    : in std_logic; 
    		C_IN 		: in std_logic;
           	DATA_OUT 	: out std_logic_vector(OPERAND_WIDTH-1 downto 0);	
    		C_OUT 		: out std_logic
	);
end entity ArmBarrelShifter;


architecture structure of ArmBarrelShifter is

type data_array is array(0 to OPERAND_WIDTH) of std_logic_vector(OPERAND_WIDTH-1 downto 0);
signal data: data_array := (others => (others => '0'));
signal case_of_rightshift: std_logic;
signal i: integer;
signal j: integer;

begin
	data(0) <= OPERAND;
	case_of_rightshift <= '1' when ARITH_SHIFT ='1' and data(0)(OPERAND_WIDTH -1 ) = '1' else 
		              '0';
	SHIFT_LAYER:for i in 0 to SHIFTER_DEPTH-1 generate
		CASE_SHIFT1: if AMOUNT(i) = '1' generate
			MUX:for j in 0 to OPERAND_WIDTH - 1 generate
				LSBs:if j < 2**i  generate --LSBs
					MUX1:entity work.Mux port map (
						A => data(i)(j), --kein Shift
						B => '0',	 --Linksshift 
						C => data(i)(j+2**i),--Rechtsshift 
						D => data(i)(j+2**i),--Rechtsrotation 
						S => MUX_CTRL,
						MUX_OUT => data(i+1)(j)
					);
				end generate LSBs;
				
				MIDDLE_BITs:if j >= 2**i and j <= OPERAND_WIDTH - 1 - (2**i) generate --MIDDLE_BITs
					MUX2:entity work.Mux port map (
						A => data(i)(j), --kein Shift
						B => data(i)(j-2**i),	 --Linksshift 
						C => data(i)(j+2**i),--Rechtsshift 
						D => data(i)(j+2**i),--Rechtsrotation 
						S => MUX_CTRL,
						MUX_OUT => data(i+1)(j)
					);
				end generate MIDDLE_BITs;

				MSBs: if j > OPERAND_WIDTH - 1 - (2**i) generate --MSBs
					MUX3:entity work.Mux port map (
						A => data(i)(j), --kein Shift
						B => data(i)(j-2**i),	 --Linksshift 
						C => case_of_rightshift,--Rechtsshift 
						D => data(i)((j+(2**i)) mod OPERAND_WIDTH),--Rechtsrotation 
						S => MUX_CTRL,
						MUX_OUT => data(i+1)(j)
					);
				end generate MSBs;
			end generate MUX;
		end generate CASE_SHIFT1;
		CASE_SHIFT2: if AMOUNT(i) = '0' generate
			MUX_ALL:for j in 0 to OPERAND_WIDTH - 1 generate
				MUX4:entity work.Mux port map (
					A => data(i)(j), --kein Shift
					B => data(i)(j), --Linksshift 
					C => data(i)(j), --Rechtsshift 
					D => data(i)(j), --Rechtsrotation 
					S => MUX_CTRL,
					MUX_OUT => data(i+1)(j)
				);
			end generate MUX_ALL;
		end generate CASE_SHIFT2;
	end generate SHIFT_LAYER;
	DATA_OUT <=  data(SHIFTER_DEPTH);
	C_OUT <= C_IN when (unsigned(AMOUNT) = 0) else
		 C_IN when (unsigned(AMOUNT) /= 0) and (MUX_CTRL = "00") else
		 OPERAND(to_integer(unsigned(AMOUNT))-1) when (unsigned(AMOUNT) /= 0) and MUX_CTRL = "10" else 
		 OPERAND(OPERAND_WIDTH - to_integer(unsigned(AMOUNT))) when (unsigned(AMOUNT) /= 0) and MUX_CTRL = "01" else 
		 C_IN;
		 

end architecture structure;

