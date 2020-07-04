--------------------------------------------------------------------------------
--! @file TB_Tools.vhd
--! @brief Typen und Funktionen zur Unterstützung von Testbenches
--!
--! Die Funktionen zum Einlesen von Stimulidateien sollen nicht in den Testbenches
--! stehen sondern hier implementiert werden. Auf diese Weise verbessern sich
--! die Übersichtlichkeit der Testbenches so wie die Möglichkeiten der Codewieder-
--! verwendung.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--! 	Paket mit den elementaren Funktionen auf Dateien
--------------------------------------------------------------------------------
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--Führt mit ISIM zu Fehler 606, allein das Einbinden des Package. Nur bei
--Verwendung von Modelsim evtl. einkommentieren
--USE IEEE.math_real.ALL;
--------------------------------------------------------------------------------
--!	Das Paket STD_LOGIC_TEXTIO liefert zusätzliche Funktionen zum
--!	oktalen/hexadezimalen Lesen/Schreien auf Dateien
--------------------------------------------------------------------------------
use ieee.std_logic_textio.all;

library work;
use work.ArmTypes.all;
use work.ArmConfiguration.ALL;

library work;
use work.ArmFilePaths.ALL;

package TB_Tools is

--------------------------------------------------------------------------------
--! 	Basispfad für alle Testvektordateien, ist in ArmFilePaths individuell anzupassen
--------------------------------------------------------------------------------
	SIGNAL TESTDATA_FOLDER_PATH : string(1 to TESTVECTOR_FOLDER_PATH'length) := TESTVECTOR_FOLDER_PATH; --"C:\alutestdata\";
-- 	SIGNAL TESTDATA_FOLDER_PATH : string(1 to 15) := "C:\alutestdata\";

--------------------------------------------------------------------------------
--! 	Maximale Zahl von Zeichen in einer Zeile einer Testvektordatei,
--! 	willkürlich gewählt, spielt keine Rolle, wenn direkt auf line-Objekten
--! 	gearbeitet wird und kann deshalb ignoriert werden
--------------------------------------------------------------------------------
	constant MAX_STRING_LENGTH : natural := 160;
	subtype STRING160 is STRING(1 to MAX_STRING_LENGTH);

--------------------------------------------------------------------------------
--!	@brief Typen und Konstanten für Testbenchprozeduren
--! 	TAB_CHAR, SPACE_CHAR und NUL_CHAR entsprechen direkt den Definitionen
--! 	des Pakets "standard" und werden hier nur aus Übersichtsgründen neu
--! 	definiert
--------------------------------------------------------------------------------
	constant COMMENT_CHAR : character := '#';
	constant SPACE_CHAR : character := ' ';
	constant TAB_CHAR : character := HT;
    --KAIS EDIT: Added CR as character -> Used in IS_COMMENT
    constant CR_CHAR  : character := CR;
	constant NUL_CHAR : character := NUL;

--------------------------------------------------------------------------------
--! 	Zeichen anhand derer Beginn und Ende eines Datumsvektors in
--! 	Testvektordateien erkannt werden soll.
--! 	Wird hier für die öffnende Klammer ein "'" und für die
--! 	schließende Klammer ein Leerzeichen angegeben, erhält man im Prinzip
--! 	das Format der HDL Verilog.
--------------------------------------------------------------------------------
	constant VEC_OPEN_BRACKET_CHAR : character := '"';
	constant VEC_CLOSE_BRACKET_CHAR : character := '"';

--------------------------------------------------------------------------------
--! 	WHITE_SPACE_CHARS, also Zeichen, die beim Parsen von Zeilen als
--! 	"Leerzeichen" interpretiert werden und ignoriert werden sollen
--! 	Achtung: Stellenweise erfolgt die Abfrage noch nicht über desen Typ,
--! 	die entsprechenden Zeichen sind stattdessen hart in die Prozeduren
--! 	kodiert.
--------------------------------------------------------------------------------
	type WSCplus is (' ',HT,error);
	type BOOLEAN_indexed_by_WSCplus is array(character) of BOOLEAN;
	constant CHAR_IS_WHITESPACE : BOOLEAN_indexed_by_WSCplus :=
		(' ' => true, HT => true, others => false);


--------------------------------------------------------------------------------
--! 	VECTOR_PREFIX_TYPES_PLUS: Alle erlaubten Präfixe für Daten in
--!	Testvektordateien
--! 	d: dezimal, erlaubt die Angabe von Integers
--! 	b/o/h: binär/oktal/hexadezimal
--------------------------------------------------------------------------------
--!	VPTplus_to_FACTOR liefert für Präfixe, die Potenzen von 2 sind, den
--! 	Faktor, um den ein binärer Vektor länger ist als der Vektor mit dem
--! 	entsprechenden Präfix
--------------------------------------------------------------------------------
	type VPTplus is ('b','d','o','h',error);
	type VPTplus_indexed_by_char is array(character) of VPTplus;
	constant char_to_VPTplus : VPTplus_indexed_by_char :=
		('b' => 'b', 'B' => 'b', 'd' => 'd', 'D' => 'd' ,'o' => 'o',
	         'O' => 'o', 'h' => 'h', 'H' => 'h', others => error);
	type FACTOR_indexed_by_VPTplus is array(VPTplus) of integer range 0 to 4;
	constant VPTplus_to_FACTOR : FACTOR_indexed_by_VPTplus :=
		('b' => 1, 'o' => 3, 'h' => 4, others => 0);


--------------------------------------------------------------------------------
--! 	Abbildung von STD_LOGIC auf character um Strings von STD_LOGIC_VECTOR
--! 	bilden zu können
--! 	...Ja, es ist genau so absurd, wie es aussieht...
--------------------------------------------------------------------------------
	type char_indexed_by_SL is array(STD_LOGIC) of character;
	constant SL_TO_CHAR :	char_indexed_by_SL :=
		('0' => '0', '1' => '1', 'U' => 'U', 'X' => 'X', 'Z' => 'Z',
		 'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-', others => '?');
--------------------------------------------------------------------------------
--! 	Funktions/Prozedurprototypen
--------------------------------------------------------------------------------
	procedure GET_LOGIC_VECTOR_FROM_LINE(THIS_LINE : inout LINE; SLV: inout std_logic_vector);
	procedure GET_LOGIC_VECTOR_FROM_LINE(THIS_LINE : inout LINE; SLV: inout std_logic_vector; IS_COMMENT : out boolean);
--	procedure GET_DATA_LINE_FROM_LINE(THIS_LINE : inout LINE; DATA_LINE : inout LINE);
	function ULV_TO_STRING(ULV: unsigned) return string;
	function SLV_TO_STRING(SLV: STD_LOGIC_VECTOR) return STRING;
	procedure LINE_IS_COMMENT(THIS_LINE : inout LINE; COMMENT : out boolean);
--------------------------------------------------------------------------------
--! 	Unwichtige oder private Funktionen
--------------------------------------------------------------------------------
	impure function READ_STRING160 (file TEXT_FILE : TEXT) return STRING160;
	procedure GET_SLV(THIS_LINE: inout line; PREFIX : in VPTplus; SLV : inout std_logic_vector);
	function SL_TO_STRING(SL: STD_LOGIC) return STRING;
	function SLV_TO_NR_STRING(THIS_SLV: STD_LOGIC_VECTOR) return STRING;
--------------------------------------------------------------------------------
--!	Konstanten zum Aufhübschen der Testbenchausgaben
--------------------------------------------------------------------------------
--	constant SEPERATOR_LINE : string(80 downto 1) :=
--		"--------------------------------------------------------------------------------";
	constant SEPARATOR_LINE : string(80 downto 1) :=
		"--------------------------------------------------------------------------------";


	constant DESIRED_BIT_STABLE_TIME : TIME := RS232_DELAY_TIME - RS232_DELAY_TIME/10;
--------------------------------------------------------------------------------
--!	Globale Variablen und Funktionen zur Erzeugung von Zufallszahlen
--------------------------------------------------------------------------------

--	Bei der Verwendung von Modelsim und IEEE.Math_Real notwendig
--	shared variable SEEDS_INITIALIZED : boolean := false;
--	shared variable SEED1,SEED2 : integer;
--	procedure GET_RANDOM_SLV(RANDOM_SLV: inout STD_LOGIC_VECTOR);
--	procedure INIT_SEEDS(NEW_SEED1,NEW_SEED2 : in integer);

--	Produktion von Pseudozufallszahlen bei Verwendung von ISIM
	shared variable SEED_INITIALIZED_ISIM : boolean := false;
	shared variable LFSR32 : std_logic_vector(31 downto 0);
	procedure GET_RANDOM_SLV_ISIM(RANDOM_SLV: inout STD_LOGIC_VECTOR);
	procedure INIT_SEED_ISIM(NEW_SEED : in integer);

end package TB_Tools;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

package body TB_Tools is
--------------------------------------------------------------------------------
--! 	Einen String definierter Länge (160 Zeichen) zur weiteren Bearbeitung aus
--! 	einer Datei
--! 	lesen.
--! 	Das Lesen unbeschränkter Strings ist nicht möglich.
--------------------------------------------------------------------------------

	impure function READ_STRING160(file TEXT_FILE : TEXT) return STRING160 is
		variable NOT_END_OF_LINE : boolean := true;
		variable CHAR : character;
		variable TEXT_LINE : line;
		variable TEXT_STRING160 : STRING160 := (others => ' ');

	begin
--! 		Eine Zeile aus der Textdatei lesen
		readline(TEXT_FILE,TEXT_LINE);
		for i in 1 to MAX_STRING_LENGTH loop
			read(TEXT_LINE,CHAR,NOT_END_OF_LINE);
			if NOT_END_OF_LINE then
				TEXT_STRING160(i) := CHAR;
			else
				exit;
			end if;
		end loop;
		return TEXT_STRING160;
	end function READ_STRING160;

--------------------------------------------------------------------------------
--! 	Umwandlung eines gelesenen Characters nach Integer, alle Nichtzahlen werden
--!	auf 0 abgebildet
--------------------------------------------------------------------------------
	function CHAR_TO_INT(CHAR : character) return integer is
		variable temp : integer := 0;
	begin
		case CHAR is
			when '0' =>
				temp := 0;
			when '1' =>
				temp := 1;
			when '2' =>
				temp := 2;
			when '3' =>
				temp := 3;
			when '4' =>
				temp := 4;
			when '5' =>
				temp := 5;
			when '6' =>
				temp := 6;
			when '7' =>
				temp := 7;
			when '8' =>
				temp := 8;
			when '9' =>
				temp := 9;
			when others =>
				temp := 0;
		end case;
		return temp;
	end function CHAR_TO_INT;

--------------------------------------------------------------------------------
--! 	LINE_IS_COMMENT ermittelt, ob eine Zeile eine Kommentarzeile ist.
--! 	Voraussetzung: die Zeile enthält entweder nur Tabs und/oder Leerzeichen
--! 	oder das erste von Tab/Space verschiedene Zeichen ist ein Kommentarzeichen
--! 	(#).
--!     KAIS EDIT: Added CR_CHAR because Vivado fails to empty latin coded lines
--------------------------------------------------------------------------------
	procedure LINE_IS_COMMENT(THIS_LINE : inout line; COMMENT : out boolean) is
	begin
		COMMENT := true;
		for i in THIS_LINE.all'left to THIS_LINE.all'right loop
			case THIS_LINE(i) is
				when TAB_CHAR | SPACE_CHAR | CR_CHAR =>
				        null;
				when COMMENT_CHAR =>
					exit;
				when others =>
					COMMENT := false;
					exit;
			end case;
		end loop;
	end procedure LINE_IS_COMMENT;

--------------------------------------------------------------------------------
--! 	Aus der übergebenen Zeile ein Datum extrahieren un als std_logic_vector
--! 	zurückgeben.
--! 	Dabei ist die Vektorlänge egal. Das Datum in der Zeile hat die Form
--! 	Präfix"Datum"
--! 	mit Präfix = [b,o,h,d].
--! 	Vor dem Datum können Leerzeichen oder Tabulatoren stehen, dahinter
--! 	beliebige Zeichen.
--------------------------------------------------------------------------------

	procedure GET_LOGIC_VECTOR_FROM_LINE(THIS_LINE : inout line; SLV: inout std_logic_vector)is
		constant SLV_WIDTH : integer := SLV'length;
		constant L_WIDTH : integer := THIS_LINE.all'length;
		variable CHAR : character;
--		Der linke Index des Line-Strings ist immer 1.
		variable i,UPPER_BOUND,LOWER_BOUND,k,l : integer;
		variable TEMP_SLV : std_logic_vector(SLV_WIDTH-1 downto 0);
		variable TEST_DATA_TYPE : VPTplus;
		variable NEW_LINE : line;
	begin

--! 		Im Folgenden wird zur Vereinfachung auf einem Vektor der Form (n-1 downto 0)
--! 		gearbeitet, die Anpassung an das Format von SLV (Richtung, Grenzen)
--! 		erfolgt am Ende der Prozedur.
		TEMP_SLV(SLV_WIDTH-1 downto 0) := (others => 'U');
		TEST_DATA_TYPE := error;
		i := 1;
--		Nach einem vektoreinleitenden Character müssen noch mind. 2 Zeichen folgen
		while i < L_WIDTH-2 loop
			CHAR := THIS_LINE(i);
			TEST_DATA_TYPE := CHAR_TO_VPTplus(CHAR);
			if(CHAR = TAB_CHAR or CHAR = SPACE_CHAR)then
				NULL;
			elsif(CHAR=COMMENT_CHAR) then
				report "Keine Datenzeile" severity error;
				exit;
			elsif(TEST_DATA_TYPE = error)then
				report "Unerwartetes Zeichen in Datenzeile" severity error;
				exit;
			else
--			CHAR entspricht einem Vektoreinleitenden Zeichen
--			Das nächste Zeichen muss die öffnende Klammer des Vektors sein
				i := i + 1;
				if(THIS_LINE(i) /= VEC_OPEN_BRACKET_CHAR) then
					report "Datum nicht wohlgeformt" severity error;
					TEST_DATA_TYPE := error;
					exit;
				else
					LOWER_BOUND := i;
					exit;
				end if;

			end if;
			i := i + 1;
		end loop;
		if( TEST_DATA_TYPE = error ) then
			null;
		else
			UPPER_BOUND := LOWER_BOUND;
			for i in (LOWER_BOUND + 1) to L_WIDTH loop
				CHAR := THIS_LINE(i);
				if( CHAR = VEC_CLOSE_BRACKET_CHAR ) then
					UPPER_BOUND := i;
					exit;
				end if;
			end loop;

			if(UPPER_BOUND = LOWER_BOUND ) then
				report "Datum nicht wohlgeformt" severity error;
			elsif(UPPER_BOUND = LOWER_BOUND + 1 ) then
				report "Leeres Datum, wird als 0 interpretiert" severity note;
				TEMP_SLV (TEMP_SLV'left downto TEMP_SLV'right) := (others => '0');
			else
				Deallocate(NEW_LINE);
--				NEW_LINE := new string'(THIS_LINE((LOWER_BOUND+1) to (UPPER_BOUND -1)));
				WRITE(NEW_LINE, THIS_LINE((LOWER_BOUND+1) to (UPPER_BOUND -1)));
				GET_SLV(NEW_LINE, TEST_DATA_TYPE, TEMP_SLV);
				Deallocate(NEW_LINE);
			end if;
		end if;

		l := SLV_WIDTH - 1;

--		Richtungsanpassung, das gelesene Datum wird rechts im übergebenen Vektor ausgerichtet
		if SLV'ascending then
			SLV(SLV'left to SLV'right) := TEMP_SLV(SLV_WIDTH-1 downto 0);
		else
			SLV(SLV'left downto SLV'right) := TEMP_SLV(SLV_WIDTH-1 downto 0);
		end if;
	end procedure GET_LOGIC_VECTOR_FROM_LINE;


	procedure GET_LOGIC_VECTOR_FROM_LINE(THIS_LINE : inout LINE; SLV: inout std_logic_vector; IS_COMMENT : out boolean) is
		variable TEMP_COMMENT : boolean := false;
	begin
		LINE_IS_COMMENT(THIS_LINE,TEMP_COMMENT);
		IS_COMMENT := TEMP_COMMENT;
		if(TEMP_COMMENT)then
			null;
		else
			GET_LOGIC_VECTOR_FROM_LINE(THIS_LINE,SLV);
		end if;


	end procedure GET_LOGIC_VECTOR_FROM_LINE;

--	procedure GET_DATA_LINE_FROM_LINE(THIS_LINE : inout LINE; DATA_LINE : inout LINE) is
--	begin
--	end procedure GET_DATA_LINE_FROM_LINE;
--------------------------------------------------------------------------------
--! 	Hilfsfunktion für GET_LOGIC_VECTOR_FROM_LINE
--!	SLV _muss_ ein Vektor der Form (n-1 downto 0)
--------------------------------------------------------------------------------
	procedure GET_SLV(THIS_LINE : inout LINE; PREFIX: in VPTplus; SLV : inout std_logic_vector) is
--		Quellvektorgröße, ggf. mit einem Faktor für oktale und hexadezimale Angaben zu multiplizieren
		constant DATA_WIDTH : integer := THIS_LINE.all'length;
		constant REAL_DATA_WIDTH : integer := THIS_LINE.all'length * VPTplus_TO_FACTOR(PREFIX);
--		Zielvektorgröße
		constant V_WIDTH : integer := SLV'length;
		variable TEMP_INT : integer;
		variable TEMP_SLV : std_logic_vector(REAL_DATA_WIDTH-1 downto 0);
		variable READ_SUCCESS : boolean := false;
	begin
		TEMP_SLV := (others => 'U');
		case PREFIX is
			when error =>
				null;
			when 'b' =>
				read(THIS_LINE,TEMP_SLV,READ_SUCCESS);
			when 'o' =>
				oread(THIS_LINE,TEMP_SLV,READ_SUCCESS);
			when 'h' =>
				hread(THIS_LINE,TEMP_SLV,READ_SUCCESS);
			when 'd' =>
				read(THIS_LINE,TEMP_INT,READ_SUCCESS);
			when others =>
				report "Nicht implementiertes Vektorprefix aufgetreten" severity error;
		end case;
		if(READ_SUCCESS) then
			case PREFIX is
				when error =>
					SLV(SLV'left downto SLV'right) := (others => 'U');
				when 'b'|'o'|'h' =>
					if(TEMP_SLV'length = V_WIDTH ) then
						SLV := TEMP_SLV;
					elsif(TEMP_SLV'length < V_WIDTH) then
						report "Angefordertes Datum groesser als gelesendes Datum, wird mit 0 aufgefuellt" severity note;
						SLV(SLV'left downto REAL_DATA_WIDTH) := (others => '0');
						SLV(REAL_DATA_WIDTH-1 downto 0) := TEMP_SLV;
					else
						report "Angefordertes Datum kleiner als gelesendes Datum, wird beschnitten" severity warning;
						SLV := TEMP_SLV(V_WIDTH - 1 downto 0);
					end if;
				when 'd' =>
					SLV := std_logic_vector(to_signed(TEMP_INT,SLV'length));
			end case;
		else
			report "Lesen des Datums fehlgeschlagen" severity error;
			SLV(SLV'length-1 downto 0) := (others => 'U');
		end if;
	end procedure GET_SLV;

	function ULV_TO_STRING(ULV : unsigned) return string is
	begin
		return SLV_TO_STRING(std_logic_vector(ULV));
	end function ULV_TO_STRING;

--------------------------------------------------------------------------------
--! 	Gibt einen String zurück, der dem übergebenen STD_LOGIC_VECTOR entspricht.
--! 	Dient dazu, nicht mit write-Operationen auf STD_OUTPUT hantieren zu müssen
--! 	wenn ein Vektor auf der Konsole ausgegeben werden soll.
--------------------------------------------------------------------------------

	function SLV_TO_STRING(SLV: std_logic_vector) return string is
		variable SLV_STRING : string(SLV'length downto 1);
		variable j : integer;
	begin
		j := SLV'length;
		if SLV'ascending then
			for i in SLV'left to SLV'right loop
				SLV_STRING(j) := SL_TO_CHAR(SLV(i));
				j := j - 1;

			end loop;
		else
			for i in SLV'left downto SLV'right loop
				SLV_STRING(j) := SL_TO_CHAR(SLV(i));
				j := j - 1;
			end loop;
		end if;
		return SLV_STRING;
	end function SLV_TO_STRING;


	function SL_TO_STRING(SL: STD_LOGIC) return STRING is
		variable TEMP_SLV : std_logic_vector(0 downto 0);
	begin
		TEMP_SLV(0) := SL;
	       return SLV_TO_STRING(TEMP_SLV);
       end function SL_TO_STRING;

	function SLV_TO_NR_STRING(THIS_SLV: std_logic_vector) return string is
	begin
		return integer'image(to_integer(unsigned(THIS_SLV)));
	end function SLV_TO_NR_STRING;

--	procedure INIT_SEEDS(constant NEW_SEED1,NEW_SEED2 : in integer) is
--	begin
--			SEED1 := NEW_SEED1;
--			SEED2 := NEW_SEED2;
--			SEEDS_INITIALIZED := true;
--	end procedure INIT_SEEDS;
--
	procedure INIT_SEED_ISIM(constant NEW_SEED : in integer) is
	begin
			LFSR32 :=std_logic_vector(to_signed(NEW_SEED,32));
			SEED_INITIALIZED_ISIM := true;
	end procedure INIT_SEED_ISIM;

--	Seed1 und Seed2 müssen vor dem ersten Aufruf mit Werte im Intervall [1, 2147483398]
--	initialisiert werden
--	procedure GET_RANDOM_SLV(RANDOM_SLV: inout STD_LOGIC_VECTOR) is
--		variable REAL_RANDOM, MAX_VALUE : real;
--		variable REAL_RANDOM_SIGN : real;
--		variable INT_RANDOM,i : integer;
--		variable TEMP_SLV : std_logic_vector(31 downto 0);
--	begin
--		assert RANDOM_SLV'length <= 32 report "Maximale Zufallsvektorlänge : 32" severity error;
--		if NOT SEEDS_INITIALIZED then
--			INIT_SEEDS(23,42);
--		end if;
--		MAX_VALUE := 2**31.0;
--		UNIFORM(SEED1,SEED2,REAL_RANDOM);
--		UNIFORM(SEED1,SEED2,REAL_RANDOM_SIGN);
----		report real'image(REAL_RANDOM);
--		INT_RANDOM := INTEGER(TRUNC(REAL_RANDOM * MAX_VALUE));
--		TEMP_SLV := std_logic_vector(to_signed(INT_RANDOM,32));
--		if(REAL_RANDOM_SIGN < 0.5)then
--			TEMP_SLV(31) := '1';
--		end if;
--		i := 0;
--		for j in RANDOM_SLV'range loop
--			RANDOM_SLV(j) := TEMP_SLV(i);
--			i := i + 1;
--		end loop;
--
--	end procedure GET_RANDOM_SLV;

--------------------------------------------------------------------------------
--	Produktion von Pseudozufallszahlen durch ein (virtuelles) linear
--	rueckgekoppeltes Schieberegister, funktioniert unabhaengig vom
--	Simulator.
--------------------------------------------------------------------------------
	procedure GET_RANDOM_SLV_ISIM(RANDOM_SLV: inout std_logic_vector) is
		variable i : integer;
	begin
		assert RANDOM_SLV'length <= 32 report "Maximale Zufallsvektorlaenge : 32" severity error;
		if not SEED_INITIALIZED_ISIM then
			INIT_SEED_ISIM(3242);
		end if;
		for k in 0 to 6 loop
			LFSR32(31 downto 0) := LFSR32(30 downto 0) & (not LFSR32(31) xor LFSR32(22) xor LFSR32(2) xor LFSR32(1));
--		        LFSR32(0) <= NOT LFSR32(31) XOR LFSR32(22) XOR LFSR32(2) XOR LFSR32(1);
		end loop;

		i := 0;
		for j in RANDOM_SLV'range loop
			RANDOM_SLV(j) := LFSR32(i);
			i := i + 1;
		end loop;

	end procedure GET_RANDOM_SLV_ISIM;


end package body TB_Tools;
