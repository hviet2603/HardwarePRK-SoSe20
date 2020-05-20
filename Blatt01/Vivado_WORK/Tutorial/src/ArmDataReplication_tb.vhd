use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.armtypes.all;

entity ArmDataReplication_TB is
end entity ArmDataReplication_TB;

architecture testbench_arch of ArmDataReplication_TB is
    component ArmDataReplication
        port (
            DRP_INPUT 	:  In std_logic_vector (31 downto 0);
            DRP_DMAS 	:  In std_logic_vector ( 1 downto 0);
            DRP_OUTPUT 	: out std_logic_vector (31 downto 0)
        );
    end component ArmDataReplication;
    constant SEPARATOR_LINE : string(80 downto 1) := 
		"--------------------------------------------------------------------------------"; 


    signal DRP_INPUT : std_logic_vector  (31 downto 0) := "00000000000000000000000000000000";
    signal DRP_DMAS : std_logic_vector 	 ( 1 downto 0) := "00";
    signal DRP_OUTPUT : std_logic_vector (31 downto 0) := "00000000000000000000000000000000";

    shared variable TX_ERROR : integer := 0;
    shared variable TX_OUT : line;

    begin
        UUT : ArmDataReplication
        port map (
            DRP_INPUT => DRP_INPUT,
            DRP_DMAS => DRP_DMAS,
            DRP_OUTPUT => DRP_OUTPUT
        );

        process
            procedure CHECK_DRP_OUTPUT(
                next_DRP_OUTPUT : std_logic_vector (31 downto 0);
                TX_TIME : integer	
            ) is
                variable TX_STR : string(1 to 4096);
                variable TX_LOC : line;
                begin
                if (DRP_OUTPUT /= next_DRP_OUTPUT) then

		    case DRP_DMAS is
			when "00" =>
                    		STD.TEXTIO.write(TX_LOC, string'("DRP_DMAS = DMAS_BYTE      "));
			when "01" =>
                    		STD.TEXTIO.write(TX_LOC, string'("DRP_DMAS = DMAS_HWORD     "));
			when "10" =>
                    		STD.TEXTIO.write(TX_LOC, string'("DRP_DMAS = DMAS_WORD      "));
			when others =>	
                    		STD.TEXTIO.write(TX_LOC, string'("DRP_DMAS = DMAS_RESERVED  "));
	    						    

		    end case;	    
                    STD.TEXTIO.write(TX_LOC, string'("Error at time = "));
                    STD.TEXTIO.write(TX_LOC, TX_TIME);
                    STD.TEXTIO.write(TX_LOC, string'("ns DRP_OUTPUT = "));
                    IEEE.STD_LOGIC_TEXTIO.hwrite(TX_LOC, DRP_OUTPUT);
                    STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
                    IEEE.STD_LOGIC_TEXTIO.hwrite(TX_LOC, next_DRP_OUTPUT);
                    STD.TEXTIO.write(TX_LOC, string'(" "));
                    TX_STR(TX_LOC.all'range) := TX_LOC.all;
                    STD.TEXTIO.Deallocate(TX_LOC);
                    assert (false) report TX_STR severity error;
                    TX_ERROR := TX_ERROR + 1;
                end if;
            end;
            begin
                -- -------------  Current Time:  10ns
                wait for 10 ns;
                DRP_INPUT <= "01011010011010010111100011100001";
                DRP_DMAS <= "10";
                -- -------------------------------------
                -- -------------  Current Time:  15ns
                wait for 5 ns;
                CHECK_DRP_OUTPUT("01011010011010010111100011100001", 15);
                -- -------------------------------------
                -- -------------  Current Time:  20ns
                wait for 5 ns;
                DRP_INPUT <= "00000000000000000000000000000000";
                -- -------------------------------------
                -- -------------  Current Time:  25ns
                wait for 5 ns;
                CHECK_DRP_OUTPUT("00000000000000000000000000000000", 25);
                -- -------------------------------------
                -- -------------  Current Time:  30ns
                wait for 5 ns;
                DRP_INPUT <= "01011010011010010111100011100001";
                DRP_DMAS <= "01";
                -- -------------------------------------
                -- -------------  Current Time:  35ns
                wait for 5 ns;
                CHECK_DRP_OUTPUT("01111000111000010111100011100001", 35);
                -- -------------------------------------
                -- -------------  Current Time:  40ns
                wait for 5 ns;
                DRP_INPUT <= "00000000000000000000000000000000";
                DRP_DMAS <= "10";
                -- -------------------------------------
                -- -------------  Current Time:  45ns
                wait for 5 ns;
                CHECK_DRP_OUTPUT("00000000000000000000000000000000", 45);
                -- -------------------------------------
                -- -------------  Current Time:  50ns
                wait for 5 ns;
                DRP_INPUT <= "01011010011010010111100011100001";
                DRP_DMAS <= "00";
                -- -------------------------------------
                -- -------------  Current Time:  55ns
                wait for 5 ns;
                CHECK_DRP_OUTPUT("11100001111000011110000111100001", 55);
                -- -------------------------------------
                -- -------------  Current Time:  60ns
                wait for 5 ns;
                DRP_INPUT <= "00000000000000000000000000000000";
                DRP_DMAS <= "10";
                -- -------------------------------------
                -- -------------  Current Time:  65ns
                wait for 5 ns;
                CHECK_DRP_OUTPUT("00000000000000000000000000000000", 65);
                -- -------------------------------------
                -- -------------  Current Time:  70ns
                wait for 5 ns;
                DRP_INPUT <= "01011010011010010111100011100001";
                DRP_DMAS <= "11";
                -- -------------------------------------
                -- -------------  Current Time:  75ns
                wait for 5 ns;
                CHECK_DRP_OUTPUT("01011010011010010111100011100001", 75);
                -- -------------------------------------
                -- -------------  Current Time:  80ns
                wait for 5 ns;
                DRP_INPUT <= "00000000000000000000000000000000";
                DRP_DMAS <= "00";
                -- -------------------------------------
                -- -------------  Current Time:  85ns
                wait for 5 ns;
                CHECK_DRP_OUTPUT("00000000000000000000000000000000", 85);
                -- -------------------------------------
                wait for 5 ns;

		report SEPARATOR_LINE;
		report "Simulation beendet " severity note;

                if (TX_ERROR = 0) then
                  assert (FALSE) report
                      "Simulation erfolgreich (0 Fehler)."
                      severity note;
                else
                  assert (false) report "Simulation nicht erfolgreich (" & integer'image(TX_ERROR) & " Fehler)"
                         severity error;
                end if;
		report SEPARATOR_LINE;
		
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhängig von tatsächlich aufgetretenen Fehlern!" severity failure; 
            end process;

	end architecture testbench_arch;

