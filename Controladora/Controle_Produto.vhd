library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entidade que garante que apenas produtos disponíveis possam ser selecionados.
-- Essa controladora verifica se o produto solicitado possui estoque disponível,
-- utilizando o valor de STOCK_COUNT fornecido pelo módulo de Controle_Estoque.
entity Controle_Produto is
    Port (
         CLK             : in  STD_LOGIC;
         RESET           : in  STD_LOGIC;
         SEL_PRODUTO     : in  STD_LOGIC;  -- Sinal que indica a requisição de seleção do produto
         PRODUTO         : in  STD_LOGIC_VECTOR(3 downto 0);  -- Código do produto solicitado
         STOCK_COUNT     : in  STD_LOGIC_VECTOR(4 downto 0);  -- Quantidade disponível para o produto (0 a 16)
         PRODUTO_VALID   : out STD_LOGIC_VECTOR(3 downto 0);  -- Produto validado (apenas se disponível)
         DISPONIVEL_FLAG : out STD_LOGIC                     -- '1' se o produto está disponível, '0' caso contrário
    );
end Controle_Produto;

architecture Behavioral of Controle_Produto is
begin
    process(CLK, RESET)
    begin
        if RESET = '1' then
            PRODUTO_VALID   <= (others => '0');
            DISPONIVEL_FLAG <= '0';
        elsif rising_edge(CLK) then
            if SEL_PRODUTO = '1' then
                -- Verifica se há estoque disponível para o produto solicitado
                if unsigned(STOCK_COUNT) > 0 then
                    PRODUTO_VALID   <= PRODUTO;  -- Aceita a seleção e repassa o código do produto
                    DISPONIVEL_FLAG <= '1';      -- Indica que o produto está disponível
                else
                    PRODUTO_VALID   <= (others => '0');  -- Produto não é validado
                    DISPONIVEL_FLAG <= '0';              -- Indica que o produto não está disponível
                end if;
            end if;
        end if;
    end process;
end Behavioral;
