--------------------------------------------------------------------------------
--	Wrapper um Basys3-Blockram fuer den RAM des HWPR-Prozessors.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ArmRAMB_4kx32 is
	generic(
--------------------------------------------------------------------------------
--	SELECT_LINES ist fuer das HWPR irrelevant, wird aber in einer
--	komplexeren Variante dieses Speichers zur Groessenauswahl
--	benoetigt. Im Hardwarepraktikum bitte ignorieren und nicht aendern.
--------------------------------------------------------------------------------
		SELECT_LINES : natural range 0 to 2 := 1);
    port(
		RAM_CLK	: in  std_logic;
        ENA		: in  std_logic;
		ADDRA	: in  std_logic_vector(11 downto 0);
        WEB		: in  std_logic_vector(3 downto 0);
        ENB		: in  std_logic;
		ADDRB	: in  std_logic_vector(11 downto 0);
        DIB		: in  std_logic_vector(31 downto 0);
        DOA		: out  std_logic_vector(31 downto 0);
        DOB		: out  std_logic_vector(31 downto 0));
end entity ArmRAMB_4kx32;

architecture behavioral of ArmRAMB_4kx32 is
    signal i: integer;
    type DOA_reg_array is array(0 to 3) of std_logic_vector(7 downto 0);
    type DOB_reg_array is array(0 to 3) of std_logic_vector(7 downto 0);
    type DIB_byte_array is array(0 to 3) of std_logic_vector(7 downto 0);
	signal DOA_reg: DOA_reg_array;
	signal DOB_reg: DOB_reg_array;
	signal DIB_byte: DIB_byte_array;

begin
		DIB_byte(0) <= DIB(31 downto 24);
		DIB_byte(1) <= DIB(23 downto 16);
		DIB_byte(2) <= DIB(15 downto 8);
		DIB_byte(3) <= DIB(7 downto 0);
		
		ArmRAMB_32: for i = 0 to 3 generate
                ArmRAMB_8: work.ArmRAMB_4kx8 
                generic map (
                    WIDTH => 8,
                    SIZE => 4096
                )
                port map (
                    RAM_CLK => RAM_CLK,
                    ADDRA => ADDRA,
                    DOA => DOA_reg(i),
                    ENA => ENA,
                    ADDRB => ADDRB,
                    DIB => DIB_byte(i),
                    DOB => DOB_reg(i),
                    ENB => ENB,
                    WEB => WEB(i)
                );
        end generate ArmRAMB_32;
        
        DOA <= DOA_reg(0) & DOA_reg(1) & DOA_reg(2) & DOA_reg(3);
        DOB <= DOB_reg(0) & DOB_reg(1) & DOB_reg(2) & DOB_reg(3);

end architecture behavioral;
