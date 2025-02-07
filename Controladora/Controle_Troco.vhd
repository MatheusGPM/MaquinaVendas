library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- A entidade Controle_Troco aciona o Datapath para liberar o troco correto.
-- Ela recebe um sinal de solicitação (REQUEST_TROCO) e, ao detectar essa
-- solicitação, ativa o sinal LIBERAR_TROCO para o módulo Troco, aguardando
-- que o cálculo do troco seja concluído. Quando o módulo Troco indicar que o
-- troco está pronto (TROCO_PRONTO_IN = '1'), a controladora captura o valor do
-- troco (TROCO_IN) e o repassa para o Datapath, sinalizando que o troco foi
-- liberado (TROCO_PRONTO).
entity Controle_Troco is
    Port (
         CLK                : in  STD_LOGIC;
         RESET              : in  STD_LOGIC;
         REQUEST_TROCO      : in  STD_LOGIC;  -- Sinal que indica que a liberação do troco é solicitada
         VALOR_TOTAL_COMPRA : in  STD_LOGIC_VECTOR(7 downto 0);  -- Preço do produto
         VALOR_PAGO         : in  STD_LOGIC_VECTOR(7 downto 0);  -- Crédito inserido pelo cliente
         TROCO_IN           : in  STD_LOGIC_VECTOR(7 downto 0);  -- Valor calculado do troco (saída do módulo Troco)
         TROCO_PRONTO_IN    : in  STD_LOGIC;  -- Sinal que indica que o troco foi calculado (saída do módulo Troco)
         LIBERAR_TROCO      : out STD_LOGIC;  -- Sinal para acionar o módulo Troco no Datapath
         TROCO              : out STD_LOGIC_VECTOR(7 downto 0);  -- Troco final a ser enviado para o Datapath
         TROCO_PRONTO       : out STD_LOGIC  -- Sinal indicando que o troco foi liberado
    );
end Controle_Troco;

architecture Behavioral of Controle_Troco is

    type state_type is (IDLE, WAIT_TROCO);
    signal current_state, next_state : state_type;

begin

    -- Processamento síncrono: atualização do estado atual.
    process(CLK, RESET)
    begin
        if RESET = '1' then
            current_state <= IDLE;
        elsif rising_edge(CLK) then
            current_state <= next_state;
        end if;
    end process;
    
    -- Lógica combinacional: transição de estados e geração de saídas.
    process(current_state, REQUEST_TROCO, TROCO_PRONTO_IN, TROCO_IN)
    begin
        -- Valores padrão
        LIBERAR_TROCO <= '0';
        TROCO_PRONTO  <= '0';
        TROCO         <= (others => '0');
        next_state    <= current_state;
        
        case current_state is
            when IDLE =>
                if REQUEST_TROCO = '1' then
                    -- Ao solicitar o troco, ativa LIBERAR_TROCO para iniciar o cálculo
                    LIBERAR_TROCO <= '1';
                    next_state <= WAIT_TROCO;
                end if;
                
            when WAIT_TROCO =>
                -- Aguarda a indicação de que o troco foi calculado
                if TROCO_PRONTO_IN = '1' then
                    TROCO        <= TROCO_IN;  -- Captura o valor calculado do troco
                    TROCO_PRONTO <= '1';       -- Sinaliza que o troco está pronto para ser liberado
                    next_state   <= IDLE;
                end if;
                
            when others =>
                next_state <= IDLE;
        end case;
    end process;

end Behavioral;
