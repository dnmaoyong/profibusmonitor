-- CTRL_TELEGRAM_FILTER
-- Voreingestellten Profibus Telegramtyp ermitteln und Bytes ausgeben, alternativ alle Bytes durchlassen
-- Ersteller: Martin Harndt
-- Erstellt: 22.01.2013
-- Bearbeiter: mharndt
-- Geaendert: 22.01.2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CTRL_TELEGRAM_FILTER_VHDL is

    Port (BYTE_IN  : in std_logic_vector (7 downto 0); --Eingangsvariable, Byte, 8bit
         FILTER_ON : in std_logic; --Eingangsvariable, Filter einschalten
         FILTER_T : in std_logic_vector (2 downto 0); --Eingangsvariable, Telegramfilter einstellen, 3bit

         FILTER_BYTE_OUT : out std_logic_vector (7 downto 0);--Ausgangsvariable, gefilterte Telegramme
         SEND_OUT : out std_logic; --Ausgangsvariable, Byte senden
         T_CMPLT: out std_logic; --Ausgangsvariable, Telegramm komplett

		   DISPL_COUNT  : in  std_logic; --Eingangsvariable, Folgeszustand oder Bytezaehler anzeigen

 		   CLK	      : in  std_logic; --Taktvariable

		   IN_NEXT_STATE: in std_logic;  --1:Zustandsuebergang m�glich
		   RESET		 : in std_logic;   --1: Initialzustand annehmen

         
		   
		   DISPL1_SV    : out std_logic_vector (3 downto 0); --aktueller Zustand Zahl1, bin�rzahl
		   DISPL2_SV    : out std_logic_vector (3 downto 0); --aktueller Zustand Zahl2, bin�rzahl
		   DISPL1_n_SV  : out std_logic_vector (3 downto 0); --Folgezustand Zahl1, bin�rzahl
		   DISPL2_n_SV	 : out std_logic_vector (3 downto 0));  --Folgezustand Zahl2, bin�rzahl

end CTRL_TELEGRAM_FILTER_VHDL;

architecture Behavioral of CTRL_TELEGRAM_FILTER_VHDL is

type TYPE_STATE is 
              (ST_FI_00, --Zustaende TELEGRAM_CHECK
               ST_FI_01,
               ST_FI_02,
               ST_FI_03,
               ST_FI_04,
               ST_FI_05,
               ST_FI_06,
               ST_FI_07,
               ST_FI_08, 
               ST_FI_09,
               ST_FI_10,
               ST_FI_11,
               ST_FI_12,
               ST_FI_13,
               ST_FI_14,
               ST_FI_15);

signal SV  : TYPE_STATE; --Zustandsvariable
signal n_SV: TYPE_STATE; --Zustandsvariable, neuer Wert
signal SV_M: TYPE_STATE; --Zustandsvariable, Ausgang Master

signal COUNT   : std_logic_vector (7 downto 0); -- Vektor, Zaehler, 8bit
signal n_COUNT : std_logic_vector (7 downto 0); -- Vektor, Zaehler, 8bit, neuer Wert
signal COUNT_M : std_logic_vector (7 downto 0); -- Vektor, Zaehler, 8bit, Ausgang Master

signal STATE_SV   : std_logic_vector (7 downto 0); -- aktueller Zustand in 8 Bit, bin�r
signal STATE_n_SV : std_logic_vector (7 downto 0); -- Folgezustand in 8 Bit, bin�r

signal not_CLK   : std_logic; --negierte Taktvariable


begin


NOT_CLK_PROC: process (CLK) --negieren Taktvariable
begin
  not_CLK <= not CLK;
end process;

