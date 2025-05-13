signal sel_route : std_logic_vector(1 downto 0);
signal data_bus  : std_logic_vector(7 downto 0);
signal a_out, b_out : std_logic_vector(7 downto 0);

-- shift-register-mem 
signal sr_l_internal : std_logic;
signal sr_r_internal : std_logic;

--mem_sel_fct
signal sel_fct_internal : std_logic_vector(3 downto 0);



-- Buffer A
Buffer_A_inst : entity work.Buffer
    port map (
        clk       => clk,
        rst       => rst,
        sel_route => sel_route,
        buffer_id => "00",
        data_in   => data_bus,
        data_out  => a_out
    );

-- Buffer B
Buffer_B_inst : entity work.Buffer
    port map (
        clk       => clk,
        rst       => rst,
        sel_route => sel_route,
        buffer_id => "01",
        data_in   => data_bus,
        data_out  => b_out
    );

    -- Mémoire des shift registers (retenues)
Shift_Reg_Mem_inst : entity work.Shift_Register_Memory
    port map (
        clk      => clk,
        rst      => rst,
        sr_out_l => sr_out_l,      -- venant de l’ALU
        sr_out_r => sr_out_r,
        sr_in_l  => sr_l_internal, -- envoyé à l’ALU
        sr_in_r  => sr_r_internal
    );



MEM_SEL_FCT_inst : entity work.MEM_SEL_FCT
    port map (
        clk         => clk,
        rst         => rst,
        sel_fct_in  => sel_fct,          -- donné par l’extérieur ou un automate
        sel_fct_out => sel_fct_internal  -- envoyé à l’ALU
    );
