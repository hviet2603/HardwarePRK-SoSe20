--------------------------------------------------------------------------------
--	Instruktionsadressregister-Modul fuer den HWPR-Prozessor
--------------------------------------------------------------------------------
--	Datum:		29.10.2013
--	Version:	0.1
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.ArmTypes.INSTRUCTION_ID_WIDTH;
use work.ArmTypes.VCR_RESET;

entity ArmInstructionAddressRegister is
	port(
		IAR_CLK 	: in std_logic;
		IAR_RST 	: in std_logic;
		IAR_INC		: in std_logic;
		IAR_LOAD 	: in std_logic;
		IAR_REVOKE	: in std_logic;
		IAR_UPDATE_HB	: in std_logic;
--------------------------------------------------------------------------------
--	INSTRUCTION_ID_WIDTH  ist ein globaler Konfigurationsparameter
--	zur Einstellung der Breite der Instruktions-IDs und damit der Tiefe
--	der verteilten Puffer. Eine Breite von 3 Bit genuegt fuer die 
--	fuenfstufige Pipeline definitiv.
--------------------------------------------------------------------------------
		IAR_HISTORY_ID	: in std_logic_vector(INSTRUCTION_ID_WIDTH-1 downto 0);
		IAR_ADDR_IN 	: in std_logic_vector(31 downto 2);
		IAR_ADDR_OUT 	: out std_logic_vector(31 downto 2);
		IAR_NEXT_ADDR_OUT : out std_logic_vector(31 downto 2)
	    );
	
end entity ArmInstructionAddressRegister;

architecture behave of ArmInstructionAddressRegister is

	component ArmRamBuffer
	generic(
		ARB_ADDR_WIDTH : natural range 1 to 4 := 3;
		ARB_DATA_WIDTH : natural range 1 to 64 := 32
	       );
	port(
		ARB_CLK 	: in std_logic;
		ARB_WRITE_EN	: in std_logic;
		ARB_ADDR	: in std_logic_vector(ARB_ADDR_WIDTH-1 downto 0);
		ARB_DATA_IN	: in std_logic_vector(ARB_DATA_WIDTH-1 downto 0);          
		ARB_DATA_OUT	: out std_logic_vector(ARB_DATA_WIDTH-1 downto 0)
		);
	end component ArmRamBuffer;

begin

	IAR_HISTORY_BUFFER: ArmRamBuffer 
	generic map(
			ARB_ADDR_WIDTH => INSTRUCTION_ID_WIDTH,
			ARB_DATA_WIDTH => 30
		)
	port map(
		ARB_CLK		=> 
		ARB_WRITE_EN	=> 
		ARB_ADDR	=> 
		ARB_DATA_IN	=> 
		ARB_DATA_OUT	=> 
	);



end architecture behave;
