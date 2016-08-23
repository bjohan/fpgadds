res = 1e-16 %10^-16 resolution
clk= 200e6
nbits = ceil(log2(1/res))
adderBits = 48+4 %dsp48 only has 48 bits, will need to pipeline two.
maxFreq = clk/(2**(nbits-adderBits))
