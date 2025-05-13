-- Code your design here
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Buffer is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        sel_route : in  std_logic_vector(1 downto 0); -- 2 bits de sélection
        buffer_id : in  std_logic_vector(1 downto 0); -- Identifiant du buffer (ex : "00" pour A, "01" pour B)
        data_in   : in  std_logic_vector(7 downto 0);
        data_out  : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of Buffer is
    signal reg : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg <= (others => '0');
            elsif sel_route = buffer_id then
                reg <= data_in;
            end if;
        end if;
    end process;

    data_out <= reg;
end architecture;

