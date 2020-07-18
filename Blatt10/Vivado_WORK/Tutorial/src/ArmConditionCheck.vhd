--------------------------------------------------------------------------------
--	Test auf Erfuellen der Instruktionsbedingungen im Datenpfad des ARM-SoC
--------------------------------------------------------------------------------
--	Datum:		08.12.09
--	Version:	1.0
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library WORK;
use WORK.ArmTypes.all;

--------------------------------------------------------------------------------
-- 	CONDITION_FIELD: Bedingungsfeld im Befehlswort
-- 	CONDITION_CODE:  Durch alle vorherigen Befehle erzeugter Conditioncode im Datenpfad
-- 	Anordnung der CC-Bits im Statusregister: NZCV
--------------------------------------------------------------------------------

entity ArmConditionCheck is
	port(
		CDC_CONDITION_FIELD	: in std_logic_vector(3 downto 0);
		CDC_CONDITION_CODE	: in std_logic_vector(3 downto 0);
		CDC_CONDITION_MET	: out std_logic);
end entity ArmConditionCheck;


architecture behave of ArmConditionCheck is
begin

	CHECK_CONDITION : process(CDC_CONDITION_FIELD, CDC_CONDITION_CODE)is
		alias FIELD : std_logic_vector(3 downto 0) is CDC_CONDITION_FIELD;
		alias N : std_logic is CDC_CONDITION_CODE(3);
		alias Z : std_logic is CDC_CONDITION_CODE(2);
		alias C : std_logic is CDC_CONDITION_CODE(1);
		alias V : std_logic is CDC_CONDITION_CODE(0);
		alias MET : std_logic is CDC_CONDITION_MET;

	begin
--		Defaultzuweisung
		CDC_CONDITION_MET <= '0';

--		assert FIELD /= NV report "ArmConditionCheck: 'NEVER' sollte nicht als Bedingung verwendet werden" severity warning;
		case FIELD is
			-- zwei jeweils untereinander stehende Fälle repräsentieren gerade gegenteilige Bedingungen
			when EQ 	=> MET <= Z;
			when NE 	=> MET <= not Z;
			when CS 	=> MET <= C;				-- entspricht auch HS
			when CC 	=> MET <= not C; 			-- entspricht auch LO
			when MI 	=> MET <= N;
			when PL 	=> MET <= not N;
			when VS 	=> MET <= V;
			when VC 	=> MET <= not V;
			when HI 	=> MET <= C and (not Z);
			when LS 	=> MET <= (not C) or Z; 		-- NOT(C AND (NOT Z))
			when GE 	=> MET <= N xnor V;			-- Äquivalenz
			when LT 	=> MET <= N xor V;
			when GT 	=> MET <= (not Z) and (N xnor V);
			when LE 	=> MET <= Z or (N xor V);
			when AL 	=> MET <= '1';
			-- others umfasst nur den NV-Fall
			when others 	=> MET <= '0';
		end case;
	end process CHECK_CONDITION;
end architecture behave;

