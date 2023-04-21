library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity ALUPortDecode is
    Port ( 
        --Inputs
        clock : in std_logic;

        --From the register file
        valueA : in std_logic_vector(const.Width - 1 downto 0);
        valueB : in std_logic_vector(const.Width - 1 downto 0);
        valueC : in std_logic_vector(const.Width - 1 downto 0);

        --From the decoder
        ALUOpIn : in std_logic_vector(6 downto 0);
        I7 : in std_logic_vector(6 downto 0);
        I10 : in std_logic_vector(9 downto 0);  
        I16 : in std_logic_vector(15 downto 0);
        I18 : in std_logic_vector(17 downto 0);
        typeIn : in std_logic_vector(2 downto 0);
        rtIn : in std_logic_vector(6 downto 0);
        rtRRR : in std_logic_vector(6 downto 0);
        regWriteIn : in std_logic;
        instructionCount : in std_logic_vector(7 downto 0);

        --From the forwarding unit
        valueAF : in std_logic_vector(const.Width - 1 downto 0);
        forwardAF : in std_logic;
        valueBF : in std_logic_vector(const.Width - 1 downto 0);
        forwardBF : in std_logic;
        valueCF : in std_logic_vector(const.Width - 1 downto 0);
        forwardCF : in std_logic;

        --Outputs
        typeOut : out std_logic_vector(2 downto 0);
        rtOut : out std_logic_vector(6 downto 0);
        regWriteOut : out std_logic;
        ALUOpOut : out std_logic_vector(6 downto 0);
        ra : out std_logic_vector(const.WIDTH - 1 downto 0);
        rb : out std_logic_vector(const.WIDTH - 1 downto 0);
        rc : out std_logic_vector(const.WIDTH - 1 downto 0);
        instructionCountO : out std_logic_vector(7 downto 0);
        valMem : out std_logic_vector(const.WIDTH - 1 downto 0) --Only used for the LS instructions on the odd pipe
    );
end ALUPortDecode;

