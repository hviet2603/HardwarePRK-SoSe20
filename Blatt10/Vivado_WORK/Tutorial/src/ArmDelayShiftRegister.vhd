--------------------------------------------------------------------------------
--	Ein Schieberegister mit einem gemeinsamen ODER-Ausgang
--	zur termporaeren Signalmaskierung fuer das ARM-SoC
--------------------------------------------------------------------------------
--	Datum:		05.01.10
--	Version:	1.3
--------------------------------------------------------------------------------
--	Aenderungen:
--	DSR_EN als Enablesignal hinzugefuegt. Dies ist notwendig weil
--	der Kontrollpfad des ARM bei Bedarf durch ein WAIT-Signal 
--	vollstaendig angehalten werden muss und sich dieses Verhalten
--	(ausser durch clock gating) an diesem Modul nicht anderweitig 
--	erreichen laesst
-- 	EN gegen WAIT mit umgekehrter Funktion getauscht
-- 	Tiefe des Schieberegisters ist nun generisch um leichter an 
-- 	geaenderte Anforderungen in der Pipelinestruktur angepasst werden zu
-- 	koennen.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ArmDelayShiftRegister is
	generic(DSR_WIDTH : natural range 2 to 16 := 3);
	port(
		DSR_CLK : in STD_LOGIC;
		DSR_RST : in STD_LOGIC;
		DSR_WAIT: in std_logic;
		DSR_SET : in STD_LOGIC;
		DSR_OUT : out STD_LOGIC
	    );

end entity ArmDelayShiftRegister;

architecture structure of ArmDelayShiftRegister is
	signal SHIFT_REG : STD_LOGIC_VECTOR(DSR_WIDTH -1 downto 0);
begin
	SHIFT_DSR_SET : process(DSR_CLK)is
	begin
		if DSR_CLK'event and DSR_CLK = '1' then
			if DSR_RST = '1' then
				SHIFT_REG <= (others => '0');
			else
				if DSR_WAIT = '0' then
					SHIFT_REG <= DSR_SET & SHIFT_REG(DSR_WIDTH-1 downto 1);
				else
					SHIFT_REG <= SHIFT_REG;	
				end if;
			end if;
		end if;
	end process SHIFT_DSR_SET;

	SET_DSR_OUT : process(SHIFT_REG)is
		variable DSR_TEMP : std_logic := '0';
	begin
		DSR_TEMP := '0';
		for i in 0 to DSR_WIDTH -1 loop
			DSR_TEMP := DSR_TEMP or SHIFT_REG(i);
		end loop;
		DSR_OUT <= DSR_TEMP;	
	end process SET_DSR_OUT;

end architecture structure;
