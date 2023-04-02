library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

package const is
	constant WIDTH : integer := 128;

  constant QUAD_WORDSIZE : integer := 128;
  constant QUAD_WORDS : integer := WIDTH / QUAD_WORDSIZE;

  constant DOUBLE_WORDSIZE : integer := 64;
  constant DOUBLE_WORDS : integer := WIDTH / DOUBLE_WORDSIZE;
	
  constant WORDSIZE : integer := 32;
  constant WORDS : integer := WIDTH / WORDSIZE;

  constant HALF_WORDSIZE : integer := 16;
	constant HALF_WORDS : integer := WIDTH / HALF_WORDSIZE;
	
  constant BYTE_SIZE : integer := 8;
  constant BYTES : integer := WIDTH / BYTE_SIZE;

  type instructionInfo is record
    opcodeVal : integer ;
    opcodeLength : integer;
    executionUnit : integer;
    aluOpcodeVal : integer;
  end record;

  type INSTRUCTION_TABLE is array (natural range <>) of instructionInfo;

  constant TABLE : INSTRUCTION_TABLE := (
		(14, 4, 0, 65), --fma
		(15, 4, 0, 66), --fms
		(12, 4, 0, 71), --mpya
		(33, 7, 4, 21), --ila
		(28, 8, 4, 2), --ai
		(22, 8, 4, 4), --andbi
		(126, 8, 4, 9), --ceqbi
		(124, 8, 4, 10), --ceqi
		(78, 8, 4, 13), --cgtbi
		(76, 8, 4, 14), --cgti
		(92, 8, 4, 16), --clgti
		(94, 8, 4, 18), --clgtbi
		(4, 8, 4, 27), --ori
		(12, 8, 4, 30), --sfi
		(70, 8, 4, 33), --xorbi
		(68, 8, 4, 34), --xori
		(116, 8, 1, 72), --mpyi
		(117, 8, 1, 75), --mpyui
		(129, 9, 4, 20), --il
		(131, 9, 4, 22), --ilh
		(100, 9, 7, 49), --br
		(96, 9, 7, 50), --bra
		(66, 9, 7, 51), --brnz
		(64, 9, 7, 52), --brz
		(97, 9, 5, 59), --lqa
		(65, 9, 5, 61), --stqa
		(192, 11, 4, 0), --a
		(832, 11, 4, 1), --addx
		(193, 11, 4, 3), --and
		(705, 11, 4, 5), --andc
		(66, 11, 4, 6), --bg
		(960, 11, 4, 7), --ceq
		(976, 11, 4, 8), --ceqb
		(194, 11, 4, 11), --cg
		(592, 11, 4, 12), --cgtb
		(704, 11, 4, 15), --clgt
		(720, 11, 4, 17), --clgtb
		(585, 11, 4, 19), --eqv
		(201, 11, 4, 23), --nand
		(73, 11, 4, 24), --nor
		(65, 11, 4, 25), --or
		(713, 11, 4, 26), --orc
		(496, 11, 4, 28), --orx
		(64, 11, 4, 29), --sf
		(833, 11, 4, 31), --sfx
		(577, 11, 4, 32), --xor
		(694, 11, 4, 35), --xsbh
		(686, 11, 4, 36), --xshw
		(678, 11, 4, 37), --xswd
		(88, 11, 3, 38), --rot
		(120, 11, 3, 39), --roti
		(89, 11, 3, 40), --rotm
		(121, 11, 3, 41), --rotmi
		(122, 11, 3, 42), --rotmai
		(91, 11, 3, 43), --shl
		(123, 11, 3, 44), --shli
		(83, 11, 2, 45), --absdb
		(211, 11, 2, 46), --avgb
		(692, 11, 2, 47), --cntb
		(595, 11, 2, 48), --sumb
		(476, 11, 6, 53),--rotqby
		(508, 11, 6, 54),--rotqbyi
		(477, 11, 6, 55),--rotqmby
		(509, 11, 6, 56),--rotqmbyi
		(479, 11, 6, 57),--shlqby
		(511, 11, 6, 58),--shlqbyi
		(452, 11, 5, 60), --lqx
		(324, 11, 5, 62), --stqx
		(708, 11, 1, 63), --fa
		(710, 11, 1, 64), --fm
		(709, 11, 1, 67), --fs
		(962, 11, 1, 68), --fceq
		(706, 11, 1, 69), --fcgt
		(964, 11, 1, 70), --mpy
		(967, 11, 1, 73), --mpys
		(972, 11, 1, 74), --mpyu
		(1, 32, 8, 76), --lnop
		(513, 32, 8, 77), --nop
		(0, 32, 8, 78) --stop
  );
  
end package;
