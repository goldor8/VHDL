library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

entity alu is
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
end alu;

architecture alu_arch of alu is
begin
    ual_process : process(a, b, sel_fct, sr_in_l, sr_in_r)
        variable a_var, b_var, c_in_var : std_logic_vector(7 downto 0);
    begin
        case sel_fct is
            when "0000" => -- no op
                s <= (7 downto 0 => '0');
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "0001" => -- a
                s <= (7 downto 4 => '0') & a;
                sr_out_l <= sr_in_l;
                sr_out_r <= sr_in_r;
            when "0010" => -- b
                s <= (7 downto 4 => '0') & b;
                sr_out_l <= sr_in_l;
                sr_out_r <= sr_in_r;
            when "0011" => -- not a
                s <= (7 downto 4 => '0') & not a;
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "0100" => -- not b
                s <= (7 downto 4 => '0') & not b;
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "0101" => -- a and b
                s <= (7 downto 4 => '0') & (a and b);
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "0110" => -- a or b
                s <= (7 downto 4 => '0') & (a or b);
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "0111" => -- a xor b
                s <= (7 downto 4 => '0') & (a xor b);
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "1000" => -- right shift a with sr_in_l
                s <= (7 downto 4 => '0') & sr_in_l & a(3 downto 1);
                sr_out_l <= '0';
                sr_out_r <= a(0);
            when "1001" => -- left shift a with sr_in_r
                s <= (7 downto 4 => '0') & a(2 downto 0) & sr_in_r;
                sr_out_l <= a(3);
                sr_out_r <= '0';
            when "1010" => -- right shift b with sr_in_l
                s <= (7 downto 4 => '0') & sr_in_l & b(3 downto 1);
                sr_out_l <= '0';
                sr_out_r <= b(0);
            when "1011" => -- left shift b with sr_in_r
                s <= (7 downto 4 => '0') & b(2 downto 0) & sr_in_r;
                sr_out_l <= b(3);
                sr_out_r <= '0';
            when "1100" => -- a + b with carry in from sr_in_r
                a_var := (7 downto 4 => a(3)) & a;
                b_var := (7 downto 4 => b(3)) & b;
                c_in_var := (7 downto 1 => '0') & sr_in_r;
                s <= a_var + b_var + c_in_var;
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "1101" => -- a + b without carry
                a_var := (7 downto 4 => a(3)) & a;
                b_var := (7 downto 4 => b(3)) & b;
                s <= a_var + b_var;
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "1110" => -- a - b
                a_var := (7 downto 4 => a(3)) & a;
                b_var := (7 downto 4 => b(3)) & b;
                s <= a_var - b_var;
                sr_out_l <= '0';
                sr_out_r <= '0';
            when "1111" => -- a * b
                s <= a * b;
                sr_out_l <= '0';
                sr_out_r <= '0';
            when others =>
                s <= (others => '0');
                sr_out_l <= '0';
                sr_out_r <= '0';
        end case;
    end process ual_process;
end architecture;
                
                     