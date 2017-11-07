library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--Para el log2
use IEEE.math_real.ceil;
use IEEE.math_real.log2;
----------------------------------------------------------------------------------------------------
entity montgomerycompact_wrap is
    generic(
    size : positive := 1024;        -- iterations = size/k
    xk   : positive := 16
);
port(
        X      : in  std_logic_vector(xk - 1 downto 0);
        Exp    : in  std_logic_vector(xk - 1 downto 0);
        P      : in  std_logic_vector(xk - 1 downto 0);
        Uno    : in  std_logic_vector(xk - 1 downto 0);
        pPrima : in  std_logic_vector(xk - 1 downto 0);
        clk    : in  std_logic;
        rst    : in  std_logic;
        done   : out std_logic;
        R   : out std_logic_vector(xk - 1 downto 0)
    );
end entity;


architecture behave_montgomerycompact_wrap of montgomerycompact_wrap is

    type CurrentState_type is (ENDFSM, Esperar ,LlenarBram, Multiplicando, NextMult, t1 ,t2 ,t3 ,t4 ,t5 ,t6, EsperarQi, Sig_QI, ForInterno, EsperarN); 
    signal CurrentState : CurrentState_type;

    constant addrSize  : POSITIVE := integer(ceil(log2(real(size / xk)))); -- Numero de bits para (size/xk)
    constant addrKSize  : POSITIVE := integer(ceil(log2(real(xk)))); -- Numero de bits para (size/xk)
    --constant size_addr : integer  := integer(ceil(log2(real(size/ xk ))));

    constant bitsSize  : POSITIVE := integer(ceil(log2(real(size)))); -- Numero de bits para (size/xk)

    --------------------------------------------------------------------BramP
    signal bram_p_we	 :std_logic;
    signal bram_p_addr   :std_logic_vector(addrSize - 1 downto 0);
    signal bram_p_din    :std_logic_vector(xk - 1 downto 0);
    signal bram_p_dout   :std_logic_vector(xk - 1 downto 0);
    --------------------------------------------------------------------BramExp
    signal bram_exp_we	   :std_logic;
    signal bram_exp_addr   :std_logic_vector(addrSize - 1 downto 0);
    signal bram_exp_addr_temp :std_logic_vector(addrSize - 1 downto 0);
    signal bram_exp_din    :std_logic_vector(xk - 1 downto 0);
    signal bram_exp_dout   :std_logic_vector(xk - 1 downto 0);
    ---------------------------------------------------------------------------

    --Señales para las memorias R0, R1, R00, R11 
    --------------------------------------------------------------------R0
    signal a_R0_wr    : std_logic;
    signal a_R0_addr  : std_logic_vector(addrSize - 1 downto 0);
    signal a_R0_din   : std_logic_vector(xk - 1 downto 0);
    signal a_R0_dout  : std_logic_vector(xk - 1 downto 0);

    signal b_R0_wr   : std_logic;
    signal b_R0_rst  : std_logic;
    signal b_R0_addr : std_logic_vector(addrSize - 1 downto 0);
    signal b_R0_din  : std_logic_vector(xk - 1 downto 0);
    signal b_R0_dout : std_logic_vector(xk - 1 downto 0);
    --------------------------------------------------------------------

    --------------------------------------------------------------------R1
    signal a_R1_wr   : std_logic;
    signal a_R1_addr : std_logic_vector(addrSize - 1 downto 0);
    signal a_R1_din  : std_logic_vector(xk - 1 downto 0);
    signal a_R1_dout : std_logic_vector(xk - 1 downto 0);

    signal b_R1_wr   : std_logic;
    signal b_R1_rst  : std_logic;
    signal b_R1_addr : std_logic_vector(addrSize - 1 downto 0);
    signal b_R1_din  : std_logic_vector(xk - 1 downto 0);
    signal b_R1_dout : std_logic_vector(xk - 1 downto 0);
    --------------------------------------------------------------------

    --------------------------------------------------------------------R00
    signal a_R00_wr   : std_logic;
    signal a_R00_addr : std_logic_vector(addrSize - 1 downto 0);
    signal a_R00_din  : std_logic_vector(xk - 1 downto 0);
    signal a_R00_dout : std_logic_vector(xk - 1 downto 0);

    signal b_R00_wr   : std_logic;
    signal b_R00_rst  : std_logic;
    signal b_R00_addr : std_logic_vector(addrSize - 1 downto 0);
    signal b_R00_din  : std_logic_vector(xk - 1 downto 0);
    signal b_R00_dout : std_logic_vector(xk - 1 downto 0);
    --------------------------------------------------------------------

    --------------------------------------------------------------------R11
    signal a_R11_wr   : std_logic;
    signal a_R11_addr : std_logic_vector(addrSize - 1 downto 0);
    signal a_R11_din  : std_logic_vector(xk - 1 downto 0);
    signal a_R11_dout : std_logic_vector(xk - 1 downto 0);

    signal b_R11_wr   : std_logic;
    signal b_R11_rst  : std_logic;
    signal b_R11_addr : std_logic_vector(addrSize - 1 downto 0);
    signal b_R11_din  : std_logic_vector(xk - 1 downto 0);
    signal b_R11_dout : std_logic_vector(xk - 1 downto 0);
    --------------------------------------------------------------------R11
    signal orden      : std_logic; --cuando es 0 se usan las memorias R0 y R1, en caso contrario las otras memorias
    signal llena	  : std_logic;

    --------------------------------------------------------------------

    signal R_Write : std_logic;

    signal X_Addr  : std_logic_vector(addrSize - 1 downto 0);
    signal Y_Addr  : std_logic_vector(addrSize - 1 downto 0);
    signal P_Addr  : std_logic_vector(addrSize - 1 downto 0);
    signal R_Addr_A  : std_logic_vector(addrSize - 1 downto 0);
    signal R_Addr_B  : std_logic_vector(addrSize - 1 downto 0);

    --------------------------------------------------------- Señales para el 1er multiplier
    signal X_Out   : std_logic_vector(xk - 1 downto 0);
    signal Y_Out   : std_logic_vector(xk - 1 downto 0);
    signal P_Out   : std_logic_vector(xk - 1 downto 0);
    signal R_Out_A  : std_logic_vector(xk - 1 downto 0);
    signal R_Out_B  : std_logic_vector(xk - 1 downto 0); 
    signal R_IN     : std_logic_vector(xk - 1 downto 0);

    --------------------------------------------------------- Señales para 2do multiplier
    signal X_Out_2   : std_logic_vector(xk - 1 downto 0);
    signal Y_Out_2   : std_logic_vector(xk - 1 downto 0);
    signal P_Out_2   : std_logic_vector(xk - 1 downto 0);
    signal R_Out_A_2   : std_logic_vector(xk - 1 downto 0);
    signal R_Out_B_2   : std_logic_vector(xk - 1 downto 0); 
    signal R_IN_2 : std_logic_vector(xk - 1 downto 0);

    --------------------------------------------------------------------------------
    signal rst_mem : std_logic;
    signal resetCj : std_logic;
    signal exp_i : std_logic;

    -----------------------------------------------------------
    signal bram_addr_llenar : std_logic_vector(addrSize - 1 downto 0);

    signal rstInt : std_logic; 
    signal doneInt : std_logic; 
