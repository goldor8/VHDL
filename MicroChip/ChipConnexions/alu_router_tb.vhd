library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_router_tb is
end alu_router_tb;

architecture alu_router_tb_arch of alu_router_tb is
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

    signal clk : std_logic := '0';
    signal reset : std_logic := '1';

    signal SEL_FCT : std_logic_vector(3 downto 0) := "0000";
    signal SEL_ROUTE : std_logic_vector(3 downto 0) := "0000";
    signal SEL_OUT : std_logic_vector(1 downto 0) := "00";

    signal A_IN : std_logic_vector(3 downto 0) := "0000";
    signal B_IN : std_logic_vector(3 downto 0) := "0000";

    signal SR_IN_L : std_logic := '0';
    signal SR_IN_R : std_logic := '0';

    signal RES_OUT : std_logic_vector(7 downto 0);
    
    signal SR_OUT_L : std_logic;
    signal SR_OUT_R : std_logic;

    signal running : boolean := true;
begin
    ALU_ROUTER_INST : alu_router
        port map (
            clk => clk,
            reset => reset,
            SEL_FCT => SEL_FCT,
            SEL_ROUTE => SEL_ROUTE,
            SEL_OUT => SEL_OUT,
            A_IN => A_IN,
            B_IN => B_IN,
            SR_IN_L => SR_IN_L,
            SR_IN_R => SR_IN_R,
            RES_OUT => RES_OUT,
            SR_OUT_L => SR_OUT_L,
            SR_OUT_R => SR_OUT_R
        );
    
    clk_process : process
    begin
        if not running then
            wait; -- Stop the clock process if running is false
        end if;
        
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    stimulus_process : process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        
        -- Test case 1: ALU operation a + b
        SEL_FCT <= "0000"; -- no op
        A_IN <= "0001"; -- a = 1
        SEL_ROUTE <= "0000"; -- store A_IN to buffer_a
        SEL_OUT <= "00"; -- output nothing
        wait for 20 ns;

        SEL_FCT <= "1101"; -- addition
        B_IN <= "0010"; -- b = 2
        SEL_ROUTE <= "0111"; -- store B_IN to buffer_b
        SEL_OUT <= "11"; -- output alu result
        wait for 20 ns;

        assert RES_OUT = "00000011" report "Test case 1 failed: Expected 3, got " & integer'image(to_integer(unsigned(RES_OUT))) severity failure;
        
        report "All tests passed";

        running <= false; -- Stop the clock process
        wait;
    end process stimulus_process;
end architecture;