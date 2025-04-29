library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity myET2testbenchExo is
end myET2testbenchExo;

architecture myET2testbench_Arch of myET2testbenchExo is
    component ET2
    port(
        e1 : in std_logic;
        e2 : in std_logic;
        s1 : out std_logic
    );
    end component;

    signal e1_sim, e2_sim : std_logic := '0';
    signal s1_sim : std_logic;
begin
    MyComponenteET2underTest : ET2
    port map(
        e1 => e1_sim,
        e2 => e2_sim,
        s1 => s1_sim
    );
    
    MyStimulusE1 : process
    begin
        e1_sim <= '0';
        wait for 50 us;
        e1_sim <= '1';
        wait for 50 us;
    end process;

    MyStimulusE2 : process
    begin
        e2_sim <= '0';
        wait for 100 us;
        e2_sim <= '1';
        wait;
    end process;

end myET2testbench_Arch;