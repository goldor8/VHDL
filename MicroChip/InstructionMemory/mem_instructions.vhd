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
        pc          : in  integer;
        instr_out   : out std_logic_vector(INSTR_WIDTH-1 downto 0)
    );
end entity;

architecture mem_instructions_arch of mem_instructions is
    type mem_type is array (0 to MEM_DEPTH-1) of std_logic_vector(INSTR_WIDTH-1 downto 0);
    signal memory : mem_type := (
        0 => "0000000000", --  A → Buffer_A
        1 => "1111011111", --  B → Buffer_B, Multiplier, sortie S

        -- (A+B) xnor A
        2 => "0000000000", --  A_IN → Buffer_A
        3 => "1101011100", --  B_IN → Buffer_B, A+B sans retenue
        4 => "0000111000", -- nop,  S → MEM_CACHE_1
        5 => "0111100000", -- A xor B, MEM_CACHE_1 → Buffer_B
        6 => "0000111100", -- NOP,  S → MEM_CACHE_2
        7 => "0011001111", -- not A, MEM_CACHE_2 → Buffer_A, sortie S

       -- (A0 and B1) or (A1 and B0)
        8 => "0000000000", -- A_IN → Buffer_A
        9 => "1010011100", -- B_IN → Buffer_B, right shift B
        10 => "0000111000", -- S → MEM_CACHE_1, NOP
        11 => "0101100000", -- MEM_CACHE_1 → Buffer_B, A and B
        12 => "0000111000", -- S → MEM_CACHE_1, NOP
        13 => "1000011100", -- B_IN → Buffer_B, right shift A,
        14 => "0000111100", -- S → MEM_CACHE_2, NOP
        15 => "0101000100", -- MEM_CACHE_2 → Buffer_A, A and B
        16 => "0000111100", -- S → MEM_CACHE_2, NOP
        17 => "0000000100", -- MEM_CACHE_1 → Buffer_A, NOP
        18 => "0110101011", -- MEM_CACHE_2 → Buffer_B, A OR B, sortie S
        others => (others => '0')
    );
begin

    instr_out <= memory(pc);

end architecture;
