library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_Controle_Refrigeracao is
end tb_Controle_Refrigeracao;

architecture test of tb_Controle_Refrigeracao is
    -- Sinais de entrada
    signal CLK, RESET : STD_LOGIC := '0';
    signal TEMP_SENSOR : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal REFRIGERACAO_ATIVADA : STD_LOGIC;

    -- Instância do DUT (Device Under Test)
    component Controle_Refrigeracao
        Port ( CLK, RESET : in STD_LOGIC;
               TEMP_SENSOR : in STD_LOGIC_VECTOR(7 downto 0);
               REFRIGERACAO_ATIVADA : out STD_LOGIC);
    end component;

begin
    -- Instanciar o DUT
    UUT: Controle_Refrigeracao
        port map (
            CLK => CLK,
            RESET => RESET,
            TEMP_SENSOR => TEMP_SENSOR,
            REFRIGERACAO_ATIVADA => REFRIGERACAO_ATIVADA
        );

    -- Processo de clock
    process
    begin
        while now < 500 ns loop
            CLK <= '0';
            wait for 5 ns;
            CLK <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Processo de teste
    process
    begin
        -- Reset inicial
        RESET <= '1';
        wait for 10 ns;
        RESET <= '0';

        -- Temperatura normal (Refrigeração desligada)
        TEMP_SENSOR <= "00011010"; -- 26°C
        wait for 20 ns;

        -- Temperatura alta (Refrigeração ativada)
        TEMP_SENSOR <= "00101000"; -- 40°C
        wait for 20 ns;

        -- Voltar para temperatura normal (Refrigeração desligada)
        TEMP_SENSOR <= "00011100"; -- 28°C
        wait for 20 ns;

        wait;
    end process;

end test;
