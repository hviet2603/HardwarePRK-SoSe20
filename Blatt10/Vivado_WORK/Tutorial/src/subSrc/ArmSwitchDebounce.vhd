--------------------------------------------------------------------------------
--	Modul zum Entprellen eines einzelnen Signals fuer das ARM-SoC.
--------------------------------------------------------------------------------
--	Datum:		28.05.10
--	Version:	1.0
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.armconfiguration.all;

--------------------------------------------------------------------------------
--	Der Asynchrone Eingang wird synchron auf den Ausgang geschaltet und
--	gleichzeitig ein Wait-State-Generator gestartet. Erst nach Ablauf der
--	Wait-States kann wieder ein Wert entgegengenommen werden.
--------------------------------------------------------------------------------
entity ArmSwitchDebounce is
	port(
		SYS_CLK 	: in std_logic;
		SYS_RST 	: in std_logic;
		SDB_ASYNC_INPUT : in std_logic;
		SDB_SYNC_OUTPUT : out std_logic
	    );
end ArmSwitchDebounce;

architecture behave of ArmSwitchDebounce is

	signal WSG_COUNT_INIT	: std_logic_vector(15 downto 0);
	signal WSG_START	: std_logic;
	signal WSG_WAIT		: std_logic;

	signal INPUT_VALUE : std_logic;
begin
--------------------------------------------------------------------------------
--	8192 Wartetakte, bei 10 MHz ergibt sich eine Samplefrequent von
--	ca. 1 kHz.
--------------------------------------------------------------------------------
	WSG_COUNT_INIT <= X"1FFF"; 

	SDB_SYNC_OUTPUT	<= INPUT_VALUE;

	SAMPLE_CLK_GEN : entity work.ArmWaitStateGenAsync(behave)
	generic map(
			COUNT_VALUE_WIDTH => WSG_COUNT_INIT'length
		   )
	port map(
		SYS_CLK => SYS_CLK,
		SYS_RST => SYS_RST,
		WSG_COUNT_INIT => WSG_COUNT_INIT,
		WSG_START => WSG_START,
		WSG_WAIT => WSG_WAIT				
		);

	process(SYS_CLK)
	begin
		if(SYS_CLK'event and SYS_CLK = '1')then
			if(SYS_RST = '1')then
				WSG_START <= '0';
				INPUT_VALUE <= '0';
			else
				WSG_START <= '0';
				if WSG_WAIT = '0' then
					WSG_START <= '1';
					INPUT_VALUE <= SDB_ASYNC_INPUT;
				end if;
			end if;
		end if;
	end process;
end architecture behave;
