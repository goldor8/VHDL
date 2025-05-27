library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_SEL_OUT is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        sel_out_in  : in  std_logic_vector(1 downto 0); -- largeur adaptable
        sel_out_out : out std_logic_vector(1 downto 0)
    );
end entity;

architecture Behavioral of MEM_SEL_OUT is
    signal sel_out_reg : std_logic_vector(1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sel_out_reg <= (others => '0');
            else
                sel_out_reg <= sel_out_in;
            end if;
        end if;
    end process;

    sel_out_out <= sel_out_reg;
end architecture;
