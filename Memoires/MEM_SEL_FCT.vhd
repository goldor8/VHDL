library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_SEL_FCT is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        sel_fct_in  : in  std_logic_vector(3 downto 0);
        sel_fct_out : out std_logic_vector(3 downto 0)
    );
end entity;

architecture Behavioral of MEM_SEL_FCT is
    signal sel_fct_reg : std_logic_vector(3 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sel_fct_reg <= (others => '0');
            else
                sel_fct_reg <= sel_fct_in;
            end if;
        end if;
    end process;

    sel_fct_out <= sel_fct_reg;
end architecture;
