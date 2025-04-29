library IEEE;
use IEEE.std_logic_1164.all;

entity synthcomb is
generic ( N : integer := 4 );
port (
    -- A compléter par les étudiants
    e1 : in std_logic_vector (N-1 downto 0);
    e2 : in std_logic_vector (N-1 downto 0);
    c_in : in std_logic;
    
    sel : in std_logic;

    s1 : out std_logic_vector (2*N-1 downto 0)
);
end synthcomb;

architecture synthcomb_arch of synthcomb is

	-- Déclaration du composant -> renvoie vers l'entité MultNbits (multiplieur) !
	component multiplyNbits is
        -- A compléter par les étudiants
        generic (
            N : integer
        );
        port (
            e1 : in std_logic_vector (N-1 downto 0);
            e2 : in std_logic_vector (N-1 downto 0);
            s1 : out std_logic_vector (2*N-1 downto 0)
        );
    end component;
    
    -- Déclaration d'un signal interne à raccorder à la sortie du multiplieur
    signal My_mult_s1 : std_logic_vector (2*N-1 downto 0);
    
    -- Déclaration du composant -> renvoie vers l'entité addNbits (additionneur) !
    component addNbits is
        -- A compléter par les étudiants
        generic (
            N : integer
        );
        port (
            e1 : in std_logic_vector (N-1 downto 0);
            e2 : in std_logic_vector (N-1 downto 0);
            c_in : in std_logic;
            s1 : out std_logic_vector (N-1 downto 0);
            c_out : out std_logic
        );
    end component;

    -- Déclaration de signaux internes à raccorder aux sorties de l'additionneur
	signal My_c_out : std_logic;
    signal My_add_s1 : std_logic_vector (N-1 downto 0);
    
    -- Déclaration du composant -> renvoie vers l'entité muxNbits2vers1 (multiplexeur) !
	component muxNbits2vers1 is
        -- A compléter par les étudiants
        generic (
            N : integer := 4
        );
        port (
            e1 : in std_logic_vector (N-1 downto 0);
            e2 : in std_logic_vector (N-1 downto 0);
            sel : in std_logic;
            s1 : out std_logic_vector (N-1 downto 0)
        );
    end component;    
    
    -- Déclaration de signaux internes à raccorder aux deux entrées du multiplexeur
	signal My_mux_e1 : std_logic_vector (2*N-1 downto 0) := (others => '0');
    signal My_mux_e2 : std_logic_vector (2*N-1 downto 0) := (others => '0');

begin


	-- Instanciation du composant de l'additionneur 
    MyComponentAddNbits : addNbits
    --raccordement des ports du composant aux signaux dans l'architecture
    generic map ( N => N )
    port map ( 	
        -- A compléter par les étudiants
        e1 => e1,
        e2 => e2,
        c_in => c_in,
        s1 => My_add_s1,
        c_out => My_c_out
    );

    -- Instanciation du composant du multiplieur 
    MyComponentMultNbits : multiplyNbits
    --raccordement des ports du composant aux signaux dans l'architecture
    generic map ( N => N )
    port map ( 	
        -- A compléter par les étudiants
        e1 => e1,
        e2 => e2,

        s1 => My_mult_s1
    );
    
        -- Instanciation du composant du multiplexeur 
    MyComponentmuxNbits2vers1 : muxNbits2vers1
    --raccordement des ports du composant aux signaux dans l'architecture
    generic map ( N => 2*N )
    port map ( 	
        -- A compléter par les étudiants
        e1 => My_mux_e1,
        e2 => My_mux_e2,

        sel => sel,

        s1 => s1
    );
                
	-- Gestion des entrées du multiplexeur
    My_mux_e2 <= My_mult_s1;
    My_mux_e1(N-1 downto 0) <= My_add_s1;
    My_mux_e1(N) <= My_c_out;
    My_mux_e1(2*N-1 downto N+1) <= (others=>'0');
    
end synthcomb_arch;
