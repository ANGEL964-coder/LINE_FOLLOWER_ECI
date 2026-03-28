library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_line_follower is
  Port (  clk : IN STD_LOGIC;
          ena : IN std_logic;
          rst_n : IN std_logic;
          ui_in: IN std_logic_vector(7 downto 0); -- ui_in Entradas Fijas
          uio_in: IN std_logic_vector(7 downto 0); -- Entradas Bidireccionales, ajuste va de en posiciones 0 a 3
          uo_out : OUT std_logic_vector(7 downto 0); -- uo_out Salidas Fijas
          uio_out : OUT std_logic_vector(7 downto 0); -- Salidas bidireccionales
          uio_oe : OUT std_logic_vector (7 downto 0) -- Selector de pines bidireccionales

          );
end tt_um_line_follower;




architecture Behavioral of tt_um_line_follower is

component pwm is            
    Port (clk : IN STD_LOGIC;
          Q_motor_der : OUT STD_LOGIC;
          Q_motor_izq : OUT STD_LOGIC;
          error : IN signed(7 downto 0));
end component;


signal s0, s1, s2, s3, s4, s5, s6, s7, sum_error, error: signed (7 downto 0) := "00000000";
signal aux: std_logic := '0';
signal signal_Q_motor_der : std_logic := '0';
signal signal_Q_motor_izq : std_logic := '0';


begin

pwm_signal: pwm port map(clk=>clk, Q_motor_der=>signal_Q_motor_der, Q_motor_izq=>signal_Q_motor_izq, error=>error);

uo_out(1) <= signal_Q_motor_der when (ena = '1') else '0';
uo_out(0) <= signal_Q_motor_izq when (ena = '1') else '0';

uio_oe <= "00000000";
uio_out <= "00000000";
uo_out(7 downto 2) <= "000001" when (ena = '1') else "000000"; -- Led es uo_out(2)

-- Pesos
s0 <= "11101101" when ui_in(0) = '1' else "00000000"; -- -19
s1 <= "11110001" when ui_in(1) = '1' else "00000000"; -- -15
s2 <= "11110111" when ui_in(2) = '1' else "00000000"; -- -9
s3 <= "11111011" when ui_in(3) = '1' else "00000000"; -- -5
s4 <= "00000101" when ui_in(4) = '1' else "00000000"; -- 5
s5 <= "00001001" when ui_in(5) = '1' else "00000000"; -- 9
s6 <= "00001111" when ui_in(6) = '1' else "00000000"; -- 15
s7 <= "00010011" when ui_in(7) = '1' else "00000000"; -- 19

sum_error <= s0 + s1 + s2 + s3 + s4 + s5 + s6 + s7 when (ena = '1') else "00000000";

error <= "10010010" when (ui_in = "00000000" and aux = '0' and ena = '1') else -- -110
         "01101110" when (ui_in = "00000000" and aux = '1' and ena = '1') else -- 110
         sum_error + "00000110" when (uio_in(1 downto 0) = "01" and sum_error > 0 and ena = '1') else -- 6
         sum_error + "00001011" when (uio_in(1 downto 0) = "10" and sum_error > 0 and ena = '1') else -- 11
         sum_error + "00001111" when (uio_in(1 downto 0) = "11" and sum_error > 0 and ena = '1') else -- 15
         sum_error - "00000110" when (uio_in(3 downto 2) = "01" and sum_error < 0 and ena = '1') else
         sum_error - "00001011" when (uio_in(3 downto 2) = "10" and sum_error < 0 and ena = '1') else
         sum_error - "00001111" when (uio_in(3 downto 2) = "11" and sum_error < 0 and ena = '1') else
         sum_error when (ena = '1') else
         "00000000";
           
process(clk)
begin
    if rising_edge(clk) then
        if error < 0 then
            aux <= '0';
        else
            aux <= '1';
        end if;
    end if;
end process;


end Behavioral;
