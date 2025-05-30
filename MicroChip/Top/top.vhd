library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MCU_PRJ_2021_TopLevel is
    Port (
        CLK100MHZ : in STD_LOGIC;
        sw : in STD_LOGIC_VECTOR(3 downto 0);
        btn : in STD_LOGIC_VECTOR(3 downto 0);
        led : out STD_LOGIC_VECTOR(3 downto 0);
        led0_r : out STD_LOGIC; led0_g : out STD_LOGIC; led0_b : out STD_LOGIC;                
        led1_r : out STD_LOGIC; led1_g : out STD_LOGIC; led1_b : out STD_LOGIC;
        led2_r : out STD_LOGIC; led2_g : out STD_LOGIC; led2_b : out STD_LOGIC;                
        led3_r : out STD_LOGIC; led3_g : out STD_LOGIC; led3_b : out STD_LOGIC
    );
end MCU_PRJ_2021_TopLevel;

architecture MCU_PRJ_2021_TopLevel_Arch of MCU_PRJ_2021_TopLevel is
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

    signal enable_result_mem : std_logic := '0';
    signal result_buffer_out : std_logic_vector(7 downto 0);

    type state is (IDLE, FUNC1, FUNC2, FUNC3);
    signal current_state: state := IDLE;
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

    MEM_RESULT : raiseNbuffer
        generic map (
            N => 8
        )
        port map (
            clk => clk_sim,
            reset => reset_sim,
            buffer_in => RES_OUT_sim,
            buffer_out => result_buffer_out,
            enable => enable_result_mem
        );

    led(3 downto 0) <= result_buffer_out(7 downto 4);
    led3_r <= result_buffer_out(3);
    led2_r <= result_buffer_out(2);
    led1_r <= result_buffer_out(1);
    led0_r <= result_buffer_out(0);

    reset_sim <= btn(0);
    clk_sim <= CLK100MHZ;
    
    process(instr_sim)
    begin
        SEL_FCT_sim   <= instr_sim(9 downto 6);
        SEL_ROUTE_sim <= instr_sim(5 downto 2);
        SEL_OUT_sim   <= instr_sim(1 downto 0);
    end process;
    
    
    process
    begin
        if reset_sim = '1' then
            current_state <= IDLE;
        else
            case current_state is
                when IDLE =>
                    if btn(1) = '1' then
                        current_state <= FUNC1;
                    elsif btn(2) then
                        current_state <= FUNC2;
                    elsif btn(3) then
                        current_state <= FUNC3;
                    end if;
                when FUNC1 =>
                    wait for 1 * PERIOD_CLK;
                    enable_result_mem <= '1';
                    wait for PERIOD_CLK;
                    enable_result_mem <= '0';
                    current_state <= IDLE; -- Return to IDLE after FUNC1

                when FUNC2 =>
                    wait for 5 * PERIOD_CLK;
                    enable_result_mem <= '1';
                    wait for PERIOD_CLK;
                    enable_result_mem <= '0';
                    current_state <= IDLE; -- Return to IDLE after FUNC1

                when FUNC3 =>
                    wait for 10 * PERIOD_CLK;
                    enable_result_mem <= '1';
                    wait for PERIOD_CLK;
                    enable_result_mem <= '0';
                    current_state <= IDLE; -- Return to IDLE after FUNC1
                when others =>
                    current_state <= IDLE;
            end case;
        end if;
    end process;
end architecture;