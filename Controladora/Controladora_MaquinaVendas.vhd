library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top-level Controladora_MaquinaVendas que conecta todos os módulos da controladora:
-- - FSM_MaquinaVendas: Gerencia o fluxo de operação.
-- - Controle_Credito: Controla a adição e remoção de crédito.
-- - Controle_Produto: Valida a seleção do produto com base no estoque.
-- - Controle_Troco: Aciona o cálculo e liberação do troco.
-- - Controle_Seguranca: Verifica condições de segurança (porta aberta, erro no sistema).

entity Controladora_MaquinaVendas is
    Port (
        CLK                : in  STD_LOGIC;
        RESET              : in  STD_LOGIC;
        -- Sinais de eventos externos
        COIN_EVENT         : in  STD_LOGIC;
        BILL_EVENT         : in  STD_LOGIC;
        CANCEL_EVENT       : in  STD_LOGIC;
        PRODUCT_SELECT_EVENT : in  STD_LOGIC;
        PURCHASE_EVENT     : in  STD_LOGIC;
        CREDIT_ENOUGH      : in  STD_LOGIC;
        -- Entradas de valores para crédito
        VALOR_COIN         : in  STD_LOGIC_VECTOR(7 downto 0);
        VALOR_BILL         : in  STD_LOGIC_VECTOR(7 downto 0);
        -- Entrada para seleção de produto
        PRODUTO            : in  STD_LOGIC_VECTOR(3 downto 0);
        -- Entrada de contagem de estoque (proveniente do Datapath)
        STOCK_COUNT        : in  STD_LOGIC_VECTOR(4 downto 0);
        -- Entradas para o módulo de Troco
        VALOR_TOTAL_COMPRA : in  STD_LOGIC_VECTOR(7 downto 0);
        VALOR_PAGO         : in  STD_LOGIC_VECTOR(7 downto 0);
        TROCO_IN           : in  STD_LOGIC_VECTOR(7 downto 0);
        TROCO_PRONTO_IN    : in  STD_LOGIC;
        -- Sensores externos
        DOOR_SENSOR        : in  STD_LOGIC;
        ERRO_SISTEMA       : in  STD_LOGIC;
        -- Saídas para o Datapath / Sistema
        DISPLAY_MSG        : out STD_LOGIC_VECTOR(15 downto 0);
        ADD_COIN           : out STD_LOGIC;
        ADD_BILL           : out STD_LOGIC;
        CLEAR_CREDITO      : out STD_LOGIC;
        SEL_PRODUTO        : out STD_LOGIC;
        LIBERAR_PRODUTO    : out STD_LOGIC;
        LIBERAR_TROCO      : out STD_LOGIC;
        TROCO              : out STD_LOGIC_VECTOR(7 downto 0);
        TROCO_PRONTO       : out STD_LOGIC;
        ERRO_LED           : out STD_LOGIC;
        BLOQUEAR_OPERACAO  : out STD_LOGIC;
        STATE_OUT          : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Controladora_MaquinaVendas;

architecture Structural of Controladora_MaquinaVendas is

    -- Sinais internos provenientes da FSM_MaquinaVendas
    signal fsm_DISPLAY_MSG       : STD_LOGIC_VECTOR(15 downto 0);
    signal fsm_ADD_COIN          : STD_LOGIC;
    signal fsm_ADD_BILL          : STD_LOGIC;
    signal fsm_CLEAR_CREDITO     : STD_LOGIC;
    signal fsm_SEL_PRODUTO_OUT   : STD_LOGIC;
    signal fsm_LIBERAR_PRODUTO   : STD_LOGIC;
    signal fsm_LIBERAR_TROCO     : STD_LOGIC;
    signal fsm_STATE_OUT         : STD_LOGIC_VECTOR(3 downto 0);

    -- Sinais internos do Controle_Credito
    signal cc_ADD_COIN           : STD_LOGIC;
    signal cc_ADD_BILL           : STD_LOGIC;
    signal cc_CLEAR_CREDITO      : STD_LOGIC;

    -- Sinais internos do Controle_Produto
    signal cp_PRODUTO_VALID      : STD_LOGIC_VECTOR(3 downto 0);
    signal cp_DISPONIVEL_FLAG    : STD_LOGIC;

    -- Sinais internos do Controle_Troco
    signal ct_LIBERAR_TROCO      : STD_LOGIC;
    signal ct_TROCO              : STD_LOGIC_VECTOR(7 downto 0);
    signal ct_TROCO_PRONTO       : STD_LOGIC;

    -- Sinais internos do Controle_Seguranca
    signal cs_ERRO_LED           : STD_LOGIC;
    signal cs_BLOQUEAR_OPERACAO  : STD_LOGIC;

begin

    -- Instância da FSM_MaquinaVendas
    u_FSM: entity work.FSM_MaquinaVendas
        port map (
            CLK                 => CLK,
            RESET               => RESET,
            COIN_EVENT          => COIN_EVENT,
            BILL_EVENT          => BILL_EVENT,
            CANCEL_EVENT        => CANCEL_EVENT,
            PRODUCT_SELECT_EVENT=> PRODUCT_SELECT_EVENT,
            CREDIT_ENOUGH       => CREDIT_ENOUGH,
            TROCO_PRONTO_IN     => TROCO_PRONTO_IN,
            DOOR_SENSOR         => DOOR_SENSOR,
            DISPLAY_MSG         => fsm_DISPLAY_MSG,
            ADD_COIN            => fsm_ADD_COIN,
            ADD_BILL            => fsm_ADD_BILL,
            CLEAR_CREDITO       => fsm_CLEAR_CREDITO,
            SEL_PRODUTO_OUT     => fsm_SEL_PRODUTO_OUT,
            LIBERAR_PRODUTO     => fsm_LIBERAR_PRODUTO,
            LIBERAR_TROCO       => fsm_LIBERAR_TROCO,
            STATE_OUT           => fsm_STATE_OUT
        );

    -- Instância do Controle_Credito
    u_Credito: entity work.Controle_Credito
        port map (
            CLK            => CLK,
            RESET          => RESET,
            COIN_EVENT     => COIN_EVENT,
            BILL_EVENT     => BILL_EVENT,
            CANCEL_EVENT   => CANCEL_EVENT,
            PURCHASE_EVENT => PURCHASE_EVENT,
            VALOR_COIN     => VALOR_COIN,
            VALOR_BILL     => VALOR_BILL,
            ADD_COIN       => cc_ADD_COIN,
            ADD_BILL       => cc_ADD_BILL,
            CLEAR_CREDITO  => cc_CLEAR_CREDITO
        );

    -- Instância do Controle_Produto
    u_Produto: entity work.Controle_Produto
        port map (
            CLK             => CLK,
            RESET           => RESET,
            SEL_PRODUTO     => fsm_SEL_PRODUTO_OUT,  -- Utiliza o sinal da FSM para seleção
            PRODUTO         => PRODUTO,
            STOCK_COUNT     => STOCK_COUNT,
            PRODUTO_VALID   => cp_PRODUTO_VALID,
            DISPONIVEL_FLAG => cp_DISPONIVEL_FLAG
        );

    -- Instância do Controle_Troco
    u_Troco: entity work.Controle_Troco
        port map (
            CLK                => CLK,
            RESET              => RESET,
            REQUEST_TROCO      => fsm_LIBERAR_TROCO,  -- Comando da FSM para liberar troco
            VALOR_TOTAL_COMPRA => VALOR_TOTAL_COMPRA,
            VALOR_PAGO         => VALOR_PAGO,
            TROCO_IN           => TROCO_IN,
            TROCO_PRONTO_IN    => TROCO_PRONTO_IN,
            LIBERAR_TROCO      => ct_LIBERAR_TROCO,
            TROCO              => ct_TROCO,
            TROCO_PRONTO       => ct_TROCO_PRONTO
        );

    -- Instância do Controle_Seguranca
    u_Seguranca: entity work.Controle_Seguranca
        port map (
            CLK              => CLK,
            RESET            => RESET,
            DOOR_SENSOR      => DOOR_SENSOR,
            ERRO_SISTEMA     => ERRO_SISTEMA,
            ERRO_LED         => cs_ERRO_LED,
            BLOQUEAR_OPERACAO=> cs_BLOQUEAR_OPERACAO
        );

    -- Combinação de sinais para as saídas da controladora
    -- Para os sinais de crédito, combinamos as saídas do Controle_Credito e da FSM.
    ADD_COIN      <= cc_ADD_COIN or fsm_ADD_COIN;
    ADD_BILL      <= cc_ADD_BILL or fsm_ADD_BILL;
    CLEAR_CREDITO <= cc_CLEAR_CREDITO or fsm_CLEAR_CREDITO;

    -- Sinal de seleção de produto vem da FSM.
    SEL_PRODUTO   <= fsm_SEL_PRODUTO_OUT;

    -- Sinal para dispensação do produto vem da FSM.
    LIBERAR_PRODUTO <= fsm_LIBERAR_PRODUTO;

    -- Sinais do controle de troco.
    LIBERAR_TROCO   <= ct_LIBERAR_TROCO;
    TROCO           <= ct_TROCO;
    TROCO_PRONTO    <= ct_TROCO_PRONTO;

    -- Mensagem para o display e estado interno vêm da FSM.
    DISPLAY_MSG     <= fsm_DISPLAY_MSG;
    STATE_OUT       <= fsm_STATE_OUT;

    -- Sinais de segurança.
    ERRO_LED         <= cs_ERRO_LED;
    BLOQUEAR_OPERACAO<= cs_BLOQUEAR_OPERACAO;

end Structural;
