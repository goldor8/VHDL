library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_instructions is
    generic (
        INSTR_WIDTH : integer := 10;
        MEM_DEPTH   : integer := 128
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        instr_out   : out std_logic_vector(INSTR_WIDTH-1 downto 0)
    );
end entity;

architecture mem_instructions_arch of mem_instructions is
    type mem_type is array (0 to MEM_DEPTH-1) of std_logic_vector(INSTR_WIDTH-1 downto 0);
    signal memory : mem_type := (
        0 => "0000000000", --  A → Buffer_A
        1 => "0000011100", --  B → Buffer_B 
        2 => "1111000011", -- Multiplier et sortir S

        -- (A+B) xnor A
        3 => "0000000000", --  A_IN → Buffer_A
        4 => "0000011100", --  B_IN → Buffer_B
        5 => "1101111000", -- A+B sans retenue,  S → MEM_CACHE_1
        6 => "0000100000", -- NOP, MEM_CACHE_1 → Buffer_B
        7 => "0111111100", -- A xor B,  S → MEM_CACHE_2
        8 => "0000001100", -- NOP, MEM_CACHE_2 → Buffer_A
        9 => "0011000011", -- not A (A=Buffer_A), sortie S

       -- (A0 and B1) or (A1 and B0)

        10 => "0000000000", --  A_IN → Buffer_A
        11 => "0000011100", --  B_IN → Buffer_B
        12 => "1010111000", -- right shift B,  S → MEM_CACHE_1
        13 => "0000100000", -- NOP, MEM_CACHE_1 → Buffer_B
        14 => "0101111000", -- A and B,  S → MEM_CACHE_1
        15 => "0000011100", --  B_IN → Buffer_B
        16 => "1000111100", -- right shift A,  S → MEM_CACHE_2
        17 => "0000000100", -- NOP, MEM_CACHE_2 → Buffer_A
        18 => "0101111100", -- A and B,  S → MEM_CACHE_2
        19 => "0000000100", -- NOP, MEM_CACHE_1 → Buffer_A
        20 => "0000101000", -- NOP, MEM_CACHE_2 → Buffer_B
        21 => "0110000011", -- A OR B, sortie S
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
