-- Single-Port Block RAM Read-First Mode
-- rams_01.vhd
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------------------------------------------------------
--Para el log2
use IEEE.math_real.ceil;
use IEEE.math_real.log2;
--constant size_addr : integer := integer(ceil(log2(real(size/ xk ))));
----------------------------------------------------------------------------------------------------


entity rams_01 is
    generic( 
             width: positive;
             addrSize: positive);

    port (clk : in std_logic;
          we	: in std_logic;
          addr : in std_logic_vector(addrSize-1 downto 0);
          di	: in std_logic_vector(width-1 downto 0);
          do	: out std_logic_vector(width-1 downto 0));
end rams_01;

architecture syn of rams_01 is
    type ram_type is array ( 2**addrSize - 1 downto 0) of std_logic_vector (width-1 downto 0); 
    signal RAM: ram_type := (others => (others => '0'));


    signal do_1 : std_logic_vector(width-1 downto 0); 
begin

    process (clk)
    begin
        if clk'event and clk = '1' then
            if we = '1' then
                RAM(conv_integer(addr)) <= di;
            end if;
            do_1 <= RAM(conv_integer(addr)) ;
        end if;
    end process;


    process(clk)
    begin     
        if(clk'event and clk='1')then
            do <= do_1;
        end if;
    end process; 
end syn;
