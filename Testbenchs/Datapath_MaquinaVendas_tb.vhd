library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Datapath_MaquinaVendas_tb is
end Datapath_MaquinaVendas_tb;

architecture testbench of Datapath_MaquinaVendas_tb is

    -- Component Under Test (CUT)
    component Datapath_MaquinaVendas
        Port ( CLK, RESET : in STD_LOGIC;
               ADD_COIN, ADD_BILL, CLEAR_CREDITO : in STD_LOGIC;
               VALOR_COIN, VALOR_BILL : in STD_LOGIC_VECTOR(7 downto 0);
               SEL_PRODUTO : in STD_LOGIC;
               PRODUTO : in STD_LOGIC_VECTOR(3 downto 0);
               TEMP_SENSOR : in STD_LOGIC_VECTOR(7 downto 0);
               TROCO_DISPONIVEL, PRODUTO_DISPONIVEL : out STD_LOGIC;
               MENSAGEM : out STD_LOGIC_VECTOR(31 downto 0);
               REFRIGERACAO_ATIVADA : out STD_LOGIC);
    end component;

    -- Sinais para estímulo
    signal CLK, RESET, ADD_COIN, ADD_BILL, CLEAR_CREDITO, SEL_PRODUTO : STD_LOGIC := '0';
    signal VALOR_COIN, VALOR_BILL : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal PRODUTO : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal TEMP_SENSOR : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal TROCO_DISPONIVEL, PRODUTO_DISPONIVEL, REFRIGERACAO_ATIVADA : STD_LOGIC;
    signal MENSAGEM : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- Instanciando o Datapath
    CUT: Datapath_MaquinaVendas
        port map (
            CLK => CLK,
            RESET => RESET,
            ADD_COIN => ADD_COIN,
            ADD_BILL => ADD_BILL,
            CLEAR_CREDITO => CLEAR_CREDITO,
            VALOR_COIN => VALOR_COIN,
            VALOR_BILL => VALOR_BILL,
            SEL_PRODUTO => SEL_PRODUTO,
            PRODUTO => PRODUTO,
            TEMP_SENSOR => TEMP_SENSOR,
            TROCO_DISPONIVEL => TROCO_DISPONIVEL,
            PRODUTO_DISPONIVEL => PRODUTO_DISPONIVEL,
            MENSAGEM => MENSAGEM,
            REFRIGERACAO_ATIVADA => REFRIGERACAO_ATIVADA
        );

    -- Geração do Clock
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

    -- Processo de Teste
    process
    begin
        -- Resetando a máquina
        RESET <= '1';
        wait for 10 ns;
        RESET <= '0';

        -- Inserindo uma moeda de 50
        ADD_COIN <= '1';
        VALOR_COIN <= "00110010";  -- 50 em binário
        wait for 10 ns;
        ADD_COIN <= '0';

        -- Inserindo uma nota de 100
        ADD_BILL <= '1';
        VALOR_BILL <= "01100100";  -- 100 em binário
        wait for 10 ns;
        ADD_BILL <= '0';

        -- Selecionando um produto
        SEL_PRODUTO <= '1';
        PRODUTO <= "0001";  -- Produto 1
        wait for 10 ns;
        SEL_PRODUTO <= '0';

        -- Simulando temperatura alta para ativação da refrigeração
        TEMP_SENSOR <= "10010100";  -- 148 em binário
        wait for 20 ns;

        -- Simulando temperatura baixa para desativação
        TEMP_SENSOR <= "00011001";  -- 25 em binário
        wait for 20 ns;

        -- Limpar crédito
        CLEAR_CREDITO <= '1';
        wait for 10 ns;
        CLEAR_CREDITO <= '0';

        wait;
    end process;

end testbench;
