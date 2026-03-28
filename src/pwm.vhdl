library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm is      
    Port (clk : IN STD_LOGIC;
          Q_motor_der : OUT STD_LOGIC;
          Q_motor_izq : OUT STD_LOGIC; 
          error : IN signed(7 downto 0));
end pwm;

architecture Behavioral of pwm is

    signal duty_motor_der : INTEGER range 0 to 255 := 0;
    signal duty_motor_izq : INTEGER range 0 to 255:= 0;

    signal sQ_motor_der : STD_LOGIC := '0';
    signal sQ_motor_izq : STD_LOGIC := '0';

    signal cont : unsigned(7 downto 0)  := "00000000";

begin

    duty_motor_der <= to_integer(error) + 192; -- Duty base de 75%
    duty_motor_izq <= 384 - duty_motor_der;


process(CLK)
begin
        if rising_edge(clk) then
    
            if (cont = "11111111") then
                cont <= "00000000";
            else
                cont <= cont + "00000001";
            end if;
    
            -- PWM motor izquierdo
            if (cont < duty_motor_izq) then
                sQ_motor_izq <= '1';
            else
                sQ_motor_izq <= '0';
            end if;
    
            -- PWM motor derecho
            if (cont < duty_motor_der) then
                sQ_motor_der <= '1';
               
            else
                sQ_motor_der <= '0';
            end if;
        end if;

end process;

Q_motor_izq <= sQ_motor_izq;
Q_motor_der <= sQ_motor_der;

end Behavioral;
