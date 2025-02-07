library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- FSM_MaquinaVendas.vhd
-- Implementação principal da FSM que controla o fluxo de operação da máquina de vendas.
-- Essa FSM coordena a inserção de crédito, seleção de produto, comparação de crédito,
-- liberação do produto, cálculo e liberação do troco, além de tratar cancelamentos e erros.

entity FSM_MaquinaVendas is
    Port (
         CLK                 : in  STD_LOGIC;
         RESET               : in  STD_LOGIC;
         -- Sinais de eventos externos:
         COIN_EVENT          : in  STD_LOGIC;  -- Evento de inserção de moeda
         BILL_EVENT          : in  STD_LOGIC;  -- Evento de inserção de nota
         CANCEL_EVENT        : in  STD_LOGIC;  -- Evento de cancelamento da operação
         PRODUCT_SELECT_EVENT: in  STD_LOGIC;  -- Evento de seleção de produto
         CREDIT_ENOUGH       : in  STD_LOGIC;  -- Indica que o crédito acumulado é suficiente para a compra
         TROCO_PRONTO_IN     : in  STD_LOGIC;  -- Sinal vindo do módulo de Troco, indicando que o troco foi calculado
         DOOR_SENSOR         : in  STD_LOGIC;  -- Sinal do sensor de porta (produto retirado)
         
         -- Sinais de controle para acionar os módulos do Datapath:
         DISPLAY_MSG         : out STD_LOGIC_VECTOR(15 downto 0);  -- Mensagem a ser exibida no display
         ADD_COIN            : out STD_LOGIC;  -- Ativa a adição de crédito via moeda
         ADD_BILL            : out STD_LOGIC;  -- Ativa a adição de crédito via nota
         CLEAR_CREDITO       : out STD_LOGIC;  -- Limpa o registrador de crédito
         SEL_PRODUTO_OUT     : out STD_LOGIC;  -- Sinal para registrar a seleção do produto
         LIBERAR_PRODUTO     : out STD_LOGIC;  -- Sinal para dispensar o produto
         LIBERAR_TROCO       : out STD_LOGIC;  -- Sinal para acionar o cálculo/liberação do troco
         
         -- Sinal para monitoramento interno (opcional, para debug)
         STATE_OUT           : out STD_LOGIC_VECTOR(3 downto 0)
    );
end FSM_MaquinaVendas;

architecture Behavioral of FSM_MaquinaVendas is

    -- Definição dos estados da FSM.
    -- Nota: o estado "DISPENSA_PRODUTO" foi nomeado dessa forma para evitar conflito
    -- com o nome do sinal de saída LIBERAR_PRODUTO.
    type state_type is (
        INIT,
        IDLE,
        ACUMULA_CREDITO,
        TELA_SELECAO,
        COMPARADOR,
        DISPENSA_PRODUTO,   -- Renomeado para evitar conflito com o sinal LIBERAR_PRODUTO
        CALCULA_TROCO,
        TROCO_ENTREGUE,
        PORTA_SAIDA,
        CANCELAR,
        ERRO
    );
    
    signal current_state, next_state : state_type;
    
    -- Definição de mensagens para o display (cada mensagem tem 16 bits = 2 caracteres)
    -- Utilizando abreviações de 2 letras:
    constant MSG_WELCOME     : STD_LOGIC_VECTOR(15 downto 0) := x"5743";  -- "WC" (Welcome)
    constant MSG_CRED_UPD    : STD_LOGIC_VECTOR(15 downto 0) := x"4352";  -- "CR" (Crédito atualizado)
    constant MSG_AGUARDA_PROD: STD_LOGIC_VECTOR(15 downto 0) := x"4147";  -- "AG" (Aguardando produto)
    constant MSG_SEL_PROD    : STD_LOGIC_VECTOR(15 downto 0) := x"5350";  -- "SP" (Selecione produto)
    constant MSG_PROD_SEL    : STD_LOGIC_VECTOR(15 downto 0) := x"5052";  -- "PR" (Produto selecionado)
    constant MSG_COMPRA_APR  : STD_LOGIC_VECTOR(15 downto 0) := x"4150";  -- "AP" (Compra aprovada)
    constant MSG_CRED_INSUF  : STD_LOGIC_VECTOR(15 downto 0) := x"4349";  -- "CI" (Crédito insuficiente)
    constant MSG_DISP_PROD   : STD_LOGIC_VECTOR(15 downto 0) := x"4450";  -- "DP" (Dispensando produto)
    constant MSG_CALC_TROCO  : STD_LOGIC_VECTOR(15 downto 0) := x"4354";  -- "CT" (Calculando troco)
    constant MSG_TROCO_LIB   : STD_LOGIC_VECTOR(15 downto 0) := x"544C";  -- "TL" (Troco liberado)
    constant MSG_RETIRE_PROD : STD_LOGIC_VECTOR(15 downto 0) := x"5254";  -- "RT" (Retire produto)
    constant MSG_AGUARDA_RET : STD_LOGIC_VECTOR(15 downto 0) := x"4152";  -- "AR" (Aguardando retirada)
    constant MSG_OPER_CANCEL : STD_LOGIC_VECTOR(15 downto 0) := x"434E";  -- "CN" (Operação cancelada)
    constant MSG_ERRO        : STD_LOGIC_VECTOR(15 downto 0) := x"4552";  -- "ER" (Erro no sistema)
    
