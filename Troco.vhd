library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Troco is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        valor_total : in  STD_LOGIC_VECTOR (7 downto 0); -- Valor total da compra
        valor_pago  : in  STD_LOGIC_VECTOR (7 downto 0); -- Valor inserido pelo cliente
        liberar_troco : in  STD_LOGIC; -- Sinal para liberar troco
        troco       : out STD_LOGIC_VECTOR (7 downto 0); -- Valor do troco calculado
        troco_pronto : out STD_LOGIC  -- Indica que o troco foi calculado e liberado
    );
end Troco;

architecture Behavioral of Troco is
    signal troco_interno : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal troco_calculado : STD_LOGIC := '0';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            troco_interno <= (others => '0');
            troco_calculado <= '0';
        elsif rising_edge(clk) then
            if liberar_troco = '1' then
                if valor_pago >= valor_total then
                    troco_interno <= valor_pago - valor_total;
                    troco_calculado <= '1';
                else
                    troco_interno <= (others => '0');
                    troco_calculado <= '0';
                end if;
            end if;
        end if;
    end process;

    troco <= troco_interno;
    troco_pronto <= troco_calculado;

end Behavioral;
