--------------------------------------------------------------------------------
--	Chip Select Generator fuer die Auswahl von Peripherie am Datenbus
--------------------------------------------------------------------------------
--	Datum:		28.05.10
--	Version:	1.0
--------------------------------------------------------------------------------
--	Aenderungen:
--	Der Betriebsmodus des Prozessorkerns wird verarbeitet, sodass im USER-
--	Modus bei Bedarf nicht mehr jede Peripheriekomponente aktiviert werden 
--	kann. Dazu muss natuerlich jeder Master einen Modus anzeigen.
--	Der CSG ueberprueft das DEN-Signal des Datenbus (veroderte Bus-Requests
--	aller Master, sodass CS-signale nicht mehr pauschal aktiviert werden,
--	sobald eine gueltige Adresse vorliegt.
--	Die urspruengliche Fassung des CSG (expliziter Adressvergleich durch
--	Test auf die Adressbereichsgrenzen mit groesser/kleiner-Operatoren)
--	wurde entfernt da sie zur Synthese zahlreicher Arithemtikschaltungen 
--	fuehrt. Es verbleibt nur die bessere Neufassung.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
--	CSG_ENTRIES enthaelt die Konfiguration des CSG
use work.ArmConfiguration.CSG_ENTRIES;
use work.ArmTypes.all;

entity ArmChipSelectGenerator is
	port(
		CSG_DA 		: in std_logic_vector(31 downto 0);
		CSG_DEN		: in std_logic;
		CSG_MODE	: in std_logic_vector(4 downto 0);
		CSG_ABORT 	: out std_logic;
		CSG_CS_LINES	: out std_logic_vector(0 to 7)
	    );
end ArmChipSelectGenerator;

--------------------------------------------------------------------------------
-- 	Neue Version des CSG. Der CSG enthaelt 8 statische Eintraege, die mit
-- 	der angelegten Adresse verglichen werden. Zusaetzlich kann gesteuert
-- 	werden, ob Zugriffe im USER-Modus erlaubt sein sollen und ob der
-- 	jeweilige CSG-Eintrag generell aktiv ist.
--------------------------------------------------------------------------------
architecture behave of ArmChipSelectGenerator is
	signal MODE_IS_VALID		: boolean := false;
	signal MODE_IS_USER		: boolean := false;
--------------------------------------------------------------------------------
--	Offset fuer den Vergleich von Adressbits und den Eintraegen
--	in CSG_ENTRIES (entspricht den 12 niederwertigen Addressbits, die fuer
--	die Geraeteanwahl nicht ausgewertet werden.
--------------------------------------------------------------------------------
	constant INDEX_OFFSET		: natural := 12;
--------------------------------------------------------------------------------
--	Nach Adressvergleich mit Maskierung erzeugte interne CS-Signale
--	Mehrere RAW_CS_SIGNALS koennen gleichzeitig aktiv sein, Prio-
--	risierung folgt in einer weiteren Schaltungsstufe. Enable-Wert
--	und Modusinformation sind noch nicht beruecksichtigt.
--------------------------------------------------------------------------------
	signal RAW_CS_SIGNALS		: std_logic_vector(0 to 7) := X"00";
--------------------------------------------------------------------------------
--	Nach Enable und Modusvergleich, vor Priorisierung
-------------------------------------------------------------------------------
	signal FILTERED_CS_SIGNALS	: std_logic_vector(0 to 7) := X"00";
--------------------------------------------------------------------------------
--	Gefilterte, priorisierte, interne, CS-Signale
--------------------------------------------------------------------------------
	signal CSG_CS_LINES_INTERN	: std_logic_vector(0 to 7) := X"00";
begin
--------------------------------------------------------------------------------
-- 	Test, ob der am Datenbus angelegte Moduscode einem definierten Modus
-- 	zugeordnet ist und ob es sich um den USER-Modus handelt
--------------------------------------------------------------------------------
	MODE_IS_VALID	<= true when (CSG_MODE(4) and (
			 	((not CSG_MODE(3)) and (not CSG_MODE(2))) or
				(CSG_MODE(1) and CSG_MODE(0))
				)) = '1' else false;
	MODE_IS_USER	<= MODE_IS_VALID and (CSG_MODE(1 downto 0) = "00");
		
--------------------------------------------------------------------------------
--	Erzeugen der ungefilterten CS-Leitungen durch reinen Adressvergleich
--	unter Beruecksichtigung der Adressmaske
--------------------------------------------------------------------------------
	GEN_RAW_CS_SIGNALS : process(CSG_DA)is
		variable MASKED_ADDRESS : std_logic_vector(19 downto 0);
		variable CMP_BIT	: std_logic;
	begin
		for i in CSG_ENTRIES_TYPE'left to CSG_ENTRIES_TYPE'right loop
			CMP_BIT := '1';			
			for j in 19 downto 0 loop
				CMP_BIT := CMP_BIT and ((not CSG_ENTRIES(i).BASE_ADDRESS_MASK(j)) or
					(CSG_DA(j + INDEX_OFFSET) xnor CSG_ENTRIES(i).BASE_ADDRESS(j)));
			end loop;
			RAW_CS_SIGNALS(i) <= CMP_BIT;
		end loop;
	end process GEN_RAW_CS_SIGNALS;
--------------------------------------------------------------------------------
--	Erste Filterstufe mit Beruecksichtigung des aktuellen Betriebsmodus.
--------------------------------------------------------------------------------
	GEN_FILTERED_CS_SIGNALS : process(MODE_IS_VALID,MODE_IS_USER,CSG_DEN, RAW_CS_SIGNALS)is
	begin
		for i in CSG_ENTRIES_TYPE'left to CSG_ENTRIES_TYPE'right loop
			if CSG_ENTRIES(i).ENABLE_CS_LINE = '0' then
				FILTERED_CS_SIGNALS(i) <= '0';				
			else
				if MODE_IS_VALID and CSG_DEN = '1' then
					if (MODE_IS_USER and (CSG_ENTRIES(i).ALLOW_USER = '1')) or (not MODE_IS_USER)then
						FILTERED_CS_SIGNALS(i) <= RAW_CS_SIGNALS(i);				
					else 
						FILTERED_CS_SIGNALS(i) <= '0';				
					end if;
				else
					FILTERED_CS_SIGNALS(i) <= '0';				
				end if;	
			end if;
		end loop;
	end process GEN_FILTERED_CS_SIGNALS;
--------------------------------------------------------------------------------
--	Priorisierung (0 > 1 > 2 .. > 7) der CS-Leitungen, sodass immer maximal
-- 	eine aktiv ist, Abort wird angezeigt, wenn keine der Leitungen aktiv
-- 	ist, also keine Peripheriekomponente ausgewaehlt
--------------------------------------------------------------------------------
	GEN_CS_LINES : process(FILTERED_CS_SIGNALS)is
		variable CS_ACTIVE	 : boolean := false;
		variable TEMP_CS_SIGNALS : std_logic_vector(0 to 7) := X"00";
	begin
		CS_ACTIVE := false;
		for i in 0 to 7 loop
			if FILTERED_CS_SIGNALS(i) = '1' and not CS_ACTIVE then
				TEMP_CS_SIGNALS(i)	:= '1';
				CS_ACTIVE := true;
			else
				TEMP_CS_SIGNALS(i)	:= '0';
				CS_ACTIVE := false;
			end if;
		end loop;
		CSG_CS_LINES_INTERN <= TEMP_CS_SIGNALS;
	end process GEN_CS_LINES;
--------------------------------------------------------------------------------
--	Signalzuweisung testweise mit Verzoegerungen um Kollisionen in der
-- 	Verhaltenssimulation zu begegnen
-- 	CSG_ABORT wird auf Z gesetzt wenn eine der CS-Leitungen aktiv
-- 	ist, weil das dadurch aktivierte Geraet die ABORT-Leitung des
-- 	Datenbus ebenfalls treibt. Das Abort-Signal wird in allen anderen
--	Faellen getrieben, auch wenn kein Bus-Request vorliegt. Das sollte
--	unproblematisch sein, weil ohne Request kein Master das Abort
--	auswertet.	
--------------------------------------------------------------------------------
	CSG_ABORT	<= '1' after 1 ns when CSG_CS_LINES_INTERN = X"00" else 'Z' after 1 ns;
	CSG_CS_LINES	<= CSG_CS_LINES_INTERN;
--------------------------------------------------------------------------------
-- 	Test waehrend der Verhaltenssimulation, es darf nie mehr als eine
--	der CS-Leitungen aktiv sein.
--------------------------------------------------------------------------------
-- synthesis translate_off
	CHECK_CS_SIGNALS : process(CSG_CS_LINES_INTERN)is
		variable NR_SET : natural range 0 to 8 := 0;
	begin
		NR_SET := 0;
		for i in CSG_CS_LINES_INTERN'left to CSG_CS_LINES_INTERN'right loop
			if CSG_CS_LINES_INTERN(i) = '1' then
				NR_SET := NR_SET + 1;
			end if;
		end loop;
		assert NR_SET < 2 report "Fehler: > 1 CS-Leitungen aktiv." severity failure;
	end process CHECK_CS_SIGNALS;
-- synthesis translate_on		
end architecture behave;

