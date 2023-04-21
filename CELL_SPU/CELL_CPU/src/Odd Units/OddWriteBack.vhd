library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity OddWriteBack is 
    Port(
        --Inputs
        clock : in std_logic;

        --Control signals from branch unit
        blockIn : in std_logic;
        branchIndex : in std_logic_vector(7 downto 0);

        --Inputs for pipe 5
        regWriteLS : in std_logic;
        rtLS : in std_logic_vector(6 downto 0);
        resultLS : in std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountLS : in std_logic_vector(7 downto 0);
        
        --Inputs for pipe 6
        regWriteP : in std_logic;
        rtP : in std_logic_vector(6 downto 0);
        resultP : in std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountP : in std_logic_vector(7 downto 0);
        
        --Outputs
        rtR : out std_logic_vector(6 downto 0);
        resultR : out std_logic_vector(const.WIDTH - 1 downto 0);
        regWriteR : out std_logic
    );
end OddWriteBack;

architecture Behavioral of OddWriteBack is
    begin 
        --Mux for the outputs
        WriteBack : process (clock)
        begin
            if rising_edge(clock) then
                if (regWriteLS = '1' and ((blockIn = '1' and instructionCountLS < branchIndex) or blockIn = '0')) then
                    rtR <= rtLS;
                    resultR <= resultLS;
                    regWriteR <= regWriteLS;
                elsif (regWriteP = '1' and ((blockIn = '1' and instructionCountP < branchIndex) or blockIn = '0')) then
                    rtR <= rtP;
                    resultR <= resultP;
                    regWriteR <= regWriteP;
                else
                    rtR <= (others => '0');
                    resultR <= (others => '0');
                    regWriteR <= '0';
                end if;
            end if;
        end process WriteBack;
end Behavioral;
