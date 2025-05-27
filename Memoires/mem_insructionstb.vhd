library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_instructions_tb is
end mem_instructions_tb;

architecture mem_instructions_tb_arch of mem_instructions_tb is

    -- ==========================================================================
    -- Déclaration des signaux de simulation
    -- ==========================================================================
    signal clk_sim, reset_sim : std_logic := '0';
    signal addr_sim : unsigned(6 downto 0) := (others => '0');
    signal instr_sim : std_logic_vector(9 downto 0);

    signal RES_OUT_sim : std_logic_vector(7 downto 0);

    -- Signaux pour les buffers 8 bits
    signal MEM_CACHE_1_in_sim, MEM_CACHE_2_in_sim : std_logic_vector(7 downto 0) := (others => '0');
    signal MEM_CACHE_1_out_sim, MEM_CACHE_2_out_sim : std_logic_vector(7 downto 0);
    signal MEM_CACHE_1_enable_sim, MEM_CACHE_2_enable_sim : std_logic := '0';

    -- Buffers 4 bits
    signal Buffer_A_sim, Buffer_B_sim : std_logic_vector(3 downto 0);
    signal Buffer_A_enable_sim, Buffer_B_enable_sim : std_logic := '0';
    signal bufferA_out, bufferB_out : std_logic_vector(3 downto 0);
    signal SR_IN_L_sim, SR_IN_R_sim : std_logic:= '0';

    signal SEL_FCT_sim   : std_logic_vector(3 downto 0);
    signal SEL_ROUTE_sim : std_logic_vector(3 downto 0);
    signal SEL_OUT_sim   : std_logic_vector(1 downto 0);

    -- Registres
    signal SEL_FCT_reg   : std_logic_vector(3 downto 0);
    signal SEL_ROUTE_reg : std_logic_vector(3 downto 0);
    signal SEL_OUT_reg   : std_logic_vector(1 downto 0);
    signal SR_IN_L_reg, SR_IN_R_reg : std_logic;

    -- UAL
    signal S_sim : std_logic_vector(7 downto 0);
    signal SR_OUT_L_sim, SR_OUT_R_sim : std_logic;

    signal SR_OUT_L_vec, SR_OUT_R_vec : std_logic_vector(0 downto 0);
    signal SR_IN_L_vec, SR_IN_R_vec   : std_logic_vector(0 downto 0);

    -- Interconnexion
    signal A_IN_sim, B_IN_sim : std_logic_vector(3 downto 0) := (others => '0');

    signal ready_sim : std_logic;

    -- ==========================================================================
    -- Déclaration des composants
    -- ==========================================================================
    component MEM_INSTRUCTIONS
        port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            instruction : in  unsigned(6 downto 0);
            donnee     : out std_logic_vector(9 downto 0)
        );
    end component;

    component ALU
        port(
            A        : in  std_logic_vector(3 downto 0);
            B        : in  std_logic_vector(3 downto 0);
            SR_IN_L  : in  std_logic;
            SR_IN_R  : in  std_logic;
            SEL_FCT  : in  std_logic_vector(3 downto 0);
            SR_OUT_L : out std_logic;
            SR_OUT_R : out std_logic;
            S        : out std_logic_vector(7 downto 0)
        );
    end component;

    component Routeur
        port(
            SEL_ROUTE : in std_logic_vector(3 downto 0);
            A_IN      : in std_logic_vector(3 downto 0);
            B_IN      : in std_logic_vector(3 downto 0);
            S         : in std_logic_vector(7 downto 0);
            MEM_CACHE_1: in std_logic_vector(7 downto 0);
            MEM_CACHE_1_out_enable : out std_logic;
            MEM_CACHE_1_out : out std_logic_vector(7 downto 0);
            MEM_CACHE_2 : in std_logic_vector(7 downto 0);
            MEM_CACHE_2_out_enable : out std_logic;
            MEM_CACHE_2_out : out std_logic_vector(7 downto 0);
            Buffer_A  : out std_logic_vector(3 downto 0);
            Buffer_A_enable : out std_logic;
            Buffer_B  : out std_logic_vector(3 downto 0);
            Buffer_B_enable : out std_logic;
            SEL_OUT : in std_logic_vector(1 downto 0);
            RES_OUT : out std_logic_vector(7 downto 0);
            ready   : out std_logic
        );
    end component;

    component Buffer is
        generic (
            N : integer := 4  
        );
        port (
            e1 : in std_logic_vector (N-1 downto 0);
            reset : in std_logic;
            clock : in std_logic;
            enable : in std_logic;
            s1 : out std_logic_vector (N-1 downto 0)
        );
    end  component; 
    -------------------------------------------------------------------------------

