library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entidade que define as regras para adicionar e remover crédito.
-- Essa controladora gera os sinais que controlam o registrador de crédito (Reg_Credito)
-- de acordo com os eventos do sistema, como inserção de moeda, inserção de nota,
-- cancelamento da operação ou conclusão da compra.
entity Controle_Credito is
    Port (
         CLK            : in  STD_LOGIC;
         RESET          : in  STD_LOGIC;
         -- Eventos de entrada provenientes do usuário/sistema
         COIN_EVENT     : in  STD_LOGIC;  -- Evento de inserção de moeda
         BILL_EVENT     : in  STD_LOGIC;  -- Evento de inserção de nota
         CANCEL_EVENT   : in  STD_LOGIC;  -- Evento de cancelamento da operação
         PURCHASE_EVENT : in  STD_LOGIC;  -- Evento indicando que a compra foi concluída
         -- Valores associados à moeda ou nota inserida
         VALOR_COIN     : in  STD_LOGIC_VECTOR(7 downto 0);
         VALOR_BILL     : in  STD_LOGIC_VECTOR(7 downto 0);
         -- Sinais de controle para o Reg_Credito
         ADD_COIN       : out STD_LOGIC;
         ADD_BILL       : out STD_LOGIC;
         CLEAR_CREDITO  : out STD_LOGIC
    );
end Controle_Credito;

architecture Behavioral of Controle_Credito is
begin
    -- A lógica da controladora prioriza os eventos de cancelamento ou conclusão da compra
    -- para que o crédito seja removido (clear) antes de processar novas inserções.
    process(CLK, RESET)
    begin
        if RESET = '1' then
            ADD_COIN      <= '0';
            ADD_BILL      <= '0';
            CLEAR_CREDITO <= '0';
        elsif rising_edge(CLK) then
            -- Se ocorrer um cancelamento ou a compra foi finalizada, limpa o crédito.
            if (CANCEL_EVENT = '1') or (PURCHASE_EVENT = '1') then
                CLEAR_CREDITO <= '1';
                ADD_COIN      <= '0';
                ADD_BILL      <= '0';
            -- Se uma moeda for inserida, gera o pulso para adicionar crédito via moeda.
            elsif COIN_EVENT = '1' then
                ADD_COIN      <= '1';
                ADD_BILL      <= '0';
                CLEAR_CREDITO <= '0';
            -- Se uma nota for inserida, gera o pulso para adicionar crédito via nota.
            elsif BILL_EVENT = '1' then
                ADD_BILL      <= '1';
                ADD_COIN      <= '0';
                CLEAR_CREDITO <= '0';
            else
                -- Se nenhum evento ocorrer, mantém os sinais inativos.
                ADD_COIN      <= '0';
                ADD_BILL      <= '0';
                CLEAR_CREDITO <= '0';
            end if;
        end if;
    end process;
end Behavioral;
