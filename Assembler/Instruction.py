from enum import Enum

class Format(Enum):
    RR = 0
    RRR = 1
    RI7 = 2
    RI8 = 3
    RI10 = 4
    RI16 = 5
    RI18 = 6
    RR2 = 7
    SPECIAL = 8

class Instruction():    
    def __init__(self, opcode, format):
        self.opcode = opcode
        self.format = format

    def __str__(self):
        return str(self.opcode) + " " + str(self.format)


#Returns the binary representation of a register
def getRegister(register):
    register = register.lower()

    if register[0] == 'r':
        register = register[1:]

    return bin(int(register))[2:].zfill(7)

#Returns the binary representation of a n-bit immediate
def binRep(immediate, n):
    return bin(int(immediate))[2:].zfill(n)

"""
Instruction Formats

Normal Versions
RR-> op rt, ra, rb (11 bit opcode)
RRR-> op rt, ra, rb, rc (4 bit opcode)
RI7-> op rt, ra, 7-bit (11 bit opcode)
RI8-> op rt, ra, 8-bit (10 bit opcode)
RI10-> op rt, ra, 10-bit (8 bit opcode)
RI16-> op rt, ra, 16-bit (9 bit opcode)
RI18-> op rt, 18-bit (7 bit opcode)
RR2-> op rt, ra (11 bit opcode)

Registers are numbered R0-R127

Special Versions
lnop 
nop
stop
"""

