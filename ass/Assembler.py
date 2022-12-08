#!/usr/bin/python3
import sys
import argparse

class Assembler():
    labels = {}
    jpoint_instrs = {}
    RType = ['ADD', 'ADDU', 'ADDC', 'ADDCU', 'SUB', 'CMP', 'CMPU', 'AND', 'OR', 'XOR','MOV']
    Immediates = ['ADDI', 'ADDUI', 'ADDCI', 'ADDCUI', 'SUBI', 'CMPI', 'CMPUI', 'ANDI', 'ORI', 'XORI','MOVI','LUI']
    Shift = ['LSH', 'RSH', 'ALSH', 'ARSH']
    ImmdShift = ['LSHI', 'RSHI', 'ALSHI', 'ARSHI']
    Branch = ['BEQ', 'BNE', 'BGE', 'BCS', 'BCC', 'BHI', 'BLS', 'BLO', 'BHS', 'BGT', 'BLE', 'BFS', 'BFC', 'BLT', 'BUC']
    Jump = ['JEQ', 'JNE', 'JGE', 'JCS', 'JCC', 'JHI', 'JLS', 'JLO', 'JHS', 'JGT', 'JLE', 'JFS', 'JFC', 'JLT', 'JUC']
    REGISTERS = ['%r0', '%r1', '%r2', '%r3', '%r4', '%r5', '%r6', '%r7', '%r8', '%r9', '%r10', '%r11', '%r12', '%r13', '%r14', '%r15']

    def ADD():
        return '0101'

    def ADDU():
        return '0110'

    def ADDC():
        return '0111'

    def ADDCU():
        return '0100'

    def ADDCUI():
        return '1010'

    def SUB():
        return '1001'

    def CMP():
        return '1011'

    def CMPU():
        return '1000'

    def CMPUI():
        return '1100'

    def AND():
        return '0001'

    def OR():
        return '0010'

    def XOR():
        return '0011'

    def LSH():
        return '0100'

    def LSHI():
        return '0000'

    def RSH():
        return '0101'

    def RSHI():
        return '0011'

    def ALSH():
        return '0110'

    def ALSHI():
        return '1000'

    def ARSH():
        return '0111'

    def ARSHI():
        return '1011'

    def EQ():
        return '0000'
    
    def NE():
        return '0001'
    
    def GE():
        return '1101'
    
    def CS():
        return '0010'
    
    def CC():
        return '0011'
    
    def HI():
        return '0100'
    
    def LS():
        return '0101'
    
    def LO():
        return '1010'
    
    def HS():
        return '1011'
    
    def GT():
        return '0110'
    
    def LE():
        return '0111'
    
    def FS():
        return '1000'
    
    def FC():
        return '1001'
    
    def LT():
        return '1100'
    
    def UC():
        return '1110'

    def MOV():
        return '1101'

    def LUI():
        return '1111'


    switcher = {
        'ADD': ADD,
        'ADDU': ADDU,
        'ADDC': ADDC,
        'ADDCU': ADDCU,
        'SUB': SUB,
        'CMP': CMP,
        'CMPU': CMPU,
        'AND': AND,
        'OR': OR,
        'XOR': XOR,
        'ADDI': ADD,
        'ADDUI': ADDU,
        'ADDCI': ADDC,
        'ADDCUI': ADDCUI,
        'SUBI': SUB,
        'CMPI': CMP,
        'CMPUI': CMPUI,
        'ANDI': AND,
        'ORI': OR,
        'XORI': XOR,
        'LSH': LSH,
        'LSHI': LSHI,
        'RSH': RSH,
        'RSHI': RSHI,
        'ALSH': ALSH,
        'ALSHI': ALSHI,
        'ARSH': ARSH,
        'ARSHI': ARSHI,
        'EQ' : EQ,
        'NE' : NE,
        'GE' : GE,
        'CS' : CS,
        'CC' : CC,
        'HI' : HI,
        'LS' : LS,
        'LO' : LO,
        'HS' : HS,
        'GT' : GT,
        'LE' : LE,
        'FS' : FS,
        'FC' : FC,
        'LT' : LT,
        'UC' : UC,
        'MOV': MOV,
        'MOVI': MOV,
        'LUI': LUI
    }

    def instrCode(self, name):
        func = self.switcher.get(name)
        return func()
    
    def replaceLabel(self, label):
        def r(l):
           if (l[0] == '.'):
                  return '$' + str(self.labels[l])
           else:
                  return l

        if (label.startswith('JPT')):
            return label
        else:
            m = map(r, label.split())
            return ' '.join(m)
        
    def __init__(self, args):
        # find the labels and their addresses
        f = open(args.file, 'r')

        address = -1

        for x in f:
            line = x.split('#')[0] # catch a # comment after a command
            parts = line.split()
            
            if (len(parts) > 0):
                if (line[0] == '.'):
                    labelAddress = address + 1

                    if (labelAddress % 2 == 0):
                       odd = False
                    else:
                       odd = True
                       labelAddress -= 1
                       
                    count = 0
                    # reduce to shift for 8-bit immediate
                    while labelAddress > 127:
                       labelAddress /= 2
                       count += 1

                    label = parts.pop(0)

                    self.jpoint_instrs[label] = {
                       'initial_immd': labelAddress,
                       'shift_count': count,
                       'is_odd': odd	
                    }	
                    if odd:
                        # if it is odd, we have to correct for the -1 above
                        self.labels[label] = labelAddress + 1
                    else:
                        self.labels[label] = labelAddress
                elif (parts[0] == 'JPT'):
                    # JPT gets expanded into 4 instructions to do a jump to label
                    address = address + 4
                else:
                    address = address + 1

        f.close()

        print(self.labels)

        f = open(args.file, 'r')
        out_name = str(args.file.rsplit('.', 1)[0] + '.bin')
        wf = open(out_name, 'w')
        sf = open('stripped.mc', 'w')

        address = -1
        for x in f:
            line = x.split('#')[0]
            parts = self.replaceLabel(line).split()
            if ((len(parts) > 0) and (line[0] != '.')):
                for part in parts:
                    sf.write(part + ' ')
                sf.write('\n')
                address = address + 1
                instr = parts.pop(0)
                if (instr in self.RType):
                    if (len(parts) == 2):
                        print(parts)
                        firstReg = parts.pop(0)
                        secondReg = parts.pop(0)
                        if ((firstReg in self.REGISTERS) and (secondReg in self.REGISTERS)):
                            firstRegNum = '{0:04b}'.format(int(firstReg.replace('%r', '')))
                            secondRegNum = '{0:04b}'.format(int(secondReg.replace('%r', '')))
                            data = '0000' + secondRegNum + self.instrCode(instr) + firstRegNum
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: R-type needs two registers')
                    else:
                        sys.exit('Syntax Error: R-type needs two args')
                elif (instr in self.Immediates):
                    if (len(parts) == 2):
                        Immd = parts.pop(0)
                        secondReg = parts.pop(0)
                        if ((Immd[0] in '$') and (secondReg in self.REGISTERS)):
                            immdInt = int(Immd.replace('$', ''))
                            if ((immdInt > 127) or (-128 > immdInt)):
                                print('issue with ', line)
                                sys.exit('Syntax Error: Immediate can not be larger then 127 or less then -128, got ' + str(immdInt))
                            elif (immdInt >= 0): 
                                immediate = '{0:08b}'.format(immdInt)
                            else:
                                immediate = '{0:08b}'.format(((-1 * immdInt) ^ 255) + 1)
                            secondRegNum = '{0:04b}'.format(int(secondReg.replace('%r', '')))
                            data = self.instrCode(instr) + secondRegNum + immediate
                            wf.write(data + '\n')
                        else:
                            print(line)
                            sys.exit('Syntax Error: Immediate operations need an immd then a register')
                    else:
                        sys.exit('Syntax Error: Immediate operations need two args: ' + line)
                elif (instr in self.Shift):
                   if (len(parts) == 2):
                        firstReg = parts.pop(0)
                        secondReg = parts.pop(0)
                        if ((firstReg in self.REGISTERS) and (secondReg in self.REGISTERS)):
                            firstRegNum = '{0:04b}'.format(int(firstReg.replace('%r', '')))
                            secondRegNum = '{0:04b}'.format(int(secondReg.replace('%r', '')))
                            data = '1000' + secondRegNum + self.instrCode(instr) + firstRegNum
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: shifts needs two self.REGISTERS')
                   else:
                       sys.exit('Syntax Error: shifts needs two args')
                elif (instr in self.ImmdShift):
                    if (len(parts) == 2):
                        Immd = parts.pop(0)
                        secondReg = parts.pop(0)
                        if ((Immd[0] in '$') and (secondReg in self.REGISTERS)):
                            immdInt = int(Immd.replace('$', ''))
                            if ((immdInt > 15) or (0 > immdInt)):
                                sys.exit('Syntax Error: Immediate can not be larger then 15 or less then 0')
                            else:  
                                immediate = '{0:04b}'.format(immdInt)
                            secondRegNum = '{0:04b}'.format(int(secondReg.replace('%r', '')))
                            data = '1000' + secondRegNum + self.instrCode(instr) + immediate
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: Immediate shifts need an immd then a register')
                    else:
                        sys.exit('Syntax Error: Immediate shifts need two args')
                elif (instr in self.Branch):
                    if (len(parts) == 1):
                        Disp = parts.pop(0)
                        if (Disp[0] in '$'):
                            dispInt = int(Disp.replace('$', ''))
                            if ((dispInt > 255) or (-255 > dispInt)):
                                sys.exit('Syntax Error: Branch can not be larger then 255 or less then -255')
                            elif (dispInt >= 0): 
                                Displacement = '{0:08b}'.format(dispInt)
                            else:
                                Displacement = '{0:08b}'.format(((-1 * dispInt) ^ 255) + 1)
                            data = '1100' + self.instrCode(instr.replace('B', '')) + Displacement
                            wf.write(data + '\n')
                        elif (Disp[0] in '.'):
                            dispInt = self.labels[Disp] - address
                            if ((dispInt > 255) or (-255 > dispInt)):
                                sys.exit('Syntax Error: Branch can not be larger then 255 or less then -255')
                            elif (dispInt >= 0): 
                                Displacement = '{0:08b}'.format(dispInt)
                            else:
                                Displacement = '{0:08b}'.format(((-1 * dispInt) ^ 255) + 1)
                            data = '1110' + instrCode(instr.replace('B', '')) + Displacement
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: Branch operations need a displacement or label')
                    else:
                        sys.exit('Syntax Error: Branch operations need one arg')
                elif (instr in self.Jump):
                    if (len(parts) == 1):
                        firstReg = parts.pop(0)
                        if ((firstReg in self.REGISTERS)):
                            firstRegNum = '{0:04b}'.format(int(firstReg.replace('%r', '')))
                            data = '0100' + self.instrCode(instr.replace('J', '')) + '1100' + firstRegNum
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: Jump operations need a register')
                    else:
                        sys.exit('Syntax Error: Jump operations need one arg')
                elif (instr == 'NOT'):
                    if (len(parts) == 1):
                        firstReg = parts.pop(0)
                        if ((firstReg in self.REGISTERS)):
                            firstRegNum = '{0:04b}'.format(int(firstReg.replace('%r', '')))
                            data = '0000' + firstRegNum + '11110000'
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: NOT operation needs one register')
                    else:
                        sys.exit('Syntax Error: NOT operation needs one arg')
                elif (instr == 'LOAD'):
                   if (len(parts) == 2):
                        firstReg = parts.pop(0)
                        secondReg = parts.pop(0)
                        if ((firstReg in self.REGISTERS) and (secondReg in self.REGISTERS)):
                            firstRegNum = '{0:04b}'.format(int(firstReg.replace('%r', '')))
                            secondRegNum = '{0:04b}'.format(int(secondReg.replace('%r', '')))
                            data = '0100' + firstRegNum + '0000' + secondRegNum
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: load needs two registers')
                   else:
                       sys.exit('Syntax Error: load needs two args')
            
                elif (instr == 'STOR'):
                   if (len(parts) == 2):
                        firstReg = parts.pop(0)
                        secondReg = parts.pop(0)
                        if ((firstReg in self.REGISTERS) and (secondReg in self.REGISTERS)):
                            firstRegNum = '{0:04b}'.format(int(firstReg.replace('%r', '')))
                            secondRegNum = '{0:04b}'.format(int(secondReg.replace('%r', '')))
                            data = '0100' + firstRegNum + '0100' + secondRegNum
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: store needs two registers')
                   else:
                       sys.exit('Syntax Error: store needs two args')
                elif (instr == 'LUI'):
                    Rdest = parts.pop(0)
                    Immd = parts.pop(1)
                    data = '1111' + Rdest + Immd
                    wf.write(data + '\n')
                elif (instr == 'JALR'):
                    if (len(parts) == 2):
                        firstReg = parts.pop(0)
                        secondReg = parts.pop(0)
                        if ((firstReg in self.REGISTERS) and (secondReg in self.REGISTERS)):
                            firstRegNum = '{0:04b}'.format(int(firstReg.replace('%r', '')))
                            secondRegNum = '{0:04b}'.format(int(secondReg.replace('%r', '')))
                            data = '0100' + firstRegNum + '1000' + secondRegNum
                            wf.write(data + '\n')
                        else:
                            sys.exit('Syntax Error: JALR needs two registers')
                    else:
                        sys.exit('Syntax Error: JALR needs two args')
                elif (instr == 'NOP'):
                   if (len(parts) == 0):
                        data = '0000000000000000'
                        wf.write(data + '\n')
                   else:
                       sys.exit('Syntax Error: NOP has no arguments!')

                # pseudo-instruction to point to jump addresses
                elif (instr == 'JPT'):
                    if (len(parts) != 2):
                        sys.exit('Syntax Error: JPT needs a pointer and a register')
                    pointer = parts.pop(0)
                    reg = parts.pop(0)
                    if not self.jpoint_instrs.has_key(pointer):
                        sys.exit('Syntax Error: pointer not found: ' + pointer)
                    if (reg not in self.REGISTERS):
                        sys.exit('Invalid register')

                    instr_data = self.jpoint_instrs[pointer]
                    immediate = '{0:08b}'.format(instr_data['initial_immd'])
                    regNumber = '{0:04b}'.format(int(reg.replace('%r', '')))
                    shift_amt = '{0:04b}'.format(instr_data['shift_count'])
                    zero_out = self.instrCode('ANDI') + regNumber + '00000000'
                    or_in = self.instrCode('ORI') + regNumber + immediate
                    shift = '1000' + regNumber + self.instrCode('LSHI') + shift_amt
                    if instr_data['is_odd']:
                       add = self.instrCode('ADDI') + regNumber + '00000001'
                    else:
                       add = self.instrCode('ADDI') + regNumber + '00000000'
                    wf.write(zero_out + '\n')
                    wf.write(or_in + '\n')
                    wf.write(shift + '\n')
                    wf.write(add + '\n')
                    # increment address to adjust for the extra instructions
                    address += 3
                else:
                    sys.exit('Syntax Error: not a valid instruction: ' + line)

        while(address < 1023):
            wf.write('0000000000000000\n')
            address = address + 1
        wf.close()
        f.close()

def main():
    parser = argparse.ArgumentParser(description='This is the Assembler')
    parser.add_argument('-f', dest='file')
    args = parser.parse_args()
    assembler = Assembler(args)
  
if __name__ == "__main__":
    main()
