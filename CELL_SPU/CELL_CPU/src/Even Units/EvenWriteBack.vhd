library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity EvenWriteBack is
    Port(
        --Inputs
        clock : in std_logic;

        --Inputs for pipe 0
        regWriteSPIMA : in std_logic;
        rtSPIMA : in std_logic_vector(6 downto 0);
        resultSPIMA : in std_logic_vector(const.WIDTH - 1 downto 0);
        
        --Inputs for pipe 1
        regWriteSPFP : in std_logic;
        rtSPFP : in std_logic_vector(6 downto 0);
        resultSPFP : in std_logic_vector(const.WIDTH - 1 downto 0);
        
        --Inputs for pipe 2
        regWriteB : in std_logic;
        rtB : in std_logic_vector(6 downto 0);
        resultB : in std_logic_vector(const.WIDTH - 1 downto 0);
        
        --Inputs for pipe 3
        regWriteSF2 : in std_logic;
        rtSF2 : in std_logic_vector(6 downto 0);
        resultSF2 : in std_logic_vector(const.WIDTH - 1 downto 0);
        
        --Inputs for pipe 4
        regWriteSF1 : in std_logic;
        rtSF1 : in std_logic_vector(6 downto 0);
        resultSF1 : in std_logic_vector(const.WIDTH - 1 downto 0);

        --Ouputs
        regWriteR : out std_logic;
        rtR : out std_logic_vector(6 downto 0);
        resultR : out std_logic_vector(const.WIDTH - 1 downto 0)
    );
end EvenWriteBack;

architecture Behavioral of EvenWriteBack is
    begin 
        WriteBack : process(clock) 
        begin 
            if(rising_edge(clock)) then
                if(regWriteSPIMA = '1') then
                    regWriteR <= regWriteSPIMA;
                    rtR <= rtSPIMA;
                    resultR <= resultSPIMA;
                elsif(regWriteSPFP = '1') then
                    regWriteR <= regWriteSPFP;
                    rtR <= rtSPFP;
                    resultR <= resultSPFP;
                elsif(regWriteB = '1') then
                    regWriteR <= regWriteB;
                    rtR <= rtB;
                    resultR <= resultB;
                elsif(regWriteSF2 = '1') then
                    regWriteR <= regWriteSF2;
                    rtR <= rtSF2;
                    resultR <= resultSF2;
                elsif(regWriteSF1 = '1') then
                    regWriteR <= regWriteSF1;
                    rtR <= rtSF1;
                    resultR <= resultSF1;
                else
                    regWriteR <= '0';
                    rtR <= (others => '0');
                    resultR <= (others => '0');
                end if;
            end if;
        end process;

end Behavioral;