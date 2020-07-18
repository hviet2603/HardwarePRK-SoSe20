--------------------------------------------------------------------------------
--	Komponente zur Vereinheitlichung der diversion Shiftangaben
--------------------------------------------------------------------------------
--	Datum:		06.11.09
--	Version:	1.3
--------------------------------------------------------------------------------
--	Aenderungen:
--	Die Schiebeweite aus einem Register wird nicht mehr
--	durch den Shiftrecoder geleitet, stattdesssen steuert
--	ein hier erzeugtes Steuersignal, ob der Datenausgang
--	des Shiftrecoders oder unmittelbar Byte 0 von Operand C
--	in der Decodestufe in das OPC-Register geschrieben werden sollen.
--	Dadurch koennte AMOUNT auch auf 6 Bit verkleinert werden, vorlaeufig
--	werden die ueberfluessigen 3 Bit aber beibehalten
-- 	Eingang SRC_RS_BYTE_0 wurde (weil nun ueberfluessig) entfernt.
--	Verkleinerung von SHIFT_AMOUNT
--	SHIFT_AMOUNT wird auf die notwendige Stellenzahl von 6 verkleinert
--	um die entsprechenden Synthesewarnungen zu entfernen
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;

--Um alle Shifts auf Operand 2 im Datenpfad möglichst gleich behandeln zu können, 
--müssen die Unterschiedlichen Shifttypen und Weitenangaben auf einheitliche Steuersignale
--umkodiert werden.
entity ArmShiftRecoder is
	port(	SRC_OPERAND_2 		: in std_logic_vector(11 downto 5);
		SRC_OPERAND_2_TYPE 	: in std_logic_vector(1 downto 0);
		SRC_SHIFT_AMOUNT	: out std_logic_vector(5 downto 0);
		SRC_SHIFT_TYPE		: out std_logic_vector(1 downto 0);
		SRC_SHIFT_RRX		: out std_logic;
		SRC_USE_OPC		: out std_logic	
	);
end ArmShiftRecoder;

architecture behave of ArmShiftRecoder is
begin

	SET_SHIFT_CTRL_SIGNALS : process(SRC_OPERAND_2, SRC_OPERAND_2_TYPE)IS
		alias IMMEDIATE_ROT_WIDTH : STD_LOGIC_VECTOR(3 downto 0) IS SRC_OPERAND_2(11 downto 8);
		alias REGISTER_SHIFT_WIDTH : STD_LOGIC_VECTOR(4 downto 0) IS SRC_OPERAND_2(11 downto 7);
		alias OPERAND_2_SHIFT_TYPE : STD_LOGIC_VECTOR(1 downto 0) IS SRC_OPERAND_2(6 downto 5);
	begin
--		Standardzuweisungen, Operand 2 wird ohne Veränderung durch den Shifter geleitet
		SRC_SHIFT_AMOUNT <= (others => '0');
		SRC_SHIFT_TYPE <= SH_LSL;
		SRC_SHIFT_RRX <= '0';
		SRC_USE_OPC <= '0';
		case SRC_OPERAND_2_TYPE is
			when OP2_IMMEDIATE =>
--				Die tatsächliche Schiebeweite entspricht der Angabe im Befehl * 2
				SRC_SHIFT_AMOUNT <= '0' & IMMEDIATE_ROT_WIDTH & '0';
				SRC_SHIFT_TYPE <= SH_ROR;
			when OP2_REGISTER =>
				SRC_SHIFT_TYPE <= OPERAND_2_SHIFT_TYPE;
				CASE OPERAND_2_SHIFT_TYPE IS
					when SH_LSL =>
						SRC_SHIFT_AMOUNT <= '0' & REGISTER_SHIFT_WIDTH;
					when SH_LSR|SH_ASR =>
						if(REGISTER_SHIFT_WIDTH = "00000")then
							SRC_SHIFT_AMOUNT <= "100000"; 	-- = 32
						else
							SRC_SHIFT_AMOUNT <= '0' & REGISTER_SHIFT_WIDTH;
						end if;
					when others =>
					-- SH_ROR, hier muss RRX erkannt werden
						SRC_SHIFT_AMOUNT <= '0' & REGISTER_SHIFT_WIDTH;
						if(REGISTER_SHIFT_WIDTH = "00000")then
							SRC_SHIFT_RRX <= '1';
						end if;	
				end CASE;
			when OP2_REGISTER_REGISTER =>
				SRC_SHIFT_TYPE <= OPERAND_2_SHIFT_TYPE;
				SRC_SHIFT_AMOUNT <= (others => '0');
				SRC_USE_OPC <= '1';
			when others =>	
		end case;
	end process SET_SHIFT_CTRL_SIGNALS;

end architecture behave;
