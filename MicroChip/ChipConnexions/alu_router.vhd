library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_router is
    Port (
        clk            : in  std_logic;
        reset          : in  std_logic;

        SEL_FCT      : in  std_logic_vector(3 downto 0);
        SEL_ROUTE      : in  std_logic_vector(3 downto 0);
        SEL_OUT      : in  std_logic_vector(1 downto 0);

        A_IN           : in  std_logic_vector(3 downto 0);
        B_IN           : in  std_logic_vector(3 downto 0);

        SR_IN_L      : in  std_logic;
        SR_IN_R      : in  std_logic;
        
        RES_OUT        : out std_logic_vector(7 downto 0);

        SR_OUT_L     : out std_logic;
        SR_OUT_R     : out std_logic
    );
end alu_router;

architecture alu_router_arch of alu_router is
    component alu is
        port(
            a : in std_logic_vector(3 downto 0);
            b : in std_logic_vector(3 downto 0);
            sel_fct : in std_logic_vector(3 downto 0);
            sr_in_l : in std_logic;
            sr_in_r : in std_logic;
            sr_out_l : out std_logic;
            sr_out_r : out std_logic;
            s : out std_logic_vector(7 downto 0)
        );
    end component;

    component Nbuffer is
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
    end component;

    signal mem_cache1_in, mem_cache1_out, mem_cache2_in, mem_cache2_out : std_logic_vector(7 downto 0);
    signal cache_1_enable, cache_2_enable : std_logic;

    signal buffer_a_in, buffer_b_in, buffer_a_out, buffer_b_out : std_logic_vector(3 downto 0);
    signal buffer_a_enable, buffer_b_enable : std_logic;

    signal sr_buffer_out_l, sr_buffer_out_r : std_logic_vector(0 downto 0);

    signal alu_out : std_logic_vector(7 downto 0);

    signal alu_sel_fct : std_logic_vector(3 downto 0);
    signal sel_out_mem : std_logic_vector(1 downto 0);
