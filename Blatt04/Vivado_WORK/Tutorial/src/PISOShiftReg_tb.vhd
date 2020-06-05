library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

library work;
use work.TB_Tools.all;

entity PISOShiftReg_tb is
end PISOShiftReg_tb;

architecture testbench of PISOShiftReg_tb is
    constant test_width : integer :=  8; --STUDENT: SET TO ARBITRARY VALUE THAT FITS YOUR TESTDATA

    signal tb_in       : std_logic_vector(test_width-1 downto 0) := "10001011";
    signal tb_out      : std_logic;
    signal tb_load     : std_logic;
    signal tb_last_bit : std_logic;

    signal clk : std_logic;
    signal ce  : std_logic;
    signal counter: integer := 0;

    component PISOShiftReg
        generic ( WIDTH : integer);
        port(
            CLK      : in std_logic;
            CLK_EN   : in std_logic;
            LOAD     : in std_logic;
            D_IN     : in std_logic_vector(WIDTH-1 downto 0);
            D_OUT    : out std_logic;
            LAST_BIT : out std_logic
        );
    end component;

    begin

    --generate basic clock
    clk_gen : process
    begin
        clk <= '1';
        wait for 1 ns;
        clk <= '0';
        wait for 1 ns;
    end process clk_gen;

    --generate clock enable signal
    clk_en_gen : process
    begin
        ce <= '1';
        wait for 1 ns;
        ce <= '0';
        wait for 9 ns;
    end process clk_en_gen;

    uut : PISOShiftReg
    generic map (WIDTH => test_width)
    port map (
        CLK => clk,
        CLK_EN => ce,
        LOAD => tb_load,
        D_IN => tb_in,
        D_OUT => tb_out,
        LAST_BIT => tb_last_bit
    );

    --STUDENT: INSERT TESTBENCH CODE HERE (SIGNAL ASSIGNMENTS ETC.)
    load_gen: process
    begin
	-- Init
	tb_load <= 'U';
	wait for 10 ns;
	-- erster Schreibzugriff
	tb_load <= '1';
        wait for 10 ns;
	-- Schiebvorgang
        tb_load <= '0';
	wait; 
    end process load_gen;
    
    test: process
    begin
	if counter = 0 then
		wait for 10 ns;
	end if;
	-- Register in Betrieb
        if counter <= test_width - 1 then
		wait for 2 ns;
		report "Das " & integer'image(counter+1) & ".Bit ist: " & SL_TO_STRING(tb_out) severity note;
		counter <= counter + 1;
	end if;
	if counter = test_width then
		report "Das letzte Bit wird uebertragen" severity note;
		wait for 2 ns; 
		if (tb_last_bit = '1') then
			report "Das LAST_BIT Signal wurde gesetzt" severity note;
		else 
			report "Das LAST_BIT Signal wurde nicht gesetzt" severity note;
		end if;
		report "-----END OF TEST-----" severity failure;
	end if;

        wait for 8 ns;
    end process test;
        

end testbench;
