from myhdl import *


from component_rs232rx import rs232rx


clk = Signal(False)
toTx = Signal(intbv(0x00, min=0, max=256))
rxdata = Signal(intbv(0x00, min=0, max=256))
baudDiv = Signal(intbv(min=0, max=2**24))
txValid = Signal(False)
rxValid = Signal(False)
txReady = Signal(False)
txd = Signal(True)
reset = Signal(False)

rs232rx_inst = toVHDL(rs232rx, reset, rxdata, rxValid, txd, clk, baudDiv);