Instructions = {
    #Instrunctions used
    #Simple Fixed 1
    "a" : Instruction(0b00011000000, Format.RR),
    "addx" : Instruction(0b01101000000, Format.RR),
    "ai" : Instruction(0b00011100, Format.RI10),
    "and" : Instruction(0b00011000001, Format.RR),
    "andbi" : Instruction(0b00010110, Format.RI10),
    "andhi" : Instruction(0b00010101, Format.RI10),
    "andc" : Instruction(0b01011000001, Format.RR),
    "bg" : Instruction(0b00001000010, Format.RR),
    "ceq" : Instruction(0b01111000000, Format.RR),
    "ceqb" : Instruction(0b01111010000, Format.RR),
    "ceqbi" : Instruction(0b01111110, Format.RI10),
    "ceqi" : Instruction(0b01111100, Format.RI10),
    "cg" : Instruction(0b00011000010, Format.RR),
    "cgtb" : Instruction(0b01001010000, Format.RR),
    "cgtbi" : Instruction(0b01001110, Format.RI10),
    "cgti" : Instruction(0b01001100, Format.RI10),
    "clgt" : Instruction(0b01011000000, Format.RR),
    "clgti" : Instruction(0b01011100, Format.RI10),
    "clgtb" : Instruction(0b01011010000, Format.RR),
    "clgtbi" : Instruction(0b01011110, Format.RI10),
    "eqv" : Instruction(0b01001001001, Format.RR),
    "il" : Instruction(0b010000001, Format.RI16),
    "ila" : Instruction(0b0100001, Format.RI18),
    "ilh" : Instruction(0b010000011, Format.RI16),
    "nand" : Instruction(0b00011001001, Format.RR),
    "nor" : Instruction(0b00001001001, Format.RR),
    "or" : Instruction(0b00001000001, Format.RR),
    "ori" : Instruction(0b00000100, Format.RI10),
    "orc" : Instruction(0b01011001001, Format.RR),
    "orx" : Instruction(0b00111110000, Format.RR2),
    "sf" : Instruction(0b00001000000, Format.RR),
    "sfi" : Instruction(0b00001100, Format.RI10),
    "sfx" : Instruction(0b01101000001, Format.RR),
    "xor" : Instruction(0b01001000001, Format.RR),
    "xorbi" : Instruction(0b01000110, Format.RI10),
    "xori" : Instruction(0b01000100, Format.RI10),
    "xsbh" : Instruction(0b01010110110, Format.RR2),
    "xshw" : Instruction(0b01010101110, Format.RR2),
    "xswd" : Instruction(0b01010100110, Format.RR2),

    #Simple Fixed 2
    "rot" : Instruction(0b00001011000, Format.RR),
    "roti" : Instruction(0b00001111000, Format.RI7),
    "rotm" : Instruction(0b00001011001, Format.RR),
    "rotmi" : Instruction(0b00001111001, Format.RI7),
    "rotmai" : Instruction(0b00001111010, Format.RI7),
    "shl" : Instruction(0b00001011011, Format.RR),
    "shli" : Instruction(0b00001111011, Format.RI7),

    #Byte
    "absdb" : Instruction(0b00001010011, Format.RR),
    "avgb" : Instruction(0b00011010011, Format.RR),
    "cntb" : Instruction(0b01010110100, Format.RR2),
    "sumb" : Instruction(0b01001010011, Format.RR),

    #Branch
    "br" : Instruction(0b001100100, Format.RI16),
    "bra" : Instruction(0b001100000, Format.RI16),
    "brasl" : Instruction(0b001100010, Format.RI16),
    "brsl" : Instruction(0b001100110, Format.RI16),
    "brnz" : Instruction(0b001000010, Format.RI16),
    "brz" : Instruction(0b001000000, Format.RI16),
    
    #Permute
    "rotqby" : Instruction(0b00111011100, Format.RR),
    "rotqbyi" : Instruction(0b00111111100, Format.RI7),
    "rotqmby" : Instruction(0b00111011101, Format.RR),
    "rotqmbyi" : Instruction(0b00111111101, Format.RI7),
    "shlqby" : Instruction(0b00111011111, Format.RR),
    "shlqbyi" : Instruction(0b00111111111, Format.RI7),
    
    #Load Store
    "lqa" : Instruction(0b001100001, Format.RI16), 
    "lqx" : Instruction(0b00111000100, Format.RR), 
    "stqa" : Instruction(0b001000001, Format.RI16),
    "stqx" : Instruction(0b00101000100, Format.RR),

    #Floating Point
    "fa" : Instruction(0b01011000100, Format.RR),
    "fm" : Instruction(0b01011000110, Format.RR),
    "fma" : Instruction(0b1110, Format.RRR),
    "fms" : Instruction(0b1111, Format.RRR),
    "fs" : Instruction(0b01011000101, Format.RR),
    "fceq" : Instruction(0b01111000010, Format.RR),
    "fcgt" : Instruction(0b01011000010, Format.RR),
    "mpy" : Instruction(0b01111000100, Format.RR),
    "mpya" : Instruction(0b1100, Format.RRR),
    "mpyi" : Instruction(0b01110100, Format.RI10),
    "mpys" : Instruction(0b01111000111, Format.RR),
    "mpyu" : Instruction(0b01111001100, Format.RR),
    "mpyui" : Instruction(0b01110101, Format.RI10),

    #Control Instructions
    "lnop" : Instruction(0b00000000001, Format.SPECIAL),
    "nop" : Instruction(0b01000000001, Format.SPECIAL),
    "stop" : Instruction(0b00000000000, Format.SPECIAL),



    #Unused instructions
    #Memory-Load/Store Instructions
    "lqd" : Instruction(0b00110100, Format.RI10), 
    "lqr" : Instruction(0b001100111, Format.RI16), 
    "stqd" : Instruction(0b00100100, Format.RI10), 
    "stqr" : Instruction(0b001000111, Format.RI16),
    "cbd" : Instruction(0b00111110100, Format.RI7), 
    "cbx" : Instruction(0b00111010100, Format.RR),
    "chd" : Instruction(0b00111110101, Format.RI7),
    "chx" : Instruction(0b00111010101, Format.RR),
    "cwd" : Instruction(0b00111110110, Format.RI7),
    "cwx" : Instruction(0b00111010110, Format.RR),
    "cdd" : Instruction(0b00111110111, Format.RI7),
    "cdx" : Instruction(0b00111010111, Format.RR),

    #Constant0-Formation Instructions
    "ilhu" : Instruction(0b010000010, Format.RI16),
    "iohl" : Instruction(0b011000001, Format.RI16),
    "fsmbi" : Instruction(0b001100101, Format.RI16),

    #Integer and Logical Instructions
    "ah" : Instruction(0b00011001000, Format.RR),
    "ahi" : Instruction(0b00011101, Format.RI10),
    "sfh" : Instruction(0b00001001000, Format.RR),
    "sfhi" : Instruction(0b00001101, Format.RI10),
    "cgx" : Instruction(0b01101000010, Format.RR),
    "bgx" : Instruction(0b01101000011, Format.RR),
    "mpyh" : Instruction(0b01111000101, Format.RR),
    "mpyhh" : Instruction(0b01111000110, Format.RR),
    "mpyhha" : Instruction(0b01101000110, Format.RR),
    "mpyhhu" : Instruction(0b01111001110, Format.RR),
    "mpyhhau" : Instruction(0b01101001110, Format.RR),
    "clz" : Instruction(0b01010100101, Format.RR),
    "fsmb" : Instruction(0b00110110110, Format.RR),
    "fsmh" : Instruction(0b00110110101, Format.RR),
    "fsm" : Instruction(0b00110110100, Format.RR),
    "gbb" : Instruction(0b00110110010, Format.RR),
    "gbh" : Instruction(0b00110110001, Format.RR),
    "gb" : Instruction(0b00110110000, Format.RR),
    "andi" : Instruction(0b00010100, Format.RI10),
    "orbi" : Instruction(0b00000110, Format.RI10),
    "orhi" : Instruction(0b00000101, Format.RI10),
    "xorhi" : Instruction(0b01000101, Format.RI10),
    "selb" : Instruction(0b1000, Format.RRR),
    "shufb" : Instruction(0b1011, Format.RRR),

    #Shift and Rotate Instructions
    "shlh" : Instruction(0b00001011111, Format.RR),
    "shlhi" : Instruction(0b00001111111, Format.RI7),
    "shlqbi" : Instruction(0b00111011011, Format.RR),
    "shlqbii" : Instruction(0b00111111011, Format.RI7),
    "shlqbybi" : Instruction(0b00111001111, Format.RR),
    "roth" : Instruction(0b00001011100, Format.RR),
    "rothi" : Instruction(0b00001111100, Format.RI7),
    "rotqbybi" : Instruction(0b00111001100, Format.RR),
    "rotqbi" : Instruction(0b00111011000, Format.RR),
    "rotqbii" : Instruction(0b00111111000, Format.RI7),
    "rothm" : Instruction(0b00001011101, Format.RR),
    "rothmi" : Instruction(0b00001111101, Format.RI7),
    "rotqmbybi" : Instruction(0b00111001101, Format.RR),
    "rotqmbi" : Instruction(0b00111011001, Format.RR),
    "rotqmbii" : Instruction(0b00111111001, Format.RI7),
    "rotmah" : Instruction(0b00001011110, Format.RR),
    "rotmahi" : Instruction(0b00001111110, Format.RI7),
    "rotma" : Instruction(0b00001011010, Format.RR),

    #Compare, Branch, and Halt Instructions
    "heq" : Instruction(0b01111011000, Format.RR),
    "heqi" : Instruction(0b01111111, Format.RI10),
    "hqt" : Instruction(0b01001011000, Format.RR),
    "hgti" : Instruction(0b01001111, Format.RI10),
    "hlgt" : Instruction(0b01011011000, Format.RR),
    "hlgti" : Instruction(0b01011111, Format.RI10),
    "ceqh" : Instruction(0b01111001000, Format.RR),
    "ceqhi" : Instruction(0b01111101, Format.RI10),
    "cgth" : Instruction(0b01001001000, Format.RR),
    "cgthi" : Instruction(0b01001101, Format.RI10),
    "cgt" : Instruction(0b01001000000, Format.RR),
    "clgth" : Instruction(0b01011001000, Format.RR),
    "clgthi" : Instruction(0b01011101, Format.RI10),
    "iret" : Instruction(0b001101000, Format.RI16), #<-- This one is definitely wrong 
    "bisled" : Instruction(0b001101110, Format.RI16), #<-- This one is definitely wrong 
    "brhnz" : Instruction(0b001000110, Format.RI16),
    "brhz" : Instruction(0b001000100, Format.RI16),
    "biz" : Instruction(0b001001000, Format.RI16), #<-- This one is definitely wrong
    "binz" : Instruction(0b001001010, Format.RI16), #<-- This one is definitely wrong
    "bihz" : Instruction(0b001001100, Format.RI16), #<-- This one is definitely wrong
    "bihnz" : Instruction(0b001001110, Format.RI16), #<-- This one is definitely wrong

    #Hint-for-Branch Instructions
    "hbr" : Instruction(0b001100101, Format.RI16), #<-- This one is definitely wrong
    "hbra" : Instruction(0b001100001, Format.RI16), #<-- This one is definitely wrong
    "hbrr" : Instruction(0b001100111, Format.RI16), #<-- This one is definitely wrong

    #Floating-Point Instructions
    "dfa" : Instruction(0b01011001100, Format.RR),
    "dfs" : Instruction(0b01011001101, Format.RR),
    "dfm" : Instruction(0b01011001110, Format.RR),
    "dfma" : Instruction(0b01101011100, Format.RR),
    "fnms" : Instruction(0b1101, Format.RRR),
    "dfnms" : Instruction(0b01101011110, Format.RR),
    "dfms" : Instruction(0b01101011101, Format.RR),
    "dfnma" : Instruction(0b01101011111, Format.RR),
    "frest" : Instruction(0b00110111000, Format.RR),
    "frsqest" : Instruction(0b00110111001, Format.RR),
    "fi" : Instruction(0b01111010100, Format.RR),
    "csflt" : Instruction(0b01111010101, Format.RI8), 
    "cflts" : Instruction(0b0111011000, Format.RI8),
    "cuflt" : Instruction(0b0111011011, Format.RI8),
    "cfltu" : Instruction(0b0111011001, Format.RI8),
    "frds" : Instruction(0b01110111001, Format.RR),
    "fesd" : Instruction(0b01110111000, Format.RR),
    "dfceq" : Instruction(0b01111000011, Format.RR),
    "dfcmeq" : Instruction(0b01111001011, Format.RR),
    "dfcgt" : Instruction(0b01011000011, Format.RR),
    "dfcmgt" : Instruction(0b01011001011, Format.RR),
    "dftsv" : Instruction(0b01110111111, Format.RR),
    "fcmeq" : Instruction(0b01111001010, Format.RR),
    "fcmgt" : Instruction(0b01011001010, Format.RR),
    "fscrwr" : Instruction(0b01110111010, Format.RR),
    "fscrrd" : Instruction(0b01110011000, Format.RR),

    #Control Instructions
    "stopd" : Instruction(0b00101000000, Format.RR),
    "sync" : Instruction(0b00000000010, Format.SPECIAL), 
    "dsync" : Instruction(0b00000000011, Format.SPECIAL),
    "mfspr" : Instruction(0b00000001100, Format.SPECIAL),
    "mtspr" : Instruction(0b00100001100, Format.SPECIAL),

    #Channel Instructions
    "rdch" : Instruction(0b00000001101, Format.SPECIAL),
    "rchcnt" : Instruction(0b00000001111, Format.SPECIAL),
    "wrch" : Instruction(0b00100001101, Format.SPECIAL),
}

