library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity BranchUnit is 
    port (
        --Inputs
        Clock : in std_logic;
        result : in std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCount : in std_logic_vector(7 downto 0);

        --Outputs
        isAbsolute : out std_logic;
        branchIndex : out std_logic_vector(7 downto 0);
        stallAndBlock : out std_logic;
        pcWrite : out std_logic;
        pcValue : out std_logic_vector(7 downto 0)
    );
end BranchUnit;

--The result that comes in is encoded as follows
--The bottom 32 bits are the address to branch to
--The 33rd bit is whether the branch was taken '1' or not '0'
--The 34th bit is whether the branch was absolute '1' or relative '0'
architecture behavioral of BranchUnit is

    begin
        brancher : process(Clock)
            variable branchTaken : std_logic;
            variable branchAbsolute : std_logic;
            variable count : integer range 0 to 12;
            variable flushFlag : std_logic := '0';
            begin
                if rising_edge(Clock) then
                    branchTaken := result(32);
                    branchAbsolute := result(33);

                    --If the branch was taken previously flush the pipeline
                    if(flushFlag = '1') then 
                        pcWrite <= '0';

                        --If the pipeline has been flushed for 12 cycles then reset the flush flag and the counter
                        if(count = 12) then
                            flushFlag := '0';
                            count := 0;
                            stallAndBlock <= '0';
                        end if;

                        count := count + 1;
                    else
                        --If the branch was encoded as taken
                        if(branchTaken = '1') then
                            pcWrite <= '1';
                            stallAndBlock <= '1';
                            isAbsolute <= branchAbsolute;
                            pcValue <= result(7 downto 0);
                            branchIndex <= instructionCount;
                            flushFlag := '1';
                        end if;
                    end if;

                end if;
        end process brancher;
end behavioral;


