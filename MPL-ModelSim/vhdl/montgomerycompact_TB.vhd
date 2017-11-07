library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

--Para lectura de archivos

library ieee,std;
use std.textio.all; 

entity montgomerycompact_tb is
	generic(  	 	
		       size: positive := 1024 ;  -- iterations = size/k
		       xk: positive := 16
	       );
end montgomerycompact_tb;

architecture TB_ARCHITECTURE of montgomerycompact_tb is

	signal X : std_logic_vector(xk-1 downto 0);
	signal Exp : std_logic_vector(xk-1 downto 0);
	signal P : std_logic_vector(xk-1 downto 0);
	signal Uno : std_logic_vector(xk-1 downto 0);
	signal pPrima : std_logic_vector(xk-1 downto 0);
	signal clk : std_logic := '0';
	signal rst : std_logic;

	-- Observed signals - signals mapped to the output ports of tested entity
	signal done : std_logic;
	signal R : std_logic_vector(xk-1 downto 0);
begin

	MM : entity work.montgomerycompact_wrap
	generic map (size, xk ) 
	port map (X, Exp, P, Uno, pPrima, clk, rst, done, R);


	clk <= NOT clk after 5 NS when 1 < 2 ELSE '0';
	rst <= '1' after 0 NS, '0' after 20 ns;

	--Nota.- Los datos de entrada son insertados con un script tcl, el cual va poniendo los valores correctos en las señales de entrada!  
end TB_ARCHITECTURE;
