library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity ShiftEven is 
    Port(
        --Inputs
        clock : in std_logic;

        ALUopE : in std_logic_vector(6 downto 0);
        I7E : in std_logic_vector(6 downto 0);
        I10E : in std_logic_vector(9 downto 0);
        I16E : in std_logic_vector(15 downto 0);
        I18E : in std_logic_vector(17 downto 0);
        typeE : in std_logic_vector(2 downto 0);
        regWriteE : in std_logic;

        --Outputs
        ALUopEOut : out std_logic_vector(6 downto 0);
        I7EOut : out std_logic_vector(6 downto 0);
        I10EOut : out std_logic_vector(9 downto 0);
        I16EOut : out std_logic_vector(15 downto 0);
        I18EOut : out std_logic_vector(17 downto 0);
        typeEOut : out std_logic_vector(2 downto 0);
        regWriteEOut : out std_logic
    );
end ShiftEven;

architecture Behavioral of ShiftEven is
    begin 
        shiftEven : process(clock)
            begin
                if rising_edge(clock) then
                    ALUopEOut <= ALUopE;
                    I7EOut <= I7E;
                    I10EOut <= I10E;
                    I16EOut <= I16E;
                    I18EOut <= I18E;
                    typeEOut <= typeE;
                    regWriteEOut <= regWriteE;
                end if;
            end process;
end Behavioral;

