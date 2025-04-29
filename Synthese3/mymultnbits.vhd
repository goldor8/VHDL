library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity multiplyNbits is
generic (
    N : integer
);
port (
    e1 : in std_logic_vector (N-1 downto 0);
    e2 : in std_logic_vector (N-1 downto 0);
    s1 : out std_logic_vector (2*N-1 downto 0)
);
end multiplyNbits;

architecture multiplyNbits_DataFlow of multiplyNbits is

begin
    s1 <= e1 * e2;

end multiplyNbits_DataFlow;