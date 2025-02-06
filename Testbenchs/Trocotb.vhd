library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_Troco is
end tb_Troco;

architecture test of tb_Troco is
    -- Sinais de entrada
    signal CLK, RESET, CALCULAR_TROCO, TROCO_ENTREGUE : STD_LOGIC := '0';
    signal CREDITO, PRECO_PRODUTO, TROCO_CALCULADO : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Instância do DUT (Device Under Test)
    component Troco
        Port ( CLK, RESET, CALCULAR_TROCO, TROCO_ENTREGUE : in STD_LOGIC;
               CREDITO, PRECO_PRODUTO : in STD_LOGIC_VECTOR(7 downto 0);
               TROCO_CALCULADO : out STD_LOGIC_VECTOR(7 downto 0));
    end component;

begin
    -- Instanciar o DUT
    UUT: Troco
        port map (
            CLK => CLK,
            RESET => RESET,
            CALCULAR_TROCO => CALCULAR_TROCO,
            TROCO_ENTREGUE => TROCO_ENTREGUE,
            CREDITO => CREDITO,
            PRECO_PRODUTO => PRECO_PRODUTO,
            TROCO_CALCULADO => TROCO_CALCULADO
        );

    -- Processo de clock
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

        -- Inserir crédito de 10 e preço do produto 6
        CREDITO <= "00001010"; -- 10 em binário
        PRECO_PRODUTO <= "00000110"; -- 6 em binário
        wait for 10 ns;

        -- Calcular troco (deve ser 4)
        CALCULAR_TROCO <= '1';
        wait for 10 ns;
        CALCULAR_TROCO <= '0';

        -- Confirmar entrega do troco
        TROCO_ENTREGUE <= '1';
        wait for 10 ns;
        TROCO_ENTREGUE <= '0';

        -- Testar caso sem troco (preço = crédito)
        CREDITO <= "00001000"; -- 8
        PRECO_PRODUTO <= "00001000"; -- 8
        wait for 10 ns;

        -- Calcular troco (deve ser 0)
        CALCULAR_TROCO <= '1';
        wait for 10 ns;
        CALCULAR_TROCO <= '0';

        wait;
    end process;

end test;
