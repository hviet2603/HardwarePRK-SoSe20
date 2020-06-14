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
	signal INST_7_4 : std_logic_vector(1 downto 0);
	signal INST_23_21_20: std_logic_vector(2 downto 0);
	signal INST_20_6: std_logic_vector(1 downto 0);
--	...

begin
	CID_DECODED_VECTOR	<= DECV;
--	...

--	INST_7_4 <= CID_INSTRUCTION(7) & CID_INSTRUCTION(4);
--	INST_23_21_20 <= CID_INSTRUCTION(23) & CID_INSTRUCTION(21) & CID_INSTRUCTION(20);
--	INST_20_6 <= CID_INSTRUCTION(20) & CID_INSTRUCTION(6);

INST_DECODER: process (CID_INSTRUCTION) is
begin
--if Is_X(CID_INSTRUCTION) then
--    DECV <= CD_UNDEFINED;
--else
    case CID_INSTRUCTION(27 downto 25) is
	
		when "111" =>
			if (CID_INSTRUCTION(24) = '1') then	
				DECV <= CD_SWI;
			else DECV <= CD_COPROCESSOR;
			end if;

		when "110" => DECV <= CD_COPROCESSOR;
	
		when "101" => DECV <= CD_BRANCH;
	
		when "100" => DECV <= CD_LOAD_STORE_MULTIPLE;

		when "011" =>
			if (CID_INSTRUCTION(4) = '1') then
				DECV <= CD_UNDEFINED;
			else DECV <= CD_LOAD_STORE_UNSIGNED_REGISTER;
			end if;

		when "010" => DECV <= CD_LOAD_STORE_UNSIGNED_IMMEDIATE;
		
		when "001" =>
			if (CID_INSTRUCTION(24 downto 23) = "10") then
				if (CID_INSTRUCTION(21 downto 20) = "10") then
					DECV <= CD_MSR_IMMEDIATE;
				elsif (CID_INSTRUCTION(21 downto 20) = "00") then
					DECV <= CD_UNDEFINED;
				else DECV <= CD_ARITH_IMMEDIATE; 
				end if;
			else DECV <= CD_ARITH_IMMEDIATE;
			end if;

		when others =>
			case CID_INSTRUCTION(7) & CID_INSTRUCTION(4) is
				when "11" =>
					case CID_INSTRUCTION(6 downto 5) is
						when "00" =>
							case CID_INSTRUCTION(24) is
								when '0' => DECV <= CD_MULTIPLY;
								when others => 	
									case CID_INSTRUCTION(23) & CID_INSTRUCTION(21) & CID_INSTRUCTION(20) is
										when "000" => DECV <= CD_SWAP;
										when others => DECV <= CD_UNDEFINED;
									end case;
							end case;
						when others =>
							case CID_INSTRUCTION(20) & CID_INSTRUCTION(6) is
								when "01" => DECV <= CD_UNDEFINED;
								when others =>
									case CID_INSTRUCTION(22) is
										when '1' => DECV <= CD_LOAD_STORE_SIGNED_IMMEDIATE;                                                    
										when others => DECV <= CD_LOAD_STORE_SIGNED_REGISTER;
									end case;							
							end case;	 
					end case;
				when "10" =>
					case CID_INSTRUCTION(24 downto 23) is
						when "10" =>
							if (CID_INSTRUCTION(20) = '1') then
								DECV <= CD_ARITH_REGISTER;
							else DECV <= CD_UNDEFINED;
							end if;
						when others => DECV <= CD_ARITH_REGISTER;
					end case;
				when "01" =>
					case CID_INSTRUCTION(24 downto 23) is
						when "10" =>
							if (CID_INSTRUCTION(20) = '1') then
								DECV <= CD_ARITH_REGISTER_REGISTER;
							else DECV <= CD_UNDEFINED;
							end if;
						when others => DECV <= CD_ARITH_REGISTER_REGISTER;
					end case;
				when others =>
					case CID_INSTRUCTION(24 downto 23) is
						when "10" =>
							if (CID_INSTRUCTION(20) = '1') then
								DECV <= CD_ARITH_REGISTER;
							else
								if (CID_INSTRUCTION(21) = '1') then
									DECV <= CD_MSR_REGISTER;
								else DECV <= CD_MRS;
								end if;
							end if;
						when others => DECV <= CD_ARITH_REGISTER;
					end case;
			end case;
	end case;	
--end if;

end process INST_DECODER;


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