begin
    R <= b_R0_dout;

    --------------------------------------------- Memorias BRAM (Exp y p) 
    BRAMP   : entity work.rams_01 generic map(xk, addrSize) Port Map( clk, bram_p_we, bram_p_addr, bram_p_din, bram_p_dout);
    BRAMExp : entity work.rams_01 generic map(xk, addrSize) Port Map( clk, bram_exp_we, bram_exp_addr, bram_exp_din, bram_exp_dout); 
    --------------------------------------------- Memorias R0 R1, R00 y R11
    ---------------------------------------------
    R0 : entity work.rams_16b generic map(xk, addrSize) Port Map(
        clk         ,  clk        ,
        '0'         ,  b_R0_rst	  , 
        a_R0_wr     ,  b_R0_wr    ,
        a_R0_addr   ,  b_R0_addr  ,
        a_R0_din    ,  b_R0_din	  ,
        a_R0_dout   ,  b_R0_dout	  
    );

    R1 : entity work.rams_16b generic map(xk, addrSize) Port Map(
        clk         ,  clk        ,
        '0'         ,  b_R1_rst	  , 
        a_R1_wr     ,  b_R1_wr    ,
        a_R1_addr   ,  b_R1_addr  ,
        a_R1_din    ,  b_R1_din	  ,
        a_R1_dout   ,  b_R1_dout	  
    );

    R00 : entity work.rams_16b generic map(xk, addrSize) Port Map(
        clk          ,  clk        ,
        '0'          ,  b_R00_rst	  , 
        a_R00_wr     ,  b_R00_wr    ,
        a_R00_addr   ,  b_R00_addr  ,
        a_R00_din    ,  b_R00_din	  ,
        a_R00_dout   ,  b_R00_dout	  
    );

    R11 : entity work.rams_16b generic map(xk, addrSize) Port Map(
        clk          ,  clk        ,
        '0'          ,  b_R11_rst	  , 
        a_R11_wr     ,  b_R11_wr    ,
        a_R11_addr   ,  b_R11_addr  ,
        a_R11_din    ,  b_R11_din	  ,
        a_R11_dout   ,  b_R11_dout	  
    );

    bram_p_din   <= P; 
    bram_exp_din <= Exp;

    bram_p_addr   <= bram_addr_llenar when llena = '1' else P_Addr;
    bram_exp_addr <= bram_addr_llenar when llena = '1' else bram_exp_addr_temp;

    bram_p_we <= llena;
    bram_exp_we <= llena;

    --------------------------------------------- Configuración de las señales de entrada de las memorias
    ---------------------------------------------------------------------------------------------------------------------------
    a_R0_wr   <= '1' when llena = '1' else '0' when orden = '0' else R_Write;
    a_R0_addr <= bram_addr_llenar when llena= '1' else X_Addr  when orden = '0' else R_Addr_A;
    a_R0_din  <= Uno     when llena = '1' else R_IN;
    b_R0_addr <= Y_Addr  when orden = '0' else R_Addr_B;
    b_R0_rst  <= '0'     when orden = '0' else rst_mem;

    a_R1_wr   <= '1' when llena = '1' else '0' when orden = '0' else  R_Write;
    a_R1_addr <= bram_addr_llenar when llena = '1' else X_Addr  when orden = '0' else R_Addr_A;
    a_R1_din  <= X       when llena = '1' else R_IN_2;
    b_R1_addr <= Y_Addr  when orden = '0' else R_Addr_B;
    b_R1_rst  <= '0'     when orden = '0' else rst_mem;

    --------------------------------------------------------------------------------------------------------------------------
    a_R00_wr   <= '0'     when orden = '1' else R_Write;
    a_R00_addr <= X_Addr  when orden = '1' else R_Addr_A;
    a_R00_din  <= R_IN;
    b_R00_addr <= Y_Addr  when orden = '1' else R_Addr_B;
    b_R00_rst  <= '0'     when orden = '1' else rst_mem;

    a_R11_wr   <= '0'     when orden = '1' else R_Write;
    a_R11_addr <= X_Addr  when orden = '1' else R_Addr_A;
    a_R11_din  <= R_IN_2;
    b_R11_addr <= Y_Addr  when orden = '1' else R_Addr_B;
    b_R11_rst  <= '0'     when orden = '1' else rst_mem;
    -----------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------

    -----------------------------------------------------------
    X_Out   <= a_R0_dout  when orden = '0' else a_R00_dout;
    R_Out_B <= b_R00_dout when orden = '0' else b_R0_dout;
    ----------------------------------------------------------
    X_Out_2   <= a_R1_dout  when orden = '0' else a_R11_dout;
    R_Out_B_2 <= b_R11_dout when orden = '0' else b_R1_dout;


    Y_Out   <= b_R0_dout when orden = '0' and exp_i = '0' else
               b_R1_dout when orden = '0' and exp_i = '1' else
               b_R00_dout  when orden = '1' and exp_i = '0' else
               b_R11_dout  when orden = '1' and exp_i = '1' else
               (others => 'Z');

    MONTG : entity work.montg_wrap generic map(size, xk, addrSize) port map(
        clk,
        rstInt,
        ----------------------- Control
        X_Addr,                 --bram_x_addr_temp,
        Y_Addr,                 --bram_y_addr_temp,
        P_Addr,                 --bram_p_addr_temp,
        --
        R_Write,                --bram_r_a_we,
        R_Addr_A,               --bram_r_a_addr,
        --                        --
        OPEN,                    --bram_r_b_we,
        R_Addr_B,               --bram_r_b_addr,
        --
        doneInt,
        ------------------------ PE
        --------- mult1
        X_Out,                  --bram_x_do,
        R_Out_B,                --bram_r_b_do,
        --------- mult2
        X_Out_2,                  --bram_x_do,
        R_Out_B_2,                --bram_r_b_do,
        ------------------------
        bram_p_dout,              --bram_p_do,
        Y_Out,                   --bram_y_do,
        --------------------------
        pPrima,
        R_IN,
        R_IN_2,
        rst_mem
    );



    MAIN_FSM : process(CLK)
        variable contador  : std_logic_vector(addrKSize - 1 downto 0); 
        variable shift_exp : std_logic_vector(xk - 1 downto 0); 
        variable contador_size : std_logic_vector(bitsSize - 1 downto 0); 
    Begin
        if CLK'event and CLK = '1' then 
            if Rst = '1' then
                llena   <= '1';
                orden   <= '0';
                rstInt  <= '1';

                bram_addr_llenar <= (others => '0');
                bram_exp_addr_temp <= (others => '1');
                contador := (others => '0');

                CurrentState <= LlenarBram;
                 contador_size := (others => '0');
            else
                case CurrentState is
                    when LlenarBram => 
                        bram_addr_llenar <= bram_addr_llenar + 1;

                        if bram_addr_llenar = size / xk - 1 then
                            llena <= '0';
                            exp_i <= '1';
                            CurrentState <= Esperar;
                        end if;
                    when Esperar => -- Esperar la lectura de exp i;
                            CurrentState <= T1;
                    when T1 => 
                            CurrentState <= T2;
                    when T2 =>
                        if contador = 0 then
                            shift_exp := bram_exp_dout;
                            bram_exp_addr_temp <= bram_exp_addr_temp - 1;
                        end if;
                        
                        contador := contador + 1;
                        CurrentState <= NextMult;
                        rstInt  <= '0';
                    when NextMult =>
                        exp_i <= shift_exp(xk-1);
                        if doneInt = '1' then
                            shift_exp := shift_exp(xk-2 downto 0) & '0';
                            orden <= not orden;
                            rstInt  <= '1';

                             if contador_size = size-1 then
                                CurrentState <= ENDFSM;
                                rstInt  <= '1';
                            else
                                CurrentState <= T2;
                            end if; 

                            contador_size := contador_size + 1; 
                        end if;
                    when ENDFSM =>
                        done <= '1';
                    when others =>
                        null;
                end case; 
            end if;
        end if;
    end process;
end;