begin
    -- ==========================================================================
    -- Instanciation des buffers et mémoires
    -- ==========================================================================

    -- Buffer A
    buffer_A_inst : buffer_ual
        generic map (N => 4)
        port map (
            e1 => Buffer_A_sim,
            reset => reset_sim,
            clock => clk_sim,
            enable => Buffer_A_enable_sim,
            s1 => bufferA_out
        );
    -- Buffer B
    buffer_B_inst : buffer_ual
        generic map (N => 4)
        port map (
            e1 => Buffer_B_sim,
            reset => reset_sim,
            clock => clk_sim,
            enable => Buffer_B_enable_sim,
            s1 => bufferB_out
        );
    -- Mémoire cache 1
    mem_cache_1_inst : buffer_ual
        generic map (N => 8)
        port map (
            e1     => MEM_CACHE_1_in_sim,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => MEM_CACHE_1_enable_sim,
            s1     => MEM_CACHE_1_out_sim
        );
    -- Mémoire cache 2
    mem_cache_2_inst : buffer_ual
        generic map (N => 8)
        port map (
            e1     => MEM_CACHE_2_in_sim,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => MEM_CACHE_2_enable_sim,
            s1     => MEM_CACHE_2_out_sim
        );

    -- ==========================================================================
    -- Buffers de commande (pour signaux de contrôle)
    -- ==========================================================================
    buffer_cmd_fct : buffer_ual
        generic map (N => 4)
        port map (
            e1     => SEL_FCT_sim,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => '1',
            s1     => SEL_FCT_reg
        );

    buffer_cmd_route : buffer_ual
        generic map (N => 4)
        port map (
            e1     => SEL_ROUTE_sim,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => '1',
            s1     => SEL_ROUTE_reg
        );

    buffer_cmd_out : buffer_ual
        generic map (N => 2)
        port map (
            e1     => SEL_OUT_sim,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => '1',
            s1     => SEL_OUT_reg
        );

    -- ==========================================================================
    -- Buffers pour les retenues (SR_IN_L / SR_IN_R)
    -- ==========================================================================
    buffer_sr_in_l : buffer_ual
        generic map (N => 1)
        port map (
            e1     => SR_OUT_L_vec,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => '1',
            s1     => SR_IN_L_vec
        );

    buffer_sr_in_r : buffer_ual
        generic map (N => 1)
        port map (
            e1     => SR_OUT_R_vec,
            reset  => reset_sim,
            clock  => clk_sim,
            enable => '1',
            s1     => SR_IN_R_vec
        );

    -- ==========================================================================
    -- UAL
    -- ==========================================================================
    alu_inst : hearth_ual
        port map (
            A        => bufferA_out,
            B        => bufferB_out,
            SR_IN_L  => SR_IN_L_vec(0),
            SR_IN_R  => SR_IN_R_vec(0),
            SEL_FCT  => SEL_FCT_reg,
            SR_OUT_L => SR_OUT_L_sim,
            SR_OUT_R => SR_OUT_R_sim,
            S        => S_sim
        );

    -- ==========================================================================
    -- Mémoire d'instructions
    -- ==========================================================================
    mem_inst : mem_instructions
        port map (
            clk        => clk_sim,
            reset      => reset_sim,
            instruction=> addr_sim,
            donnee     => instr_sim
        );

    -- ==========================================================================
    -- Interconnexion
    -- ==========================================================================
    interco_inst : interconnexion
        port map (
            SEL_ROUTE              => SEL_ROUTE_reg,
            A_IN                   => A_IN_sim,
            B_IN                   => B_IN_sim,
            S                      => S_sim,
            MEM_CACHE_1_in         => MEM_CACHE_1_out_sim,
            MEM_CACHE_1_out_enable => MEM_CACHE_1_enable_sim,
            MEM_CACHE_1_out        => MEM_CACHE_1_in_sim,
            MEM_CACHE_2_in         => MEM_CACHE_2_out_sim,
            MEM_CACHE_2_out_enable => MEM_CACHE_2_enable_sim,
            MEM_CACHE_2_out        => MEM_CACHE_2_in_sim,
            Buffer_A               => Buffer_A_sim,
            Buffer_A_enable        => Buffer_A_enable_sim,
            Buffer_B               => Buffer_B_sim,
            Buffer_B_enable        => Buffer_B_enable_sim,
            SEL_OUT                => SEL_OUT_reg,
            RES_OUT                => RES_OUT_sim,
            ready   => ready_sim
        );

    -- ==========================================================================
    -- Génération de l'horloge
    -- ==========================================================================
    clk_process : process
    begin
        while now < 300 ns loop
            clk_sim <= '0'; wait for 5 ns;
            clk_sim <= '1'; wait for 5 ns;
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
        reset_sim <= '1'; wait for 10 ns;
        reset_sim <= '0'; wait for 10 ns;

        -- Charger A et B via les entrées de l'interconnexion
        A_IN_sim <= "0011"; -- 3
        B_IN_sim <= "0010"; -- 2

        -- cycle 0 : charger A
        addr_sim <= to_unsigned(0,7); wait until rising_edge(clk_sim);
        -- cycle 1 : charger B
        addr_sim <= to_unsigned(1,7); wait until rising_edge(clk_sim);
        -- cycle 2 : multiplier
        addr_sim <= to_unsigned(2,7); wait until rising_edge(clk_sim);
        -- Attendre que le résultat soit prêt
        wait until ready_sim = '1';
        report "RES_OUT = " & integer'image(to_integer(unsigned(RES_OUT_sim)));
        assert RES_OUT_sim = std_logic_vector(to_unsigned(6,8))
            report "Erreur multiplication" severity error;
        wait for 10 ns;

        -- (A+B) xnor A
        -- Exemple : A = 5 ("0101"), B = 3 ("0011")
        reset_sim <= '1'; wait for 10 ns;
        reset_sim <= '0'; wait for 10 ns;
        A_IN_sim <= "0101"; -- 5
        B_IN_sim <= "0011"; -- 3
        
        addr_sim <= to_unsigned(3,7); wait until rising_edge(clk_sim);
        addr_sim <= to_unsigned(4,7); wait until rising_edge(clk_sim); 
        addr_sim <= to_unsigned(5,7); wait until rising_edge(clk_sim); 
        addr_sim <= to_unsigned(6,7); wait until rising_edge(clk_sim); 
        addr_sim <= to_unsigned(7,7); wait until rising_edge(clk_sim); 
        addr_sim <= to_unsigned(8,7); wait until rising_edge(clk_sim);
        addr_sim <= to_unsigned(9,7); wait until rising_edge(clk_sim);
        wait until ready_sim = '1';
        wait for 2 ns;
        report "RES_OUT (A+B xnor A) = " & integer'image(to_integer(unsigned(RES_OUT_sim)));
    
        -- RES_OUT_3 = (A0 and B1) or (A1 and B0) (RES_OUT_3 sur le bit de poids faible)
        reset_sim <= '1'; wait for 10 ns;
        reset_sim <= '0'; wait for 10 ns;
        A_IN_sim <= "0101"; -- 5
        B_IN_sim <= "0011"; -- 3
        addr_sim <= to_unsigned(10,7); wait until rising_edge(clk_sim);
        addr_sim <= to_unsigned(11,7); wait until rising_edge(clk_sim);
        addr_sim <= to_unsigned(12,7); wait until rising_edge(clk_sim);
        addr_sim <= to_unsigned(13,7); wait until rising_edge(clk_sim);
        addr_sim <= to_unsigned(14,7); wait until rising_edge(clk_sim);
        addr_sim <= to_unsigned(15,7); wait until rising_edge(clk_sim);
        addr_sim <= to_unsigned(16,7); wait until rising_edge(clk_sim);
        wait until ready_sim = '1';
        wait for 2 ns;
        report "RES_OUT (A0 and B1) or (A1 and B0) = " & integer'image(to_integer(unsigned(RES_OUT_sim)));
    
        wait;
    end process;

    -- ==========================================================================
    -- Conversion des signaux SR_OUT_L/SR_OUT_R en vecteurs pour les buffers
    -- ==========================================================================
    SR_OUT_L_vec(0) <= SR_OUT_L_sim;
    SR_OUT_R_vec(0) <= SR_OUT_R_sim;

end mem_instructions_tb_arch;