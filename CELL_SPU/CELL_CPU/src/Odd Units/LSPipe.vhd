library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity LSPipe is 
    port(
        --Inputs
        clock : in std_logic;
        valMem : in std_logic_vector(const.WIDTH - 1 downto 0);
        regWrite : in std_logic;
        rt : in std_logic_vector(6 downto 0);
        address : in std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCount : in std_logic_vector(7 downto 0);

        --Outputs
        valMemOut : out std_logic_vector(const.WIDTH - 1 downto 0);
        regWriteOut : out std_logic;
        rtOut : out std_logic_vector(6 downto 0);
        addressOut : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountOut : out std_logic_vector(7 downto 0)
    );
end LSPipe;

--On each clock edge the inputs are latched into the outputs
architecture Behavioral of LSPipe is
begin
    Shift : process(clock)
    begin
        if rising_edge(clock) then
            valMemOut <= valMem;
            regWriteOut <= regWrite;
            rtOut <= rt;
            addressOut <= address;
            instructionCountOut <= instructionCount;
        end if;
    end process;
end Behavioral;
