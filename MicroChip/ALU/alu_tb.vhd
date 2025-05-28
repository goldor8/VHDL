library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

entity alu_tb is
end alu_tb;

architecture alutb_arch of alu_tb is
    -- Déclaration du composant à tester
    component ALU is
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

    -- Déclaration de la constante pour la période de l'horloge
    constant PERIOD : time := 50 ns;

    -- Déclaration des signaux internes à l'architecture pour réaliser les simulations
    signal a_sim, b_sim, sel_fct_sim : std_logic_vector(3 downto 0) := (others => '0');
    signal sr_in_l_sim, sr_in_r_sim, sr_out_l_sim, sr_out_r_sim : std_logic := '0';
    signal s_sim : std_logic_vector(7 downto 0) := (others => '0');

begin
    
    MyALU : alu
    port map(
        a => a_sim,
        b => b_sim,
        sel_fct => sel_fct_sim,
        sr_in_l => sr_in_l_sim,
        sr_in_r => sr_in_r_sim,
        sr_out_l => sr_out_l_sim,
        sr_out_r => sr_out_r_sim,
        s => s_sim
    );

    My_tb_Proc : process
    begin
        sr_in_l_sim <= '0';
        sr_in_r_sim <= '0';

        a_sim <= "0001"; -- a = 1
        b_sim <= "0010"; -- b = 2
        sel_fct_sim <= "0000"; -- no op
        wait for PERIOD;
        assert (s_sim = "00000000" and sr_out_l_sim = '0' and sr_out_r_sim = '0') report "Test 1 failed" severity failure;

        a_sim <= "0001"; -- a = 1
        b_sim <= "0010"; -- b = 2
        sel_fct_sim <= "1101"; -- a + b
        wait for PERIOD;
        assert (s_sim = "00000011" and sr_out_l_sim = '0' and sr_out_r_sim = '0') report "Test 2 failed, found : " & integer'image(to_integer(signed(s_sim))) & ", " & to_string(s_sim) severity failure;

        report "All tests passed";

        wait; -- Wait for the end of the simulation
    end process My_tb_Proc;
end architecture;


