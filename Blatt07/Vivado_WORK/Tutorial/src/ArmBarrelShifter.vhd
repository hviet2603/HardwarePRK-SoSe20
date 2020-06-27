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
		 SHIFTER_DEPTH : integer := 5 -- log_2(4)
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

type data_array is array(SHIFTER_DEPTH downto 0) of std_logic_vector(OPERAND_WIDTH-1 downto 0);
signal data: data_array;
type ctrl_array is array(SHIFTER_DEPTH-1 downto 0) of std_logic_vector(1 downto 0);
signal ctrl : ctrl_array;
signal case_of_rightshift: std_logic;

begin
	data(0) <= OPERAND;
	case_of_rightshift <= '1' when ARITH_SHIFT ='1' and data(0)(OPERAND_WIDTH -1 ) = '1' else 
		              '0';
	SHIFT_LAYER:for i in 0 to SHIFTER_DEPTH-1 generate
			ctrl(i) <= MUX_CTRL when AMOUNT(i) = '1' else
					    "00";
			MUX:for j in 0 to OPERAND_WIDTH - 1 generate
				LSBs:if j < 2**i  generate --LSBs
					MUX1:entity work.Mux port map (
						A => data(i)(j), --kein Shift
						B => '0',	 --Linksshift 
						C => data(i)(j+2**i),--Rechtsshift 
						D => data(i)(j+2**i),--Rechtsrotation 
						S => ctrl(i),
						MUX_OUT => data(i+1)(j)
					);
				end generate LSBs;
				
				MIDDLE_BITs:if j >= 2**i and j <= OPERAND_WIDTH - 1 - (2**i) generate --MIDDLE_BITs
					MUX2:entity work.Mux port map (
						A => data(i)(j), --kein Shift
						B => data(i)(j-2**i),	 --Linksshift 
						C => data(i)(j+2**i),--Rechtsshift 
						D => data(i)(j+2**i),--Rechtsrotation 
						S => ctrl(i),
						MUX_OUT => data(i+1)(j)
					);
				end generate MIDDLE_BITs;

				MSBs: if j > OPERAND_WIDTH - 1 - (2**i) generate --MSBs
					MUX3:entity work.Mux port map (
						A => data(i)(j), --kein Shift
						B => data(i)(j-2**i),	 --Linksshift 
						C => case_of_rightshift,--Rechtsshift 
						D => data(i)((j+(2**i)) mod OPERAND_WIDTH),--Rechtsrotation 
						S => ctrl(i),
						MUX_OUT => data(i+1)(j)
					);
				end generate MSBs;
			end generate MUX;
	end generate SHIFT_LAYER;
	DATA_OUT <=  data(SHIFTER_DEPTH);
	C_OUT <= C_IN when (to_integer(unsigned(AMOUNT)) = 0) else 
		 C_IN when (to_integer(unsigned(AMOUNT)) /= 0) and MUX_CTRL = "00" else
		 OPERAND(to_integer(unsigned(AMOUNT))-1) when MUX_CTRL = "10" else
		 OPERAND(to_integer(unsigned(AMOUNT))-1) when MUX_CTRL = "11" else
	         OPERAND((OPERAND_WIDTH) - to_integer(unsigned(AMOUNT))) when MUX_CTRL = "01" else
		 '0';
		 

end architecture structure;

