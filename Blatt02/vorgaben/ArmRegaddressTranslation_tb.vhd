--------------------------------------------------------------------------------
--	Testbench der Uebersetzungsfunktion fuer Registeradressen des ARM-SoC
--------------------------------------------------------------------------------
--	Datum:		03.05.2010
--	Version:	1.0
--------------------------------------------------------------------------------
--library std;
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ArmTypes.all;
use work.ArmRegaddressTranslation.GET_INTERNAL_ADDRESS;

--------------------------------------------------------------------------------		
--	Zusaetzliche Entity in der die zu testende Funktion aufgerufen wird, auf
--	diese Weise erhaelt man beim Aufruf von ModelSim aus ISE zuverlaessig
--	die relevanten Signale in der Waveform (im Gegensatz zum direkten 
--	Aufruf der Funktion in der TB)
--------------------------------------------------------------------------------		
entity unit_under_test is
	port(THIS_MODE			: in MODE;
	     VIRTUAL_ADDRESS	: in std_logic_vector(3 downto 0);
	     User_Bit			: in std_logic;
	     PHYSICAL_ADDRESS	: out std_logic_vector(4 downto 0)
     );
end entity unit_under_test;

architecture behave of unit_under_test is
begin
	PHYSICAL_ADDRESS <= GET_INTERNAL_ADDRESS(VIRTUAL_ADDRESS, THIS_MODE, User_Bit);
end architecture behave;	
		
--------------------------------------------------------------------------------		
--	Ab hier: Testbench
--------------------------------------------------------------------------------		
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE ieee.std_logic_textio.all;
library work;
use work.ArmTypes.all;
use work.ArmRegaddressTranslation.GET_INTERNAL_ADDRESS;
use work.TB_Tools.all;

entity ArmRegaddressTranslation_tb is
end ArmRegaddressTranslation_tb;

