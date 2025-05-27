library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

entity MEM_CACHE_TB is
end MEM_CACHE_TB;

architecture MEM_CACHE_TB_arch of MEM_CACHE_TB is
    -- Déclaration du composant à tester
    component MEM_CACHE is
        port(
            clk : in std_logic;
            cache_in       : in  std_logic_vector(7 downto 0);
            cache_out      : out std_logic_vector(7 downto 0);
            enable : in std_logic
        );
    end component;

    -- Déclaration de la constante pour la période de l'horloge
    constant PERIOD : time := 50 ns;

    -- Déclaration des signaux internes à l'architecture pour réaliser les simulations
    signal clk_sim, enable_sim : std_logic := '0';
    signal cache_in_sim, cache_out_sim, s_sim : std_logic_vector(7 downto 0) := (others => '0');

begin
    
    MyCache : MEM_CACHE
    port map(
        clk => clk_sim,
        cache_in => cache_in_sim,
        cache_out => cache_out_sim,
        enable => enable_sim
    );

    My_tb_Proc : process
    begin
        s_sim <= "00000001";
        enable_sim <= '1'; -- Activer l'écriture dans le cache
        cache_in_sim <= s_sim; -- Initialiser le cache avec 1
        
        wait for PERIOD;

        enable_sim <= '0'; -- Désactiver l'écriture pour les prochaines opérations
        s_sim <= "00000010";
        assert (cache_out_sim = "00000001") report "Test 1 failed cache out value : (" & integer'image(to_integer(unsigned(cache_out_sim))) & ")"  severity error; -- Vérifier que le cache contient 1

        enable_sim <= '1'; -- Réactiver l'écriture dans le cache
        cache_in_sim <= s_sim; -- Mettre à jour le cache avec 2
        wait for PERIOD;

        enable_sim <= '0'; -- Désactiver l'écriture pour les prochaines opérations
        s_sim <= "00000011";
        assert (cache_out_sim = "00000010") report "Test 2 failed cache out value : (" & integer'image(to_integer(unsigned(cache_out_sim))) & ")" severity error; -- Vérifier que le cache contient 2


    end process My_tb_Proc;


    clock : process
    begin
        clk_sim <= '0';
        wait for PERIOD / 2;
        clk_sim <= '1';
        wait for PERIOD / 2;
    end process;
end MEM_CACHE_TB_arch;


