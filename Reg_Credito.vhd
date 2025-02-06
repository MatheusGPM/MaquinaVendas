library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Reg_Credito is
    Port ( CLK, RESET, ADD_COIN, ADD_BILL, CLEAR : in STD_LOGIC;
           VALOR_COIN, VALOR_BILL : in STD_LOGIC_VECTOR(7 downto 0);
           CREDITO : out STD_LOGIC_VECTOR(7 downto 0));
end Reg_Credito;

architecture Behavioral of Reg_Credito is
    signal reg_value : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
    process (CLK, RESET)
    begin
        if RESET = '1' then
            reg_value <= (others => '0');
        elsif rising_edge(CLK) then
            if CLEAR = '1' then
                reg_value <= (others => '0');
            elsif ADD_COIN = '1' then
                reg_value <= reg_value + VALOR_COIN;
            elsif ADD_BILL = '1' then
                reg_value <= reg_value + VALOR_BILL;
            end if;
        end if;
    end process;
    CREDITO <= reg_value;
end Behavioral;