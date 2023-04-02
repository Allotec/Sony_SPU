library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity InstructionBuffer is 
    port(
        --Inputs 
        count : in std_logic_vector(7 downto 0);
        clock : in std_logic; --Only used to load values initially
        dataIn : in std_logic_vector(const.WORDSIZE - 1 downto 0); --Only used to load values initially
        addressIn : in std_logic_vector(7 downto 0); --Only used to load values initially
        imWrite : in std_logic; --Only used to load values initially

        --Outputs
        instructionOdd : out std_logic_vector(const.WORDSIZE - 1 downto 0);
        instructionEven : out std_logic_vector(const.WORDSIZE - 1 downto 0)
    );
end InstructionBuffer;


architecture behavioral of InstructionBuffer is
    type instructions is array (0 to 2**8 - 1) of std_logic_vector(const.WORDSIZE - 1 downto 0);
    signal instructionMemory : instructions;

begin		
    readAndWrite : process(clock)
        begin
            if(rising_edge(clock)) then
                if(imWrite = '1') then
                    instructionMemory(to_integer(unsigned(addressIn))) <= dataIn(const.WORDSIZE - 1 downto 0);
                else
                    instructionOdd <= instructionMemory(to_integer(unsigned(count(7 downto 0))));
                    instructionEven <= instructionMemory(to_integer(unsigned(count(7 downto 0))) + 1);
                end if;
            end if;
    end process;
end behavioral;
