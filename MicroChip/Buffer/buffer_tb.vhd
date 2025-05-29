library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

entity buffer_tb is
end buffer_tb;

architecture buffer_tb_arch of buffer_tb is
    -- Déclaration du composant à tester
    component raiseNbuffer is
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

    -- Déclaration de la constante pour la période de l'horloge
    constant PERIOD : time := 50 ns;

    -- Déclaration des signaux internes à l'architecture pour réaliser les simulations
    signal clk_sim, enable_sim, reset_sim : std_logic := '0';
    signal buffer_in_sim, buffer_out_sim : std_logic_vector(7 downto 0) := (others => '0');

begin
    
    MyCache : raiseNbuffer
    generic map(
        N => 8
    )
    port map(
        clk => clk_sim,
        reset => reset_sim,
        buffer_in => buffer_in_sim,
        buffer_out => buffer_out_sim,
        enable => enable_sim
    );

    My_tb_Proc : process
    begin
        enable_sim <= '1'; -- Activer l'écriture dans le cache
        buffer_in_sim <= "00000001"; -- Initialiser le cache avec 1
        
        wait for PERIOD;

        enable_sim <= '0'; -- Désactiver l'écriture pour les prochaines opérations
        assert (buffer_out_sim = "00000001") report "Test 1 failed cache out value : (" & integer'image(to_integer(unsigned(buffer_out_sim))) & ")"  severity failure; -- Vérifier que le cache contient 1

        enable_sim <= '1'; -- Réactiver l'écriture dans le cache
        buffer_in_sim <= "00000010"; -- Mettre à jour le cache avec 2
        wait for PERIOD;

        enable_sim <= '0'; -- Désactiver l'écriture pour les prochaines opérations
        assert (buffer_out_sim = "00000010") report "Test 2 failed cache out value : (" & integer'image(to_integer(unsigned(buffer_out_sim))) & ")" severity failure; -- Vérifier que le cache contient 2

        reset_sim <= '1'; -- Réinitialiser le buffer
        wait for PERIOD;

        reset_sim <= '0'; -- Désactiver la réinitialisation
        assert (buffer_out_sim = "00000000") report "Test 3 failed after reset, buffer out value : (" & integer'image(to_integer(unsigned(buffer_out_sim))) & ")" severity failure; -- Vérifier que le buffer est réinitialisé à 0
        
        report "All tests passed";
        wait;
    end process My_tb_Proc;


    clock : process
    begin
        for i in 0 to 10 loop
            clk_sim <= '0';
            wait for PERIOD / 2;
            clk_sim <= '1';
            wait for PERIOD / 2;
        end loop;
        wait;
    end process;
end architecture;


