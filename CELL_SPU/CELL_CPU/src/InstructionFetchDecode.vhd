library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;	   											
use ieee.float_pkg.all;

library CELL_CPU;
use CELL_CPU.all;

entity InstructionFetchDecode is 
    port(
        --Inputs
        clock : in std_logic;
        instruction1 : in std_logic_vector(const.WORDSIZE - 1 downto 0);
        instruction2 : in std_logic_vector(const.WORDSIZE - 1 downto 0);

        --Outputs
        stall : out std_logic;

        --Odd Outputs
        rbO : out std_logic_vector(6 downto 0);
        raO : out std_logic_vector(6 downto 0);
        rtO : out std_logic_vector(6 downto 0);
        rtRRRO : out std_logic_vector(6 downto 0);
        ALUOPO : out std_logic_vector(6 downto 0);
        I7O : out std_logic_vector(6 downto 0);
        I10O : out std_logic_vector(9 downto 0);
        I16O : out std_logic_vector(15 downto 0);
        I18O : out std_logic_vector(17 downto 0);
        typeO : out std_logic_vector(2 downto 0);
        regWriteO : out std_logic;

        --Even Outputs
        rbE : out std_logic_vector(6 downto 0);
        raE : out std_logic_vector(6 downto 0);
        rtE : out std_logic_vector(6 downto 0);
        rtRRRE : out std_logic_vector(6 downto 0);
        ALUOPE : out std_logic_vector(6 downto 0);
        I7E : out std_logic_vector(6 downto 0);
        I10E : out std_logic_vector(9 downto 0);
        I16E : out std_logic_vector(15 downto 0);
        I18E : out std_logic_vector(17 downto 0);
        typeE : out std_logic_vector(2 downto 0);
        regWriteE : out std_logic
    );
end InstructionFetchDecode;

