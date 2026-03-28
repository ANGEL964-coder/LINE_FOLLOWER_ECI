library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pesos_tb is
end pesos_tb;

architecture Behavioral of pesos_tb is

    signal clk    : std_logic := '0';
    signal ena    : std_logic := '1';
    signal rst  : std_logic := '1';
    signal ui_in  : std_logic_vector(7 downto 0) := (others => '0'); -- sens
    signal uio_in : std_logic_vector(7 downto 0) := (others => '0'); -- ajuste en bits 3:0
    signal uo_out  : std_logic_vector(7 downto 0);
    signal uio_out : std_logic_vector(7 downto 0);
    signal uio_oe  : std_logic_vector(7 downto 0);

    -- uo_out(0) = motor derecha, uo_out(1) = motor izquierda
    alias out_motor_derecha   : std_logic is uo_out(0);
    alias out_motor_izquierda : std_logic is uo_out(1);

    constant CLK_PERIOD : time := 1953 ns; -- ~512 kHz

begin

    uut: entity work.pesos
        port map(
            clk     => CLK,
            ena     => ena,
            rst   => rst,
            ui_in   => ui_in,
            uio_in  => uio_in,
            uo_out  => uo_out,
            uio_out => uio_out,
            uio_oe  => uio_oe
        );

    -- Generador de clock
    clk_process : process
    begin
        while true loop
            CLK <= '0'; wait for CLK_PERIOD/2;
            CLK <= '1'; wait for CLK_PERIOD/2;
        end loop;
    end process;

    -- Estímulos
    stim_proc : process
    begin
        -- Reset inicial
        rst <= '0';
        wait for CLK_PERIOD * 4;
        rst <= '1';
        wait for CLK_PERIOD;

        -- Línea centrada, sin ajuste
        ui_in  <= "00001100";
        uio_in <= "00000000"; -- ajuste = 0
        wait for 10 ms;

        -- Línea ligeramente a la izquierda
        ui_in  <= "00110000";
        uio_in <= "00000000";
        wait for 10 ms;

        -- Línea más a la izquierda
        ui_in  <= "01100000";
        uio_in <= "00000000";
        wait for 10 ms;

        -- Línea a la derecha
        ui_in  <= "00001100";
        uio_in <= "00000000";
        wait for 10 ms;

        -- Extremo derecha
        ui_in  <= "00000110";
        uio_in <= "00000000";
        wait for 10 ms;

        -- Ajuste positivo (sum_error > 0): ajuste(1:0) = "11" ? +15
        ui_in  <= "00011000";
        uio_in <= "00000011"; -- bits 1:0 = "11"
        wait for 10 ms;

        -- Ajuste negativo (sum_error < 0): ajuste(3:2) = "01" ? -6
        ui_in  <= "11000000";
        uio_in <= "00000100"; -- bits 3:2 = "01"
        wait for 10 ms;

        -- Sin sensores (aux = '0' ? error = -110)
        ui_in  <= "00000000";
        uio_in <= "00000000";
        wait for 10 ms;
        -- Ahora con ena = '0';
        
        ena <= '0';
        ui_in  <= "00001100";
        uio_in <= "00000000"; -- ajuste = 0
        wait for 10 ms;

        -- Línea ligeramente a la izquierda
        ui_in  <= "00110000";
        uio_in <= "00000000";
        wait for 10 ms;

        -- Línea más a la izquierda
        ui_in  <= "01100000";
        uio_in <= "00000000";
        wait for 10 ms;

        -- Línea a la derecha
        ui_in  <= "00001100";
        uio_in <= "00000000";
        wait for 10 ms;

        -- Extremo derecha
        ui_in  <= "00000110";
        uio_in <= "00000000";
        wait for 10 ms;

        -- Ajuste positivo (sum_error > 0): ajuste(1:0) = "11" ? +15
        ui_in  <= "00011000";
        uio_in <= "00000011"; -- bits 1:0 = "11"
        wait for 10 ms;

        -- Ajuste negativo (sum_error < 0): ajuste(3:2) = "01" ? -6
        ui_in  <= "11000000";
        uio_in <= "00000100"; -- bits 3:2 = "01"
        wait for 10 ms;

        -- Sin sensores (aux = '0' ? error = -110)
        ui_in  <= "00000000";
        uio_in <= "00000000";
        wait for 10 ms;

        wait;
    end process;

end Behavioral;