from myhdl import *


from component_rs232tx import rs232tx

def test_rs232tx():

    clk = Signal(False)
    toTx = Signal(intbv(0xAA, min=0, max=256))
    txValid = Signal(False)
    txReady = Signal(False)
    txd = Signal(False)
    reset = Signal(True)

    @always(delay(10))
    def clkgen():
        clk.next = not clk

    rs232tx_inst = rs232tx(reset, toTx, txValid, txReady, txd, clk)

    @instance
    def stimulus():
        print "Synchronous reset"
        for i in range(3):
            yield clk.negedge
        reset.next = False
        print "Waiting 3 clks"
        for i in range(3):
            yield clk.negedge
        print "Starting to transmit"
        for b in [0xAA, 0x00, 0x01, 0x55, 0xFF, 0xF0, 0x0F]:
            print "wainting for txready"
            if not txReady:
                yield txReady.posedge
            print "Transmitting data"
            yield clk.negedge
            print "sending", b
            toTx.next = b
            txValid.next = True
            print "Waiting for ack"
            yield txReady.negedge, delay(30)
            if txReady:
                raise StopSimulation, "txValid did not deassert"
            yield clk.negedge
            print "Deasserting"
            txValid.next = False
        print "wainting for txready"
        if not txReady:
            yield txReady.posedge
        for i in range(3):
            yield clk.negedge
        raise StopSimulation

    return clkgen, rs232tx_inst, stimulus

traceSignals.name = "test_rs232tx"
t = traceSignals(test_rs232tx)
sim = Simulation(t)
sim.run()
