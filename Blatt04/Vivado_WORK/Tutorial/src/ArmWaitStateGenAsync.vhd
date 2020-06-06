library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------
--Waitstategenerator mit nicht registriertem (asynchronem) Ausgang. Das Wartesignal wird
--aktiviert, sobald das Startsignal gesetzt ist und gleichzeitig 
--der Initialwert größer null ist. Es wird davon ausgegangen, dass der Ausgang
--des Übergeordneten Moduls registriert ist. In diesem Fall liegt das Startsignal
--im gleichen Takt an, im dem das übergeordnete Modul das Wartesignal potentiell 
--erstmals überprüft.
--------------------------------------------------------------------------------

entity ArmWaitStateGenAsync is
	generic(COUNT_VALUE_WIDTH 	: positive := 32);
	port ( 	SYS_CLK 			: in std_logic;
			SYS_RST 			: in std_logic;
			WSG_COUNT_INIT 		: in std_logic_vector(COUNT_VALUE_WIDTH -1 downto 0);
			WSG_START 			: in std_logic;
			WSG_WAIT 			: out std_logic);
end entity ArmWaitStateGenAsync;

architecture behave of ArmWaitStateGenAsync is

signal COUNT_REG 	: unsigned(count_value_width -1 downto 0) := (others => '0');
signal COUNT_INIT	: unsigned(count_value_width -1 downto 0);
constant ZERO		: unsigned(count_value_width -1 downto 0) := (others => '0');

begin
	COUNT_INIT	<= unsigned(WSG_COUNT_INIT);
	WSG_WAIT	<= '1' when COUNT_REG > ZERO or (WSG_START = '1' and COUNT_INIT > ZERO) else '0';

--	Die Übernahme des Initialwertes erfolgt mit der steigenden Flanke, 
--	ebenso das Zählen. 
--	Das Wartesignal ist immer mind. einen Takt aktiv, auch wenn der 
--	Initialwert 0 ist. Bei Initialwerten > 0 wird der Wert bereits 
--	während der Übernahme dekrementiert, denn es handelt sich aus
--	Sicht des Übergeordneten Moduls bereits um den ersten Wartezyklus.

	wsg_init_and_count : process(SYS_CLK) 
	begin
		if SYS_CLK'event and SYS_CLK = '1' then
			if SYS_RST = '1' then
				COUNT_REG <= (others => '0');
			else
				if WSG_START = '1' then
					if(COUNT_INIT = ZERO) then
						COUNT_REG <= ZERO;
					else
						COUNT_REG <= COUNT_INIT -1 ;
					end if;	
				else
					if COUNT_REG > ZERO then
						COUNT_REG <= COUNT_REG -1;
					else
						COUNT_REG <= ZERO;
					end if;
				end if;
			end if;	
		end if;
	end process wsg_init_and_count;
end behave;


