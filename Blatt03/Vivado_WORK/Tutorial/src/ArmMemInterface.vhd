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
use work.ArmRAMB_4kx32.all;
use work.armtypes.all;

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
    signal OUTPUT_A: std_logic_vector(31 downto 0);
    signal OUTPUT_B: std_logic_vector(31 downto 0);
    signal WEB_SIGNAL: std_logic;
begin
    ID <= OUTPUT_A     when IDE = 1 else
          x"XXXXXXXX"                   ;
    
    RAM_BLOCK: entity work.ArmRAMB_4kx32 
    port map (
    	RAM_CLK => RAM_CLK,	
        ENA	=> IDE,	
		ADDRA => IA(13 downto 2),	
        WEB	=> WEB_SIGNAL,	
        ENB	=> DDE,	
        ADDRB => DA(13 downto 2), -- Byteaddress -> Wordaddress	
        DIB	=>  DDIN,	
        DOA	=> OUTPUT_A,	
        DOB	=>	OUTPUT_B
    );
    
    DDOUT <= OUTPUT_B when DDE = '1' and DnRW = '0' else
             x"XXXXXXXX"                                ;    
    
    DABORT <= 'X' when DDE = '0'                                                 else
              '1' when DDE = '1' and DMAS = DMAS_HWORD and DA(0) /= '0'          else
              '1' when DDE = '1' and DMAS = DMAS_WORD and DA(1 downto 0) /= "00" else
              '0';
    
    WEB_SIGNAL <= "1111" when DMAS = DMAS_WORD and DA(1 downto 0) = "00"  else -- Word: Address is divisible by 4
                  "1100" when DMAS = DMAS_HWORD and DA(1 downto 0) = "00" else -- Halfword - Case 1: first half
                  "0011" when DMAS = DMAS_HWORD and DA(1 downto 0) = "10" else -- Halfword - Case 2: second half
                  "1000" when DMAS = DMAS_BYTE and DA(1 downto 0) = "00"  else -- Byte - Case 1: 1.Byte 
                  "0100" when DMAS = DMAS_BYTE and DA(1 downto 0) = "01"  else -- Byte - Case 2: 2.Byte
                  "0010" when DMAS = DMAS_BYTE and DA(1 downto 0) = "10"  else -- Byte - Case 3: 3.Byte
                  "0001" when DMAS = DMAS_BYTE and DA(1 downto 0) = "11"  else -- Byte - Case 4: 4.Byte
                  "0000"                                                      ;

end architecture behave;
