myOutput = open("output.hex", "r")
otherOutput = open("Instruction.txt", "r")

myLines = myOutput.readlines()
otherLines = otherOutput.readlines()

for i in range(len(myLines)):
    myLines[i] = myLines[i].strip()
    otherLines[i] = otherLines[i].strip()

    split = myLines[i].split(" ")

    if otherLines[i][0] != "0" and otherLines[i][0] != "1":
        continue
    if split[1] != otherLines[i]:
        print("Line " + str(i) + " is different")
        print("My output: " + myLines[i])
        print("Other output: " + otherLines[i])

myOutput.close()
otherOutput.close()
