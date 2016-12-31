from myhdl import *


from component_rs232tx import rs232tx


clk = Signal(False)
toTx = Signal(intbv(0x00, min=0, max=256))
rxdata = Signal(intbv(0x00, min=0, max=256))
baudDiv = Signal(intbv(min=0, max=2**24))
txValid = Signal(False)
txReady = Signal(False)
txd = Signal(True)

rs232tx_inst = toVHDL(rs232tx, toTx, txValid, txReady, txd, clk, baudDiv);

