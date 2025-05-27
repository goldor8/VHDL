library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MEM_INSTRUCTIONS is
    generic (
        INSTR_WIDTH : integer := 8;
        MEM_DEPTH   : integer := 16
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        instr_out   : out std_logic_vector(INSTR_WIDTH-1 downto 0)
    );
end entity;

architecture Behavioral of MEM_INSTRUCTIONS is
    type mem_type is array (0 to MEM_DEPTH-1) of std_logic_vector(INSTR_WIDTH-1 downto 0);
    signal memory : mem_type := (
        0  => "00000001",
        1  => "00000010",
        2  => "00000011",
        3  => "00000100",
        others => (others => '0')
    );
    signal pc : integer range 0 to MEM_DEPTH-1 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc <= 0;
            else
                pc <= (pc + 1) mod MEM_DEPTH;
            end if;
        end if;
    end process;

    instr_out <= memory(pc);

end architecture;
