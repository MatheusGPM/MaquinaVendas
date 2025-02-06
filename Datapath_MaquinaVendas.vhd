library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Datapath_MaquinaVendas is
    Port (
        -- Sinais de Clock e Reset
        CLK                 : in  STD_LOGIC;
        RESET               : in  STD_LOGIC;
        
        -- Entradas para Reg_Credito (crédito inserido)
        ADD_COIN            : in  STD_LOGIC;
        ADD_BILL            : in  STD_LOGIC;
        CLEAR_CREDITO       : in  STD_LOGIC;
        VALOR_COIN          : in  STD_LOGIC_VECTOR(7 downto 0);
        VALOR_BILL          : in  STD_LOGIC_VECTOR(7 downto 0);
        
        -- Entradas para Reg_Produto (produto selecionado)
        SEL_PRODUTO         : in  STD_LOGIC;
        PRODUTO             : in  STD_LOGIC_VECTOR(3 downto 0);
        
        -- Entradas para Troco
        LIBERAR_TROCO       : in  STD_LOGIC;  -- Sinal para acionar o cálculo/liberação do troco
        VALOR_TOTAL_COMPRA  : in  STD_LOGIC_VECTOR(7 downto 0);  -- Valor total da compra (por exemplo, preço do produto)
        
        -- Entradas para Controle_Estoque
        DISPENSE            : in  STD_LOGIC;  -- Sinal que solicita a dispensação de um produto
        DRAWER_ID           : in  STD_LOGIC_VECTOR(2 downto 0);
        CHANNEL_ID          : in  STD_LOGIC_VECTOR(3 downto 0);
        
        -- Entradas para Controle_Refrigeracao
        TEMP_SENSOR         : in  STD_LOGIC_VECTOR(7 downto 0);
        LIMIAR_TEMPERATURA  : in  STD_LOGIC_VECTOR(7 downto 0);
        
        -- Entradas para Controle_Display
        LD_MSG              : in  STD_LOGIC;
        MSG_IN              : in  STD_LOGIC_VECTOR(15 downto 0);
        
        -- Saídas Gerais do Datapath
        CREDITO_OUT         : out STD_LOGIC_VECTOR(7 downto 0);
        PRODUTO_SELECIONADO_OUT : out STD_LOGIC_VECTOR(3 downto 0);
        TROCO               : out STD_LOGIC_VECTOR(7 downto 0);
        TROCO_PRONTO        : out STD_LOGIC;  -- Indica que o troco foi calculado e está disponível
        DISPENSAR           : out STD_LOGIC;  -- Indica que a dispensação de produto ocorreu
        STOCK_COUNT         : out STD_LOGIC_VECTOR(4 downto 0);  -- Quantidade atual no canal de estoque selecionado
        DISPLAY             : out STD_LOGIC_VECTOR(15 downto 0);
        REFRIGERACAO_ATIVA  : out STD_LOGIC
    );
end Datapath_MaquinaVendas;

architecture Structural of Datapath_MaquinaVendas is

    -- Sinais internos para interconectar os módulos
    signal credito_sig         : STD_LOGIC_VECTOR(7 downto 0);
    signal produto_sig         : STD_LOGIC_VECTOR(3 downto 0);
    signal troco_sig           : STD_LOGIC_VECTOR(7 downto 0);
    signal troco_pronto_sig    : STD_LOGIC;
    signal estoque_dispensar_sig : STD_LOGIC;
    signal stock_count_sig     : STD_LOGIC_VECTOR(4 downto 0);
    signal display_reg         : STD_LOGIC_VECTOR(15 downto 0);
    signal refrig_sig          : STD_LOGIC;
    
begin

    ------------------------------------------------------------------
    -- Instância do módulo Reg_Credito
    ------------------------------------------------------------------
    RegCredito_inst: entity work.Reg_Credito
        port map (
            CLK        => CLK,
            RESET      => RESET,
            ADD_COIN   => ADD_COIN,
            ADD_BILL   => ADD_BILL,
            CLEAR      => CLEAR_CREDITO,
            VALOR_COIN => VALOR_COIN,
            VALOR_BILL => VALOR_BILL,
            CREDITO    => credito_sig
        );
    CREDITO_OUT <= credito_sig;
    
    ------------------------------------------------------------------
    -- Instância do módulo Reg_Produto
    ------------------------------------------------------------------
    RegProduto_inst: entity work.Reg_Produto
        port map (
            CLK                 => CLK,
            RESET               => RESET,
            SEL_PRODUTO         => SEL_PRODUTO,
            PRODUTO             => PRODUTO,
            PRODUTO_SELECIONADO => produto_sig
        );
    PRODUTO_SELECIONADO_OUT <= produto_sig;
    
    ------------------------------------------------------------------
    -- Instância do módulo Troco
    ------------------------------------------------------------------
    Troco_inst: entity work.Troco
        port map (
            clk           => CLK,
            reset         => RESET,
            valor_total   => VALOR_TOTAL_COMPRA,
            valor_pago    => credito_sig,
            liberar_troco => LIBERAR_TROCO,
            troco         => troco_sig,
            troco_pronto  => troco_pronto_sig
        );
    TROCO        <= troco_sig;
    TROCO_PRONTO <= troco_pronto_sig;
    
    ------------------------------------------------------------------
    -- Instância do módulo Controle_Estoque
    ------------------------------------------------------------------
    ControleEstoque_inst: entity work.Controle_Estoque
        port map (
            CLK         => CLK,
            RESET       => RESET,
            DISPENSE    => DISPENSE,
            DRAWER_ID   => DRAWER_ID,
            CHANNEL_ID  => CHANNEL_ID,
            DISPENSAR   => estoque_dispensar_sig,
            STOCK_COUNT => stock_count_sig
        );
    DISPENSAR   <= estoque_dispensar_sig;
    STOCK_COUNT <= stock_count_sig;
    
    ------------------------------------------------------------------
    -- Instância do módulo Controle_Display
    ------------------------------------------------------------------
    ControleDisplay_inst: entity work.Controle_Display
        port map (
            CLK     => CLK,
            RESET   => RESET,
            LD_MSG  => LD_MSG,
            MSG_IN  => MSG_IN,
            DISPLAY => display_reg
        );
    DISPLAY <= display_reg;
    
    ------------------------------------------------------------------
    -- Instância do módulo Controle_Refrigeracao
    ------------------------------------------------------------------
    ControleRefrigeracao_inst: entity work.Controle_Refrigeracao
        port map (
            CLK                => CLK,
            RESET              => RESET,
            TEMP_SENSOR        => TEMP_SENSOR,
            LIMIAR_TEMPERATURA => LIMIAR_TEMPERATURA,
            REFRIGERACAO_ATIVA => refrig_sig
        );
    REFRIGERACAO_ATIVA <= refrig_sig;

end Structural;
