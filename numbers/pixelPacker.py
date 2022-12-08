#!/usr/bin/python3
#foreach line:
#map 24-bit pixel value into 3-bit pixel value
# (times 5)
#write that word to a line in the new file

of = open("glyphs.dat","w")
for i in range(0,10):

    f = open(str(i)+".hex","r")
    pixelCounter = 0
    pixelBuffer = ""

    for x in f:
        r = int(x[0:1],16)
        red = 0
        g = int(x[2:3],16)
        green = 0
        b = int(x[4:5],16)
        blue = 0

        if r >= 8:
            red = 1
        if g >= 8:
            green = 1
        if b >= 8:
            blue = 1
        
        pixelBuffer = str(red)+str(green)+str(blue)+"0"+pixelBuffer
        pixelCounter += 1
        if pixelCounter == 4:
            pixelCounter = 0
            of.write(pixelBuffer+"\n")
            pixelBuffer = ""