architecture testbench of ArmRegaddressTranslation_tb is
	type REGADDRTRANS_TYPE is record
		RAT_MODE : MODE;
		RAT_ADDR : RegAddress;
		RAT_USER : std_logic;
	end record REGADDRTRANS_TYPE;

	component unit_under_test
	port(THIS_MODE		: in MODE;
	     VIRTUAL_ADDRESS	: in std_logic_vector(3 downto 0);
	     User_Bit		: in std_logic;
	     PHYSICAL_ADDRESS	: out std_logic_vector(4 downto 0)
     	); 
	end component unit_under_test;

	type ALL_MODES_TYPE is array(0 to 6) of MODE;
	type TRANS_TABLE_TYPE is array( 0 to 31) of REGADDRTRANS_TYPE;
	signal TRANS_TABLE : TRANS_TABLE_TYPE := (others => ("UUUUU","UUUU",'U'));
	type TRANS_CNT_TYPE is array( 0 to 31) of integer range 0 to 31;
	constant ALL_MODES : ALL_MODES_TYPE := (USER, SYSTEM, FIQ, SUPERVISOR, IRQ, ABORT, UNDEFINED);
	type ALL_VALID_MODES_NAMES_TYPE is array(0 to 6) of string(1 to 10);
	constant ALL_VALID_MODES_NAMES : ALL_VALID_MODES_NAMES_TYPE := ("USER      ", "SYSTEM    ", "FIQ       ","SUPERVISOR", "IRQ       ", "ABORT     ", "UNDEFINED ");


	function mode_to_index(this_mode : MODE) return integer is
		variable this_index : integer range 0 to 6;
	begin
		case this_mode is
			when USER => this_index := 0;
			when SYSTEM => this_index := 1;
			when FIQ => this_index := 2;
			when SUPERVISOR => this_index := 3;
			when IRQ => this_index := 4;
			when ABORT => this_index := 5;
			when others => this_index := 6;
		end case;
		return this_index;
	end function mode_to_index;

	signal THIS_MODE : MODE;
	signal VIRTUAL_ADDRESS : std_logic_vector(3 downto 0) := "0000";
	signal User_Bit : std_logic := '0';
	signal PHYSICAL_ADDRESS : std_logic_vector(4 downto 0);

	procedure SLV_IS_BINARY(variable INPUT: in std_logic_vector; variable IS_BINARY : out boolean) is
	begin
		IS_BINARY := true;
		for i in INPUT'range loop
			if INPUT(i) /= '0' and INPUT(i) /= '1' then
				IS_BINARY := false;
				exit;
			end if;
		end loop;
	end procedure SLV_IS_BINARY;


	procedure SLV_IS_BINARY_OR_DONTCARE(variable INPUT: in std_logic_vector; variable IS_BINARY : out boolean) is
	begin
		IS_BINARY := true;
		for i in INPUT'range loop
			if INPUT(i) /= '0' and INPUT(i) /= '1' and INPUT(i) /= '-' then
				IS_BINARY := false;
				exit;
			end if;
		end loop;		
	end procedure SLV_IS_BINARY_OR_DONTCARE;

	function COUNT_DEFINED(signal TRANS_TABLE: TRANS_TABLE_TYPE) return natural is
		variable COUNT : natural range 0 to 32 := 0;
	begin
		for i in TRANS_TABLE'range loop
			if TRANS_TABLE(i).RAT_MODE /= "UUUUU" and TRANS_TABLE(i).RAT_ADDR /= "UUUU" then
				COUNT := COUNT + 1;
			else
				null;
			end if;
		end loop;
		return COUNT;
	end function COUNT_DEFINED;

	procedure PRINT_TABLE(signal TRANS_TABLE: in TRANS_TABLE_TYPE; constant LOW, HIGH : integer range 0 to 31) is
		variable THIS_MODE	: MODE;
		variable VIR_ADDR	: std_logic_vector(3 downto 0);
		variable IS_BINARY	: boolean := false;
		variable THIS_LINE	: std.textio.line;
	begin
		report SEPARATOR_LINE;
		report "Ermittelte Adressabbildung:";
		report "phy. Adresse" & TAB_CHAR & "<=" & TAB_CHAR & " Modus; " & TAB_CHAR & " virt. Adresse"; 
		report SEPARATOR_LINE;
		for i in LOW to HIGH loop
			THIS_MODE	:= TRANS_TABLE(i).RAT_MODE;
			VIR_ADDR	:= TRANS_TABLE(i).RAT_ADDR;
			SLV_IS_BINARY(this_mode,IS_BINARY);
			if IS_BINARY then
				std.textio.write(this_line, SLV_TO_STRING(std_logic_vector(to_unsigned(i,5))) & " (" & integer'image(i)& ") " & TAB_CHAR & "<=" & TAB_CHAR & ALL_VALID_MODES_NAMES(mode_to_index(this_mode)) & "; " & TAB_CHAR & SLV_TO_STRING(VIR_ADDR) & " (" & integer'image(to_integer(unsigned(VIR_ADDR))) & ")");
			else
				std.textio.write(this_line, SLV_TO_STRING(std_logic_vector(to_unsigned(i,5))) & " (" & integer'image(i)& ") " & TAB_CHAR &"<=" & TAB_CHAR & "?????     ; " & TAB_CHAR & " ????");
			end if;	
			report this_line.all;
			std.textio.Deallocate(this_line);
		end loop;
		report SEPARATOR_LINE;
	end procedure PRINT_TABLE;

begin	
	uut: UNIT_UNDER_TEST
	port map(THIS_MODE => THIS_MODE,
		VIRTUAL_ADDRESS => VIRTUAL_ADDRESS,
		User_BIT => User_bit,
		PHYSICAL_ADDRESS => PHYSICAL_ADDRESS);

	test: process is
	variable TVECTOR : REGADDRTRANS_TYPE := (USER, "0001", '0');
	variable IS_BINARY : boolean;
	variable PHY_ADDR_NO_USER : std_logic_vector(4 downto 0) := "00000";
	variable PHY_ADDR_USER : std_logic_vector(4 downto 0) := "00000";
	variable GENERAL_ERROR, USER_ERROR, VALIDITY_ERROR, EQUAL_ERROR, UNINITIALIZED_ERROR : boolean := false;
	type REGS_FOR_MODES is array (ALL_MODES'range) of std_logic_vector(4 downto 0);
	variable PHY_ADDR_REGS_MODE : REGS_FOR_MODES;
--------------------------------------------------------------------------------
--Ueberprueft ob alle Elemente eine Arrays gleich sind
--------------------------------------------------------------------------------
	function ALL_EQUAL (VAL_AR : REGS_FOR_MODES) return boolean is
		variable RESULT : boolean := true;
	begin
		for i in VAL_AR'range loop
			for j in i+1 to VAL_AR'high loop
				RESULT := RESULT and (VAL_AR(i) = VAL_AR(J));
			end loop;						
		end loop;
		return RESULT;
	end function ALL_EQUAL;

	begin
	report SEPARATOR_LINE;
	report "Test 1: Erzeugen aller 31 notwendigen Kombinationen von Betriebsmodus und virtueller Registeradresse um alle 31 physischen ARM-Register anzusprechen. Die von der Adressabbildung erzeugten physischen Adressen werden gespeichert. Am Ende des ersten Tests muessen 31 unterschiedliche pysische Adressen erzeugt worden sein. Zusaetzlich wird sichergestellt, dass in den Modi User und System fuer jede virtuelle dieselbe physische Adresse erzeugt wird.";
	report SEPARATOR_LINE;
		for i in 0 to 6 loop--ALL_MODES'range loop
			report "Modus: " & ALL_VALID_MODES_NAMES(i);
			TVECTOR.RAT_MODE	:= ALL_MODES(i);
			THIS_MODE			<= ALL_MODES(i);
			TVECTOR.RAT_USER	:= '0';
			User_Bit		<= '0';
			case i is				
				when 0 | 1=> --USER/SYSTEM				
					for j in 0 to 15 loop
						TVECTOR.RAT_ADDR	:= std_logic_vector(to_unsigned(j,4));
						VIRTUAL_ADDRESS		<= std_logic_vector(to_unsigned(j,4));
						wait for 1 ns;
						if i = 0 then
							TRANS_TABLE(to_integer(unsigned(PHYSICAL_ADDRESS))) <= (TVECTOR.RAT_MODE,std_logic_vector(to_unsigned(j,4)),'0');
						else
--							Test mit SYSTEM-Modus, nachdem bereits der Test im USER-Modus durchlaufen wurde.
--							An dieser Stelle muss bereits in Eintrag in TRANS_TABLE vorhanden sein, er wird nicht 
--							erneuert, sondern ueberprueft, ob die dort hinterlegte virt. Adresse mit der aktuellen
--							virt. Adresse uebereinstimmt.
							if TRANS_TABLE(to_integer(unsigned(PHYSICAL_ADDRESS))).RAT_ADDR /= std_logic_vector(to_unsigned(j,4)) then
								report "Abbild fuer User und System ist nicht identisch fuer virt. Adresse " & integer'image(j) severity error;
								GENERAL_ERROR := true;
							end if;
						end if;
						wait for 1 ns;

					end loop;
			when 2 => --FIQ
				 for j in 8 to 14 loop
					TVECTOR.RAT_ADDR := std_logic_vector(to_unsigned(j,4));
					VIRTUAL_ADDRESS <= std_logic_vector(to_unsigned(j,4));
					wait for 1 ns;
					TRANS_TABLE(to_integer(unsigned(PHYSICAL_ADDRESS))) <= (TVECTOR.RAT_MODE,std_logic_vector(to_unsigned(j,4)),'0');
					wait for 1 ns;
				end loop;
			when others =>
				for j in 13 to 14 loop
					TVECTOR.RAT_ADDR := std_logic_vector(to_unsigned(j,4));
					VIRTUAL_ADDRESS <= std_logic_vector(to_unsigned(j,4));
					wait for 1 ns;
					TRANS_TABLE(to_integer(unsigned(PHYSICAL_ADDRESS))) <= (TVECTOR.RAT_MODE,std_logic_vector(to_unsigned(j,4)),'0');
					wait for 1 ns;
				end loop;
			end case;		
		end loop;
		wait for 1 ns;
		PRINT_TABLE(TRANS_TABLE,0,31);

		if COUNT_DEFINED(TRANS_TABLE)<31 then
			report "Es wurden weniger als 31 physische Adressen erzeugt (moeglicher Grund: falsche Mehrfachabbildung auf dieselbe phy. Adresse)." severity error;
			report "Test 1 nicht erfolgreich." severity note;
			GENERAL_ERROR := true;

		else
			report "Es wurden 31 physische Adressen erzeugt, Test 1 erfolgreich." severity note;
		end if;
		report SEPARATOR_LINE;
--------------------------------------------------------------------------------		
--		Test 2: Test auf Wirkung des User-Bits, Testfaelle sind alle 
--		Stimuli, in denen der User-Bit mehr oder weniger sinnvoll
--		auftreten kann, also alle validen Modi, mit allen validen 
--		Registeradressen. Getestet wird jeweils gegen die gleiche
--		Registeradresse im User-Modus, die physischen Adressen 
--		muessen uebereinstimmen.
		report "Test 2: Test auf Wirkung des USER-Bits. In allen validen Betriebsmodi werden alle virt. Registeradressen gemeinsam mit gesetztem USER-Bit erzeugt. Die physische Adresse muss identisch sein mit der Abbildung derselben virtuellen Adresse im USER-Modus (viele der Kombinationen aus Betriebsmodus und Registeradresse verweisen natuerlich auch ohne USER-Bit auf dieselbe physische Adresse wie im USER-Modus)."; 
		report SEPARATOR_LINE;

--	Alle validen Modi	
		for i in 0 to 6 loop
		report "Modus: " & ALL_VALID_MODES_NAMES(i);
--		Alle virtuellen Adressen	
			for j in 0 to 15 loop
				VIRTUAL_ADDRESS <= std_logic_vector(to_unsigned(j,4));
				THIS_MODE <= USER;
				User_bit <= '0';
				wait for 1 ns;
				PHY_ADDR_NO_USER := PHYSICAL_ADDRESS;
				THIS_MODE <= ALL_MODES(i);
				User_Bit <= '1';
				wait for 1 ns;
				PHY_ADDR_USER := PHYSICAL_ADDRESS;
				if (PHY_ADDR_USER /= PHY_ADDR_NO_USER)then
					report "USER-Bit nicht korrekt beruecksichtigt fuer Modus " & ALL_VALID_MODES_NAMES(i) & ", virt. Adresse " & integer'image(j) severity error;
					USER_ERROR := true;
				
				end if;
			end loop;
		end loop;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		if USER_ERROR then
			report "Test 2 nicht erfolgreich.";
		else
			report "Test 2 erfolgreich.";
		end if;
		report SEPARATOR_LINE;
------------------------------------------------------------------------------
--		Test 3: in keiner der moeglichen Eingangskombinationen
--		darf die Physische Adresse andere Werte als 1,0,- annehmen
--		In den Ausgaben der Testbench wird nicht explizit auf die Moeglichkeit hingewiesen, den Ausgang fuer sinnlose 
--		Kombinationen als "-----" zu erzeugen (fuer bessere Syntheseergebnisse), weil dadurch zusaetzlicher 
--	      	Erklaerungsbedarf entsteht.	
		report "Test 3: Abbildung _aller_ moeglich binaeren Parameterkombinationen inkl. nicht erlaubter Modus-Codes durch die Abbildungsfunktion. Die physische Adresse muss dabei immer binaer erzeugt werden (kein X,Z,U,W,L).";
		report SEPARATOR_LINE;
--		Alle THIS_MODE-Codes, auch sinnlose
		for i in 0 to 31 loop
			for j in 0 to 15 loop
				for k in 0 to 1 loop
					THIS_MODE <= std_logic_vector(to_unsigned(i,5));
					VIRTUAL_ADDRESS <= std_logic_vector(to_unsigned(j,4));
					if k = 0 then User_Bit <= '0'; else User_Bit <= '1'; end if;
					wait for 1 ns;
					PHY_ADDR_USER := PHYSICAL_ADDRESS;
					SLV_IS_BINARY_OR_DONTCARE(PHY_ADDR_USER, IS_BINARY);
					if(not IS_BINARY)then
						report "Nicht erlaubte phy. Adresse " & SLV_TO_STRING(PHY_ADDR_USER) & " fuer Modus-Code " & SLV_TO_STRING(THIS_MODE) & ", virt. Adresse " & integer'image(j) & ", USER-Bit " & integer'image(k) severity error;	
						VALIDITY_ERROR := TRUE;
					end if;
				end loop;
			end loop;
		end loop;

		report SEPARATOR_LINE;
		if VALIDITY_ERROR then
			report "Test 3 nicht erfolgreich";
		else
			report "Test 3 erfolreich";
		end if;
		report SEPARATOR_LINE;
------------------------------------------------------------------------------
--	Test 4: Test ob es mehrere PCs gibt
		report "Test 4: Ueberpruefung ob bestimmte Register (z.B.: PC) immer auf gleiche Adresse abgebildet werden.";
		User_bit <= '0';
		report "Ueberpruefe PC";
		for i in ALL_MODES'range loop
			VIRTUAL_ADDRESS <= PC;
			THIS_MODE <= ALL_MODES(i);
			wait for 1 ns;
			PHY_ADDR_REGS_MODE(i) := PHYSICAL_ADDRESS;
			report "Modus: " & ALL_VALID_MODES_NAMES(i) & " physische Adresse: " & SLV_TO_STRING(PHYSICAL_ADDRESS);
			wait for 1 ns;
		end loop;
		if ALL_EQUAL(PHY_ADDR_REGS_MODE) then
		else 
			report "Fehler: PC wird auf verschiedene Adressen abgebildet";
			EQUAL_ERROR := TRUE;
		end if;
		
		for j in 0 to 7 loop
			report "Ueberpruefe R" & integer'image(j);
			for i in ALL_MODES'range loop
				VIRTUAL_ADDRESS <= std_logic_vector(to_unsigned(j,VIRTUAL_ADDRESS'length));
				THIS_MODE <= ALL_MODES(i);
				wait for 1 ns;
				PHY_ADDR_REGS_MODE(i) := PHYSICAL_ADDRESS;
				report "Modus: " & ALL_VALID_MODES_NAMES(i) & " physische Adresse: " & SLV_TO_STRING(PHYSICAL_ADDRESS);
				wait for 1 ns;
			end loop;
			if ALL_EQUAL(PHY_ADDR_REGS_MODE) then
			else
				report "Fehler: R" & integer'image(j) & " wird auf verschiedene Adressen abgebildet";
				EQUAL_ERROR := TRUE;
			end if;
		end loop;

		for j in 8 to 12 loop
			report "Ueberpruefe R" & integer'image(j);
			for i in 0 to 1 loop
				VIRTUAL_ADDRESS <= std_logic_vector(to_unsigned(j,VIRTUAL_ADDRESS'length));
				THIS_MODE <= ALL_MODES(i);
				wait for 1 ns;
				PHY_ADDR_REGS_MODE(i) := PHYSICAL_ADDRESS;
				report "Modus: " & ALL_VALID_MODES_NAMES(i) & " physische Adresse: " & SLV_TO_STRING(PHYSICAL_ADDRESS);
				wait for 1 ns;
			end loop;
			for i in 3 to 6 loop
				VIRTUAL_ADDRESS <= std_logic_vector(to_unsigned(j,VIRTUAL_ADDRESS'length));
				THIS_MODE <= ALL_MODES(i);
				wait for 1 ns;
				PHY_ADDR_REGS_MODE(i) := PHYSICAL_ADDRESS;
				report "Modus: " & ALL_VALID_MODES_NAMES(i) & " physische Adresse: " & SLV_TO_STRING(PHYSICAL_ADDRESS);
				wait for 1 ns;
			end loop;
			-- FIQ ueberschreiben
			PHY_ADDR_REGS_MODE(2) := PHY_ADDR_REGS_MODE(1);
			if ALL_EQUAL(PHY_ADDR_REGS_MODE) then
			else
				report "Fehler: R" & integer'image(j) & " wird auf verschiedene Adressen abgebildet";
				EQUAL_ERROR := TRUE;
			end if;
		end loop;

		if EQUAL_ERROR then
			report "Test 4 nicht erfolgreich";
		else 
			report "Test 4 erfolgreich";
		end if;

------------------------------------------------------------------------------
--	Test 5: Test stets definierte Werte zurueck geliefert werden
		report "Test 5: Pruefe ob stets definierte Werte (also '0' oder '1') zurueck gegeben werden";
		report SEPARATOR_LINE;
		User_Bit <= 'U';
		THIS_MODE <= (others => '0');
		VIRTUAL_ADDRESS <= (others => '0');
		wait for 1 ns;
		PHY_ADDR_USER := PHYSICAL_ADDRESS;
		SLV_IS_BINARY_OR_DONTCARE(PHY_ADDR_USER, IS_BINARY);
		if (not IS_BINARY) then
			report "Physikalische Adresse " & SLV_TO_STRING(PHY_ADDR_USER) & " nicht zur Adressierung nutzbar. "& " Modus-Code " & SLV_TO_STRING(THIS_MODE) & ", virt. Adresse " & SLV_TO_STRING(VIRTUAL_ADDRESS) & ", USER-Bit " & SL_TO_STRING(User_Bit) severity error;	
			UNINITIALIZED_ERROR := TRUE;
		end if;
		wait for 1 ns;
		User_Bit <= '0';
		THIS_MODE <= (others => 'U');
		VIRTUAL_ADDRESS <= (others => '0');
		wait for 1 ns;
		PHY_ADDR_USER := PHYSICAL_ADDRESS;
		SLV_IS_BINARY_OR_DONTCARE(PHY_ADDR_USER, IS_BINARY);
		if (not IS_BINARY) then
			report "Physikalische Adresse " & SLV_TO_STRING(PHY_ADDR_USER) & " nicht zur Adressierung nutzbar. "& " Modus-Code " & SLV_TO_STRING(THIS_MODE) & ", virt. Adresse " & SLV_TO_STRING(VIRTUAL_ADDRESS) & ", USER-Bit " & SL_TO_STRING(User_Bit) severity error;	
			UNINITIALIZED_ERROR := TRUE;
		end if;
		wait for 1 ns;
		User_Bit <= '0';
		THIS_MODE <= (others => '0');
		VIRTUAL_ADDRESS <= (others => 'U');
		wait for 1 ns;
		PHY_ADDR_USER := PHYSICAL_ADDRESS;
		SLV_IS_BINARY_OR_DONTCARE(PHY_ADDR_USER, IS_BINARY);
		if (not IS_BINARY) then
			report "Physikalische Adresse " & SLV_TO_STRING(PHY_ADDR_USER) & " nicht zur Adressierung nutzbar. "& " Modus-Code " & SLV_TO_STRING(THIS_MODE) & ", virt. Adresse " & SLV_TO_STRING(VIRTUAL_ADDRESS) & ", USER-Bit " & SL_TO_STRING(User_Bit) severity error;	
			UNINITIALIZED_ERROR := TRUE;
		end if;
		wait for 1 ns;
		User_Bit <= 'X';
		THIS_MODE <= (others => '0');
		VIRTUAL_ADDRESS <= (others => '0');
		wait for 1 ns;
		PHY_ADDR_USER := PHYSICAL_ADDRESS;
		SLV_IS_BINARY_OR_DONTCARE(PHY_ADDR_USER, IS_BINARY);
		if (not IS_BINARY) then
			report "Physikalische Adresse " & SLV_TO_STRING(PHY_ADDR_USER) & " nicht zur Adressierung nutzbar. "& " Modus-Code " & SLV_TO_STRING(THIS_MODE) & ", virt. Adresse " & SLV_TO_STRING(VIRTUAL_ADDRESS) & ", USER-Bit " & SL_TO_STRING(User_Bit) severity error;	
			UNINITIALIZED_ERROR := TRUE;
		end if;
		wait for 1 ns;
		User_Bit <= '0';
		THIS_MODE <= (others => 'X');
		VIRTUAL_ADDRESS <= (others => '0');
		wait for 1 ns;
		PHY_ADDR_USER := PHYSICAL_ADDRESS;
		SLV_IS_BINARY_OR_DONTCARE(PHY_ADDR_USER, IS_BINARY);
		if (not IS_BINARY) then
			report "Physikalische Adresse " & SLV_TO_STRING(PHY_ADDR_USER) & " nicht zur Adressierung nutzbar. "& " Modus-Code " & SLV_TO_STRING(THIS_MODE) & ", virt. Adresse " & SLV_TO_STRING(VIRTUAL_ADDRESS) & ", USER-Bit " & SL_TO_STRING(User_Bit) severity error;	
			UNINITIALIZED_ERROR := TRUE;
		end if;
		wait for 1 ns;
		User_Bit <= '0';
		THIS_MODE <= (others => '0');
		VIRTUAL_ADDRESS <= (others => 'X');
		wait for 1 ns;
		PHY_ADDR_USER := PHYSICAL_ADDRESS;
		SLV_IS_BINARY_OR_DONTCARE(PHY_ADDR_USER, IS_BINARY);
		if (not IS_BINARY) then
			report "Physikalische Adresse " & SLV_TO_STRING(PHY_ADDR_USER) & " nicht zur Adressierung nutzbar. "& " Modus-Code " & SLV_TO_STRING(THIS_MODE) & ", virt. Adresse " & SLV_TO_STRING(VIRTUAL_ADDRESS) & ", USER-Bit " & SL_TO_STRING(User_Bit) severity error;	
			UNINITIALIZED_ERROR := TRUE;
		end if;
		wait for 1 ns;

		if UNINITIALIZED_ERROR then
			report "Test 5 nicht erfolgreich";
		else 
			report "Test 5 erfolgreich";
		end if;

		--Equal Error ist der Error von Test 1
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		if not GENERAL_ERROR then
			if not EQUAL_ERROR then
				if (not USER_ERROR) and (not VALIDITY_ERROR)then
					if (not UNINITIALIZED_ERROR) then
						report "Gesamtpunktzahl (max. 4 Punkte = 1 Punkt (Test 1) + 1 Punkt (Tests 2 und 3) + 1 Punkt (Test 4) + 1 Punkt (Test 5)): 4 Punkte";
					else                                                                                                                          
						report "Gesamtpunktzahl (max. 4 Punkte = 1 Punkt (Test 1) + 1 Punkt (Tests 2 und 3) + 1 Punkt (Test 4) + 0 Punkt (Test 5)): 3 Punkte";
					end if;
				else
					if (not UNINITIALIZED_ERROR) then
						report "Gesamtpunktzahl (max. 4 Punkte = 1 Punkt (Test 1) + 0 Punkt (Tests 2 und 3) + 1 Punkt (Test 4) + 1 Punkt (Test 5)): 3 Punkte";
					else                                                                                                                          
						report "Gesamtpunktzahl (max. 4 Punkte = 1 Punkt (Test 1) + 0 Punkt (Tests 2 und 3) + 1 Punkt (Test 4) + 0 Punkt (Test 5)): 2 Punkte";
					end if;
				end if;
			else 
				if (not USER_ERROR) and (not VALIDITY_ERROR)then
					if (not UNINITIALIZED_ERROR) then
						report "Gesamtpunktzahl (max. 4 Punkte = 1 Punkt (Test 1) + 1 Punkt (Tests 2 und 3) + 0 Punkt (Test 4) + 1 Punkt (Test 5)): 3 Punkte";
					else                                                                                                                          
						report "Gesamtpunktzahl (max. 4 Punkte = 1 Punkt (Test 1) + 1 Punkt (Tests 2 und 3) + 0 Punkt (Test 4) + 0 Punkt (Test 5)): 2 Punkte";
					end if;
				else
					if (not UNINITIALIZED_ERROR) then
						report "Gesamtpunktzahl (max. 4 Punkte = 1 Punkt (Test 1) + 0 Punkt (Tests 2 und 3) + 0 Punkt (Test 4) + 1 Punkt (Test 5)): 2 Punkte";
					else                                                                                                                          
						report "Gesamtpunktzahl (max. 4 Punkte = 1 Punkt (Test 1) + 0 Punkt (Tests 2 und 3) + 0 Punkt (Test 4) + 1 Punkt (Test 5)): 1 Punkt";
					end if;
				end if;
			end if;
		else
			if not EQUAL_ERROR then
				if (not USER_ERROR) and (not VALIDITY_ERROR)then
					if (not UNINITIALIZED_ERROR) then
						report "Gesamtpunktzahl (max. 4 Punkte = 0 Punkt (Test 1) + 1 Punkt (Tests 2 und 3) + 1 Punkt (Test 4) + 1 Punkt (Test 5)) : 3 Punkt";
					else
						report "Gesamtpunktzahl (max. 4 Punkte = 0 Punkt (Test 1) + 1 Punkt (Tests 2 und 3) + 1 Punkt (Test 4) + 0 Punkt (Test 5)) : 2 Punkt";
					end if;
				else
					if (not UNINITIALIZED_ERROR) then
						report "Gesamtpunktzahl (max. 4 Punkte = 0 Punkt (Test 1) + 0 Punkt (Tests 2 und 3) + 1 Punkt (Test 4) + 1 Punkt (Test 5)) : 2 Punkte";
					else
						report "Gesamtpunktzahl (max. 4 Punkte = 0 Punkt (Test 1) + 0 Punkt (Tests 2 und 3) + 1 Punkt (Test 4) + 0 Punkt (Test 5)) : 1 Punkt";
					end if;
				end if;
			else
				if (not USER_ERROR) and (not VALIDITY_ERROR)then
					if (not UNINITIALIZED_ERROR) then
						report "Gesamtpunktzahl (max. 4 Punkte = 0 Punkt (Test 1) + 1 Punkt (Tests 2 und 3) + 0 Punkt (Test 4) + 1 Punkt (Test 5)) : 2 Punkte";
					else
						report "Gesamtpunktzahl (max. 4 Punkte = 0 Punkt (Test 1) + 1 Punkt (Tests 2 und 3) + 0 Punkt (Test 4) + 0 Punkt (Test 5)) : 1 Punkt";
					end if;
				else
					if (not UNINITIALIZED_ERROR) then
						report "Gesamtpunktzahl (max. 4 Punkte = 0 Punkt (Test 1) + 0 Punkt (Tests 2 und 3) + 0 Punkt (Test 4) + 1 Punkt (Test 5)) : 1 Punkt";
					else
						report "Gesamtpunktzahl (max. 4 Punkte = 0 Punkt (Test 1) + 0 Punkt (Tests 2 und 3) + 0 Punkt (Test 4) + 0 Punkt (Test 5)) : 0 Punkte";
					end if;
				end if;
			end if;
		end if;
		report SEPARATOR_LINE;
		report SEPARATOR_LINE;
		report " EOT (END OF TEST) - Diese Fehlermeldung stoppt den Simulator unabhaengig von tatsaechlich aufgetretenen Fehlern!" severity failure; 
		wait;
	report "Ende" severity failure;


end process test;

end architecture testbench;