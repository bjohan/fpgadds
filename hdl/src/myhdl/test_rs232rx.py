from myhdl import *


from component_rs232tx import rs232tx
from component_rs232rx import rs232rx
def test_rs232rx():

    clk = Signal(False)
    toTx = Signal(intbv(0xAA, min=0, max=256))
    rxdata = Signal(intbv(0x00, min=0, max=256))
    txValid = Signal(False)
    rxValid = Signal(False)
    txReady = Signal(False)
    txd = Signal(True)

    @always(delay(10))
    def clkgen():
        clk.next = not clk

    rs232tx_inst = rs232tx(toTx, txValid, txReady, txd, clk)
    rs232rx_inst = rs232rx(rxdata, rxValid, txd, clk);

    @instance
    def stimulus():
        print "Waiting 3 clks"
        for i in range(3):
            yield clk.negedge
        print "Starting to transmit"
        for b in [0xFF, 0xAA, 0x00, 0x01, 0x55, 0xFF, 0xF0, 0x0F]+range(256):
            if not txReady:
                yield txReady.posedge
            yield clk.negedge
            toTx.next = b
            txValid.next = True
            yield txReady.negedge, delay(30)
            if txReady:
                raise StopSimulation, "txValid did not deassert"
            yield clk.negedge
            txValid.next = False

        print "wainting for txready after last transmit"
        if not txReady:
            yield txReady.posedge
        for i in range(3):
            yield clk.negedge
        raise StopSimulation

    return clkgen, rs232tx_inst, rs232rx_inst, stimulus

traceSignals.name = "test_rs232rx"
t = traceSignals(test_rs232rx)
sim = Simulation(t)
sim.run()
