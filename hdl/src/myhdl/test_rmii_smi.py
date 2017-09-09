from myhdl import *


from component_rmii_smi import rmii_smi

def test_rmii_smi():
    mdi = Signal(False)
    mdo = Signal(False)
    mdioz = Signal(False)
    mdc = Signal(False)
    clkdiv = Signal(intbv(100))
    addr = Signal(intbv(3))
    rdata = Signal(intbv(2**16))
    wdata = Signal(intbv(2**16))
    wstart = Signal(False)
    rstart = Signal(False)
    busy = Signal(False)
    
    clk = Signal(False)
    toTx = Signal(intbv(0xAA, min=0, max=256))
    txValid = Signal(False)
    txReady = Signal(False)
    txd = Signal(False)

    @always(delay(10))
    def clkgen():
        clk.next = not clk

    rmii_smi_inst = rmii_smi(clk, mdi, mdo, mdioz, mdc, clkdiv, addr, rdata, wdata, wstart, rstart, busy)


    @instance
    def stimulus():
        print "Waiting 3 clks"
        for i in range(3):
            yield clk.negedge
        print "Starting to transmit"
        for b in [0xAA, 0x00, 0x01, 0x55, 0xFF, 0xF0, 0x0F]:
            print "wainting for txready"
            if busy:
                yield busy.negedge
            print "Transmitting data"
            yield clk.negedge
            print "sending", b
            wdata.next = b
            wstart.next = True
            if not busy:
                yield busy.posedge
            wstart.next = False

            if busy:
                yield busy.negedge
            print "Waiting 3000 clks"
            for i in range(3000):
                yield clk.negedge
        #    print "Waiting for ack"
        #    yield txReady.negedge, delay(30)
        #    if txReady:
        #        raise StopSimulation, "txValid did not deassert"
        #    yield clk.negedge
        #    print "Deasserting"
        #    txValid.next = False
        #print "wainting for txready"
        #if busy:
        #    yield busy.negedge
        for i in range(3):
            yield clk.negedge
        raise StopSimulation

    return clkgen, rmii_smi_inst, stimulus

traceSignals.name = "test_rmii_smi"
t = traceSignals(test_rmii_smi)
sim = Simulation(t)
sim.run()
