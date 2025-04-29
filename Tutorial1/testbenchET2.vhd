library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity myET2testbench is
end myET2testbench;

architecture myET2testbench_Arch of myET2testbench is
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
    
    MyStimulus : process
    begin
        e1_sim <= '0';
        e2_sim <= '0';
        wait for 100 us;
        assert s1_sim=(e1_sim and e2_sim) report "e1_sim = " & std_logic'image(e1_sim) & " | e2_sim = " & std_logic'image(e2_sim) & " | s1_sim = " & std_logic'image(s1_sim) severity failure;
        e1_sim <= '0';
        e2_sim <= '1';
        wait for 100 us;
        assert s1_sim=(e1_sim and e2_sim) report "e1_sim = " & std_logic'image(e1_sim) & " | e2_sim = " & std_logic'image(e2_sim) & " | s1_sim = " & std_logic'image(s1_sim) severity failure;
        e1_sim <= '1';
        e2_sim <= '0';
        wait for 100 us;
        assert s1_sim=(e1_sim and e2_sim) report "e1_sim = " & std_logic'image(e1_sim) & " | e2_sim = " & std_logic'image(e2_sim) & " | s1_sim = " & std_logic'image(s1_sim) severity failure;
        e1_sim <= '1';
        e2_sim <= '1';
        wait for 100 us;
        assert s1_sim=(e1_sim xor e2_sim) report "e1_sim = " & std_logic'image(e1_sim) & " | e2_sim = " & std_logic'image(e2_sim) & " | s1_sim = " & std_logic'image(s1_sim) severity failure;
        
        report "Test ok (no assertion fail)";
        
        wait;

    end process;

end myET2testbench_Arch;