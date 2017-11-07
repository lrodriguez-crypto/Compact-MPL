library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity PE is
	generic(
		       size : POSITIVE := 1024;   -- Tamano del operando
		       yk   : POSITIVE := 32;     -- Tamano del digito de y
		       xk   : POSITIVE := 32      -- Tamano del digito de x
	       );

	port(
		    clk : in std_logic;
		-------------------------------------------------- Entrada por arriba
		    Xj : in std_logic_vector(xk - 1 downto 0);
		    Aj : in std_logic_vector(xk - 1 downto 0);
		    Pj : in std_logic_vector(xk - 1 downto 0);
		-------------------------------------------------- Entrada encadenada del PE anterior
		    Yi : in std_logic_vector(yk - 1 downto 0);
		    qi : in std_logic_vector(yk - 1 downto 0);
		    cj : in std_logic_vector(xk downto 0);
		-------------------------------------------------- Resultados
		    cj_o : out std_logic_vector(xk  downto 0);
		    t6j_o : out std_logic_vector(xk - 1 downto 0);
		    xk_por_yi_mas_aj : out std_logic_vector(xk-1 downto 0)
	    );
end PE;

architecture behave_PE of PE is
	signal resultForQi : std_logic_vector(xk + yk downto 0);
begin
	xk_por_yi_mas_aj <= resultForQi(xk - 1 downto 0);

	PE_Proc: process (clk)
		variable sum3 : std_logic_vector(xk + yk downto 0);
	begin		
		if clk'event and clk = '1' then
			resultForQi <= ('0' & (Xj * Yi)) + Aj;
			sum3 := resultForQi + (Pj * qi) + cj;

			cj_o <= sum3(xk + yk downto xk);
			t6j_o <= sum3(xk -1 downto 0);
		end if;	
	end process;
end architecture behave_PE;
