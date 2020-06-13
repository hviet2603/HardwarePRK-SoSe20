--------------------------------------------------------------------------------
--	Decoder zur Ermittlung der Instruktionsgruppe der aktuellen
--	Instruktion im der ID-Stufe im Kontrollpfad des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2014
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

--------------------------------------------------------------------------------
--	17 Instruktionsgruppen:
--	CD_UNDEFINED
--	CD_SWI
--	CD_COPROCESSOR
--	CD_BRANCH
--	CD_LOAD_STORE_MULTIPLE
--	CD_LOAD_STORE_UNSIGNED_IMMEDIATE
--	CD_LOAD_STORE_UNSIGNED_REGISTER
--	CD_LOAD_STORE_SIGNED_IMMEDIATE
--	CD_LOAD_STORE_UNSIGNED_REGISTER
--	CD_ARITH_IMMEDIATE
--	CD_ARITH_REGISTER
--	CD_ARITH_REGISTER_REGISTER
--	CD_MSR_IMMEDIATE
--	CD_MSR_REGISTER
--	CD_MRS
--	CD_MULTIPLY
--	CD_SWAP

-- 	UNDEFINED wird durch den Nullvektor angezeigt, die anderen
--	Befehlsgruppen durch einen 1-aus-16-Code.
--------------------------------------------------------------------------------

entity ArmCoarseInstructionDecoder is
	port(
		CID_INSTRUCTION		: in std_logic_vector(31 downto 0);
		CID_DECODED_VECTOR	: out std_logic_vector(15 downto 0)
	    );
end entity ArmCoarseInstructionDecoder;

architecture behave of ArmCoarseInstructionDecoder is
	signal DECV	: COARSE_DECODE_TYPE;
--	...

begin
	CID_DECODED_VECTOR	<= DECV;
--	...

	
	



--------------------------------------------------------------------------------
--	Test fuer die Verhaltenssimulation.
--------------------------------------------------------------------------------
-- synthesis translate_off
 	CHECK_NR_OF_SIGNALS : process(CID_INSTRUCTION,DECV)IS
 		variable NR : integer range 0 to 16 := 0;
 	begin
 		NR := 0;
 		for i in DECV'range loop
 			if DECV(i) = '1' then
 				NR := NR + 1;
 			end if;
 		end loop;
  		assert NR <= 1 report "Fehler in ArmCoarseInstructionDecoder: Instruktion nicht eindeutig erkannt." severity error;
 	end process CHECK_NR_OF_SIGNALS;
-- synthesis translate_on
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end architecture behave;
