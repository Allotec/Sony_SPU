library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity InstructionFetchUnit is 
	port(
		--Inputs
		addressIn : in std_logic_vector(7 downto 0);
		dataIn : in std_logic_vector(const.WORDSIZE - 1 downto 0);
		imWrite : in std_logic;
		stall : in std_logic;
		branchStall : in std_logic;
		clock : in std_logic;
		pcWrite : in std_logic;
		pcWriteValue : in std_logic_vector(7 downto 0);
		isAbsolute : in std_logic;
		
		--Output									   
		instruction1 : out std_logic_vector(const.WORDSIZE - 1 downto 0);
    instructionCount1 : out std_logic_vector(7 downto 0);
    instruction2 : out std_logic_vector(const.WORDSIZE - 1 downto 0);
		instructionCount2 : out std_logic_vector(7 downto 0)
	);
	
end InstructionFetchUnit;


architecture structure of InstructionFetchUnit is
	signal localCount : std_logic_vector(7 downto 0);

	begin		 
		u0: entity InstructionBuffer port map(
			addressIn => addressIn,
			dataIn => dataIn,
			imWrite => imWrite,
			clock => clock,
			instruction1 => instruction1,
			instructionCount1 => instructionCount1,
      instruction2 => instruction2,
      instructionCount2 => instructionCount2,
			count => localCount
			);
	   
		u1: entity ProgramCounter port map(
			stall => stall,
			branchStall => branchStall,
			clock => clock,
			pcWrite => pcWrite,
			pcWriteValue => pcWriteValue,
			count => localCount,
			isAbsolute => isAbsolute
			);
			
end structure;
