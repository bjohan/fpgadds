from myhdl import *

t_State = enum('IDLE', 'WRITE')

startSeq = intbv(0b10)
wrOp = intbv(0b10)
wrTa = intbv(0x01)




def reversebv(inp, outp, n):
    @always_comb
    def logic():
        for i in range(n):
            outp.next[n-i-1] = inp[i]
    return logic

def rmii_smi(clk, mdi, mdo, mdioz, mdc, clkdiv, addr, rdata, wdata, wstart, rstart, busy):
    state = Signal(t_State.IDLE)
    baudTick = Signal(False)
    baudCnt = Signal(intbv(min=0, max=2**24))
    currentBit = Signal(intbv(0, min=0, max=33));
    completeWord = Signal(intbv(0, min=0, max=2**32))
    phyAddrRev = Signal(intbv(0)[5:])
    addrRev = Signal(intbv(0)[4:])
    wdataRev = Signal(intbv(0)[16:])
    #width = Signal(intbv(5))

    phyAddr = Signal(intbv(0x0c)[5:])
    inst_phyAddrReverser = reversebv(phyAddr, phyAddrRev, intbv(5))
    inst_addrReverser = reversebv(addr, addrRev, intbv(4))
    inst_dataReverser = reversebv(wdata, wdataRev, intbv(16));

    @always(clk.posedge)
    def logic():
        if currentBit > 0:
            baudCnt.next = baudCnt +1;
            if baudCnt == 2*clkdiv:
                baudCnt.next = 0

                baudTick.next = True
            else:
                baudTick.next = False
        if baudCnt == 0:
            mdc.next = False;
        if baudCnt == clkdiv:
            mdc.next = True;

        if state == t_State.IDLE:
            if wstart:
                state.next = t_State.WRITE
                busy.next = True;
                currentBit.next = 1
                completeWord.next[2:0]=startSeq #intbv(0x00) #start
                completeWord.next[4:2]=wrOp #intbv(0x03) #write
                completeWord.next[9:4]=phyAddrRev #intbv(0x0c) #default phy addr
                completeWord.next[13:9]=addrRev;
                completeWord.next[15:14]=wrTa #intbv(0x1); #TA
                completeWord.next[31:15]=wdataRev;
                mdioz.next=False;
                mdo.next = startSeq[0] #First bit in start
        elif state == t_State.WRITE:
                if baudTick == True:
                    if currentBit < 32:
                        mdo.next = completeWord[currentBit]
                        currentBit.next = currentBit+1;
                    else:
                        currentBit.next = 0;
                        baudCnt.next = 0;
                        mdioz.next = True;
                        busy.next = False;
                        state.next = t_State.IDLE
            
    return logic, inst_phyAddrReverser, inst_addrReverser, inst_dataReverser
