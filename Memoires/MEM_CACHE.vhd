library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_CACHE is
    port(
        clk : in std_logic;
        cache_in       : in  std_logic_vector(7 downto 0);
        cache_out      : out std_logic_vector(7 downto 0);
        enable : in std_logic
    );
end entity;

architecture Behavioral of MEM_CACHE is
    -- signal cache_data : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                -- Si l'écriture est activée, on met à jour le cache
                cache_out <= cache_in;
            end if;
        end if;
    end process;

    -- cache_out <= cache_data;
end architecture;
        