architecture Behavioral of ALUPortDecode is
    --Searches through the Table to find which format the instruction is
    function findFormat (aluOpcode : integer) return integer is
        variable i : integer := 0; 

        begin
            for i in 0 to const.TABLE'length - 1 loop
                if const.TABLE(i).aluOpcodeVal = aluOpcode then
                    return const.TABLE(i).format;
                end if;
            end loop;

            assert false report "Invalid ALU Opcode" severity error; 
			return -1;
    end function;

    --Sign extend a 10 bit std_logic_vector to a 32 bit std_logic_vector
    function signExtend (val : std_logic_vector; valSize : integer; resultSize : integer) return std_logic_vector is
        variable sign : std_logic := val(valSize - 1);
        variable i : integer := 0;
        variable temp : std_logic_vector(resultSize - 1 downto 0) := (others => '0');

        begin
            --Load in the bottom 10 bits
            for i in 0 to valSize - 1 loop
                temp(i) := val(i);
            end loop;

            --Sign extend the rest of the bits
            for i in valSize to resultSize - 1 loop
                temp(i) := sign;
            end loop;

            return temp;
    end function;

    begin
        --Procedure to put the correct values in the correct ports for the instruction
        portDecode : process(clock) 
            variable valA : std_logic_vector(const.WIDTH - 1 downto 0);
            variable valB : std_logic_vector(const.WIDTH - 1 downto 0);
            variable valC : std_logic_vector(const.WIDTH - 1 downto 0);

            begin
                if rising_edge(clock) then 
                    --Set the variables to the port values
                    valA := valueA;
                    valB := valueB;
                    valC := valueC;

                    --Replace the values with the forwarded version
                    if (forwardAF = '1') then
                        valA := valueAF;
                    end if;

                    if (forwardBF = '1') then
                        valB := valueBF;
                    end if;

                    if (forwardCF = '1') then
                        valC := valueCF;
                    end if;

                    --opcode rt, ra, rb -> 0
                    if (findFormat(to_integer(unsigned(ALUOpIn))) = 0) then
                        ra <= valA;
                        rb <= valB;
                        rtOut <= rtIn;
                        valMem <= valC; --For store instruction stqx
	                --opcode rt, ra, I10 -> 1
	                elsif (findFormat(to_integer(unsigned(ALUOpIn))) = 1) then
                        ra <= valA;
                        rb <= (others => '0');
                        rb(9 downto 0) <= I10;
                        rtOut <= rtIn;
	                --opcode rrrt, ra, rb, rc -> 2
	                elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 2) then
                        ra <= valA;
                        rb <= valB;
                        rc <= valC;
                        rtOut <= rtRRR;
	                --opcode rt, ra, I10 -> 3 (Sign extended to 32 bits)
	                elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 3) then
                        ra <= valA;
                        rb <= (others => '0');
                        rb(const.WORDSIZE - 1 downto 0) <= signExtend(I10, 10, 32);
                        rtOut <= rtIn;
	                --opcode rt, ra, I10 -> 4 (Take the least significant 8 bits and place in byte slot)
	                elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 4) then
                        ra <= valA;
                        rb <= (others => '0');
                        rb(7 downto 0) <= I10(7 downto 0);
                        rtOut <= rtIn;
	                --opcode rt, I18 -> 5 (Not sign extended placed in the bottom word)
                    elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 5) then
                        rb <= (others => '0');
                        rb(17 downto 0) <= I18;
                        rtOut <= rtIn;
	                --opcode I16 -> 6 (sign extended to 32 bits)
	                elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 6) then
                        rb <= (others => '0');
                        rb(const.WORDSIZE - 1 downto 0) <= signExtend(I16, 16, 32);
                        rtOut <= rtIn;
	                --opcode rt, I16 -> 7 (sign extended to 32 bits and rt is placed in ra)
                    elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 7) then
                        ra <= valC;
                        rb <= (others => '0');
                        rb(const.WORDSIZE - 1 downto 0) <= signExtend(I16, 16, 32);
                        rtOut <= rtIn;
                        valMem <= valC; --For store instruction stqa
	                --opcode rt, ra -> 8
                    elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 8) then
                        ra <= valA;
                        rb <= valB;
                        rtOut <= rtIn;
	                --opcode rt, ra, I7 -> 9 (Sign extended to 32 bits)
	                elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 9) then
                        ra <= valA;
                        rb <= (others => '0');
                        rb(const.WORDSIZE - 1 downto 0) <= signExtend(I7, 7, 32);
                        rtOut <= rtIn;
	                --opcode rt, ra, I7 -> 10 (Take the rightmost 4 bits of I7 and place in the byte slot)
	                elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 10) then
                        ra <= valA;
                        rb <= (others => '0');
                        rb(3 downto 0) <= I7(3 downto 0);
                        rtOut <= rtIn;
	                --opcode rt, ra, I7 -> 11 (Placed in the byte slot unsigned)
	                elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 11) then
                        ra <= valA;
                        rb <= (others => '0');
                        rb(6 downto 0) <= I7;
                        rtOut <= rtIn;
	                --opcode rt, ra, I10 -> 12 (Sign extend to 16 bits)
	                elsif(findFormat(to_integer(unsigned(ALUOpIn))) = 12) then
                        ra <= valA;
                        rb <= (others => '0');
                        rb(const.WORDSIZE - 1 downto 0) <= signExtend(I10, 10, 32);
                        rtOut <= rtIn;
                    end if;
                    
                    --Operations that happen for all instruction types
                    instructionCountO <= instructionCount;
                    ALUOpOut <= ALUOpIn;
                    regWriteOut <= regWriteIn;
                    typeOut <= typeIn;
                    
                    --opcode opcode -> 13 (Used for the special instructions) 
                    --Set all values to 0 except for the opcode and instruction count 
	                if(findFormat(to_integer(unsigned(ALUOpIn))) = 13) then
                        typeOut <= (others => '0');
                        ra <= (others => '0');
                        rb <= (others => '0');
                        rc <= (others => '0');
                        rtOut <= (others => '0');
                        regWriteOut <= '0';
                        valMem <= (others => '0');
                    end if;

                end if;

        end process;
end Behavioral;
