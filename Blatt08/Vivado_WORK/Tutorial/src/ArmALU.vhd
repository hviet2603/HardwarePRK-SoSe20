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
signal ALU_RES_REF: std_logic_vector(32 downto 0);
signal CARRY: std_logic_vector(32 downto 0); 
signal RSV_CARRY: std_logic_vector(32 downto 0);
begin
CARRY <= '0' & x"00000000" when ALU_CC_IN(1) = '0' else
	     '0' & x"00000001" 			                   ;

RSV_CARRY <= '0' & x"00000001" when ALU_CC_IN(1) = '0' else
             '0' & x"00000000" 			                   ;
	     
ALU_RES_REF <= '0' & ALU_OP1 and '0' & ALU_OP2 				 		                                when ALU_CTRL="0000" else --AND: AND 
	           '0' & ALU_OP1 xor '0' & ALU_OP2					 		                            when ALU_CTRL="0001" else --EOR: XOR
                std_logic_vector(signed('0' & ALU_OP1) - signed('0' & ALU_OP2)) 		            when ALU_CTRL="0010" else --SUB: SUB
                std_logic_vector(signed('0' & ALU_OP2) - signed('0' & ALU_OP1)) 		            when ALU_CTRL="0011" else --RSB: Reverse SUB
                std_logic_vector(signed('0' & ALU_OP1) + signed('0' & ALU_OP2)) 		            when ALU_CTRL="0100" else --ADD: ADD
                std_logic_vector(signed('0' & ALU_OP1) + signed('0' & ALU_OP2) + signed(CARRY))     when ALU_CTRL="0101" else --ADC: ADD with Carry
                std_logic_vector(signed('0' & ALU_OP1) - signed('0' & ALU_OP2) - signed(RSV_CARRY)) when ALU_CTRL="0110" else --SBC: Subtract with Carry
                std_logic_vector(signed('0' & ALU_OP2) - signed('0' & ALU_OP1) - signed(RSV_CARRY)) when ALU_CTRL="0111" else --RSC: Reverse Subtract with Carry
                '0' & ALU_OP1 and '0' & ALU_OP2 						                            when ALU_CTRL="1000" else --TST: Test 
                '0' & ALU_OP1 xor '0' & ALU_OP2							                            when ALU_CTRL="1001" else --TEQ: Test Equivalence
                std_logic_vector(signed('0' & ALU_OP1) - signed('0' & ALU_OP2)) 		            when ALU_CTRL="1010" else --CMP: Compare
                std_logic_vector(signed('0' & ALU_OP1) + signed('0' & ALU_OP2)) 		            when ALU_CTRL="1011" else --CMN: Compare Negated
                '0' & ALU_OP1 or '0' & ALU_OP2							                            when ALU_CTRL="1100" else --ORR: OR
                '0' & ALU_OP2 								                                        when ALU_CTRL="1101" else --MOV: Move
                '0' & ALU_OP1 and (not ('0' & ALU_OP2)) 						                    when ALU_CTRL="1110" else --BIC: Bit Clear
                not ('0' & ALU_OP2)								                 	                                         ;--MVN: Move Not 
	   
-- Negativ
ALU_CC_OUT(3) <= ALU_RES_REF(31);
-- Zero
ALU_CC_OUT(2) <= '1' when ALU_RES_REF(31 downto 0) = x"00000000" else
                 '0'				                                 ;
-- Carry
ALU_CC_OUT(1) <= ALU_RES_REF(32) when ALU_CTRL="0100" or ALU_CTRL="0101" or ALU_CTRL="1011"                                           else  -- ADDs
                 not ALU_RES_REF(32) when ALU_CTRL="0010" or ALU_CTRL="0011" or ALU_CTRL="0110" or ALU_CTRL="0111" or ALU_CTRL="1010" else  -- SUBs
		         ALU_CC_IN(1)                                                                                                             ;
-- Overflow		  
ALU_CC_OUT(0) <= -- ADDs
                 (NOT ALU_OP1(31) AND NOT ALU_OP2(31) AND ALU_RES_REF(31)) OR (ALU_OP1(31) AND ALU_OP2(31) AND NOT ALU_RES_REF(31)) when ALU_CTRL="0100" or ALU_CTRL="0101" or ALU_CTRL="1011" else
                 -- SUBs
                 (NOT ALU_OP1(31) AND ALU_OP2(31) AND ALU_RES_REF(31)) OR (ALU_OP1(31) AND NOT ALU_OP2(31) AND NOT ALU_RES_REF(31)) when ALU_CTRL="0010" or ALU_CTRL="0110" or ALU_CTRL="1010" else
                 -- reverse SUBs
                 (NOT ALU_OP2(31) AND ALU_OP1(31) AND ALU_RES_REF(31)) OR (ALU_OP2(31) AND NOT ALU_OP1(31) AND NOT ALU_RES_REF(31)) when ALU_CTRL="0011" or ALU_CTRL="0111"                    else
                 -- LOGIC
                 ALU_CC_IN(0)                                                                                                                                                                      ;      

ALU_RES <= ALU_RES_REF(31 downto 0);
   
	   	
end architecture behave;