SREG_M_PROC: process (RESET, n_SV, CLK) --Master
begin
  if (RESET ='1')
   then SV_M    <= ST_FI_00;
        COUNT_M <= x"00";	
   else
     if (CLK'event and CLK = '1')
	 then
	   if (IN_NEXT_STATE = '1')
	    then SV_M    <= n_SV;
            COUNT_M <= n_COUNT;
	    else SV_M    <= SV_M;
            COUNT_M <= COUNT_M;
        end if;
	end if;
  end if;
end process;

SREG_S_PROC: process (RESET, SV_M, not_CLK) --Slave
begin
  if (RESET = '1')
   then SV    <= ST_FI_00;
        COUNT <= x"00";	
   else
     if (not_CLK'event and not_CLK = '1')
	 then SV    <= SV_M;
         COUNT <= COUNT_M;
     end if;
   end if;
end process;

TELEGRAM_FILTER_PROC:process (FILTER_ON, FILTER_T, BYTE_IN, SV, COUNT) --Telegramme Filtern und ausgeben
begin
 case SV is
  when ST_FI_00 =>
   if (FILTER_ON = '1')
    then
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_01;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
   end if;
  
  when ST_FI_01 =>
   if (FILTER_T = "000")
    then
     --FI01
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
    else
     --FI01
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_02;
   end if;

  when ST_FI_02 =>
   if (FILTER_T = "001")
    then
     --FI01
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_03;
    else
     --FI01
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_05;
   end if;

  when ST_FI_03 =>
   if (BYTE_IN = x"10")
    then
     --FI02
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= COUNT+1;
     n_SV <= ST_FI_04;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
   end if;

  when ST_FI_04 =>
   if (COUNT = x"06")
    then
     --FI03
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '1';
     SEND_OUT <= '1';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
    else
     --FI02
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= COUNT+1;
     n_SV <= ST_FI_04;
   end if;

  when ST_FI_05 =>
   if (FILTER_T= "010")
    then
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_06;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_08;
   end if;

  when ST_FI_06 =>
   if (BYTE_IN = x"68")
    then
     --FI02
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= COUNT+1;
     n_SV <= ST_FI_07;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
   end if;

  when ST_FI_07 =>
   if (COUNT = x"F9" OR BYTE_IN = x"16")
    then
     --FI03
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '1';
     SEND_OUT <= '1';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
    else
     --FI02
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= COUNT+1;
     n_SV <= ST_FI_07;
   end if;

  when ST_FI_08 =>
   if (FILTER_T= "011")
    then
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_09;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_11;
   end if;

  when ST_FI_09 =>
   if (BYTE_IN = x"A2")
    then
     --FI02
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= COUNT+1;
     n_SV <= ST_FI_10;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
   end if;

  when ST_FI_10 =>
   if (COUNT = x"0E")
    then
     --FI03
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '1';
     SEND_OUT <= '1';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
    else
     --FI02
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= COUNT+1;
     n_SV <= ST_FI_10;
   end if;

  when ST_FI_11 =>
   if (FILTER_T= "100")
    then
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_12;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_14;
   end if;

  when ST_FI_12 =>
   if (BYTE_IN = x"DC")
    then
     --FI02
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= COUNT+1;
     n_SV <= ST_FI_13;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
   end if;

  when ST_FI_13 =>
   if (COUNT = x"03")
    then
     --FI03
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '1';
     SEND_OUT <= '1';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
    else
     --FI02
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '0';
     SEND_OUT <= '1';
     n_COUNT <= COUNT+1;
     n_SV <= ST_FI_13;
   end if;

  when ST_FI_14 =>
   if (FILTER_T= "101")
    then
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_15;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
   end if;

  when ST_FI_15 =>
   if (BYTE_IN = x"E5")
    then
     --FI03
     FILTER_BYTE_OUT <= BYTE_IN;
     T_CMPLT <= '1';
     SEND_OUT <= '1';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
    else
     --FI00
     FILTER_BYTE_OUT <= x"00";
     T_CMPLT <= '0';
     SEND_OUT <= '0';
     n_COUNT <= x"00";
     n_SV <= ST_FI_00;
   end if;

  when others =>
   -- FI00
   FILTER_BYTE_OUT <= x"00";
   T_CMPLT <= '0';
   SEND_OUT <= '0';
   n_COUNT <= x"00";
   n_SV <= ST_FI_00;
 end case;
end process;

STATE_DISPL_PROC: process (SV, n_SV, DISPL_COUNT, STATE_SV, STATE_n_SV, COUNT) -- Zustandsanzeige
 begin
  STATE_SV   <= conv_std_logic_vector(TYPE_STATE'pos(  SV),8); --Zustandsumwandlung in 8 Bit
  STATE_n_SV <= conv_std_logic_vector(TYPE_STATE'pos(n_SV),8);
  --anktuellen Zustand anzeigen   
  DISPL1_SV(0) <= STATE_SV(0); --Bit0
  DISPL1_SV(1) <= STATE_SV(1); --Bit1
  DISPL1_SV(2) <= STATE_SV(2); --Bit2
  DISPL1_SV(3) <= STATE_SV(3); --Bit3

  DISPL2_SV(0) <= STATE_SV(4); --usw.
  DISPL2_SV(1) <= STATE_SV(5);
  DISPL2_SV(2) <= STATE_SV(6);
  DISPL2_SV(3) <= STATE_SV(7);

  if (DISPL_COUNT ='0') --Original
   then --Folgezustand anzeigen
    DISPL1_n_SV(0)  <= STATE_n_SV(0);
    DISPL1_n_SV(1)  <= STATE_n_SV(1);
    DISPL1_n_SV(2)  <= STATE_n_SV(2);
    DISPL1_n_SV(3)  <= STATE_n_SV(3);
   
    DISPL2_n_SV(0)  <= STATE_n_SV(4);
    DISPL2_n_SV(1)  <= STATE_n_SV(5);
    DISPL2_n_SV(2)  <= STATE_n_SV(6);
    DISPL2_n_SV(3)  <= STATE_n_SV(7);

   else  --Telegrammzaehler anzeigen 
    DISPL1_n_SV(0) <= COUNT(0);
    DISPL1_n_SV(1) <= COUNT(1);
    DISPL1_n_SV(2) <= COUNT(2);
    DISPL1_n_SV(3) <= COUNT(3);
    
    DISPL2_n_SV(0) <= COUNT(4);
    DISPL2_n_SV(1) <= COUNT(5);
    DISPL2_n_SV(2) <= COUNT(6);
    DISPL2_n_SV(3) <= COUNT(7);
  end if;
 end process;

end Behavioral;
