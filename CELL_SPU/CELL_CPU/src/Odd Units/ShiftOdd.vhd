library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity ShiftOdd is 
    Port(
        --Inputs
        clock : in std_logic;

        ALUopO : in std_logic_vector(6 downto 0);
        I7O : in std_logic_vector(6 downto 0);
        I10O : in std_logic_vector(9 downto 0);
        I16O : in std_logic_vector(15 downto 0);
        I18O : in std_logic_vector(17 downto 0);
        typeO : in std_logic_vector(2 downto 0);
        instructionCountO : in std_logic_vector(7 downto 0);
        regWriteO : in std_logic;

        --Outputs
        ALUopOOut: out std_logic_vector(6 downto 0);
        I7OOut: out std_logic_vector(6 downto 0);
        I10OOut: out std_logic_vector(9 downto 0);
        I16OOut: out std_logic_vector(15 downto 0);
        I18OOut: out std_logic_vector(17 downto 0);
        typeOOut: out std_logic_vector(2 downto 0);
        instructionCountOOut: out std_logic_vector(7 downto 0);
        regWriteOOut: out std_logic
    );
end ShiftOdd;

architecture Behavioral of ShiftOdd is
    begin 
        shiftEven : process(clock)
            begin
                if rising_edge(clock) then
                    ALUopOOut<= ALUopO;
                    I7OOut<= I7O;
                    I10OOut<= I10O;
                    I16OOut<= I16O;
                    I18OOut<= I18O;
                    typeOOut<= typeO;
                    instructionCountOOut<= instructionCountO;
                    regWriteOOut<= regWriteO;
                end if;
            end process;
end Behavioral;
