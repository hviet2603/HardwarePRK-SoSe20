--------------------------------------------------------------------------------
--	16-Bit-Register zur Steuerung der Auswahl des naechsten Registers
--	bei der Ausfuehrung von STM/LDM-Instruktionen. Das Register wird
--	mit der Bitmaske der Instruktion geladen. Ein Prioritaetsencoder
--	(Modul ArmPriorityVectorFilter) bestimmt das Bit mit der hochsten 
--	Prioritaet. Zu diesem Bit wird eine 4-Bit-Registeradresse erzeugt und
--	das Bit im Register geloescht. Bis zum Laden eines neuen Datums wird
--	mit jedem Takt ein Bit geloescht bis das Register leer ist.	
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ArmLdmStmNextAddress is
	port(
		SYS_RST			: in std_logic;
		SYS_CLK			: in std_logic;	
		LNA_LOAD_REGLIST 	: in std_logic;
		LNA_HOLD_VALUE 		: in std_logic;
		LNA_REGLIST 		: in std_logic_vector(15 downto 0);
		LNA_ADDRESS 		: out std_logic_vector(3 downto 0);
		LNA_CURRENT_REGLIST_REG : out std_logic_vector(15 downto 0)
	    );
end entity ArmLdmStmNextAddress;

architecture behave of ArmLdmStmNextAddress is
	signal REGLIST : std_logic_vector(15 downto 0);
	signal FILTERED_REGLIST : std_logic_vector(15 downto 0);

	component ArmPriorityVectorFilter
		port(
			PVF_VECTOR_UNFILTERED	: in std_logic_vector(15 downto 0);
			PVF_VECTOR_FILTERED	: out std_logic_vector(15 downto 0)
		);
	end component ArmPriorityVectorFilter;
begin

	CURRENT_REGLIST_FILTER : ArmPriorityVectorFilter
		port map(
			PVF_VECTOR_UNFILTERED => REGLIST,
			PVF_VECTOR_FILTERED => FILTERED_REGLIST
		);

	UPDATE_REGLIST : process (SYS_CLK) begin
		if rising_edge(SYS_CLK) then
			if SYS_RST = '1' then
				REGLIST <= x"0000";
			elsif LNA_LOAD_REGLIST = '1' then
				REGLIST <= LNA_REGLIST;
			elsif LNA_HOLD_VALUE = '0' then
				for i in 0 to 15 loop
					if FILTERED_REGLIST(i) = '1' then
						REGLIST(i) <= '0';
						exit;
					end if;
				end loop;
			end if;
		end if;
	end process UPDATE_REGLIST;

	LNA_ADDRESS <=
		"0000" when FILTERED_REGLIST = "0000000000000001" else
		"0001" when FILTERED_REGLIST = "0000000000000010" else
		"0010" when FILTERED_REGLIST = "0000000000000100" else
		"0011" when FILTERED_REGLIST = "0000000000001000" else
		"0100" when FILTERED_REGLIST = "0000000000010000" else
		"0101" when FILTERED_REGLIST = "0000000000100000" else
		"0110" when FILTERED_REGLIST = "0000000001000000" else
		"0111" when FILTERED_REGLIST = "0000000010000000" else
		"1000" when FILTERED_REGLIST = "0000000100000000" else
		"1001" when FILTERED_REGLIST = "0000001000000000" else
		"1010" when FILTERED_REGLIST = "0000010000000000" else
		"1011" when FILTERED_REGLIST = "0000100000000000" else
		"1100" when FILTERED_REGLIST = "0001000000000000" else
		"1101" when FILTERED_REGLIST = "0010000000000000" else
		"1110" when FILTERED_REGLIST = "0100000000000000" else
		"1111" when FILTERED_REGLIST = "1000000000000000" else
		(others => '0');

	LNA_CURRENT_REGLIST_REG <= REGLIST;

end architecture behave;

