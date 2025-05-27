library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

signal sel_route : std_logic_vector(3 downto 0);
signal data_bus  : std_logic_vector(7 downto 0);
signal a_out, b_out : std_logic_vector(7 downto 0);

-- shift-register-mem 
signal sr_l_internal : std_logic;
signal sr_r_internal : std_logic;

--mem_sel_fct
signal sel_fct_internal : std_logic_vector(3 downto 0);

-- MEM_Cache
signal sel_route_cache1 : std_logic_vector(1 downto 0);
signal sel_route_cache2 : std_logic_vector(1 downto 0);
signal A_IN_internal    : std_logic_vector(7 downto 0);
signal B_IN_internal    : std_logic_vector(7 downto 0);
signal alu_result       : std_logic_vector(7 downto 0);
signal cache1_out       : std_logic_vector(7 downto 0);
signal cache2_out       : std_logic_vector(7 downto 0);

-- mem_sel_out 
signal sel_out          : std_logic_vector(1 downto 0); -- donné par un automate ou instruction
signal sel_out_internal : std_logic_vector(1 downto 0); -- mémorisé

--mem_instructions
signal current_instruction : std_logic_vector(7 downto 0);





-- Buffer A
Buffer_A_inst : entity work.Buffer
    port map (
        clk       => clk,
        rst       => rst,
        sel_route => sel_route,
        buffer_id => "00",
        data_in   => data_bus,
        data_out  => a_out
    );

-- Buffer B
Buffer_B_inst : entity work.Buffer
    port map (
        clk       => clk,
        rst       => rst,
        sel_route => sel_route,
        buffer_id => "01",
        data_in   => data_bus,
        data_out  => b_out
    );

    -- Mémoire des shift registers (retenues)
Shift_Reg_Mem_inst : entity work.Shift_Register_Memory
    port map (
        clk      => clk,
        rst      => rst,
        sr_out_l => sr_out_l,      -- venant de l’ALU
        sr_out_r => sr_out_r,
        sr_in_l  => sr_l_internal, -- envoyé à l’ALU
        sr_in_r  => sr_r_internal
    );



MEM_SEL_FCT_inst : entity work.MEM_SEL_FCT
    port map (
        clk         => clk,
        rst         => rst,
        sel_fct_in  => sel_fct,          
        sel_fct_out => sel_fct_internal  -- envoyé à l’ALU
    );


-- MEM_CACHE_1
MEM_CACHE1_inst : entity work.MEM_CACHE
    port map (
        clk       => clk,
        rst       => rst,
        sel_route => sel_route_cache1,
        A_in      => A_IN_internal,
        B_in      => B_IN_internal,
        S_in      => alu_result,
        Q_out     => cache1_out
    );

-- MEM_CACHE_2
MEM_CACHE2_inst : entity work.MEM_CACHE
    port map (
        clk       => clk,
        rst       => rst,
        sel_route => sel_route_cache2,
        A_in      => A_IN_internal,
        B_in      => B_IN_internal,
        S_in      => alu_result,
        Q_out     => cache2_out
    );

--SEL_out memory
MEM_SEL_OUT_inst : entity work.MEM_SEL_OUT
    port map (
        clk         => clk,
        rst         => rst,
        sel_out_in  => sel_out,
        sel_out_out => sel_out_internal
    );


--mem_instructions 
INST_MEM : entity work.MEM_INSTRUCTIONS
    port map (
        clk       => clk,
        rst       => rst,
        instr_out => current_instruction
    );




entity Routeur is
    Port (
        clk            : in  std_logic;
        SEL_ROUTE      : in  std_logic_vector(3 downto 0);
        SEL_OUT      : in  std_logic_vector(1 downto 0);

        A_IN           : in  std_logic_vector(3 downto 0);
        B_IN           : in  std_logic_vector(3 downto 0);
        S              : in  std_logic_vector(7 downto 0);
        MEM_CACHE_1: in  std_logic_vector(7 downto 0);
        MEM_CACHE_2    : in  std_logic_vector(7 downto 0);

        buffer_a_out   : out std_logic_vector(3 downto 0);
        buffer_b_out   : out std_logic_vector(3 downto 0);
        MEM_CACHE_1_out: out std_logic_vector(7 downto 0);
        MEM_CACHE_2_out: out std_logic_vector(7 downto 0);
        RES_OUT      : out std_logic_vector(7 downto 0)
    );
