from myhdl import *

def rs232tx(toTx, txValid, txReady, txd, clk):

    #run = Signal(False)
    baudTick = Signal(False)
    baudCnt = Signal(intbv(0))
    #toTx = Signal(intbv(min = 0, max=255))
    #txReady = Signal(True)
    currentBit = Signal(intbv(0, min=0, max=11));
    completeWord = Signal(intbv(0, min=0, max=1024))
    #txd = Signal(True);



    @always(clk.posedge)
    def logic():
        if currentBit > 0:
            baudCnt.next = baudCnt +1;
            if baudCnt == 15:
                baudCnt.next = 0
                baudTick.next = True
            else:
                baudTick.next = False

        if currentBit == 0 and txValid:
            txReady.next = False;
            currentBit.next = 1
            completeWord.next[0] = False;
            completeWord.next[9:1] = toTx;
            completeWord.next[9] = True;
            txd.next = completeWord[0]
        elif currentBit > 0 and currentBit < 10 and baudTick:
            txd.next = completeWord[currentBit]
            currentBit.next = currentBit + 1
        elif currentBit == 10 and baudTick:
            currentBit.next = 0
            txReady.next = True;
        elif currentBit == 0:
            txReady.next = True;


    return logic
