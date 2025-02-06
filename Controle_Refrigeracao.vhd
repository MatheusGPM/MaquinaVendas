library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Controle_Refrigeracao is
    Port (
        CLK                : in  STD_LOGIC;
        RESET              : in  STD_LOGIC;
        TEMP_SENSOR        : in  STD_LOGIC_VECTOR(7 downto 0);  -- Leitura do sensor de temperatura (8 bits)
        LIMIAR_TEMPERATURA : in  STD_LOGIC_VECTOR(7 downto 0);  -- Valor limiar para ativação do resfriamento
        REFRIGERACAO_ATIVA : out STD_LOGIC                    -- Sinal de controle: '1' ativa o resfriamento
    );
end Controle_Refrigeracao;

architecture Behavioral of Controle_Refrigeracao is
begin
    process(CLK, RESET)
        variable temp_val   : unsigned(7 downto 0);
        variable limiar_val : unsigned(7 downto 0);
    begin
        if RESET = '1' then
            REFRIGERACAO_ATIVA <= '0';
        elsif rising_edge(CLK) then
            -- Converte as entradas para o tipo unsigned para facilitar a comparação
            temp_val   := unsigned(TEMP_SENSOR);
            limiar_val := unsigned(LIMIAR_TEMPERATURA);
            
            -- Se a temperatura medida exceder o limiar, ativa o resfriamento
            if temp_val > limiar_val then
                REFRIGERACAO_ATIVA <= '1';
            else
                REFRIGERACAO_ATIVA <= '0';
            end if;
        end if;
    end process;
end Behavioral;
