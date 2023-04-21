library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity ShiftPickerOdd is 
    Port(
        --Inputs
        valMem : in std_logic_vector(const.WIDTH - 1 downto 0);
        pipeNumber : in std_logic_vector(2 downto 0);
        rt : in std_logic_vector(6 downto 0);
        result : in std_logic_vector(const.WIDTH - 1 downto 0);
        regWrite : in std_logic;
        instructionCount : in std_logic_vector(7 downto 0);

        --Outputs for pipe 5
        valMemLS : out std_logic_vector(const.WIDTH - 1 downto 0);
        regWriteLS : out std_logic;
        rtLS : out std_logic_vector(6 downto 0);
        resultLS : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountLS : out std_logic_vector(7 downto 0);

        --Outputs for pipe 6
        regWriteP : out std_logic;
        rtP : out std_logic_vector(6 downto 0);
        resultP : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountP : out std_logic_vector(7 downto 0);

        --Outputs for pipe 7
        regWriteB : out std_logic;
        rtB : out std_logic_vector(6 downto 0);
        resultB : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountB : out std_logic_vector(7 downto 0)
    );
end ShiftPickerOdd;

architecture Behavioral of ShiftPickerOdd is
    begin 
        --Mux for the outputs
        Mux : process (pipeNumber, valMem, rt, result, regWrite)
            begin
                --Set all the ouputs to 0
                valMemLS <= (others => '0');
                regWriteLS <= '0';
                rtLS <= (others => '0');
                resultLS <= (others => '0');
                regWriteP <= '0';
                rtP <= (others => '0');
                resultP <= (others => '0');
                regWriteB <= '0';
                rtB <= (others => '0');
                resultB <= (others => '0');
                instructionCountLS <= (others => '0');
                instructionCountP <= (others => '0');
                instructionCountB <= (others => '0');

                case pipeNumber is
                    when "101" => 
                        valMemLS <= valMem;
                        regWriteLS <= regWrite;
                        rtLS <= rt;
                        resultLS <= result;
                        instructionCountLS <= instructionCount;
                    when "110" => 
                        regWriteP <= regWrite;
                        rtP <= rt;
                        resultP <= result; 
                        instructionCountP <= instructionCount;
                    when "111" =>
                        regWriteB <= regWrite;
                        rtB <= rt;
                        resultB <= result;
                        instructionCountB <= instructionCount;
                    when others =>
                        assert false report "Invalid pipe number" severity error;
                end case;
        end process Mux;
end Behavioral;
