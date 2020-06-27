--------------------------------------------------------------------------------
--	Shifter des HWPR-Prozessors, instanziiert einen Barrelshifter.
--------------------------------------------------------------------------------
--	Datum:		??.??.2013
--	Version:	?.?
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ArmTypes.all;
use work.ArmBarrelShifter;
entity ArmShifter is
	port (
		SHIFT_OPERAND	: in	std_logic_vector(31 downto 0);
		SHIFT_AMOUNT	: in	std_logic_vector(7 downto 0);
		SHIFT_TYPE_IN	: in	std_logic_vector(1 downto 0);
		SHIFT_C_IN	: in	std_logic;
		SHIFT_RRX	: in	std_logic;
		SHIFT_RESULT	: out	std_logic_vector(31 downto 0);
		SHIFT_C_OUT		: out	std_logic    		
 	);
end entity ArmShifter;

architecture behave of ArmShifter is
signal  ABS_MUX_CTRL  : std_logic_vector(1 downto 0);
signal  ABS_ARITH_SHIFT: std_logic; 
signal ABS_DATA_OUT : std_logic_vector(31 downto 0);
signal  ABS_C_OUT: std_logic;

begin
ARM_BARREL_SHIFTER : entity work.ArmBarrelShifter(structure)
	generic map (
		OPERAND_WIDTH => 32,
		SHIFTER_DEPTH => 5
	)
	port map (
		OPERAND => SHIFT_OPERAND,
		MUX_CTRL => ABS_MUX_CTRL,
		AMOUNT => SHIFT_AMOUNT(4 downto 0),
		ARITH_SHIFT => ABS_ARITH_SHIFT,
		C_IN => SHIFT_C_IN,
		DATA_OUT => ABS_DATA_OUT,
		C_OUT => ABS_C_OUT
	);

SET_SHIFT_TYPE : process (SHIFT_TYPE_IN) begin
	case SHIFT_TYPE_IN is
		when SH_LSL => 
			ABS_MUX_CTRL <= "01";
			ABS_ARITH_SHIFT <= '0';
		when SH_LSR =>
			ABS_MUX_CTRL <= "10";
			ABS_ARITH_SHIFT <= '0';
		when SH_ASR => 
			ABS_MUX_CTRL <= "10";
			ABS_ARITH_SHIFT <= '1';
		when SH_ROR => 
			ABS_MUX_CTRL <= "11";
			ABS_ARITH_SHIFT <= '0';
		when others =>
			ABS_MUX_CTRL <= "00";
			ABS_ARITH_SHIFT <= '0';
	end case;
end process SET_SHIFT_TYPE;

	 
SHIFT_RESULT <= ABS_DATA_OUT      			when (unsigned(SHIFT_AMOUNT) < 32) and (SHIFT_RRX = '0') else
      	      (others => '0')				when (unsigned(SHIFT_AMOUNT) >= 32) and (SHIFT_TYPE_IN = SH_LSL) and SHIFT_RRX = '0' else
	      (others => '0')				when (unsigned(SHIFT_AMOUNT) >= 32) and (SHIFT_TYPE_IN = SH_LSR) and SHIFT_RRX = '0' else
      	      (others => SHIFT_OPERAND(31))		when (unsigned(SHIFT_AMOUNT) >= 32) and (SHIFT_TYPE_IN = SH_ASR) and SHIFT_RRX = '0' else
	      ABS_DATA_OUT    				when (SHIFT_TYPE_IN = SH_ROR) and SHIFT_RRX = '0' else
	      SHIFT_C_IN & SHIFT_OPERAND(31 downto 1)   when SHIFT_RRX = '1' else
	      (others => '0');

SHIFT_C_OUT  <= ABS_C_OUT  				when (unsigned(SHIFT_AMOUNT) < 32) and (SHIFT_RRX = '0') else
	      '0'					when (unsigned(SHIFT_AMOUNT) > 32) and (SHIFT_TYPE_IN = SH_LSL) and SHIFT_RRX = '0' else
	      SHIFT_OPERAND(0)				when (unsigned(SHIFT_AMOUNT) = 32) and (SHIFT_TYPE_IN = SH_LSL) and SHIFT_RRX = '0' else
              '0'  					when (unsigned(SHIFT_AMOUNT) > 32) and (SHIFT_TYPE_IN = SH_LSR) and SHIFT_RRX = '0'else
	      SHIFT_OPERAND(31)				when (unsigned(SHIFT_AMOUNT) = 32) and (SHIFT_TYPE_IN = SH_LSR) and SHIFT_RRX = '0' else
	      SHIFT_OPERAND(31)				when (unsigned(SHIFT_AMOUNT) >= 32) and (SHIFT_TYPE_IN = SH_ASR) and SHIFT_RRX = '0'else
	      ABS_C_OUT 				when (SHIFT_TYPE_IN = SH_ROR) and SHIFT_RRX = '0' else
              SHIFT_OPERAND(0)				when SHIFT_RRX = '1' else
	      '0';
end architecture behave;

