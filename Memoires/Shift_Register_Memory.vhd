library IEEE;
use IEEE.std_logic_1164.all;

entity Shift_Register_Memory is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        sr_out_l   : in  std_logic;
        sr_out_r   : in  std_logic;
        sr_in_l    : out std_logic;
        sr_in_r    : out std_logic
    );
end entity;

architecture Behavioral of Shift_Register_Memory is
    signal reg_l : std_logic := '0';
    signal reg_r : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                reg_l <= '0';
                reg_r <= '0';
            else
                reg_l <= sr_out_l;
                reg_r <= sr_out_r;
            end if;
        end if;
    end process;

    sr_in_l <= reg_l;
    sr_in_r <= reg_r;
end architecture;
