
library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity control is
    generic(
            size: positive;
            xk  : positive;
            addrSize : positive
           );

    port(
            clk : in std_logic;
            rst : in std_logic;
            bram_x_addr : out std_logic_vector(addrSize-1 downto 0);
            bram_y_addr : out std_logic_vector(addrSize-1 downto 0);
            bram_p_addr : out std_logic_vector(addrSize-1 downto 0);
            bram_r_a_we   : out std_logic;
            bram_r_a_addr : out std_logic_vector(addrSize-1 downto 0);
            bram_r_b_we   : out std_logic;
            bram_r_b_addr : out std_logic_vector(addrSize-1 downto 0); 
            done          : out std_logic;
            reset_cj : out std_logic;
            load_qi  : out std_logic;
            write_cj : out std_logic;
            rst_mem  : out std_logic
    );
end control;

architecture behave_control of control is

    type state_type is (S0,S1,S2,S3,S4,S5,S6,S7,S8,S9, END_FSM , SA, SB, SC, SD);
	signal Current_State, Next_State : state_type; 

    signal bram_x_addr_temp : std_logic_vector(addrSize-1 downto 0);
    signal bram_y_addr_temp : std_logic_vector(addrSize-1 downto 0);
    signal bram_p_addr_temp : std_logic_vector(addrSize-1 downto 0);
    signal bram_r_a_addr_temp : std_logic_vector(addrSize-1 downto 0);
    signal bram_r_b_addr_temp : std_logic_vector(addrSize-1 downto 0); 


    signal bram_r_a_we_temp : std_logic;
    signal reset_cj_temp    : std_logic;

    signal wr_t1 : std_logic;
begin

    bram_x_addr   <= bram_x_addr_temp   ;
    bram_y_addr   <= bram_y_addr_temp   ;
    bram_p_addr   <= bram_p_addr_temp   ;
    bram_r_a_addr <= bram_r_a_addr_temp ;
    bram_r_b_addr  <= bram_r_b_addr_temp ;

    bram_r_a_we <= bram_r_a_we_temp;
    reset_cj <= reset_cj_temp;

    FSM : process(clk)
        variable first_iteration : std_logic;
    begin
        if rising_edge(clk) then 
            if rst = '1' then

                bram_x_addr_temp <= (others => '0');
                bram_y_addr_temp <= (others => '0');
                bram_p_addr_temp <= (others => '0');
                bram_r_a_addr_temp <= (0 => '0', 1 => '0', others => '1');
                bram_r_b_addr_temp <= (others => '0'); 

                bram_r_a_we_temp <= '0';
                bram_r_b_we <= '0';

                write_cj <= '0';
                reset_cj_temp <= '1';

                wr_t1 <= '0';
                done <= '0';
                first_iteration := '1';
                rst_mem <= '1'; 

                Current_State <= SA;
            else
                case Current_State is
--                    when S0 =>
                        --bram_x_addr_temp <= bram_x_addr_temp + 1;
                        --bram_y_addr_temp <= bram_y_addr_temp + 1;
                        --bram_p_addr_temp <= bram_p_addr_temp + 1;

                        --if bram_x_addr_temp = size/xk-1 then
                            --bram_x_we <= '0';
                            --bram_y_we <= '0';
                            --bram_p_we <= '0'; 

                            --Current_State <= SA;
                        --end if; 
                    when SA => -- Aqui las direcciones regresan a 0

                        Current_State <= S1; 

                    when S1 => -- Esperar el registro de las memorias

                        Current_State <= S2; 

                        bram_x_addr_temp <= bram_x_addr_temp + 1;
                        bram_r_b_addr_temp <= bram_r_b_addr_temp + 1;
                        bram_r_a_addr_temp <= bram_r_a_addr_temp + 1;

                    when S2 => --Calcular sj

                        reset_cj_temp <= '1' ; 
                        load_qi <= '1';

                        bram_x_addr_temp <= bram_x_addr_temp + 1;
                        bram_r_b_addr_temp <= bram_r_b_addr_temp + 1; 
                        bram_p_addr_temp <= bram_p_addr_temp + 1; 
                        bram_r_a_addr_temp <= bram_r_a_addr_temp + 1;

                        Current_State <= S3;

                    when S3 => --Cargar qi

                        load_qi <= '0';
                        wr_t1 <= '0';
                        write_cj <= '1'; 

                        bram_x_addr_temp <= bram_x_addr_temp + 1;
                        bram_r_b_addr_temp <= bram_r_b_addr_temp + 1;

                        bram_p_addr_temp <= bram_p_addr_temp + 1; 
                        bram_r_a_addr_temp <= bram_r_a_addr_temp + 1; 

                        if bram_y_addr_temp = 0 and first_iteration = '0' then
                            Current_State <= END_FSM;
                            done <= '1';
                        else
                            Current_State <= S4;
                        end if;

                        first_iteration := '0';
                        --Current_State <= S4;
                    when S4 => --for interno
                        write_cj <= '0'; 
                        reset_cj_temp <= '0';
                        bram_x_addr_temp <= bram_x_addr_temp + 1;
                        bram_r_b_addr_temp <= bram_r_b_addr_temp + 1;

                        bram_p_addr_temp <= bram_p_addr_temp + 1;

                        wr_t1 <= '1';
                        bram_r_a_we_temp <= wr_t1;


                        if reset_cj_temp = '0' then
                            bram_r_a_addr_temp <= bram_r_a_addr_temp + 1;
                        end if;

                        if bram_x_addr_temp = size/xk - 1 then
                            bram_y_addr_temp <= bram_y_addr_temp + 1;
                            rst_mem <= '0';
                            Current_State <= S5;
                        end if;
                    when S5 => -- bra_x_addr = 0
                        bram_p_addr_temp <= bram_p_addr_temp + 1;
                        bram_r_a_addr_temp <= bram_r_a_addr_temp + 1;

                        Current_State <= S1;
                    when END_FSM => 
                        bram_r_a_we_temp <= '0';
                        bram_r_b_addr_temp <= bram_r_b_addr_temp + 1; 
                    when others =>
                        null;
                end case; 
            end if;
        end if;
    end process;
end;

