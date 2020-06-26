library ieee;
use ieee.std_logic_1164.all;

entity MUX4 is
	port (A: in std_logic,
	      B: in std_logic,
	      C: in std_logic,
	      D: in std_logic,
	      S: in std_logic,
	      MUX_OUT: out std_logic);
end entity MUX4;

architecture structure of MUX is

begin
	MUX_OUT <= A when S = "00" else
		    B when S = "01" else
		    C when S = "10" else
		    D	        	 ;
		    
end architecture structure
	