begin

    -- Processamento síncrono do registro de estado
    process(CLK, RESET)
    begin
        if RESET = '1' then
            current_state <= INIT;
        elsif rising_edge(CLK) then
            current_state <= next_state;
        end if;
    end process;
    
    -- Lógica combinacional para determinar o próximo estado e gerar as saídas
    process(current_state, COIN_EVENT, BILL_EVENT, CANCEL_EVENT, PRODUCT_SELECT_EVENT, CREDIT_ENOUGH, TROCO_PRONTO_IN, DOOR_SENSOR)
    begin
        -- Valores padrão para as saídas
        ADD_COIN         <= '0';
        ADD_BILL         <= '0';
        CLEAR_CREDITO    <= '0';
        SEL_PRODUTO_OUT  <= '0';
        LIBERAR_PRODUTO  <= '0';
        LIBERAR_TROCO    <= '0';
        DISPLAY_MSG      <= (others => '0');  -- Mensagem em branco
        next_state       <= current_state;    -- Por padrão, mantém o estado atual
        
        case current_state is
            when INIT =>
                CLEAR_CREDITO <= '1';
                DISPLAY_MSG   <= MSG_WELCOME;
                next_state    <= IDLE;
                
            when IDLE =>
                if COIN_EVENT = '1' then
                    ADD_COIN    <= '1';
                    DISPLAY_MSG <= MSG_CRED_UPD;
                    next_state  <= ACUMULA_CREDITO;
                elsif BILL_EVENT = '1' then
                    ADD_BILL    <= '1';
                    DISPLAY_MSG <= MSG_CRED_UPD;
                    next_state  <= ACUMULA_CREDITO;
                end if;
                
            when ACUMULA_CREDITO =>
                if CANCEL_EVENT = '1' then
                    next_state  <= CANCELAR;
                    DISPLAY_MSG <= MSG_OPER_CANCEL;
                elsif PRODUCT_SELECT_EVENT = '1' then
                    next_state  <= TELA_SELECAO;
                    DISPLAY_MSG <= MSG_SEL_PROD;
                else
                    next_state  <= ACUMULA_CREDITO;
                    DISPLAY_MSG <= MSG_AGUARDA_PROD;
                end if;
                
            when TELA_SELECAO =>
                SEL_PRODUTO_OUT <= '1';
                DISPLAY_MSG   <= MSG_PROD_SEL;
                next_state    <= COMPARADOR;
                
            when COMPARADOR =>
                if CREDIT_ENOUGH = '1' then
                    DISPLAY_MSG <= MSG_COMPRA_APR;
                    next_state  <= DISPENSA_PRODUTO;
                else
                    DISPLAY_MSG <= MSG_CRED_INSUF;
                    next_state  <= ERRO;
                end if;
                
            when DISPENSA_PRODUTO =>
                LIBERAR_PRODUTO <= '1';
                DISPLAY_MSG   <= MSG_DISP_PROD;
                next_state    <= CALCULA_TROCO;
                
            when CALCULA_TROCO =>
                LIBERAR_TROCO <= '1';
                DISPLAY_MSG   <= MSG_CALC_TROCO;
                next_state    <= TROCO_ENTREGUE;
                
            when TROCO_ENTREGUE =>
                if TROCO_PRONTO_IN = '1' then
                    DISPLAY_MSG <= MSG_TROCO_LIB;
                    next_state  <= PORTA_SAIDA;
                else
                    DISPLAY_MSG <= MSG_CALC_TROCO;
                    next_state  <= TROCO_ENTREGUE;
                end if;
                
            when PORTA_SAIDA =>
                if DOOR_SENSOR = '1' then
                    CLEAR_CREDITO <= '1';
                    DISPLAY_MSG   <= MSG_RETIRE_PROD;
                    next_state    <= IDLE;
                else
                    DISPLAY_MSG <= MSG_AGUARDA_RET;
                    next_state  <= PORTA_SAIDA;
                end if;
                
            when CANCELAR =>
                CLEAR_CREDITO <= '1';
                DISPLAY_MSG   <= MSG_OPER_CANCEL;
                next_state    <= IDLE;
                
            when ERRO =>
                CLEAR_CREDITO <= '1';
                DISPLAY_MSG   <= MSG_ERRO;
                next_state    <= IDLE;
                
            when others =>
                next_state    <= INIT;
        end case;
    end process;
    
    -- Processo para mapear o estado atual para um código de 4 bits (para debug ou monitoramento)
    process(current_state)
    begin
        case current_state is
            when INIT              => STATE_OUT <= "0000";
            when IDLE              => STATE_OUT <= "0001";
            when ACUMULA_CREDITO   => STATE_OUT <= "0010";
            when TELA_SELECAO      => STATE_OUT <= "0011";
            when COMPARADOR        => STATE_OUT <= "0100";
            when DISPENSA_PRODUTO  => STATE_OUT <= "0101";
            when CALCULA_TROCO     => STATE_OUT <= "0110";
            when TROCO_ENTREGUE    => STATE_OUT <= "0111";
            when PORTA_SAIDA       => STATE_OUT <= "1000";
            when CANCELAR          => STATE_OUT <= "1001";
            when ERRO              => STATE_OUT <= "1010";
            when others            => STATE_OUT <= "0000";
        end case;
    end process;
    
end Behavioral;
