from Instruction import *
import argparse

# Get file paths
parser = argparse.ArgumentParser(description='SPU Assembler')
parser.add_argument('input', metavar='input', type=str,
                    nargs=1, help='input file')
parser.add_argument('output', metavar='output', type=str,
                    nargs=1, help='output file')
args = parser.parse_args()

# Open the input file
inputFile = open(args.input[0], 'r')

# Open the output file
outputFile = open(args.output[0], 'w')

# Read the input file
inputLines = inputFile.readlines()

# Put in output file
for line in inputLines:
    instruction = line.strip().lower().split(' ')

    # Get rid of any commas
    for i in range(len(instruction)):
        instruction[i] = instruction[i].replace(',', '')

    # Get the instruction type
    instObj = Instructions[instruction[0]]
    instructionType = instObj.format

    outputFile.write(instruction[0] + "- ")

    # Assemble the instruction
    # op rt, ra, rb
    # |0 op 10||11 rb 17||18 ra 24||25 rt 31|
    if instructionType == Format.RR:
        outputFile.write(
            binRep(instObj.opcode, 11) +
            binRep(int(instruction[3][1:]), 7) +
            binRep(int(instruction[2][1:]), 7) +
            binRep(int(instruction[1][1:]), 7) +
            "\n"
        )
    # Special case for RR
    # op rt, ra
    # |0 op 10||11 // 17||18 ra 24||25 rt 31|
    elif instructionType == Format.RR2:
        outputFile.write(
            binRep(instObj.opcode, 11) +
            binRep(0, 7) +
            binRep(int(instruction[2][1:]), 7) +
            binRep(int(instruction[1][1:]), 7) +
            "\n"
        )
    # op rt, ra, rb, rc
    # |0 op 3||4 rt 10||11 rb 17||18 ra 24||25 rc 31|
    elif instructionType == Format.RRR:
        outputFile.write(
            binRep(instObj.opcode, 4) +
            binRep(int(instruction[1][1:]), 7) +
            binRep(int(instruction[3][1:]), 7) +
            binRep(int(instruction[2][1:]), 7) +
            binRep(int(instruction[4][1:]), 7) +
            "\n"
        )

    # op rt, ra, 7-bit
    # |0 op 10||11 I7 17||18 ra 24||25 rt 31|
    elif instructionType == Format.RI7:
        outputFile.write(
            binRep(instObj.opcode, 11) +
            binRep(int(instruction[3]), 7) +
            binRep(int(instruction[2][1:]), 7) +
            binRep(int(instruction[1][1:]), 7) +
            "\n"
        )

    # op rt, ra, 8-bit
    # |0 op 9||10 I8 17||18 ra 24||25 rt 31|
    elif instructionType == Format.RI8:
        continue

    # op rt, ra, 10-bit
    # |0 op 7||8 I10 17||18 ra 24||25 rt 31|
    elif instructionType == Format.RI10:
        outputFile.write(
            binRep(instObj.opcode, 8) +
            binRep(int(instruction[3]), 10) +
            binRep(int(instruction[2][1:]), 7) +
            binRep(int(instruction[1][1:]), 7) +
            "\n"
        )

    # op rt, 16-bit
    # |0 op 8||9 I16 24||25 rt 31|
    elif instructionType == Format.RI16:
        if instruction[0] == "br" or instruction[0] == "bra":
            outputFile.write(
                binRep(instObj.opcode, 9) +
                binRep(int(instruction[1]), 16) +
                binRep(0, 7) +
                "\n"
            )
        # op ra
        # |0 op 10||11 /DE//// 17||18 RA 24||25 /// 31|
        elif instruction[0] == "bi" or instruction[0] == "bisl":
            outputFile.write(
                binRep(instObj.opcode, 11) +
                binRep(0, 7) +  # These are the /DE//// bits
                binRep(int(instruction[1][1:]), 7) +
                binRep(0, 7) +
                "\n"
            )

        else:
            outputFile.write(
                binRep(instObj.opcode, 9) +
                binRep(int(instruction[2]), 16) +
                binRep(int(instruction[1][1:]), 7) +
                "\n"
            )

    # op rt, 18-bit
    # |0 op 6||7 I18 24||25 rt 31|
    elif instructionType == Format.RI18:
        outputFile.write(
            binRep(instObj.opcode, 7) +
            binRep(int(instruction[2]), 18) +
            binRep(int(instruction[1][1:]), 7) +
            "\n"
        )
    # each one is different
    elif instructionType == Format.SPECIAL:
        if instruction[0] == "lnop":
            outputFile.write(
                binRep(0b00000000001, 11) +
                binRep(0, 21) +
                "\n"
            )
        elif instruction[0] == "nop":
            outputFile.write(
                binRep(0b01000000001, 11) +
                binRep(0, 21) +
                "\n"
            )
        elif instruction[0] == "stop":
            outputFile.write(
                binRep(0, 32) +
                "\n"
            )

    else:
        print("Error: Uknown instruction opcode: " + instruction[0])

# Close the files
inputFile.close()
outputFile.close()
