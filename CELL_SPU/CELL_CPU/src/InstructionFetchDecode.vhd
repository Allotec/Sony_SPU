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
        instructionCount1: in std_logic_vector(7 downto 0);
        instruction2 : in std_logic_vector(const.WORDSIZE - 1 downto 0);
        instructionCount2 : in std_logic_vector(7 downto 0);
        stallIn : in std_logic;

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
        instructionCountO : out std_logic_vector(7 downto 0);
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
        instructionCountE : out std_logic_vector(7 downto 0);
        regWriteE : out std_logic
    );
end InstructionFetchDecode;

--Reads in two instructions and decodes them into components and stalls if two intructions go into the same pipe
architecture Behavioral of InstructionFetchDecode is
    --Storage record for every cycle of the pipeline
    type stall_type is record
        instruction : std_logic_vector(31 downto 0);
        latency : integer;
        valid : boolean;
    end record;

    type stallArray is array (natural range <>) of stall_type;

    --Takes in the opcode value and the number of bits in the opcode and returns the execution unit
    function get_execution_unit(opcode_val: integer; opcode_length: integer) return integer is
        begin
            for i in const.TABLE'range loop
                if const.TABLE(i).opcodeVal = opcode_val and const.TABLE(i).opcodeLength = opcode_length then
                    return const.TABLE(i).executionUnit;
                end if;
            end loop;

            assert false report "Could not find execution unit" severity error;
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

            assert false report "Could not find alu opcode" severity error;
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
            assert false report "Invalid instruction" severity error;
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
            assert false report "Instruction ALU opcode not found in table" severity failure;
            return -1;
        end if;
    end function;

    --Function that returns the latency of an instruction from the const.TABLE
    function getLatency(instruction : std_logic_vector(31 downto 0)) return integer is
        variable latency : integer;
        variable opcode : integer := instructionAluOpcode(instruction);

        begin
            for i in 0 to const.TABLE'length - 1 loop
                if(const.TABLE(i).aluOpcodeVal = opcode) then
                    return(const.TABLE(i).latency);
                end if;
            end loop;

        assert false report "Instruction latency not found in table" severity failure; 
        return -1;
    end function;

    --Procedure that takes in an instruction and assigns it to the odd port and assume that it is an odd instruction
    --Can't assign to ports directly so using signals as an intermediary to get around VHDL
    procedure assignInstructionOdd(
        instruction : std_logic_vector(const.WORDSIZE - 1 downto 0);
        signal rbO : out std_logic_vector(6 downto 0);
        signal raO : out std_logic_vector(6 downto 0);
        signal rtO : out std_logic_vector(6 downto 0);
        signal rtRRRO : out std_logic_vector(6 downto 0);
        signal ALUOPO : out std_logic_vector(6 downto 0);
        signal I7O : out std_logic_vector(6 downto 0);
        signal I10O : out std_logic_vector(9 downto 0);
        signal I16O : out std_logic_vector(15 downto 0);
        signal I18O : out std_logic_vector(17 downto 0);
        signal typeO : out std_logic_vector(2 downto 0);
        signal regWriteO : out std_logic;
        signal instructionCountO : out std_logic_vector(7 downto 0)
        ) is
        begin
            rbO <= instruction(17 downto 11);
            raO <= instruction(24 downto 18);
            rtO <= instruction(31 downto 25);
            rtRRRO <= instruction(10 downto 4);
            ALUOPO <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction), 7));
            I7O <= instruction(17 downto 11);
            I10O <= instruction(17 downto 8);
            I16O <= instruction(24 downto 9);
            I18O <= instruction(24 downto 7);
            typeO <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction), 3));
            instructionCountO <= instructionCount1;
            regWriteO <= '1';
        end assignInstructionOdd;

    --Procedure that takes in an instruction and assigns it to the even port and assume that it is an even instruction
    --Can't assign to ports directly so using signals as an intermediary to get around VHDL
    procedure assignInstructionEven(
        instruction : std_logic_vector(const.WORDSIZE - 1 downto 0);
        signal rbE : out std_logic_vector(6 downto 0);
        signal raE : out std_logic_vector(6 downto 0);
        signal rtE : out std_logic_vector(6 downto 0);
        signal rtRRRE : out std_logic_vector(6 downto 0);
        signal ALUOPE : out std_logic_vector(6 downto 0);
        signal I7E : out std_logic_vector(6 downto 0);
        signal I10E : out std_logic_vector(9 downto 0);
        signal I16E : out std_logic_vector(15 downto 0);
        signal I18E : out std_logic_vector(17 downto 0);
        signal typeE : out std_logic_vector(2 downto 0);
        signal regWriteE : out std_logic;
        signal instructionCountE : out std_logic_vector(7 downto 0)
        ) is
        begin
            rbE <= instruction(17 downto 11);
            raE <= instruction(24 downto 18);
            rtE <= instruction(31 downto 25);
            rtRRRE <= instruction(10 downto 4);
            ALUOPE <= std_logic_vector(to_unsigned(instructionAluOpcode(instruction), 7));
            I7E <= instruction(17 downto 11);
            I10E <= instruction(17 downto 8);
            I16E <= instruction(24 downto 9);
            I18E <= instruction(24 downto 7);
            typeE <= std_logic_vector(to_unsigned(instructionExecutionUnit(instruction), 3));
            instructionCountE <= instructionCount2;
            regWriteE <= '1';
        end assignInstructionEven;

    --Procedure to assign all zeros to the output signals
    procedure assignZeroAll (
        signal rbE : out std_logic_vector(6 downto 0);
        signal raE : out std_logic_vector(6 downto 0);
        signal rtE : out std_logic_vector(6 downto 0);
        signal rtRRRE : out std_logic_vector(6 downto 0);
        signal ALUOPE : out std_logic_vector(6 downto 0);
        signal I7E : out std_logic_vector(6 downto 0);
        signal I10E : out std_logic_vector(9 downto 0);
        signal I16E : out std_logic_vector(15 downto 0);
        signal I18E : out std_logic_vector(17 downto 0);
        signal typeE : out std_logic_vector(2 downto 0);
        signal regWriteE : out std_logic;
        signal instructionCountE : out std_logic_vector(7 downto 0);
        
        signal rbO : out std_logic_vector(6 downto 0);
        signal raO : out std_logic_vector(6 downto 0);
        signal rtO : out std_logic_vector(6 downto 0);
        signal rtRRRO : out std_logic_vector(6 downto 0);
        signal ALUOPO : out std_logic_vector(6 downto 0);
        signal I7O : out std_logic_vector(6 downto 0);
        signal I10O : out std_logic_vector(9 downto 0);
        signal I16O : out std_logic_vector(15 downto 0);
        signal I18O : out std_logic_vector(17 downto 0);
        signal typeO : out std_logic_vector(2 downto 0);
        signal regWriteO : out std_logic;
        signal instructionCountO : out std_logic_vector(7 downto 0)
        ) is
        begin
            --Assign zero to the even ports
            rbE <= (others => '0');
            raE <= (others => '0');
            rtE <= (others => '0');
            rtRRRE <= (others => '0');
            ALUOPE <= (others => '0');
            I7E <= (others => '0');
            I10E <= (others => '0');
            I16E <= (others => '0');
            I18E <= (others => '0');
            typeE <= (others => '0');
            instructionCountE <= (others => '0');
            regWriteE <= '0';

            --Assign zero to the odd ports
            rbO <= (others => '0');
            raO <= (others => '0');
            rtO <= (others => '0');
            rtRRRO <= (others => '0');
            ALUOPO <= (others => '0');
            I7O <= (others => '0');
            I10O <= (others => '0');
            I16O <= (others => '0');
            I18O <= (others => '0');
            typeO <= (others => '0');
            instructionCountO <= (others => '0');
            regWriteO <= '0';
    end assignZeroAll;

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

    --This function returns the register that the inctruction writes to
    function writeRegister(instruction : in std_logic_vector(31 downto 0)) return std_logic_vector is
        --The bottom 7 bits are the register number and the 8th bit is whether it has a write register
        --If the eighth bit is 1 then there is a write register, if it is 0 then there is no write register
        variable writeReg : std_logic_vector(7 downto 0) := (others => '0');
    begin
        --Check if instruction2 doesn't write to a register
        if(findFormat(instructionAluOpcode(instruction)) = 13 or --If its a special instruction
            findFormat(instructionAluOpcode(instruction)) = 6 or --Or br/bra
            instructionAluOpcode(instruction) = 51 or --Or brnz 
            instructionAluOpcode(instruction) = 52 or --Or brz
            instructionAluOpcode(instruction) = 61 or --Or stqa
            instructionAluOpcode(instruction) = 62)  --Or stqx
            then
            return writeReg;
        end if;

        --Check if instruction is RRR format
        --If not then it writes to Rt
        --Rt is 25 to 31
        --Rtrrr is 4 to 10
        if (findFormat(instructionAluOpcode(instruction)) = 2) then 
            writeReg(6 downto 0) := instruction(10 downto 4);
        else
            writeReg(6 downto 0) := instruction(31 downto 25);
        end if;

        writeReg(7) := '1';

        return(writeReg);
    end function;

    --This function returns true if the two instructions passed in have a write after after write dependency
    --ie the two instructions have the same write register
    --Order of the instructions does not matter
    function writeAfterWriteDependency(
        instruction1 : in std_logic_vector(31 downto 0); 
        instruction2 : in std_logic_vector(31 downto 0)
    ) return boolean is
        
    begin 
        --Return true only if the two instructions have the same register value and instruction format
        return (writeRegister(instruction1) = writeRegister(instruction2));
    end function;

    --Data types for holding the register values that are read in an instruction
    type readRegister is record
        rr : std_logic_vector(6 downto 0);
        isValid : boolean;
    end record;

    type readRrArray is array (natural range <>) of readRegister;

    --This function returns the register that the instruction reads from
    function readRegisterInstruction(
        instruction : in std_logic_vector(31 downto 0)
    ) return readRrArray is
        --Ra 24 downto 18
        --Rb 17 downto 11
        --Rc 31 downto 25
        variable readReg : readRrArray(0 to 2) := (others => ("0000000", false));
    begin
        --If the instruction is of rrr type then it reads from ra, rb, rc
        --Format 2
        if(findFormat(instructionAluOpcode(instruction)) = 2) then
            readReg(0) := (std_logic_vector(to_unsigned(to_integer(unsigned(instruction(24 downto 18))), 7)), true);
            readReg(1) := (std_logic_vector(to_unsigned(to_integer(unsigned(instruction(17 downto 11))), 7)), true);
            readReg(2) := (std_logic_vector(to_unsigned(to_integer(unsigned(instruction(31 downto 25))), 7)), true);
        --If the instruction is of any of the types listed it reads from ra, rb
        --Format 0
        elsif(findFormat(instructionAluOpcode(instruction)) = 0) then
            readReg(0) := (std_logic_vector(to_unsigned(to_integer(unsigned(instruction(24 downto 18))), 7)), true);
            readReg(1) := (std_logic_vector(to_unsigned(to_integer(unsigned(instruction(17 downto 11))), 7)), true);
        --If the instruction is of any of the types listed it reads from only ra
        --Format 1, 3, 4, 8, 9, 10, 11, 12
        elsif(findFormat(instructionAluOpcode(instruction)) = 1 or findFormat(instructionAluOpcode(instruction)) = 3 or findFormat(instructionAluOpcode(instruction)) = 4 or 
             (findFormat(instructionAluOpcode(instruction)) >= 8 and findFormat(instructionAluOpcode(instruction)) <= 12)) then
            readReg(0) := (std_logic_vector(to_unsigned(to_integer(unsigned(instruction(24 downto 18))), 7)), true);
        --If the instruction is of any of the types listed it reads from only rc (rt)
        --Format 7
        elsif(findFormat(instructionAluOpcode(instruction)) = 7) then
            readReg(0) := (std_logic_vector(to_unsigned(to_integer(unsigned(instruction(31 downto 25))), 7)), true);
        --If the instruction is of any of the types listed it reads from none of the registers
        --Formats 5, 6, 13
        else
            readReg(0) := (std_logic_vector(to_unsigned(0, 7)), false);
            readReg(1) := (std_logic_vector(to_unsigned(0, 7)), false);
            readReg(2) := (std_logic_vector(to_unsigned(0, 7)), false);
        end if;

        return readReg;
    end function;

    --This function returns true if the two instructions passed in have a read after write dependency
    --ie the second instruction reads from the register that the first instruction writes to
    --Order of the instructions is important
    --The first intruction is the instruction that is writing and the second is the instruction that is reading
    function readAfterWriteDependency(
        instruction1 : in std_logic_vector(31 downto 0); 
        instruction2 : in std_logic_vector(31 downto 0)
    ) return boolean is
        --Get the register that instruction 1 is writing to
        variable instruction1Rt : std_logic_vector(6 downto 0) := writeRegister(instruction1)(6 downto 0);
		variable instruction2ReadRegisters : readRrArray(0 to 2) := readRegisterInstruction(instruction2);
        
        begin
        --If instruction 1 doesnt write to a register, return false
        if (writeRegister(instruction1)(7) = '1') then
            return false;
        end if;

        --Check if any of the registers that instruction 2 reads from match the register that instruction 1 writes to
        for i in 0 to instruction2ReadRegisters'length - 1 loop
            if (instruction2ReadRegisters(i).rr = instruction1Rt and instruction2ReadRegisters(i).isValid) then
                return true;
            end if;
        end loop;

		return false;
    end function;

    --Function that takes in an instruction and returns the latency if the instruction has a read after write readAfterWriteDependency
    --Instruction1 is the writer and instruction2 is the reader and stallTable is the writer
    --Returns the latency of the instruction if there is a stall else returns 0
    function readAfterWritePrevious(
        instruction1 : in std_logic_vector(31 downto 0);
        instruction2 : in std_logic_vector(31 downto 0);
        stallTable : in stallArray(0 to 13)
    ) return integer is
    begin
        --Check if the instruction has a read after write dependency on the instruction on the same level
        if(readAfterWriteDependency(instruction1, instruction2)) then
            return getLatency(instruction2);
        end if;

        --Check if the instruction has a read after write dependency on the instruction on the previous levels
        for i in 0 to stallTable'length - 1 loop
            if(readAfterWriteDependency(stallTable(i).instruction, instruction2) and stallTable(i).valid) then
                return stallTable(i).latency;
            end if;
        end loop;

        return 0;
    end function;

    --Returns true if the instruction is even
    function isEven(instruction : std_logic_vector(31 downto 0)) return boolean is
        begin
            return(instructionExecutionUnit(instruction) >= 0 and instructionExecutionUnit(instruction) <= 4);
    end function;

    begin
        decode : process(clock) 
            --Array to hold the regsiters that have been written to with their latencies
            --This is to detect read after write dependencies
            variable stallTable : stallArray(0 to 13) := (others => ((others => '0'), 0, false));
			variable executionPipe1 : integer := 0;
        	variable executionPipe2 : integer := 0;
        	variable wasStalled : boolean := false;
        	variable permenantStop : boolean := false;
        	variable stallType : integer := 0; 
        	variable stallAmount : integer := 0;
        	variable stallCounter : integer := 0;
            --Zero indicates a double even stall and 1 indicates a double odd stall
            --Stall types are as follows:
            --Double Even Stall (1 Stall) -> 0
            --Double Odd Stall (1 Stall) -> 1
            --Write after Write (1 Stall) -> 2
            --Read after Write dependency on instruction2 (Stall by the latency of the instruction in the table) -> 3
            --Read after Write dependency on instruction1 (Stall by the latency of the instruction in the table) -> 4
            --Double read after write (Stall by the latency of the bigger one then try and put them out) -> 5
		  	begin
            if(rising_edge(clock)) then
                --Check for stop instruction to see if there is a permenant stop
                --If its instruction 1 completely stop 
                if(instructionAluOpcode(instruction1) = 76) then
                    permenantStop := true;

                --If its instruction 2 put out instruction 1 and then completely stop
                elsif(instructionAluOpcode(instruction2) = 76) then
                    permenantStop := true;

                    --Assign instruction 1 to the proper port
                    if(isEven(instruction1)) then
                        assignInstructionEven(instruction1, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                    else
                        assignInstructionOdd(instruction1, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                    end if;
                end if;

                --If the unit is not stalled
                if (stallIn = '0' and not permenantStop) then
                    --If the previous clock cycle wasn't a stall procede as normal
                    if(not wasStalled) then
                        --If there is a read after write dependency on instruction1 and instruction2 then stall for the latency of the bigger one
                        if(readAfterWritePrevious(instruction1, instruction2, stallTable) /= 0 and readAfterWritePrevious(instruction2, instruction1, stallTable) /= 0) then
                            stallType := 3;
                            wasStalled := true;
                            stall <= '1';

                            --Check which instruction has the bigger latency and stall for that long
                            if(readAfterWritePrevious(instruction1, instruction2, stallTable) > readAfterWritePrevious(instruction2, instruction1, stallTable)) then
                                stallCounter:= readAfterWritePrevious(instruction1, instruction2, stallTable);
                            else
                                stallCounter:= readAfterWritePrevious(instruction2, instruction1, stallTable);
                            end if;

                        --If a read after write dependency is detected for instruction2 set the stall flag to true and the stall type to 3
                        elsif(readAfterWritePrevious(instruction1, instruction2, stallTable) /= 0) then
                            stallType := 3;
                            wasStalled := true;
                            stall <= '1';
                            stallAmount := readAfterWritePrevious(instruction1, instruction2, stallTable);

                            --Assign instruction 1 to the proper port
                            if(isEven(instruction1)) then
                                assignInstructionEven(instruction1, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                            else
                                assignInstructionOdd(instruction1, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                            end if;
                        --If a read after write dependency is detected for instruction1 set the stall flag to true and the stall type to 4
                        elsif(readAfterWritePrevious(instruction2, instruction1, stallTable) /= 0) then
                            stallType := 4;
                            wasStalled := true;
                            stall <= '1';
                            stallAmount := readAfterWritePrevious(instruction2, instruction1, stallTable);

                            if(isEven(instruction2)) then
                                assignInstructionEven(instruction2, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                            else
                                assignInstructionOdd(instruction2, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                            end if;
                        --If a write after write dependency is detected set the stall flag to true and the stall type to 2
                        elsif(writeAfterWriteDependency(instruction1, instruction2)) then
                            --Write out instruction 1 to its port
                            if(isEven(instruction1)) then
                                assignInstructionEven(instruction1, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                            else
                                assignInstructionOdd(instruction1, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                            end if;

                            stallType := 2;
                            wasStalled := true;
                            stall <= '1';
                            stallAmount := 1;
                        --If the first instruction is an even instruction and the second instruction is an odd instruction
                        elsif(isEven(instruction1) and not isEven(instruction2)) then
                            assignInstructionEven(instruction1, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                            assignInstructionOdd(instruction2, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                        --If the first instruction is an odd instruction and the second instruction is an even instruction
                        elsif(not isEven(instruction1) and isEven(instruction2)) then
                            assignInstructionOdd(instruction1, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                            assignInstructionEven(instruction2, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                        --If both instructions are even output instruction 1 to the even port and stall
                        elsif(isEven(instruction1) and isEven(instruction2)) then
                            stall <= '1';
                            assignInstructionEven(instruction1, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                            wasStalled := true;
                            stallType := 0; 
                            stallAmount := 1;
                        --If both instructions are odd output instruction 1 to the odd port and stall
                        elsif(not isEven(instruction1) and not isEven(instruction2)) then
                            stall <= '1';
                            assignInstructionOdd(instruction1, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                            wasStalled := true;
                            stallType := 1;
                            stallAmount := 1;
                        end if;

                    --If the previous clock cycle was a stall
                    else
                        --Double Even Stall (1 Stall) -> 0
                        --If the stall was a double even stall for one cycle
                        if(stallType = 0) then
                            assignInstructionEven(instruction2, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                            wasStalled := false;
                            stall <= '0';
                        --Double Odd Stall (1 Stall) -> 1
                        --If the stall was a double odd stall for one cycle
                        elsif(stallType = 1) then
                            assignInstructionOdd(instruction2, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                            wasStalled := false;
                            stall <= '0';
                        --Write after Write (1 Stall) -> 2
                        elsif(stallType = 2) then
                            --Put instruction2 on the correct line
                            if(isEven(instruction2)) then
                                assignInstructionEven(instruction2, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                            else
                                assignInstructionOdd(instruction2, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                            end if;
                            wasStalled := false;
                            stall <= '0';
                        --Read after Write dependency on instruction2 (Stall by the latency of the instruction in the table) -> 3
                        elsif(stallType = 3) then
                            if(stallCounter = stallAmount) then
                                --If the counter is equal to the amount of stalls, then we can put the instruction on the correct line and unstall
                                if(isEven(instruction2)) then
                                    assignInstructionEven(instruction2, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                                else
                                    assignInstructionOdd(instruction2, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                                end if;
                                
                                wasStalled := false;
                                stall <= '0';
                                stallCounter := 0;
                            end if;

                            stallCounter := stallCounter + 1;
                        --Read after Write dependency on instruction1 (Stall by the latency of the instruction in the table) -> 4
                        elsif(stallType = 4) then
                            --If the counter is equal to the amount of stalls, then we can put the instruction on the correct line and unstall
                            if(stallCounter = stallAmount) then
                                --Put instruction1 on the correct line
                                if(isEven(instruction1)) then
                                    assignInstructionEven(instruction1, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                                else
                                    assignInstructionOdd(instruction1, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                                end if;
                                
                                wasStalled := false;
                                stall <= '0';
                                stallCounter := 0;
                            end if;

                            stallCounter := stallCounter + 1;
                        --Double read after write (Stall by the latency of the bigger one then try and put them out) -> 5
                        --If there is a double dependency we are going to stall for the bigger number of cycles and put one out then wait a cycle and put the other
                        elsif(stalLType = 5) then
                            --If the counter is equal to the amount of stalls, then we can put the instruction on the correct line and unstall
                            if(stallCounter = stallAmount) then
                                --Put instruction1 on the correct line
                                if(isEven(instruction1)) then
                                    assignInstructionEven(instruction1, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                                else
                                    assignInstructionOdd(instruction1, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                                end if;
                                
                            --If the counter is equal to one more than the amount of stalls, then we can put the instruction on the correct line and unstall
                            elsif(stallCounter = stallAmount + 1) then
                                --Put instruction1 on the correct line
                                if(isEven(instruction2)) then
                                    assignInstructionEven(instruction2, rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE);
                                else
                                    assignInstructionOdd(instruction2, rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                                end if;

                                wasStalled := false;
                                stall <= '0';
                                stallCounter := 0;
                            end if;

                            stallCounter := stallCounter + 1;
                        else
                            assert false report "Stall type not valid" severity error;
                        end if;
                    end if;
                --If there is a stall in the input then output all zeros
                else
                    wasStalled := false;
                    stallType := 0;
                    assignZeroAll
                    (rbE, raE, rtE, rtRRRE, ALUOPE, I7E, I10E, I16E, I18E, typeE, regWriteE, instructionCountE,
                     rbO, raO, rtO, rtRRRO, ALUOPO, I7O, I10O, I16O, I18O, typeO, regWriteO, instructionCountO);
                end if;

                --Shift over the stall table twice and read in the new instructions
                --The instructions are invalid if the unit is stalled or the unit stalled itself
                for i in 0 to 1 loop
                    for j in 1 to stallTable'length - 1 loop
                        stallTable(stallTable'length - j) := stallTable(stallTable'length - j - 1);
                    end loop;
                end loop;

                --Put the instructions into the table
                stallTable(0).instruction := instruction1;
                stallTable(1).instruction := instruction2;
                stallTable(0).latency := getLatency(instruction1);
                stallTable(1).latency := getLatency(instruction2);

                --If the unit is stalled then the instruction is invalid 
                if(stallIn = '1' or permenantStop or wasStalled) then
                    stallTable(0).valid := false;
                    stallTable(1).valid := false;
                --else it is valid
                else
                    stallTable(0).valid := true;
                    stallTable(1).valid := true;
                end if;

            end if;
        end process;
end Behavioral;
