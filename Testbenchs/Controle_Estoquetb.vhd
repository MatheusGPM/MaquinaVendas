library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity tb_Controle_Estoque is
end tb_Controle_Estoque;

architecture test of tb_Controle_Estoque is
    -- Sinais de entrada
    signal CLK, RESET, VENDER_PRODUTO : STD_LOGIC := '0';
    signal PRODUTO : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal ESTOQUE_DISPONIVEL : STD_LOGIC;

    -- Instância do DUT (Device Under Test)
    component Controle_Estoque
        Port ( CLK, RESET, VENDER_PRODUTO : in STD_LOGIC;
               PRODUTO : in STD_LOGIC_VECTOR(3 downto 0);
               ESTOQUE_DISPONIVEL : out STD_LOGIC);
    end component;

begin
    -- Instanciar o DUT
    UUT: Controle_Estoque
        port map (
            CLK => CLK,
            RESET => RESET,
            VENDER_PRODUTO => VENDER_PRODUTO,
            PRODUTO => PRODUTO,
            ESTOQUE_DISPONIVEL => ESTOQUE_DISPONIVEL
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

        -- Selecionar produto 3 e tentar vender
        PRODUTO <= "0011"; -- Produto 3
        VENDER_PRODUTO <= '1';
        wait for 10 ns;
        VENDER_PRODUTO <= '0';

        -- Selecionar produto 7 e tentar vender (deve estar disponível)
        PRODUTO <= "0111"; -- Produto 7
        VENDER_PRODUTO <= '1';
        wait for 10 ns;
        VENDER_PRODUTO <= '0';

        -- Tentar vender produto que pode estar esgotado (Produto 15)
        PRODUTO <= "1111"; -- Produto 15
        VENDER_PRODUTO <= '1';
        wait for 10 ns;
        VENDER_PRODUTO <= '0';

        wait;
    end process;

end test;
