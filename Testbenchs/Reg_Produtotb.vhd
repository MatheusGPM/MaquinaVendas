library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Reg_Produto is
end tb_Reg_Produto;

architecture test of tb_Reg_Produto is
    -- Sinais de entrada
    signal CLK, RESET, SEL_PRODUTO : STD_LOGIC := '0';
    signal PRODUTO : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    -- Sinal de saída
    signal PRODUTO_SELECIONADO : STD_LOGIC_VECTOR(3 downto 0);

    -- Instância do DUT (Device Under Test)
    component Reg_Produto
        Port ( CLK, RESET, SEL_PRODUTO : in STD_LOGIC;
               PRODUTO : in STD_LOGIC_VECTOR(3 downto 0);
               PRODUTO_SELECIONADO : out STD_LOGIC_VECTOR(3 downto 0));
    end component;

begin
    -- Instanciar o DUT
    UUT: Reg_Produto
        port map (
            CLK => CLK,
            RESET => RESET,
            SEL_PRODUTO => SEL_PRODUTO,
            PRODUTO => PRODUTO,
            PRODUTO_SELECIONADO => PRODUTO_SELECIONADO
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

        -- Selecionar produto 3
        SEL_PRODUTO <= '1';
        PRODUTO <= "0011"; -- Produto 3
        wait for 10 ns;
        SEL_PRODUTO <= '0';

        -- Selecionar produto 7
        SEL_PRODUTO <= '1';
        PRODUTO <= "0111"; -- Produto 7
        wait for 10 ns;
        SEL_PRODUTO <= '0';

        -- Reset (deve limpar o produto selecionado)
        RESET <= '1';
        wait for 10 ns;
        RESET <= '0';

        wait;
    end process;

end test;
