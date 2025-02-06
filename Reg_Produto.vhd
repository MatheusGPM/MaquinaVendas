library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reg_Produto is
    Port ( CLK, RESET, SEL_PRODUTO : in STD_LOGIC;
           PRODUTO : in STD_LOGIC_VECTOR(3 downto 0);
           PRODUTO_SELECIONADO : out STD_LOGIC_VECTOR(3 downto 0));
end Reg_Produto;

architecture Behavioral of Reg_Produto is
    signal reg_produto : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
begin
    process (CLK, RESET)
    begin
        if RESET = '1' then
            reg_produto <= (others => '0');
        elsif rising_edge(CLK) then
            if SEL_PRODUTO = '1' then
                reg_produto <= PRODUTO;
            end if;
        end if;
    end process;
    PRODUTO_SELECIONADO <= reg_produto;
end Behavioral;