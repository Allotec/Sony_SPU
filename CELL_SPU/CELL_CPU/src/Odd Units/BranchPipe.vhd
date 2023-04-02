library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity BranchPipe is 
    port (
        --Inputs
        Clock : in std_logic;
        regWrite : in std_logic;
        rt : in std_logic_vector(6 downto 0);
        result : in std_logic_vector(const.WIDTH - 1 downto 0);

        --Outputs
        regWriteOut : out std_logic;
        rtOut : out std_logic_vector(6 downto 0);
        resultOut : out std_logic_vector(const.WIDTH - 1 downto 0)
    );
end BranchPipe;

--A shift register containing 2 shift pipes 
--It is assigned the as pipe 8 for the odd picker
--Currently a wrapper for a shiftpipe to be expanded later on
architecture structure of BranchPipe is

    begin 
        u0 : entity shiftPipe port map(
            Clock => Clock,
            regWrite => regWrite,
            rt => rt,
            result => result,
            regWriteOut => regWriteOut,
            rtOut => rtOut,
            resultOut => resultOut
        );

end structure;