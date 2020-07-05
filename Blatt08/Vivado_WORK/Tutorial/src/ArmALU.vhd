--------------------------------------------------------------------------------
--	ALU des ARM-Datenpfades
--------------------------------------------------------------------------------
--	Datum:		??.??.14
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.all;

entity ArmALU is
    Port ( ALU_OP1 		: in	std_logic_vector(31 downto 0);
           ALU_OP2 		: in 	std_logic_vector(31 downto 0);           
    	   ALU_CTRL 	: in	std_logic_vector(3 downto 0);
    	   ALU_CC_IN 	: in	std_logic_vector(1 downto 0);
		   ALU_RES 		: out	std_logic_vector(31 downto 0);
		   ALU_CC_OUT	: out	std_logic_vector(3 downto 0)
   	);
end entity ArmALU;

architecture behave of ArmALU is
signal CARRY: std_logic_vector(32 downto 0); 
begin
CARRY <= '0' & x"0000" when ALU_CC_IN(1) = '0' else
	 '0' & x"0001" 			     ;

ALU_RES_REF <= ALU_OP1 and ALU_OP2 				 		                when ALU_CTRL="0000" else --AND: AND 
	       ALU_OP1 xor ALU_OP2					 		        when ALU_CTRL="0001" else --EOR: XOR
	       std_logic_vector(unsigned(ALU_OP1) - unsigned(ALU_OP2)) 		        when ALU_CTRL="0010" else --SUB: SUB
	       std_logic_vector(unsigned(ALU_OP2) - unsigned(ALU_OP1)) 		        when ALU_CTRL="0011" else --RSB: Reverse SUB
	       std_logic_vector(unsigned(ALU_OP1) + unsigned(ALU_OP2)) 		        when ALU_CTRL="0100" else --ADD: ADD
	       std_logic_vector(unsigned(ALU_OP1) + unsigned(ALU_OP2) + unsigned(CARRY))     when ALU_CTRL="0101" else --ADC: ADD with Carry
	       std_logic_vector(unsigned(ALU_OP1) - unsigned(ALU_OP2) - unsigned(not CARRY)) when ALU_CTRL="0110" else --SBC: Subtract with Carry
	       std_logic_vector(unsigned(ALU_OP2) - unsigned(ALU_OP1) - unsigned(not CARRY)) when ALU_CTRL="0111" else --RSC: Reverse Subtract with Carry
	       ALU_OP1 and ALU_OP2 						                when ALU_CTRL="1000" else --TST: Test 
	       ALU_OP1 xor ALU_OP2							        when ALU_CTRL="1001" else --TEQ: Test Equivalence
	       std_logic_vector(unsigned(ALU_OP1) - unsigned(ALU_OP2)) 		        when ALU_CTRL="1010" else --CMP: Compare
	       std_logic_vector(unsigned(ALU_OP1) + unsigned(ALU_OP2)) 		        when ALU_CTRL="1011" else --CMN: Compare Negated
	       ALU_OP1 or ALU_OP2							        when ALU_CTRL="1100" else --ORR: OR
	       ALU_OP2 								        when ALU_CTRL="1101" else --MOV: Move
	       ALU_OP1 and not ALU_OP2 						        when ALU_CTRL="1110" else --BIC: Bit Clear
	       not ALU_OP2								                 	          ;--MVN: Move Not 
	   
ALU_CC_OUT(3) <= ALU_RES_REF(31); 	   
ALU_CC_OUT(2) <= '1' when ALU_RES_REF = x"0000" else
                 '0'				      ;
ALU_CC_OUT(1) <= ALU_RES_REF(32) when ALU_CTRL="0010" or ALU_CTRL="0011" or ALU_CTRL="0100" or ALU_CTRL="0101" or ALU_CTRL="0110" or ALU_CTRL="0111" or ALU_CTRL="1010" or ALU_CTRL="1011" else
		  ALU_CC_IN(1);
		  
ALU_CC_OUT(0) <= (NOT ALU_OP1(31) AND NOT ALU_OP2(31) AND ALU_RES_REF(31)) OR (ALU_OP1(31) AND ALU_OP2(31) AND NOT ALU_RES_REF(31)) when ALU_CTRL="0100" or ALU_CTRL="0101" or ALU_CTRL="1011" else
		  (NOT ALU_OP1(31) AND ALU_OP2(31) AND ALU_RES_REF(31)) OR (ALU_OP1(31) AND NOT ALU_OP2(31) AND NOT ALU_RES_REF(31)) when ALU_CTRL="0010" or ALU_CTRL="0110" or ALU_CTRL="1010" else
		  (NOT ALU_OP2(31) AND ALU_OP1(31) AND ALU_RES_REF(31)) OR (ALU_OP2(31) AND NOT ALU_OP1(31) AND NOT ALU_RES_REF(31)) when ALU_CTRL="0011" or ALU_CTRL="0111" else
		  ALU_CC_IN(0);      

ALU_RES <= ALU_RES_REF;
   
	   	
end architecture behave;
