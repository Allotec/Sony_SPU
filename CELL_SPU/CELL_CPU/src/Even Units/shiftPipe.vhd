library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity shiftPipe is 
    port(
        --Inputs
        clock : in std_logic;
        regWrite : in std_logic;
        rt : in std_logic_vector(6 downto 0);
        result : in std_logic_vector(const.WIDTH - 1 downto 0);

        --Outputs
        regWriteOut : out std_logic;
        rtOut : out std_logic_vector(6 downto 0);
        resultOut : out std_logic_vector(const.WIDTH - 1 downto 0)
    );
end shiftPipe;

--On each clock edge the inputs are latched into the outputs
architecture Behavioral of shiftPipe is
begin
    Shift : process(clock)
    begin
        if rising_edge(clock) then
            regWriteOut <= regWrite;
            rtOut <= rt;
            resultOut <= result;
        end if;
    end process;
end Behavioral;

