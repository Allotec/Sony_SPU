library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity ShiftPickerEven is
    Port(
        --Inputs
        regWrite : in std_logic;
        pipeNumber : in std_logic_vector(2 downto 0);
        rt : in std_logic_vector(6 downto 0);
        result : in std_logic_vector(const.WIDTH - 1 downto 0);
        valMem : in std_logic_vector(const.WIDTH - 1 downto 0); --Unused for even pipe
        instructionCount : in std_logic_vector(7 downto 0);

        --Outputs
        --Outputs for pipe 0
        regWriteSPIMA : out std_logic;
        rtSPIMA : out std_logic_vector(6 downto 0);
        resultSPIMA : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountSPIMA : out std_logic_vector(7 downto 0);

        --Outputs for pipe 1
        regWriteSPFP : out std_logic;
        rtSPFP : out std_logic_vector(6 downto 0);
        resultSPFP : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountSPFP : out std_logic_vector(7 downto 0);

        --Outputs for pipe 2
        regWriteB : out std_logic;
        rtB : out std_logic_vector(6 downto 0);
        resultB : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountB : out std_logic_vector(7 downto 0);

        --Outputs for pipe 3
        regWriteSF2 : out std_logic;
        rtSF2 : out std_logic_vector(6 downto 0);
        resultSF2 : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountSF2 : out std_logic_vector(7 downto 0);

        --Outputs for pipe 4
        regWriteSF1 : out std_logic;
        rtSF1 : out std_logic_vector(6 downto 0);
        resultSF1 : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountSF1 : out std_logic_vector(7 downto 0)
    );
end ShiftPickerEven;

architecture Behavioral of ShiftPickerEven is
    begin 
        Mux : process(pipeNumber, regWrite, rt, result) 
        begin 
            --Set everything to zero initially then set the correct output based on the pipe number
            regWriteSPIMA <= '0';
            rtSPIMA <= (others => '0');
            resultSPIMA <= (others => '0');
            regWriteSPFP <= '0';
            rtSPFP <= (others => '0');
            resultSPFP <= (others => '0');
            regWriteB <= '0';
            rtB <= (others => '0');
            resultB <= (others => '0');
            regWriteSF2 <= '0';
            rtSF2 <= (others => '0');
            resultSF2 <= (others => '0');
            regWriteSF1 <= '0';
            rtSF1 <= (others => '0');
            resultSF1 <= (others => '0');
            instructionCountSPIMA <= (others => '0');
            instructionCountSPFP <= (others => '0');
            instructionCountB <= (others => '0');
            instructionCountSF2 <= (others => '0');
            instructionCountSF1 <= (others => '0');

            --Switch on the pipe number
            case pipeNumber is
                when "000" => 
                    regWriteSPIMA <= regWrite;
                    rtSPIMA <= rt;
                    resultSPIMA <= result;
                    instructionCountSPIMA <= instructionCount;
                when "001" => 
                    regWriteSPFP <= regWrite;
                    rtSPFP <= rt;
                    resultSPFP <= result;
                    instructionCountSPFP <= instructionCount;
                when "010" => 
                    regWriteB <= regWrite;
                    rtB <= rt;
                    resultB <= result;
                    instructionCountB <= instructionCount;
                when "011" => 
                    regWriteSF2 <= regWrite;
                    rtSF2 <= rt;
                    resultSF2 <= result;
                    instructionCountSF2 <= instructionCount;
                when "100" => 
                    regWriteSF1 <= regWrite;
                    rtSF1 <= rt;
                    resultSF1 <= result;
                    instructionCountSF1 <= instructionCount;
                when others => 
                    assert false report "Invalid pipe number" severity error;
            end case;
        end process;

end Behavioral;
