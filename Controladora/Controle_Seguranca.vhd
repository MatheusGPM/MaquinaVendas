library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- A entidade Controle_Seguranca lida com a detecção de situações de segurança,
-- como a abertura indevida da porta (DOOR_SENSOR = '1') ou a ocorrência de erros no sistema (ERRO_SISTEMA = '1').
-- Quando qualquer uma dessas condições é detectada, a entidade ativa um LED de erro (ERRO_LED)
-- e emite um sinal para bloquear a operação (BLOQUEAR_OPERACAO).

entity Controle_Seguranca is
    Port (
        CLK              : in  STD_LOGIC;
        RESET            : in  STD_LOGIC;
        DOOR_SENSOR      : in  STD_LOGIC;  -- Sinal do sensor de porta (1 = porta aberta, 0 = porta fechada)
        ERRO_SISTEMA     : in  STD_LOGIC;  -- Sinal de erro do sistema (1 = erro detectado)
        ERRO_LED         : out STD_LOGIC;  -- Sinal que acende o LED de erro
        BLOQUEAR_OPERACAO: out STD_LOGIC   -- Sinal para bloquear a operação da máquina
    );
end Controle_Seguranca;

architecture Behavioral of Controle_Seguranca is
begin
    process(CLK, RESET)
    begin
        if RESET = '1' then
            ERRO_LED          <= '0';
            BLOQUEAR_OPERACAO <= '0';
        elsif rising_edge(CLK) then
            -- Se a porta estiver aberta ou ocorrer um erro no sistema,
            -- ativa o LED de erro e bloqueia a operação.
            if (DOOR_SENSOR = '1') or (ERRO_SISTEMA = '1') then
                ERRO_LED          <= '1';
                BLOQUEAR_OPERACAO <= '1';
            else
                ERRO_LED          <= '0';
                BLOQUEAR_OPERACAO <= '0';
            end if;
        end if;
    end process;
end Behavioral;
