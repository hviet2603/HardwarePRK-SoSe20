--------------------------------------------------------------------------------
--	Dekoder fuer die verschiedenen Coprozessorinstruktionen, wobei
--	hier nur die Instruktionstypen getrennt werden aber noch keine
--	coprozessorspezifischen Bedingungen erkannt.
--------------------------------------------------------------------------------
--	Datum:		26.10.09
--	Version:	1.0
--------------------------------------------------------------------------------
--	Aenderungen:
--	Fuer LDC/STC-Instruktionen ist die Kombination PUW=000 nicht definiert
--	und muss zu CIT_NON fuehren. Nur fuer diesen Test werden die 
--	Instruktionsbits 23 und 21 benoetigt, Bit 22 wird nur fuer die
--	zukuenftige Erweiterbarkeit gelesen aber aktuell nicht verwendet
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

entity ArmCopDecoder is
	port(
		ACD_INSTRUCTION_BITS	: in std_logic_vector(8 downto 0); --Instruktionsbits 27:20,4
		ACD_INSTRUCTION_TYPE	: out std_logic_vector(2 downto 0)
	    );
end entity ArmCopDecoder;

architecture behavioral of ArmCopDecoder is
	alias AIT		: std_logic_vector(2 downto 0) is ACD_INSTRUCTION_TYPE;
	alias INST_27_25	: std_logic_vector(2 downto 0) is ACD_INSTRUCTION_BITS(8 downto 6);
	alias INST_24		: std_logic is ACD_INSTRUCTION_BITS(5);
	alias INST_23		: std_logic is ACD_INSTRUCTION_BITS(4);
	alias INST_22		: std_logic is ACD_INSTRUCTION_BITS(3);
	alias INST_21		: std_logic is ACD_INSTRUCTION_BITS(2);
	alias INST_20		: std_logic is ACD_INSTRUCTION_BITS(1);
	alias INST_4		: std_logic is ACD_INSTRUCTION_BITS(0);
	alias INST_24_21	: std_logic_vector(3 downto 0) is ACD_INSTRUCTION_BITS(5 downto 2);
begin
	DETERMINE_INSTRUCTION_TYPE : process(ACD_INSTRUCTION_BITS, INST_27_25, INST_24_21, INST_24, INST_23, INST_22, INST_21, INST_20, INST_4)is
	begin
		AIT <= CIT_NON;
		case INST_27_25 is
			when "111"	=>
				if INST_24 = '0' then
					if INST_4 = '0' then
						AIT <= CIT_CDP;
					else
						if INST_20 = '0' then
							AIT <= CIT_MCR;
						else
							AIT <= CIT_MRC;
						end if;
					end if;
				else
					AIT <= CIT_NON;
				end if;
			when "110"	=>
--				PUNW darf nicht 00-0 sein => UNDEFINED
				if INST_24_21 = "0000" or INST_24_21 = "0010" then
					AIT <= CIT_NON;
				else
					if INST_20 = '0' then
						AIT <= CIT_STC;
					else
						AIT <= CIT_LDC;
					end if;
				end if;
			when others	=>
					AIT <= CIT_NON;	
		end case;
	end process DETERMINE_INSTRUCTION_TYPE;
end architecture BEHAVIORAL;

