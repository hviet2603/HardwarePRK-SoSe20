--------------------------------------------------------------------------------
--	Prioritaetsencoder fuer das Finden des niederwertigsten
-- 	gesetzten Bits in einem 16-Bit-Vektor.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.??
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ArmPriorityVectorFilter is
	port(
		PVF_VECTOR_UNFILTERED	: in std_logic_vector(15 downto 0);
		PVF_VECTOR_FILTERED	: out std_logic_vector(15 downto 0)
	    );
end entity ArmPriorityVectorFilter;

architecture structure of ArmPriorityVectorFilter is

begin

PRIO_FILTER: process
variable index: integer := -1;
variable i: integer; 

begin

PVF_VECTOR_FILTERED <= x"0000";
for i in 15 downto 0 loop
	if (PVF_VECTOR_UNFILTERED(i) = '1') then 
		index = i; 
	end if;
end loop

if (index >= 0) then
	PVF_VECTOR_FILTERED(index) <= '1';
end if;

end process PRIO_FILTER;

end architecture structure;

