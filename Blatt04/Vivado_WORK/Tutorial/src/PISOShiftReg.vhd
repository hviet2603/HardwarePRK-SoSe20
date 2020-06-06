--------------------------------------------------------------------------------
-- PISO-Schieberegister als mögliche Grundlage für die Implementierung der RS232-
-- Schnittstelle im Hardwarepraktikum
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PISOShiftReg is
	generic(
		WIDTH	 : integer := 8
	);
	port(
		CLK	 : in std_logic;
		CLK_EN	 : in std_logic;
		LOAD	 : in std_logic;
		D_IN	 : in std_logic_vector(WIDTH-1 downto 0);
		D_OUT	 : out std_logic;
		LAST_BIT : out std_logic
	);
end entity PISOShiftReg;

architecture behavioral of PISOShiftReg is
type data_reg is array(WIDTH-1 downto 0) of std_logic;
signal D_reg: data_reg;
signal i: integer;
signal counter: integer := 0;
begin

shiftRegister: process(CLK, CLK_EN) is 
begin

if (rising_edge(CLK)) then
    LAST_BIT <= '0';
    if (CLK_EN = '1') then
	-- Erster Schreibzugriff
        if (LOAD = '1') then
            for i in WIDTH-1 downto 0 loop
                D_reg(i) <= D_IN(i);
            end loop;
	end if;
	-- Schiebvorgang
        if (LOAD = '0') then
            for i in WIDTH-counter-2 downto 0 loop    
                D_reg(i) <= D_reg(i+1);
            end loop;
            for i in WIDTH-1 downto WIDTH-counter-1 loop    
                D_reg(i) <= '0';
            end loop;
            if counter < WIDTH-1 then 
                counter <= counter + 1; 
            end if;
            if counter = WIDTH-1 then
                LAST_BIT <= '1';
            end if;
        end if;
    end if;
end if; 

end process shiftRegister;

D_OUT <= D_REG(0); 


end architecture behavioral;
