library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controle_Estoque is
    Port (
        CLK         : in  STD_LOGIC;
        RESET       : in  STD_LOGIC;
        DISPENSE    : in  STD_LOGIC;  -- Sinal para solicitar a dispensação do produto
        DRAWER_ID   : in  STD_LOGIC_VECTOR(2 downto 0);  -- Identificador da gaveta (0 a 5)
        CHANNEL_ID  : in  STD_LOGIC_VECTOR(3 downto 0);  -- Identificador do canal (0 a 9)
        DISPENSAR   : out STD_LOGIC;  -- Sinal indicando que o produto foi dispensado (estoque decrementado)
        STOCK_COUNT : out STD_LOGIC_VECTOR(4 downto 0)   -- Quantidade atual disponível no canal selecionado (0 a 16)
    );
end Controle_Estoque;

architecture Behavioral of Controle_Estoque is
    -- Definição de um array 2D para representar o estoque:
    -- 6 gavetas x 10 canais por gaveta, onde cada canal possui um valor de 5 bits (0 a 16)
    type stock_array is array (0 to 5, 0 to 9) of STD_LOGIC_VECTOR(4 downto 0);
    signal estoque : stock_array;
begin
    process(CLK, RESET)
        variable d : integer;
        variable c : integer;
    begin
        if RESET = '1' then
            -- Inicializa todos os canais com 16 itens (em binário "10000")
            for i in 0 to 5 loop
                for j in 0 to 9 loop
                    estoque(i, j) <= "10000";  -- 16 itens por canal
                end loop;
            end loop;
            DISPENSAR   <= '0';
            STOCK_COUNT <= (others => '0');
        elsif rising_edge(CLK) then
            -- Converter DRAWER_ID e CHANNEL_ID para inteiros
            d := to_integer(unsigned(DRAWER_ID));
            c := to_integer(unsigned(CHANNEL_ID));
            
            -- Atualiza a saída STOCK_COUNT com o valor do canal selecionado
            STOCK_COUNT <= estoque(d, c);
            
            if DISPENSE = '1' then
                -- Se houver produto disponível, decrementa o estoque e ativa DISPENSAR
                if unsigned(estoque(d, c)) > 0 then
                    estoque(d, c) <= std_logic_vector(unsigned(estoque(d, c)) - 1);
                    DISPENSAR <= '1';
                else
                    -- Se o estoque estiver zerado, não ativa DISPENSAR
                    DISPENSAR <= '0';
                end if;
            else
                DISPENSAR <= '0';
            end if;
        end if;
    end process;
end Behavioral;
