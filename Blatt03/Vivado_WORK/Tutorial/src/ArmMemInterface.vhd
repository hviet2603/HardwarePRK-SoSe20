--------------------------------------------------------------------------------
--	Schnittstelle zur Anbindung des RAM an die Busse des HWPR-Prozessors
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmConfiguration.all;

entity ArmMemInterface is
	generic(
--------------------------------------------------------------------------------
--	Beide Generics sind fuer das HWPR nicht relevant und koennen von
--	Ihnen ignoriert werden.
--------------------------------------------------------------------------------
		SELECT_LINES				: natural range 0 to 2 := 1;
		EXTERNAL_ADDRESS_DECODING_INSTRUCTION : boolean := false);
	port (  RAM_CLK	:  in  std_logic;
		--	Instruction-Interface	
       		IDE		:  in std_logic;	
			IA		:  in std_logic_vector(31 downto 2);
			ID		: out std_logic_vector(31 downto 0);	
			IABORT	: out std_logic;
		--	Data-Interface
			DDE		:  in std_logic;
			DnRW	:  in std_logic;
			DMAS	:  in std_logic_vector(1 downto 0);
			DA 		:  in std_logic_vector(31 downto 0);
			DDIN	:  in std_logic_vector(31 downto 0);
			DDOUT	: out std_logic_vector(31 downto 0);
			DABORT	: out std_logic);
end entity ArmMemInterface;

architecture behave of ArmMemInterface is	

begin	

end architecture behave;
