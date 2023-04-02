library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity shiftPipeLS is
    Port ( 
        --Inputs
        clk : in std_logic;
        valMem : in std_logic_vector(const.WIDTH - 1 downto 0);
        regWrite : in std_logic;
        rt : in std_logic_vector(6 downto 0);
        address : in std_logic_vector(const.WIDTH - 1 downto 0);

        --Outputs
        --To the write back register
        resultOut : out std_logic_vector(const.WIDTH - 1 downto 0);
        rtOut : out std_logic_vector(6 downto 0);
        regWriteOut : out std_logic;

        --To the fowarding Unit
        resultF : out std_logic_vector(const.WIDTH - 1 downto 0);
        rtF : out std_logic_vector(6 downto 0);
        regWriteF : out std_logic
        );
end shiftPipeLS;


architecture structure of shiftPipeLS is
    signal valMem1 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal regWrite1 : std_logic;
    signal rt1 : std_logic_vector(6 downto 0);
    signal address1 : std_logic_vector(const.WIDTH - 1 downto 0);

    signal valMem2 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal regWrite2 : std_logic;
    signal rt2 : std_logic_vector(6 downto 0);
    signal address2 : std_logic_vector(const.WIDTH - 1 downto 0);

    signal valMem3 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal regWrite3 : std_logic;
    signal rt3 : std_logic_vector(6 downto 0);
    signal address3 : std_logic_vector(const.WIDTH - 1 downto 0);

    signal valMem4 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal regWrite4 : std_logic;
    signal rt4 : std_logic_vector(6 downto 0);
    signal address4 : std_logic_vector(const.WIDTH - 1 downto 0);

    signal valMem5 : std_logic_vector(const.WIDTH - 1 downto 0);
    signal regWrite5 : std_logic;
    signal rt5 : std_logic_vector(6 downto 0);
    signal address5 : std_logic_vector(const.WIDTH - 1 downto 0);

    signal regWriteOut1 : std_logic;
    signal rtOut1 : std_logic_vector(6 downto 0);
    signal resultOut1 : std_logic_vector(const.WIDTH - 1 downto 0);

    signal regWriteOut2 : std_logic;
    signal rtOut2 : std_logic_vector(6 downto 0);
    signal resultOut2 : std_logic_vector(const.WIDTH - 1 downto 0);

    begin 
        u0 : entity LSPipe port map(
            clock => clk,
            valMem => valMem,
            regWrite => regWrite,
            rt => rt,
            address => address,

            valMemOut => valMem1,
            regWriteOut => regWrite1,
            rtOut => rt1,
            addressOut => address1
        );

        u1 : entity LSPipe port map(
            clock => clk,
            valMem => valMem1,
            regWrite => regWrite1,
            rt => rt1,
            address => address1,

            valMemOut => valMem2,
            regWriteOut => regWrite2,
            rtOut => rt2,
            addressOut => address2
        );

        u2 : entity LSPipe port map(
            clock => clk,
            valMem => valMem2,
            regWrite => regWrite2,
            rt => rt2,
            address => address2,

            valMemOut => valMem3,
            regWriteOut => regWrite3,
            rtOut => rt3,
            addressOut => address3
        );

        u3 : entity LSPipe port map(
            clock => clk,
            valMem => valMem3,
            regWrite => regWrite3,
            rt => rt3,
            address => address3,

            valMemOut => valMem4,
            regWriteOut => regWrite4,
            rtOut => rt4,
            addressOut => address4
        );

        u4 : entity LSPipe port map(
            clock => clk,
            valMem => valMem4,
            regWrite => regWrite4,
            rt => rt4,
            address => address4,

            valMemOut => valMem5,
            regWriteOut => regWrite5,
            rtOut => rt5,
            addressOut => address5
        );

        u5 : entity LocalStore port map(
            clk => clk,
            valMem => valMem5,
            regWrite => regWrite5,
            rt => rt5,
            address => address5,

            regWriteOut => regWriteOut1,
            rtOut => rtOut1,
            resultOut => resultOut1
        );
        
        u6 : entity shiftPipe port map(
            clock => clk,
            result => resultOut1,
            regWrite => regWriteOut1,
            rt => rtOut1,

            resultOut => resultOut2,
            rtOut => rtOut2,
            regWriteOut => regWriteOut2
        );

        --To the write back register
        resultOut <= resultOut2;
        rtOut <= rtOut2;
        regWriteOut <= regWriteOut2;

        --To the fowarding Unit
        resultF <= resultOut1;
        rtF <= rtOut1;
        regWriteF <= regWriteOut1;
        
end structure;
        