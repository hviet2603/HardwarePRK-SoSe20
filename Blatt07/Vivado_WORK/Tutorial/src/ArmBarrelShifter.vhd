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
use work.MUX4;

entity ArmBarrelShifter is
--------------------------------------------------------------------------------
--	Breite der Operanden (n) und die Zahl der notwendigen
--	Multiplexerstufen (m) um Shifts von 0 bis n-1 Stellen realisieren zu
--	koennen. Es muss gelten: ???
--------------------------------------------------------------------------------
	generic (OPERAND_WIDTH : integer := 4;	
		 SHIFTER_DEPTH : integer := 2; -- log_2(4)
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

component MUX4 is
    port (
        A,B,C,D,S: in std_logic;
        MUX_OUT: out std_logic;
    )
end component MUX4;

signal i: integer;


begin





end architecture structure;