--Reads in two instructions and decodes them into components and stalls if two intructions go into the same pipe
architecture Behavioral of InstructionFetchDecode is
    --Takes in the opcode value and the number of bits in the opcode and returns the execution unit
    function get_execution_unit(opcode_val: integer; opcode_length: integer) return integer is
        begin
            for i in const.TABLE'range loop
                if const.TABLE(i).opcodeVal = opcode_val and const.TABLE(i).opcodeLength = opcode_length then
                    return const.TABLE(i).executionUnit;
                end if;
            end loop;

            return -1; -- opcode not found
    end function;

    --Takes in the opcode value and the number of bits in the opcode and returns the aluOpcodeVal
    function get_alu_opcode(opcode_val: integer; opcode_length: integer) return integer is
        begin
            for i in const.TABLE'range loop
                if const.TABLE(i).opcodeVal = opcode_val and const.TABLE(i).opcodeLength = opcode_length then
                    return const.TABLE(i).aluOpcodeVal;
                end if;
            end loop;

            return -1; -- opcode not found
    end function;

    --Function that takes in an instruction and tries the different opcode sizes and returns the execution unit
    function instructionExecutionUnit(instruction : std_logic_vector(const.WORDSIZE - 1 downto 0)) return integer is
        begin
        --First check if they are special instructions
        --stop
        if(to_integer(unsigned(instruction)) = 0) then
            return 8;
        --lnop
        elsif(to_integer(unsigned(instruction)) = 1) then
            return 8;
        --nop
        elsif(to_integer(unsigned(instruction)) = 513) then
            return 8;
        end if;

        --Try the top 4 bits for the RRR instructions
        if get_execution_unit(to_integer(unsigned(instruction(31 downto 28))), 4) /= -1 then
            return get_execution_unit(to_integer(unsigned(instruction(31 downto 28))), 4);
        --Try the top 7 bits for RI18 instructions
        elsif get_execution_unit(to_integer(unsigned(instruction(31 downto 25))), 7) /= -1 then
            return get_execution_unit(to_integer(unsigned(instruction(31 downto 25))), 7);
        --Try the top 8 bits for RI10 instructions
        elsif get_execution_unit(to_integer(unsigned(instruction(31 downto 24))), 8) /= -1 then
            return get_execution_unit(to_integer(unsigned(instruction(31 downto 24))), 8);
        --Try the top 9 bits for RI16 instructions
        elsif get_execution_unit(to_integer(unsigned(instruction(31 downto 23))), 9) /= -1 then
            return get_execution_unit(to_integer(unsigned(instruction(31 downto 23))), 9);
        --Try the top 11 bits for RR and RI7 instructions
        elsif get_execution_unit(to_integer(unsigned(instruction(31 downto 21))), 11) /= -1 then
            return get_execution_unit(to_integer(unsigned(instruction(31 downto 21))), 11);
        else 
            return -1;
        end if;
    end function;

    --Function that takes in an instruction and tries the different opcode sizes and returns the aluOpcodeVal
    function instructionAluOpcode(instruction : std_logic_vector(const.WORDSIZE - 1 downto 0)) return integer is
        begin
        --First check if they are special instructions
        --stop
        if(to_integer(unsigned(instruction)) = 0) then
            return 76;
        --lnop
        elsif(to_integer(unsigned(instruction)) = 1) then
            return 77;
        --nop
        elsif(to_integer(unsigned(instruction)) = 513) then
            return 78;
        end if;

        --Try the top 4 bits for the RRR instructions
        if get_alu_opcode(to_integer(unsigned(instruction(31 downto 28))), 4) /= -1 then
            return get_alu_opcode(to_integer(unsigned(instruction(31 downto 28))), 4);
        --Try the top 7 bits for RI18 instructions
        elsif get_alu_opcode(to_integer(unsigned(instruction(31 downto 25))), 7) /= -1 then
            return get_alu_opcode(to_integer(unsigned(instruction(31 downto 25))), 7);
        --Try the top 8 bits for RI10 instructions
        elsif get_alu_opcode(to_integer(unsigned(instruction(31 downto 24))), 8) /= -1 then
            return get_alu_opcode(to_integer(unsigned(instruction(31 downto 24))), 8);
        --Try the top 9 bits for RI16 instructions
        elsif get_alu_opcode(to_integer(unsigned(instruction(31 downto 23))), 9) /= -1 then
            return get_alu_opcode(to_integer(unsigned(instruction(31 downto 23))), 9);
        --Try the top 11 bits for RR and RI7 instructions
        elsif get_alu_opcode(to_integer(unsigned(instruction(31 downto 21))), 11) /= -1 then
            return get_alu_opcode(to_integer(unsigned(instruction(31 downto 21))), 11);
        else 
            return -1;
        end if;
    end function;

    begin
        decode : process(clock) 
			variable executionPipe1 : integer := 0;
        	variable executionPipe2 : integer := 0;
        	variable wasStalled : boolean := false;
        	variable stallType : integer := 0; --Zero indicates a double even stall and 1 indicates a double odd stall

		  	begin
            if(rising_edge(clock)) then
                --If the previous clock cycle wasn't a stall procede as normal
                if(not wasStalled) then
                    --TODO Handling special instructions of type 8
                    --Get the execution unit for the first and second instruction
                    executionPipe1 := instructionExecutionUnit(instruction1);
                    executionPipe2 := instructionExecutionUnit(instruction2);

                    --If the first instruction is an even instruction and the second instruction is an odd instruction
                    if((executionPipe1 >= 0 and executionPipe1 <= 4) and (executionPipe2 > 4 and executionPipe2 < 8)) then
                        --Assign Instruction 1 to the even port
                        rbE <= instruction1(17 downto 11);
                        raE <= instruction1(24 downto 18);
                        rtE <= instruction1(31 downto 25);
                        rtRRRE <= instruction1(10 downto 4);
                        ALUOPE <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction1), 7));
                        I7E <= instruction1(17 downto 11);
                        I10E <= instruction1(17 downto 8);
                        I16E <= instruction1(24 downto 9);
                        I18E <= instruction1(24 downto 7);
                        typeE <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction1), 3));
                        regWriteE <= '1';

                        --Assign Instruction 2 to the odd port
                        rbO <= instruction2(17 downto 11);
                        raO <= instruction2(24 downto 18);
                        rtO <= instruction2(31 downto 25);
                        rtRRRO <= instruction2(10 downto 4);
                        ALUOPO <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction2), 7));
                        I7O <= instruction2(17 downto 11);
                        I10O <= instruction2(17 downto 8);
                        I16O <= instruction2(24 downto 9);
                        I18O <= instruction2(24 downto 7);
                        typeO <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction2), 3));
                        regWriteO <= '1';
                    --If the first instruction is an odd instruction and the second instruction is an even instruction
                    elsif((executionPipe1 > 4 and executionPipe1 < 8) and (executionPipe2 >= 0 and executionPipe2 <= 4)) then
                        --Assign Instruction 1 to the odd port
                        rbO <= instruction1(17 downto 11);
                        raO <= instruction1(24 downto 18);
                        rtO <= instruction1(31 downto 25);
                        rtRRRO <= instruction1(10 downto 4);
                        ALUOPO <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction1), 7));
                        I7O <= instruction1(17 downto 11);
                        I10O <= instruction1(17 downto 8);
                        I16O <= instruction1(24 downto 9);
                        I18O <= instruction1(24 downto 7);
                        typeO <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction1), 3));
                        regWriteO <= '1';

                        --Assign Instruction 2 to the even port
                        rbE <= instruction2(17 downto 11);
                        raE <= instruction2(24 downto 18);
                        rtE <= instruction2(31 downto 25);
                        rtRRRE <= instruction2(10 downto 4);
                        ALUOPE <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction2), 7));
                        I7E <= instruction2(17 downto 11);
                        I10E <= instruction2(17 downto 8);
                        I16E <= instruction2(24 downto 9);
                        I18E <= instruction2(24 downto 7);
                        typeE <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction2), 3));
                        regWriteE <= '1';
                    --If both instructions are even output instruction 1 to the even port and stall
                    elsif((executionPipe1 >= 0 and executionPipe1 <= 4) and (executionPipe2 >= 0 and executionPipe2 <= 4)) then
                        stall <= '1';
                        wasStalled := true;
                        stallType := 0;
                        regWriteO <= '0';
                        
                        --Assign Instruction 1 to the even port
                        rbE <= instruction1(17 downto 11);
                        raE <= instruction1(24 downto 18);
                        rtE <= instruction1(31 downto 25);
                        rtRRRE <= instruction1(10 downto 4);
                        ALUOPE <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction1), 7));
                        I7E <= instruction1(17 downto 11);
                        I10E <= instruction1(17 downto 8);
                        I16E <= instruction1(24 downto 9);
                        I18E <= instruction1(24 downto 7);
                        typeE <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction1), 3));
                        regWriteE <= '1';
                        
                    --If both instructions are odd output instruction 1 to the odd port and stall
                    elsif((executionPipe1 > 4 and executionPipe1 < 8) and (executionPipe2 > 4 and executionPipe2 < 8)) then
                        stall <= '1';
                        wasStalled := true;
                        stallType := 1;
                        regWriteE <= '0';
                        
                        --Assign Instruction 1 to the odd port
                        rbO <= instruction1(17 downto 11);
                        raO <= instruction1(24 downto 18);
                        rtO <= instruction1(31 downto 25);
                        rtRRRO <= instruction1(10 downto 4);
                        ALUOPO <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction1), 7));
                        I7O <= instruction1(17 downto 11);
                        I10O <= instruction1(17 downto 8);
                        I16O <= instruction1(24 downto 9);
                        I18O <= instruction1(24 downto 7);
                        typeO <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction1), 3));
                        regWriteO <= '1';
                        
                    end if;
                --If the previous clock cycle was a stall
                else
                    --Stall will be resolved
                    wasStalled := false;
                    stall <= '0';

                    --If the stall was a double even stall
                    if(stallType = 0) then
                        --Assign Instruction 2 to the even port
                        rbE <= instruction2(17 downto 11);
                        raE <= instruction2(24 downto 18);
                        rtE <= instruction2(31 downto 25);
                        rtRRRE <= instruction2(10 downto 4);
                        ALUOPE <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction2), 7));
                        I7E <= instruction2(17 downto 11);
                        I10E <= instruction2(17 downto 8);
                        I16E <= instruction2(24 downto 9);
                        I18E <= instruction2(24 downto 7);
                        typeE <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction2), 3));
                        regWriteE <= '1';
                    --If the stall was a double odd stall
                    elsif(stallType = 1) then
                        --Assign Instruction 2 to the odd port
                        rbO <= instruction2(17 downto 11);
                        raO <= instruction2(24 downto 18);
                        rtO <= instruction2(31 downto 25);
                        rtRRRO <= instruction2(10 downto 4);
                        ALUOPO <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction2), 7));
                        I7O <= instruction2(17 downto 11);
                        I10O <= instruction2(17 downto 8);
                        I16O <= instruction2(24 downto 9);
                        I18O <= instruction2(24 downto 7);
                        typeO <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction2), 3));
                        regWriteO <= '1';
                    end if;
                end if;

            end if;
        end process;

end Behavioral;
