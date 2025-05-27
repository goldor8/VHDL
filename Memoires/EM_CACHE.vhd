library IEEE;
use IEEE.std_logic_1164.all;

entity MEM_CACHE is
    port(
        clk : in std_logic;
        rst        : in  std_logic;
        sel_route  : in  std_logic_vector(1 downto 0);
        A_in       : in  std_logic_vector(7 downto 0);
        B_in       : in  std_logic_vector(7 downto 0);
        S_in       : in  std_logic_vector(7 downto 0);
        Q_out      : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of MEM_CACHE is
    signal reg_data : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_data <= (others => '0');
            else
                case sel_route is
                    when "01" => reg_data <= A_in;
                    when "10" => reg_data <= B_in;
                    when "11" => reg_data <= S_in;
                    when others => -- "00"
                        reg_data <= reg_data;
                end case;
            end if;
        end if;
    end process;

    Q_out <= reg_data;
end architecture;
        

