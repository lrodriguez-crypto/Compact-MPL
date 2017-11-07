-- Dual-Port Block RAM with Two Write Ports
-- Correct Modelization with a Shared Variable
-- File: rams_16b.vhd

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity rams_16b is
    generic( width: positive;
    addrSize: positive);

    port(clka : in std_logic;
         clkb : in std_logic;
         rsta	: in std_logic;
         rstb	: in std_logic;
         wea	: in std_logic;
         web	: in std_logic;
         addra : in std_logic_vector(addrSize - 1 downto 0);
         addrb : in std_logic_vector(addrSize - 1 downto 0);
         dia	: in std_logic_vector(width - 1 downto 0);
         dib	: in std_logic_vector(width - 1 downto 0);
         doa	: out std_logic_vector(width - 1 downto 0);
         dob	: out std_logic_vector(width - 1 downto 0));
end rams_16b;

architecture syn of rams_16b is
    type ram_type is array (2**addrSize - 1 downto 0) of std_logic_vector(width - 1 downto 0);

    signal doa_1 : std_logic_vector(width - 1 downto 0);
    signal dob_1 : std_logic_vector(width - 1 downto 0);


    shared variable RAM : ram_type := (others => (others => '0'));
begin

    process (CLKA)
    begin
        if CLKA'event and CLKA = '1' then
            if rsta = '1' then
                doa_1 <= (others => '0');
            else
                doa_1 <= RAM(conv_integer(ADDRA));
            end if; 
            if WEA = '1' then
                RAM(conv_integer(ADDRA)) := DIA;
            end if;
        end if;
    end process;

    process(CLKA)
    begin
        if CLKA'event and CLKA = '1' then
            doa <= doa_1;
        end if;
    end process; 


    ----------------------------------------------------------------------------------------------------

    process (CLKB)
    begin
        if CLKB'event and CLKB = '1' then
            
            if rstb = '1' then
                dob_1 <= (others => '0');
            else
                dob_1 <= RAM(conv_integer(ADDRB)); 
            end if; 

            if WEB = '1' then
                RAM(conv_integer(ADDRB)) := DIB;
            end if;
        end if;
    end process;

    process(CLKB)
    begin
        if CLKB'event and CLKB = '1' then
            dob <= dob_1;
        end if;
    end process; 
end syn;
