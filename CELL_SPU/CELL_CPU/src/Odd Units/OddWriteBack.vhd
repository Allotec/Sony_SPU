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

        --Inputs for pipe 5
        valMemLS : in std_logic_vector(const.WIDTH - 1 downto 0);
        regWriteLS : in std_logic;
        rtLS : in std_logic_vector(6 downto 0);
        resultLS : in std_logic_vector(const.WIDTH - 1 downto 0);
        
        --Inputs for pipe 6
        regWriteP : in std_logic;
        rtP : in std_logic_vector(6 downto 0);
        resultP : in std_logic_vector(const.WIDTH - 1 downto 0);
        
        --Inputs for pipe 7
        regWriteB : in std_logic;
        rtB : in std_logic_vector(6 downto 0);
        resultB : in std_logic_vector(const.WIDTH - 1 downto 0);
        
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
                if regWriteLS = '1' then
                    rtR <= rtLS;
                    resultR <= valMemLS;
                    regWriteR <= regWriteLS;
                elsif regWriteP = '1' then
                    rtR <= rtP;
                    resultR <= resultP;
                    regWriteR <= regWriteP;
                elsif regWriteB = '1' then
                    rtR <= rtB;
                    resultR <= resultB;
                    regWriteR <= regWriteB;
                else
                    rtR <= (others => '0');
                    resultR <= (others => '0');
                    regWriteR <= '0';
                end if;
            end if;
        end process WriteBack;
end Behavioral;