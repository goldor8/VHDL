library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_instructions_tb is
end mem_instructions_tb;

architecture mem_instructions_tb_arch of mem_instructions_tb is

    component alu_router is
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
    end component;

    component mem_instructions is
        generic (
            INSTR_WIDTH : integer := 10;
            MEM_DEPTH   : integer := 128
        );
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            instr_out   : out std_logic_vector(INSTR_WIDTH-1 downto 0)
        );
    end component;

    constant PERIOD_CLK : time := 10 ns;

    signal clk_sim, reset_sim : std_logic := '0';
    signal instr_sim : std_logic_vector(9 downto 0);

    signal SEL_FCT_sim   : std_logic_vector(3 downto 0);
    signal SEL_ROUTE_sim : std_logic_vector(3 downto 0);
    signal SEL_OUT_sim   : std_logic_vector(1 downto 0);

    signal A_IN_sim, B_IN_sim : std_logic_vector(3 downto 0);
    signal SR_IN_L_sim, SR_IN_R_sim : std_logic := '0';
    signal RES_OUT_sim : std_logic_vector(7 downto 0);
    signal SR_OUT_L_sim, SR_OUT_R_sim : std_logic;
begin

    ALU_ROUTER_INST : alu_router
        port map (
            clk => clk_sim,
            reset => reset_sim,
            SEL_FCT => SEL_FCT_sim,
            SEL_ROUTE => SEL_ROUTE_sim,
            SEL_OUT => SEL_OUT_sim,
            A_IN => A_IN_sim,
            B_IN => B_IN_sim,
            SR_IN_L => SR_IN_L_sim,
            SR_IN_R => SR_IN_R_sim,
            RES_OUT => RES_OUT_sim,
            SR_OUT_L => SR_OUT_L_sim,
            SR_OUT_R => SR_OUT_R_sim
        );

    MEM_INSTRUCTIONS_INST : mem_instructions
        port map (
            clk => clk_sim,
            rst => reset_sim,
            instr_out => instr_sim
        );
    

    -- ==========================================================================
    -- Génération de l'horloge
    -- ==========================================================================
    clk_process : process
    begin
        while now < 30 * PERIOD_CLK loop
            clk_sim <= '0'; wait for PERIOD_CLK/2;
            clk_sim <= '1'; wait for PERIOD_CLK/2;
        end loop;
        wait;
    end process;
    
    -- ==========================================================================
    -- Routage instructions -> signaux de contrôle
    -- ==========================================================================
    process(instr_sim)
    begin
        SEL_FCT_sim   <= instr_sim(9 downto 6);
        SEL_ROUTE_sim <= instr_sim(5 downto 2);
        SEL_OUT_sim   <= instr_sim(1 downto 0);
    end process;

    -- ==========================================================================
    -- Séquence de test
    -- ==========================================================================
    process
    begin
        reset_sim <= '1';
        wait for 1 ns;
        reset_sim <= '0';
        
        A_IN_sim <= "0011"; -- 3
        B_IN_sim <= "0010"; -- 2

        wait for 3 * PERIOD_CLK; -- wait for A * B instructions
        report "RES_OUT = " & integer'image(to_integer(unsigned(RES_OUT_sim)));
        assert RES_OUT_sim = std_logic_vector(to_unsigned(6,8))
            report "Erreur multiplication" severity failure;

        
        A_IN_sim <= "0101"; -- 5
        B_IN_sim <= "0011"; -- 3
        
        wait for 7 * PERIOD_CLK; -- wait for (A+B xnor A) instructions
        report "RES_OUT (A+B xnor A) = " & integer'image(to_integer(unsigned(RES_OUT_sim)));
        assert RES_OUT_sim = "00000010"
            report "Erreur A+B xnor A" severity error;
    
        
        A_IN_sim <= "0101"; -- 5
        B_IN_sim <= "0011"; -- 3

        wait for 12 * PERIOD_CLK; -- wait for (A0 and B1) or (A1 and B0) instructions
        report "RES_OUT (A0 and B1) or (A1 and B0) = " & std_logic'image(RES_OUT_sim(0));
        assert RES_OUT_sim(0) = '1'
            report "Erreur A0 and B1 or A1 and B0" severity error;

    
        wait;
    end process;

end mem_instructions_tb_arch;