end Routeur;

architecture Behavioral of Routeur is
    signal buffer_a_reg    : std_logic_vector(3 downto 0);
    signal buffer_b_reg    : std_logic_vector(3 downto 0);
    signal MEM_CACHE_1_reg : std_logic_vector(7 downto 0);
    signal MEM_CACHE_2_reg : std_logic_vector(7 downto 0);
begin

    buffer_a_out    <= buffer_a_reg;
    buffer_b_out    <= buffer_b_reg;
    MEM_CACHE_1_out <= MEM_CACHE_1_reg;
    MEM_CACHE_2_out <= MEM_CACHE_2_reg;

    process(SEL_ROUTE, A_IN, B_IN, S, MEM_CACHE_1, MEM_CACHE_2)
    begin
        case SEL_ROUTE is
                when "0000" =>  -- A_IN → Buffer_A
                    buffer_a_reg <= A_IN;

                  when "0001" =>  -- MEM_CACHE_1(3:0) → Buffer_A
                    buffer_a_reg <= MEM_CACHE_1(3 downto 0);

                when "0010" =>  -- MEM_CACHE_1(7:4) → Buffer_A
                    buffer_a_reg <= MEM_CACHE_1(7 downto 4);

                when "0011" =>  -- MEM_CACHE_2(3:0) → Buffer_A
                    buffer_a_reg <= MEM_CACHE_2(3 downto 0);

                when "0100" =>  -- MEM_CACHE_2(7:4) → Buffer_A
                    buffer_a_reg <= MEM_CACHE_2(7 downto 4);

                when "0101" =>  -- S(3:0) → Buffer_A
                    buffer_a_reg <= S(3 downto 0);

                when "0110" =>  -- S(7:4) → Buffer_A
                    buffer_a_reg <= S(7 downto 4);

                when "0111" =>  -- B_IN → Buffer_B
                    buffer_b_reg <= B_IN;

                when "1000" =>  -- MEM_CACHE_1(3:0) → Buffer_B
                    buffer_b_reg <= MEM_CACHE_1(3 downto 0);

                when "1001" =>  -- MEM_CACHE_1(7:4) → Buffer_B
                    buffer_b_reg <= MEM_CACHE_1(7 downto 4);

                when "1010" =>  -- MEM_CACHE_2(3:0) → Buffer_B
                    buffer_b_reg <= MEM_CACHE_2(3 downto 0);

                when "1011" =>  -- MEM_CACHE_2(7:4) → Buffer_B
                    buffer_b_reg <= MEM_CACHE_2(7 downto 4);

                when "1100" =>  -- S(3:0) → Buffer_B
                    buffer_b_reg <= S(3 downto 0);

                when "1101" =>  -- S(7:4) → Buffer_B
                    buffer_b_reg <= S(7 downto 4);

                when "1110" =>  -- S → MEM_CACHE_1
                    MEM_CACHE_1_reg <= S;

                when "1111" =>  -- S → MEM_CACHE_2
                    MEM_CACHE_2_reg <= S;

                when others =>
                    null;
            end case;
    end process;

    process(SEL_OUT, MEM_CACHE_1, MEM_CACHE_2, S)
    begin
        case SEL_OUT is
            when "00" =>  -- Aucune sortie
                RES_OUT <= (others => '0');

            when "01" =>  -- RES_OUT = MEM_CACHE_1
                RES_OUT <= MEM_CACHE_1;

            when "10" =>  -- RES_OUT = MEM_CACHE_2
                RES_OUT <= MEM_CACHE_2;

            when "11" =>  -- RES_OUT = S
                RES_OUT <= S;

            when others =>
                RES_OUT <= (others => '0');
        end case;
    end process;

end Behavioral;