begin
    BUFFER_A : Nbuffer
    generic map(
        N => 4
    )
    port map(
        clk => clk,
        reset => reset,
        buffer_in => buffer_a_in,
        buffer_out => buffer_a_out,
        enable => buffer_a_enable
    );

    BUFFER_B : Nbuffer
    generic map(
        N => 4
    )
    port map(
        clk => clk,
        reset => reset,
        buffer_in => buffer_b_in,
        buffer_out => buffer_b_out,
        enable => buffer_b_enable
    );

    MEM_CACHE_1 : Nbuffer
    generic map(
        N => 8
    )
    port map(
        clk => clk,
        reset => reset,
        buffer_in => mem_cache1_in,
        buffer_out => mem_cache1_out,
        enable => cache_1_enable
    );

    MEM_CACHE_2 : Nbuffer
    generic map(
        N => 8
    )
    port map(
        clk => clk,
        reset => reset,
        buffer_in => mem_cache2_in,
        buffer_out => mem_cache2_out,
        enable => cache_2_enable
    );

    SR_IN_L_BUFFER : Nbuffer
    generic map(
        N => 1
    )
    port map(
        clk => clk,
        reset => reset,
        buffer_in => (0 => SR_IN_L),
        buffer_out => sr_buffer_out_l,
        enable => '1'  -- Always enabled for SR_IN_L
    );

    SR_IN_R_BUFFER : Nbuffer
    generic map(
        N => 1
    )
    port map(
        clk => clk,
        reset => reset,
        buffer_in => (0 => SR_IN_R),
        buffer_out => sr_buffer_out_r,
        enable => '1'  -- Always enabled for SR_IN_R
    );

    ALU_INST : alu
    port map(
        a => buffer_a_out,
        b => buffer_b_out,
        sel_fct => alu_sel_fct,
        sr_in_l => sr_buffer_out_l(0),
        sr_in_r => sr_buffer_out_r(0),
        sr_out_l => SR_OUT_L,
        sr_out_r => SR_OUT_R,
        s => alu_out
    );

    MEM_SEL_FCT : Nbuffer
    generic map(
        N => 4
    )
    port map(
        clk => clk,
        reset => reset,
        buffer_in => SEL_FCT,
        buffer_out => alu_sel_fct,
        enable => '1'  -- Always enabled for function selection
    );

    MEM_SEL_OUT : Nbuffer
    generic map(
        N => 2
    )
    port map(
        clk => clk,
        reset => reset,
        buffer_in => SEL_OUT,
        buffer_out => sel_out_mem,
        enable => '1'  -- Always enabled for output selection
    );

    process(SEL_ROUTE, A_IN, B_IN, alu_out, mem_cache1_out, mem_cache2_out)
    begin
        cache_1_enable <= '0';
        cache_2_enable <= '0';
        buffer_a_enable <= '0';
        buffer_b_enable <= '0';
        buffer_a_in <= (others => '0');
        buffer_b_in <= (others => '0');
        mem_cache1_in <= (others => '0');
        mem_cache2_in <= (others => '0');

        case SEL_ROUTE is
                when "0000" =>  -- A_IN → Buffer_A
                    buffer_a_enable <= '1';
                    buffer_a_in <= A_IN;

                when "0001" =>  -- MEM_CACHE_1(3:0) → Buffer_A
                    buffer_a_enable <= '1';
                    buffer_a_in <= mem_cache1_out(3 downto 0);

                when "0010" =>  -- MEM_CACHE_1(7:4) → Buffer_A
                    buffer_a_enable <= '1';
                    buffer_a_in <= mem_cache1_out(7 downto 4);

                when "0011" =>  -- MEM_CACHE_2(3:0) → Buffer_A
                    buffer_a_enable <= '1';
                    buffer_a_in <= mem_cache2_out(3 downto 0);

                when "0100" =>  -- MEM_CACHE_2(7:4) → Buffer_A
                    buffer_a_enable <= '1';
                    buffer_a_in <= mem_cache2_out(7 downto 4);

                when "0101" =>  -- S(3:0) → Buffer_A
                    buffer_a_enable <= '1';
                    buffer_a_in <= alu_out(3 downto 0);

                when "0110" =>  -- S(7:4) → Buffer_A
                    buffer_a_enable <= '1';
                    buffer_a_in <= alu_out(7 downto 4);

                when "0111" =>  -- B_IN → Buffer_B
                    buffer_b_enable <= '1';
                    buffer_b_in <= B_IN;

                when "1000" =>  -- MEM_CACHE_1(3:0) → Buffer_B
                    buffer_b_enable <= '1';
                    buffer_b_in <= mem_cache1_out(3 downto 0);

                when "1001" =>  -- MEM_CACHE_1(7:4) → Buffer_B
                    buffer_b_enable <= '1';
                    buffer_b_in <= mem_cache1_out(7 downto 4);

                when "1010" =>  -- MEM_CACHE_2(3:0) → Buffer_B
                    buffer_b_enable <= '1';
                    buffer_b_in <= mem_cache2_out(3 downto 0);

                when "1011" =>  -- MEM_CACHE_2(7:4) → Buffer_B
                    buffer_b_enable <= '1';
                    buffer_b_in <= mem_cache2_out(7 downto 4);

                when "1100" =>  -- S(3:0) → Buffer_B
                    buffer_b_enable <= '1';
                    buffer_b_in <= alu_out(3 downto 0);

                when "1101" =>  -- S(7:4) → Buffer_B
                    buffer_b_enable <= '1';
                    buffer_b_in <= alu_out(7 downto 4);

                when "1110" =>  -- S → MEM_CACHE_1
                    cache_1_enable <= '1';
                    mem_cache1_in <= alu_out;

                when "1111" =>  -- S → MEM_CACHE_2
                    cache_2_enable <= '1';
                    mem_cache2_in <= alu_out;

                when others =>
                    null;
            end case;
    end process;

    process(sel_out_mem, mem_cache1_out, mem_cache2_out, alu_out)
    begin
        case sel_out_mem is
            when "00" =>  -- Aucune sortie
                RES_OUT <= (others => '0');

            when "01" =>  -- RES_OUT = MEM_CACHE_1
                RES_OUT <= mem_cache1_out;

            when "10" =>  -- RES_OUT = MEM_CACHE_2
                RES_OUT <= mem_cache2_out;

            when "11" =>  -- RES_OUT = S
                RES_OUT <= alu_out;

            when others =>
                RES_OUT <= (others => '0');
        end case;
    end process;

end architecture;
