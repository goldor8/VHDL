library IEEE;
use IEEE.std_logic_1164.all;

entity Nbuffer is
    generic(
        N : integer := 8
    );
    port(
        clk : in std_logic;
        reset : in std_logic;
        buffer_in : in  std_logic_vector(N-1 downto 0);
        buffer_out : out std_logic_vector(N-1 downto 0);
        enable : in std_logic
    );
end entity;

architecture Nbuffer_arch of Nbuffer is
begin
    process(clk)
    begin
        if reset = '1' then
            buffer_out <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                buffer_out <= buffer_in;
            end if;
        end if;
    end process;
end architecture;
        

