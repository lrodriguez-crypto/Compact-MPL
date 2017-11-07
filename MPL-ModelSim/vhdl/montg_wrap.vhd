library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;

--Para lectura de archivos
library std;
use std.textio.all; 

----------------------------------------------------------------------------------------------------
--Para el log2
use IEEE.math_real.ceil;
use IEEE.math_real.log2;
--constant size_addr : integer := integer(ceil(log2(real(size/ xk ))));
----------------------------------------------------------------------------------------------------

entity montg_wrap is
	generic(
	size : positive := 1024;
	xk   : positive := 16;
    addrSize : positive := 6
);

port(
        clk : in std_logic;
        rst : in std_logic;
        -------------------------------------------------- Señales del control
        bram_x_addr : out std_logic_vector(addrSize-1 downto 0);
        bram_y_addr : out std_logic_vector(addrSize-1 downto 0);
        bram_p_addr : out std_logic_vector(addrSize-1 downto 0);
        ----
        bram_r_a_we   : out std_logic;
        bram_r_a_addr : out std_logic_vector(addrSize-1 downto 0);
        --
        bram_r_b_we   : out std_logic;
        bram_r_b_addr : out std_logic_vector(addrSize-1 downto 0); 
        ----
        done     : out std_logic;
        -------------------------------------------------- Señales para el PE
        --------- bram_x_do, bram_r_b_do, bram_p_do, bram_y_do, qi, cj, cj_o, t6j, sj
        -------------------------------------------------- Entrada por arriba
        bram_x_do   : in std_logic_vector(xk - 1 downto 0);                        --Xj    : in std_logic_vector(xk - 1 downto 0);
        bram_r_b_do : in std_logic_vector(xk - 1 downto 0);                        --Aj    : in std_logic_vector(xk - 1 downto 0);
        ---------------------- mult 2
        bram_x_do_2   : in std_logic_vector(xk - 1 downto 0);                        --Xj    : in std_logic_vector(xk - 1 downto 0);
        bram_r_b_do_2 : in std_logic_vector(xk - 1 downto 0);                        --Aj    : in std_logic_vector(xk - 1 downto 0);
        ----------------------
        bram_p_do   : in std_logic_vector(xk - 1 downto 0);                        --Pj    : in std_logic_vector(xk - 1 downto 0);
        ---------------------------------------------------- Entrada encadenada del PE anterior
        bram_y_do   : in std_logic_vector(xk - 1 downto 0);                        --Yi    : in std_logic_vector(yk - 1 downto 0);
        --qi    : in std_logic_vector(yk - 1 downto 0);
        --cj    : in std_logic_vector(xk downto 0);
        ---------------------------------------------------- Resultados
        --cj_o  : out std_logic_vector(xk  downto 0);
        --t6j_o : out std_logic_vector(xk - 1 downto 0);
        --xk_por_yi_mas_aj : out std_logic_vector(xk-1 downto 0)
        -------------------------------------------------------
        pPrima      : in std_logic_vector(xk-1 downto 0); 
        bram_r_a_di : out std_logic_vector(xk-1 downto 0);
        bram_r_a_di_2 : out std_logic_vector(xk-1 downto 0);
        rst_mem     : out std_logic
    );
end montg_wrap;

architecture behave_montg_wrap of montg_wrap is

	signal qi : std_logic_vector(xk-1 downto 0);
	signal load_qi : std_logic;
	signal sj : std_logic_vector(xk - 1 downto 0);
	signal t6j : std_logic_vector(xk - 1 downto 0);
	signal write_c : std_logic;
	signal t_temp : std_logic_vector(2*xk downto 0);

	signal cj : std_logic_vector(xk downto 0);
	signal cj_reg : std_logic_vector(xk downto 0);
	signal cj_o : std_logic_vector(xk downto 0);
	signal reset_cj : std_logic;
	signal write_cj : std_logic;

   	signal qi_2 : std_logic_vector(xk-1 downto 0);
	signal sj_2 : std_logic_vector(xk - 1 downto 0);
	signal t6j_2 : std_logic_vector(xk - 1 downto 0);
	signal t_temp_2 : std_logic_vector(2*xk downto 0);

	signal cj_2 : std_logic_vector(xk downto 0);
	signal cj_reg_2 : std_logic_vector(xk downto 0);
	signal cj_o_2 : std_logic_vector(xk downto 0);
begin

    CONTROL : entity work.control generic map(size, xk, addrSize) 
    port map(
                clk , rst ,
                bram_x_addr,
                bram_y_addr,
                bram_p_addr,
                bram_r_a_we , bram_r_a_addr,
                bram_r_b_we,  bram_r_b_addr,
                done,
                reset_cj,
                load_qi,
                write_cj,
                rst_mem
            ); 
    
    ---------------------------------------------------------------------------------------------------- Multiplicador 1
    PE :   entity work.pe      generic map(size, xk, xk ) port map(clk, bram_x_do, bram_r_b_do, bram_p_do, bram_y_do, qi, cj, cj_o, t6j, sj); 

    cj <= (others => '0') when reset_cj = '1' else cj_o;
    bram_r_a_di <= cj_reg(xk - 1 downto 0) when write_cj = '1' else t6j;

    process(clk)
        variable qi_temp : std_logic_vector(2*xk - 1 downto 0); 
    begin
        if clk'event and clk='1' then
            if (load_qi = '1') then
                qi_temp := sj(xk - 1 downto 0) * pPrima;
                qi <= qi_temp(xk - 1 downto 0);
            end if;
        end if;
    end process;

    process(clk)
    begin
        if clk'event and clk='1' then
            cj_reg <= cj_o;
        end if;
    end process;

    ---------------------------------------------------------------------------------------------------- Multiplicador 2
    PE2 :   entity work.pe      generic map(size, xk, xk ) port map(clk, bram_x_do_2, bram_r_b_do_2, bram_p_do, bram_y_do, qi_2, cj_2, cj_o_2, t6j_2, sj_2); 

    cj_2 <= (others => '0') when reset_cj = '1' else cj_o_2;
    bram_r_a_di_2 <= cj_reg_2(xk - 1 downto 0) when write_cj = '1' else t6j_2;

    process(clk)
        variable qi_temp_2 : std_logic_vector(2*xk - 1 downto 0); 
    begin
        if clk'event and clk='1' then
            if (load_qi = '1') then
                qi_temp_2 := sj_2(xk - 1 downto 0) * pPrima;
                qi_2 <= qi_temp_2(xk - 1 downto 0);
            end if;
        end if;
    end process;

    process(clk)
    begin
        if clk'event and clk='1' then
            cj_reg_2 <= cj_o_2;
        end if;
    end process;
end;
