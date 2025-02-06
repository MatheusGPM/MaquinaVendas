library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controle_Display is
    Port (
        CLK     : in  STD_LOGIC;
        RESET   : in  STD_LOGIC;
        LD_MSG  : in  STD_LOGIC;  -- Sinal para carregar nova mensagem
        MSG_IN  : in  STD_LOGIC_VECTOR(15 downto 0);  -- Mensagem a ser exibida
        DISPLAY : out STD_LOGIC_VECTOR(15 downto 0)   -- Saída para o display
    );
end Controle_Display;

architecture Behavioral of Controle_Display is
    signal display_reg : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
begin
    process(CLK, RESET)
    begin
        if RESET = '1' then
            display_reg <= (others => '0');  -- Zera a mensagem ao resetar
        elsif rising_edge(CLK) then
            if LD_MSG = '1' then
                display_reg <= MSG_IN;  -- Atualiza a mensagem exibida
            end if;
        end if;
    end process;
    
    DISPLAY <= display_reg;
end Behavioral;
