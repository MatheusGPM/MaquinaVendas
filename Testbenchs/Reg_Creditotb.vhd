library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_Reg_Credito is
end tb_Reg_Credito;

architecture test of tb_Reg_Credito is
    -- Sinais de entrada
    signal CLK, RESET, ADD_COIN, ADD_BILL, CLEAR : STD_LOGIC := '0';
    signal VALOR_COIN, VALOR_BILL : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    
    -- Sinal de saída
    signal CREDITO : STD_LOGIC_VECTOR(7 downto 0);

    -- Instância do DUT (Device Under Test)
    component Reg_Credito
        Port ( CLK, RESET, ADD_COIN, ADD_BILL, CLEAR : in STD_LOGIC;
               VALOR_COIN, VALOR_BILL : in STD_LOGIC_VECTOR(7 downto 0);
               CREDITO : out STD_LOGIC_VECTOR(7 downto 0));
    end component;

begin
    -- Instanciar o DUT
    UUT: Reg_Credito
        port map (
            CLK => CLK,
            RESET => RESET,
            ADD_COIN => ADD_COIN,
            ADD_BILL => ADD_BILL,
            CLEAR => CLEAR,
            VALOR_COIN => VALOR_COIN,
            VALOR_BILL => VALOR_BILL,
            CREDITO => CREDITO
        );

    -- Processo de clock (simulando borda de subida)
    process
    begin
        while now < 1000 ns loop
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

        -- Inserir moeda de valor 5
        ADD_COIN <= '1';
        VALOR_COIN <= "00000101"; -- 5 em binário
        wait for 10 ns;
        ADD_COIN <= '0';

        -- Inserir cédula de valor 20
        ADD_BILL <= '1';
        VALOR_BILL <= "00010100"; -- 20 em binário
        wait for 10 ns;
        ADD_BILL <= '0';

        -- Tentar adicionar moeda e cédula ao mesmo tempo (não deve acumular)
        ADD_COIN <= '1';
        ADD_BILL <= '1';
        VALOR_COIN <= "00000011"; -- 3
        VALOR_BILL <= "00001000"; -- 8
        wait for 10 ns;
        ADD_COIN <= '0';
        ADD_BILL <= '0';

        -- Ativar CLEAR (deve zerar o crédito)
        CLEAR <= '1';
        wait for 10 ns;
        CLEAR <= '0';

        wait;
    end process;

end test;
