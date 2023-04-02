
file = open("input.asm", "r")
file2 = open("inputAlt.asm", "w")

lines = file.readlines()

for line in lines:
    file2.write(line.replace(",", "").replace("R", ""))

