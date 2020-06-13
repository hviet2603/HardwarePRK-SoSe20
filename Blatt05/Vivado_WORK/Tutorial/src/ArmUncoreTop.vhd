--------------------------------------------------------------------------------
--	Topmodul aller Komponenten ausserhalb des Prozessorkerns fuer einen
--	Funktionstest im Hardwarepraktikum
--------------------------------------------------------------------------------
--	Datum:		30.05.2010
--	Version:	0.91
--------------------------------------------------------------------------------
library work;
	use work.ArmRS232Interface;
	use work.ArmMemInterface;
    use work.ArmSwitchDebounce;
    use work.ArmChipSelectGenerator;
    use work.ArmSystemController;

--	wird immer benoetigt
	use work.ArmTypes.SUPERVISOR;

--library ARM_SIM_LIB;
--	use ARM_SIM_LIB.ArmRS232Interface;
--	use ARM_SIM_LIB.ArmMemInterface;

library ieee;
use ieee.std_logic_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

--------------------------------------------------------------------------------
--	Vollstaendige Schnittstelle des ARM-SoC wenn die gesammte 
--	Kommunikation ueber TXD,RXD und LED erfolgt.
--------------------------------------------------------------------------------
entity ArmUncoreTop is
    Port ( EXT_RST : in  std_logic;
           EXT_CLK : in  std_logic;
--    Load Programm
    	   EXT_LDP : in std_logic;
           EXT_RXD : in  std_logic;
           EXT_TXD : out  std_logic;
	   EXT_LED : out std_logic_vector(7 downto 0)
   );

end entity ArmUncoreTop;

architecture behave of ArmUncoreTop is
--------------------------------------------------------------------------------
--	Signale des Instruktionsbus
--	Im Prinzip werden die Instruktionsbussignale 
--	hier gar nicht benoetigt und sind nur vorhanden, um die
--	Konsistenz zum spaeteren Topmodul mit Prozessorkern zu wahren.
--	Der System-Controller zeigt nach der Initialisierung
--	Teile der Instruktionsbus-Adresse, sie muss daher
--	wenigstes pro forma existieren.
--------------------------------------------------------------------------------
	signal IBUS_IA 		: std_logic_vector(9 downto 2);
--	signal IBUS_ID 		: std_logic_vector(31 downto 0);
--	signal IBUS_ABORT 	: std_logic;
--	signal IBUS_WAIT 	: std_logic;	
--	signal IBUS_IBE		: std_logic;
--	signal IBUS_IEN		: std_logic;
--	signal IBUS_MODE	: std_logic_vector(4 downto 0);

--------------------------------------------------------------------------------
--	Signale des Datenbus, die Benennung der unidirektioalen Datenleitungen
--	ist aus Master-Sicht zu lesen.
--------------------------------------------------------------------------------
	signal DBUS_DA		: std_logic_vector(31 downto 0);
	signal DBUS_DDOUT	: std_logic_vector(31 downto 0);
	signal DBUS_DDIN	: std_logic_vector(31 downto 0);
	--Kais Edit: Signals for High Impedance EDIF Bug -> more information in behave
	--Same goes for DBUS_ABORT
	signal DBUS_DDIN_MEM	: std_logic_vector(31 downto 0);
	signal DBUS_DDIN_RS232	: std_logic_vector(31 downto 0);
	constant HIGH_IMP 		: std_logic := 'Z';
	constant HIGH_IMP_VEC       : std_logic_vector(31 downto 0) := (others => 'Z');
--	signal DBUS_WAIT	: std_logic;
	signal DBUS_ABORT	: std_logic;
	signal DBUS_ABORT_MEM	: std_logic;
	signal DBUS_ABORT_RS232 : std_logic;
	signal DBUS_ABORT_CS	: std_logic;
	signal DBUS_DnRW	: std_logic;
	signal DBUS_DMAS	: std_logic_vector(1 downto 0);
	signal DBUS_MODE	: std_logic_vector(4 downto 0);
