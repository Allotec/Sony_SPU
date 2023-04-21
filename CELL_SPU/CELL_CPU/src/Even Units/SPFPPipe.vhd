library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity SPFPPipe is 
    port (
        --Inputs
        Clock : in std_logic;
        regWrite : in std_logic;
        rt : in std_logic_vector(6 downto 0);
        result : in std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCount : in std_logic_vector(7 downto 0);

        --Outputs
        --To the write back register
        regWriteOut : out std_logic;
        rtOut : out std_logic_vector(6 downto 0);
        resultOut : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountOut : out std_logic_vector(7 downto 0);

        --To the forwarding unit
        regWriteOutF : out std_logic;
        rtOutF : out std_logic_vector(6 downto 0);
        resultOutF : out std_logic_vector(const.WIDTH - 1 downto 0)
    );
end SPFPPipe;

--A shift register containing 7 shift pipes data ready for fowarding in the sixth stage
--It is assigned the as pipe 1 for the even shift picker
architecture structure of SPFPPipe is
    signal regWriteBind1 : std_logic;
    signal rtBind1 : std_logic_vector(6 downto 0);
    signal resultBind1 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal instructionCountBind1 : std_logic_vector(7 downto 0);
    
    signal regWriteBind2 : std_logic;
    signal rtBind2 : std_logic_vector(6 downto 0);
    signal resultBind2 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal instructionCountBind2 : std_logic_vector(7 downto 0);

    signal regWriteBind3 : std_logic;
    signal rtBind3 : std_logic_vector(6 downto 0);
    signal resultBind3 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal instructionCountBind3 : std_logic_vector(7 downto 0);

    signal regWriteBind4 : std_logic;
    signal rtBind4 : std_logic_vector(6 downto 0);
    signal resultBind4 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal instructionCountBind4 : std_logic_vector(7 downto 0);

    signal regWriteBind5 : std_logic;
    signal rtBind5 : std_logic_vector(6 downto 0);
    signal resultBind5 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal instructionCountBind5 : std_logic_vector(7 downto 0);

    signal regWriteBind6 : std_logic;
    signal rtBind6 : std_logic_vector(6 downto 0);
    signal resultBind6 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal instructionCountBind6 : std_logic_vector(7 downto 0);

    signal regWriteBind7 : std_logic;
    signal rtBind7 : std_logic_vector(6 downto 0);
    signal resultBind7 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal instructionCountBind7 : std_logic_vector(7 downto 0);

    begin 
        u0 : entity shiftPipe port map(
            Clock => Clock,
            regWrite => regWrite,
            rt => rt,
            result => result,
            regWriteOut => regWriteBind1,
            rtOut => rtBind1,
            resultOut => resultBind1,
            instructionCount => instructionCount,
            instructionCountOut => instructionCountBind1
        );
        
        u1 : entity shiftPipe port map(
            Clock => Clock,
            regWrite => regWriteBind1,
            rt => rtBind1,
            result => resultBind1,
            regWriteOut => regWriteBind2,
            rtOut => rtBind2,
            resultOut => resultBind2,
            instructionCount => instructionCountBind1,
            instructionCountOut => instructionCountBind2
        );

        u2 : entity shiftPipe port map(
            Clock => Clock,
            regWrite => regWriteBind2,
            rt => rtBind2,
            result => resultBind2,
            regWriteOut => regWriteBind3,
            rtOut => rtBind3,
            resultOut => resultBind3,
            instructionCount => instructionCountBind2,
            instructionCountOut => instructionCountBind3
        );

        u3 : entity shiftPipe port map(
            Clock => Clock,
            regWrite => regWriteBind3,
            rt => rtBind3,
            result => resultBind3,
            regWriteOut => regWriteBind4,
            rtOut => rtBind4,
            resultOut => resultBind4,
            instructionCount => instructionCountBind3,
            instructionCountOut => instructionCountBind4
        );

        u4 : entity shiftPipe port map(
            Clock => Clock,
            regWrite => regWriteBind4,
            rt => rtBind4,
            result => resultBind4,
            regWriteOut => regWriteBind5,
            rtOut => rtBind5,
            resultOut => resultBind5,
            instructionCount => instructionCountBind4,
            instructionCountOut => instructionCountBind5
        );

        u5 : entity shiftPipe port map(
            Clock => Clock,
            regWrite => regWriteBind5,
            rt => rtBind5,
            result => resultBind5,
            regWriteOut => regWriteBind6,
            rtOut => rtBind6,
            resultOut => resultBind6,
            instructionCount => instructionCountBind5,
            instructionCountOut => instructionCountBind6
        );

        u6 : entity shiftPipe port map(
            Clock => Clock,
            regWrite => regWriteBind6,
            rt => rtBind6,
            result => resultBind6,
            regWriteOut => regWriteBind7,
            rtOut => rtBind7,
            resultOut => resultBind7,
            instructionCount => instructionCountBind6,
            instructionCountOut => instructionCountBind7
        );

        --To the write back register
        regWriteOut <= regWriteBind7;
        rtOut <= rtBind7;
        resultOut <= resultBind7;
        instructionCountOut <= instructionCountBind7;

        --To the forwarding unit
        regWriteOutF <= regWriteBind6;
        rtOutF <= rtBind6;
        resultOutF <= resultBind6;
end structure;
