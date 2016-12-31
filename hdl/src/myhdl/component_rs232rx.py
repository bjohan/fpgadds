from myhdl import *

def rs232rx(rxdata, rxValid, rxd, clk, baudDiv):
    baudTick = Signal(False)
    baudCnt = Signal(intbv(min=0, max=2**24))
    currentBit = Signal(intbv(0, min=0, max=11));
    completeWord = Signal(intbv(0, min=0, max=1024))

    @always(clk.posedge)
    def logic():
        if currentBit > 0:
            baudCnt.next = baudCnt +1;
            if baudCnt == 2*baudDiv:
                baudCnt.next = 0

                baudTick.next = True
            else:
                baudTick.next = False

        #Start bit detected, start the baud clock with half cycle delay
        if rxd == False and currentBit == 0:
            currentBit.next = 1;
            baudCnt.next = baudDiv;

        #Count the bits
        if baudTick and currentBit > 0:
            if currentBit < 10:
                currentBit.next = currentBit + 1
            else:
                currentBit.next = 0

        if currentBit > 1 and baudTick and currentBit < 10:
            rxdata.next[currentBit-2] = rxd
            currentBit.next = currentBit +1

        if currentBit == 10 and rxd == True and baudTick:
            rxValid.next = True
        else:
            rxValid.next = False
    return logic