--	signal DBUS_DBE		: std_logic;
--------------------------------------------------------------------------------
--	Ein gemeinsames DEN-Signal (Bus-Request wird benoetigt, um den 
--	CSG zu aktivieren, wenn ein Master den Bus beantragt. Es entspricht
--	damit dem OR der einzelnen Master-DENs.	
--------------------------------------------------------------------------------
	signal DBUS_DEN		: std_logic;
	signal DBUS_CS_RS232	: std_logic;
	signal DBUS_CS_MEM	: std_logic;
--	Bus-Request des System-Controllers
	SIGNAL CTRL_DEN		: std_logic := '1';

--	Entprelltes Load-Signal	
	signal INT_LDP		: std_logic;

--	Chip-Select-Signale	
	signal CSG_CS_LINES	: std_logic_vector(0 to 7);

	component ArmSwitchDebounce
	port(
		SYS_RST 	: in std_logic;
		SYS_CLK 	: in std_logic;
		SDB_ASYNC_INPUT : in std_logic;
		SDB_SYNC_OUTPUT : out std_logic
	);
	end component ArmSwitchDebounce;

	component ArmChipSelectGenerator
	port(
		CSG_DA 		: in std_logic_vector(31 downto 0);          
		CSG_DEN		: in std_logic;
		CSG_MODE	: in std_logic_vector(4 downto 0);
		CSG_ABORT 	: out std_logic;
		CSG_CS_LINES	: out std_logic_vector(0 to 7)
		);
	end component ArmChipSelectGenerator;

	component ArmMemInterface
	generic(
		SELECT_LINES : natural range 0 to 2 := 1
	       );
	port(
		RAM_CLK 	: in std_logic;
		IDE 		: in std_logic;
		IA 		: in std_logic_vector(31 downto 2);
		ID 		: out std_logic_vector(31 downto 0);
		IABORT 		: out std_logic;
		DDE 		: in std_logic;
		DnRW 		: in std_logic;
		DMAS 		: in std_logic_vector(1 downto 0);
		DA 		: in std_logic_vector(31 downto 0);
		DDIN 		: in std_logic_vector(31 downto 0);          
		DDOUT 		: out std_logic_vector(31 downto 0);
		DABORT 		: out std_logic
	);
	end component ArmMemInterface;


	component ArmSystemController
	port(
		EXT_RST 	: in std_logic;
		EXT_CLK 	: in std_logic;
		SYS_CLK 	: out std_logic;
		SYS_RST 	: out std_logic;
		SYS_INV_CLK 	: out std_logic;
		CTRL_DnRW 	: out std_logic;
		CTRL_DMAS 	: out std_logic_vector(1 downto 0);
		CTRL_DA 	: out std_logic_vector(31 downto 0);
		CTRL_DDIN 	: in std_logic_vector(31 downto 0);
		CTRL_DDOUT 	: out std_logic_vector(31 downto 0);
		CTRL_DABORT	: in std_logic;
		CTRL_DEN	: out std_logic;
		CTRL_LDP	: in std_logic;
		CTRL_IA		: in std_logic_vector(9 downto 2);
		CTRL_STATUS_LED : out std_logic_vector(7 downto 0);
		CTRL_WAIT	: out std_logic
		);
	end component ArmSystemController;

	component ArmRS232Interface
	port(
		SYS_CLK		: in std_logic;
		SYS_RST		: in std_logic;
		RS232_CS	: in std_logic;
		RS232_DnRW	: in std_logic;
		RS232_DMAS	: in std_logic_vector(1 downto 0);
		RS232_DA	: in std_logic_vector(3 downto 0);
		RS232_DDIN	: in std_logic_vector(31 downto 0);
		RS232_DDOUT	: out std_logic_vector(31 downto 0);
		RS232_DABORT	: out std_logic;
		RS232_IRQ	: out std_logic;
		RS232_RXD	: in std_logic;
		RS232_TXD	: out std_logic
	    );
	end component ArmRS232Interface;
	
	signal SYS_CLK		: std_logic;
	signal SYS_INV_CLK	: std_logic;
	signal SYS_RST		: std_logic;
	signal CTRL_STATUS	: std_logic_vector(7 downto 0);


begin
	Debouncing_EXT_LDP : ArmSwitchDebounce
	port map(
		SYS_RST 	=> SYS_RST,
		SYS_CLK 	=> SYS_CLK,
		SDB_ASYNC_INPUT => EXT_LDP,
		SDB_SYNC_OUTPUT => INT_LDP
	);

	Inst_ArmChipSelectGenerator: ArmChipSelectGenerator 
	port map(
		CSG_DA 		=> DBUS_DA,
		CSG_DEN		=> DBUS_DEN,
		CSG_MODE	=> DBUS_MODE,
		CSG_ABORT 	=> DBUS_ABORT_CS,
		CSG_CS_LINES	=> CSG_CS_LINES
	);

	Inst_ArmMemInterface: ArmMemInterface
	generic map(
		   SELECT_LINES => 1
		   )
	port map(
		RAM_CLK 	=> SYS_INV_CLK,
		IDE 		=> '0',
		IA 		=> (others => '0'),
		ID 		=> open,
		IABORT 		=> open,
		DDE 		=> DBUS_CS_MEM,
		DnRW 		=> DBUS_DnRW,
		DMAS 		=> DBUS_DMAS,
		DA 		=> DBUS_DA,
		DDIN 		=> DBUS_DDOUT,
		DDOUT 		=> DBUS_DDIN_MEM,
		DABORT 		=> DBUS_ABORT_MEM
	);

	Inst_ArmRS232Interface : ArmRS232Interface port map(
		SYS_CLK 	=> SYS_CLK,
		SYS_RST 	=> SYS_RST,
		RS232_CS 	=> DBUS_CS_RS232,
		RS232_DnRW 	=> DBUS_DnRW,
		RS232_DMAS	=> DBUS_DMAS,
		RS232_DA	=> DBUS_DA(3 downto 0),
		RS232_DDIN	=> DBUS_DDOUT,
		RS232_DDOUT	=> DBUS_DDIN_RS232,
		RS232_DABORT	=> DBUS_ABORT_RS232,
		RS232_IRQ	=> open,
		RS232_RXD	=> EXT_RXD,
		RS232_TXD	=> EXT_TXD
	);
	
	Inst_ArmSystemController: ArmSystemController
	port map(
		EXT_RST 	=> EXT_RST,
		EXT_CLK 	=> EXT_CLK,
		SYS_CLK 	=> SYS_CLK,
		SYS_RST 	=> SYS_RST,
		SYS_INV_CLK 	=> SYS_INV_CLK,
		CTRL_DnRW 	=> DBUS_DnRW,
		CTRL_DMAS	=> DBUS_DMAS,
		CTRL_DA 	=> DBUS_DA,
		CTRL_DDIN 	=> DBUS_DDIN,
		CTRL_DDOUT 	=> DBUS_DDOUT,
		CTRL_DABORT	=> DBUS_ABORT,
		CTRL_DEN	=> CTRL_DEN,
		CTRL_LDP	=> INT_LDP,
		CTRL_IA		=> IBUS_IA(9 downto 2),
		CTRL_STATUS_LED => CTRL_STATUS,
		CTRL_WAIT	=> open
	);
--	Arbiter, ohne zweiten Master de facto nicht vorhanden
	DBUS_DEN 	<= CTRL_DEN;

	DBUS_CS_MEM	<= CSG_CS_LINES(0);
	DBUS_CS_RS232	<= CSG_CS_LINES(1);
	EXT_LED		<= CTRL_STATUS;
	DBUS_MODE	<= SUPERVISOR;
--	DBUS_WAIT	<= '0';
	IBUS_IA		<= X"42";

	--Kais Edit: Enforcing High Impedance Information which is lost in
	--EDIF File
	DBUS_DDIN <= 	DBUS_DDIN_MEM when DBUS_DDIN_MEM /= HIGH_IMP_VEC else
					DBUS_DDIN_RS232;

	DBUS_ABORT <= 	DBUS_ABORT_MEM when DBUS_ABORT_MEM /= HIGH_IMP else
					DBUS_ABORT_RS232 when DBUS_ABORT_RS232 /= HIGH_IMP else
					DBUS_ABORT_CS;

end architecture behave;


