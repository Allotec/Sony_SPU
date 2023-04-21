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


	--Data types for representing the different types of instructions and their fields
	type instructionInfo is record
		opcodeVal : integer;
		opcodeLength : integer;
		executionUnit : integer;
		aluOpcodeVal : integer;
		format : integer;
		latency : integer;
	end record;

	--Formats for instructions
	--All immediates are placed in rb
	--rc gets the value of rt for rrr instructions
	--opcode rt, ra, rb -> 0
	--opcode rt, ra, I10 -> 1
	--opcode rrrt, ra, rb, rc -> 2
	--opcode rt, ra, I10 -> 3 (Sign extended to 32 bits)
	--opcode rt, ra, I10 -> 4 (Take the least significant 8 bits and place in byte slot)
	--opcode rt, I18 -> 5 (Not sign extended placed in the bottom word)
	--opcode I16 -> 6 (sign extended to 32 bits)
	--opcode rt, I16 -> 7 (sign extended to 32 bits and rt is placed in ra)
	--opcode rt, ra -> 8
	--opcode rt, ra, I7 -> 9 (Sign extended to 32 bits)
	--opcode rt, ra, I7 -> 10 (Take the rightmost 4 bits of I7 and place in the byte slot)
	--opcode rt, ra, I7 -> 11 (Placed in the byte slot unsigned)
	--opcode rt, ra, I10 -> 12 (Sign extend to 16 bits)
	--opcode opcode -> 13 (Used for the special instructions) 

	type INSTRUCTION_TABLE is array (natural range <>) of instructionInfo;

	constant TABLE : INSTRUCTION_TABLE := (
		(14, 4, 0, 65, 2, 6), --fma rrrt, ra, rb, rc 
		(15, 4, 0, 66, 2, 6), --fms rrrt, ra, rb, rc 
		(12, 4, 0, 71, 2, 6), --mpya rrrt, ra, rb, rc 
		(33, 7, 4, 21, 5, 2), --ila rt, I18 (not sign extended placed in the bottom word)
		(28, 8, 4, 2, 3, 2), --ai rt, ra, I10 (I10 is sign extended to 32 bits)
		(22, 8, 4, 4, 4, 2), --andbi rt, ra, I10 (Take the least significant 8 bits of I10 and place in byte slot) 
		(126, 8, 4, 9, 4, 2), --ceqbi rt, ra, I10 (Take the least significant 8 bits of I10 and place in byte slot) 
		(124, 8, 4, 10, 3, 2), --ceqi rt, ra, I10 (I10 is sign extended to 32 bits)
		(78, 8, 4, 13, 4, 2), --cgtbi rt, ra, I10 (Take the least significant 8 bits of I10 and place in byte slot) 
		(76, 8, 4, 14, 3, 2), --cgti rt, ra, I10 (I10 is sign extended to 32 bits)
		(92, 8, 4, 16, 3, 3), --clgti rt, ra, I10 (I10 is sign extended to 32 bits)
		(94, 8, 4, 18, 4, 2), --clgtbi rt, ra, I10 (Take the least significant 8 bits of I10 and place in byte slot) 
		(4, 8, 4, 27, 3, 2), --ori rt, ra, I10 (I10 is sign extended to 32 bits)
		(12, 8, 4, 30, 3, 2), --sfi rt, ra, I10 (I10 is sign extended to 32 bits)
		(70, 8, 4, 33, 4, 2), --xorbi rt, ra, I10 (Take the least significant 8 bits of I10 and place in byte slot) 
		(68, 8, 4, 34, 3, 2), --xori rt, ra, I10 (I10 is sign extended to 32 bits)
		(116, 8, 1, 72, 12, 7), --mpyi rt, ra, I10 (sign extended to 16 bits) 
		(117, 8, 1, 75, 12, 7), --mpyui rt, ra, I10 (sign extended to 16 bits) 
		(129, 9, 4, 20, 3, 2), --il rt, I16 (sign extended to 32 bits) 
		(131, 9, 4, 22, 3, 2), --ilh rtm I16 (sign extended to 32 bits) <- top 16 bits should be ignored in ALU
		(100, 9, 7, 49, 6, 1), --br I16 (Sign extend to 32 bits) <- should be shifted to the left by two bits in ALU
		(96, 9, 7, 50, 6, 1), --bra I16 (Sign extend to 32 bits) <- should be shifted to the left by two bits in ALU 
		(66, 9, 7, 51, 7, 1), --brnz rt, I16 (Sign extended to 32 bits) <- should be shifted to the left by two bits in ALU and encode whether branch is taken (rt is placed in ra slot)
		(64, 9, 7, 52, 7, 1), --brz rt, I16 (Sign extended to 32 bits) <- should be shifted to the left by two bits in ALU and encode whether branch is taken (rt is placed in ra slot)
		(97, 9, 5, 59, 7, 4), --lqa rt, I16 (Sign extended to 32 bits) <- should be shifted to the left by two bits in ALU
		(65, 9, 5, 61, 7, 6), --stqa rt, I16 (Sign extended to 32 bits) <- should be shifted to the left by two bits in ALU and encode whether branch is taken (rt is placed in ra slot)
		(192, 11, 4, 0, 0, 2), --a rt, ra, rb
		(832, 11, 4, 1, 0, 2), --addx rt, ra, rb
		(193, 11, 4, 3, 0, 2), --and rt, ra, rb
		(705, 11, 4, 5, 0, 2), --andc rt, ra, rb
		(66, 11, 4, 6, 0, 2), --bg rt, ra, rb
		(960, 11, 4, 7, 0, 2), --ceq rt, ra, rb
		(976, 11, 4, 8, 0, 2), --ceqb rt, ra, rb
		(194, 11, 4, 11, 0, 2), --cg rt, ra, rb 
		(592, 11, 4, 12, 0, 2), --cgtb rt, ra, rb
		(704, 11, 4, 15, 0, 2), --clgt rt, ra, rb
		(720, 11, 4, 17, 0, 2), --clgtb rt, ra, rb
		(585, 11, 4, 19, 0, 2), --eqv rt, ra, rb
		(201, 11, 4, 23, 0, 2), --nand rt, ra, rb
		(73, 11, 4, 24, 0, 2), --nor rt, ra, rb
		(65, 11, 4, 25, 0, 2), --or rt, ra, rb
		(713, 11, 4, 26, 0, 2), --orc rt, ra, rb
		(496, 11, 4, 28, 8, 2), --orx rt, ra
		(64, 11, 4, 29, 0, 2), --sf rt, ra, rb
		(833, 11, 4, 31, 0, 2), --sfx rt, ra, rb
		(577, 11, 4, 32, 0, 2), --xor rt, ra, rb
		(694, 11, 4, 35, 8, 2), --xsbh rt, ra
		(686, 11, 4, 36, 8, 2), --xshw rt, ra
		(678, 11, 4, 37, 8, 2), --xswd rt, ra
		(88, 11, 3, 38, 0, 4), --rot rt, ra, rb
		(120, 11, 3, 39, 9, 4), --roti rt, ra, I7 (Sign extended to 32 bits)
		(89, 11, 3, 40, 0, 4), --rotm rt, ra, rb
		(121, 11, 3, 41, 9, 4), --rotmi rt, ra, I7 (Sign extended to 32 bits)
		(122, 11, 3, 42, 9, 4), --rotmai rt, ra, I7 (Sign extended to 32 bits)
		(91, 11, 3, 43, 0, 4), --shl rt, ra, rb
		(123, 11, 3, 44, 9, 4), --shli rt, ra, I7 (Sign extended to 32 bits)
		(83, 11, 2, 45, 0, 4), --absdb rt, ra, rb
		(211, 11, 2, 46, 0, 4), --avgb rt, ra, rb
		(692, 11, 2, 47, 8, 4), --cntb rt, ra
		(595, 11, 2, 48, 0, 4), --sumb rt, ra, rb
		(476, 11, 6, 53, 0, 4), --rotqby rt, ra, rb
		(508, 11, 6, 54, 10, 4), --rotqbyi rt, ra, I7 (Take the rightmost 4 bits of I7 and place in the byte slot)
		(477, 11, 6, 55, 0, 4), --rotqmby rt, ra, rb
		(509, 11, 6, 56, 11, 4), --rotqmbyi rt, ra, I7 (Placed in the byte slot unsigned) 
		(479, 11, 6, 57, 0, 4), --shlqby rt, ra, rb
		(511, 11, 6, 58, 11, 4), --shlqbyi rt, ra, I7 (Placed in the byte slot unsigned) 
		(452, 11, 5, 60, 0, 4), --lqx rt, ra, rb
		(324, 11, 5, 62, 0, 6), --stqx rt, ra, rb
		(708, 11, 1, 63, 0, 6), --fa rt, ra, rb
		(710, 11, 1, 64, 0, 6), --fm rt, ra, rb
		(709, 11, 1, 67, 0, 6), --fs rt, ra, rb
		(962, 11, 1, 68, 0, 6), --fceq rt, ra, rb
		(706, 11, 1, 69, 0, 6), --fcgt rt, ra, rb
		(964, 11, 1, 70, 0, 6), --mpy rt, ra, rb
		(967, 11, 1, 73, 0, 7), --mpys rt, ra, rb
		(972, 11, 1, 74, 0, 7), --mpyu rt, ra, rb
		(1, 32, 8, 76, 13, 0), --lnop 
		(513, 32, 8, 77, 13, 0), --nop 
		(0, 32, 8, 78, 13, 0) --stop 
	); 
end package;
