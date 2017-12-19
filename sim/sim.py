import matplotlib.pyplot as plt
import numpy as np

class Signal:
    def __init__(self, signalName, typeName):
        self.signalName = signalName
        self.typeName = typeName

    def getDescription(self):
            return self.typeName+ " named "+self.signalName;

class SignalSource(Signal):
    def __init__(self, f, a, rate, signalName = "unnamed", typeName = "sine source"):
        Signal.__init__(self, signalName, typeName);
        self.a = a
        self.f =f
        self.t = 0
        self.r = rate

    def getTimeSteps(self, n):
        dt = 1.0/self.r
        tTot = n*dt
        tsteps = np.linspace(self.t, self.t+tTot-dt, n)
        self.t+=tTot
        return tsteps

    def getSamples(self,n):
        """Get n samples from source, autmatically steps time"""
        timeSteps = self.getTimeSteps(n)
        phases = 2.0*np.pi*timeSteps*self.f
        return self.compute(phases)*self.a, timeSteps;

    def compute(self, phases):
        return np.exp(1j*phases)

class Filter(Signal):
    def __init__(self, i):
        self.i = i
        #self.l = 0
        #self.a = a
    
    def getDescription(self):
        return self.i.getDescription()+" filtered by undefined allpass";
    
    def getSamples(self, n):
        #t = self.getTimeSteps(n)
        s, t = self.i.getSamples(n)
        f = self.filter(s, t)
        return f, t

    def filter(self, s, t):
        return  s, t

class LowPass(Filter):
    def __init__(self, i, a):
        Filter.__init__(self, i)
        self.l = None;
        self.a = a;

    def getDescription(self):
        return self.i.getDescription()+" filtered by iir lowpass alpha "+str(self.a);
    
    def filter(self, s, t):
        output = np.zeros(s.shape)
        for i in range(len(s)):
            if self.l is None:
                output[i]=s[i]
            else:
                output[i] = self.l*(1-self.a)+self.a*s[i]
            self.l = output[i]

        return output

class Operator:
    def __init__(self, a, b):
        self.a = a
        self.b = b

    def getSamples(self, n):
        a, t = self.a.getSamples(n)
        b, t2 = self.b.getSamples(n)
        return self.operate(a,b),t
    
    def operate(self, a, b):
        return a+b


class FrequencyModulatedSine(SignalSource):
    def setModulator(self, modulator):
        self.m = modulator
        self.phase = 0

    def getSamples(self, n):
        timeSteps = self.getTimeSteps(n)
        frequencies,t = self.m.getSamples(n)
        phases = np.zeros(frequencies.shape)
        i = 0
        for f in frequencies:
            phases[i] = self.phase;
            self.phase += (self.f+f)*2*np.pi/self.r
            i+=1
        #phases = 2.0*np.pi*np.multiply(frequencies, timeSteps)
        return self.compute(phases)*self.a, timeSteps


class SineSource(SignalSource):
    def __init__(self, f, a, rate, signalName = "unnamed"):
        SignalSource.__init__(self, f, a, rate, signalName, "Sine source");

class SquareSource(SignalSource):
    def __init__(self, f, a, rate, signalName = "unnamed"):
        SignalSource.__init__(self, f, a, rate, signalName, "Square source");

    def compute(self, phases):
        return np.sign(np.exp(1j*phases))

class NoiseSource(SignalSource):
    def compute(self, phases):
        return np.random.rand(phases.shape[0])-0.5

class ConstantSource(SignalSource):
    def compute(self, phases):
        return np.ones(phases.shape[0])

class PhaseModulatedSine(SignalSource):
    def setModulator(self, modulator):
        self.m = modulator

    def compute(self, phases):
        pm, t = self.m.getSamples(phases.shape[0])
        print "pm", pm.shape
        return np.exp(1j*(phases+pm))


def dB(v):
    return 10.0*np.log10(v)
    

def showFft(sig, n):
    s, t = sig.getSamples(n)
    ftd = np.fft.fftshift(np.fft.fft(s))
    plt.plot(dB(np.abs(ftd)))
    plt.show()
    print "plotted"


def showSignal(sig, n):
    s, t = sig.getSamples(n)
    plt.plot(t, s);
    plt.title(sig.getDescription())
    plt.show()



rate = 100000;
stot = rate/10;


sq = SquareSource(20,1,rate , "sq")
sqlp = LowPass(sq, 0.01)
showSignal(sqlp, stot);
exit(1)

#Create simulation of rubidium oscillator, phase noise only
rb = PhaseModulatedSine(20, 1,rate)
rbNoise = NoiseSource(0, 0.1, rate)
rbNoiseLp = LowPass(rbNoise, 0.1)
rb.setModulator(rbNoiseLp)



#Create simulation of crystal oscillator with frequency noise
xt = FrequencyModulatedSine(280, 1, rate)
xtNoise = NoiseSource(0, 2800/4, rate)
xt.setModulator(xtNoise)
showFft(xt, stot)
showSignal(xt, stot)


#s, t = rb.getSamples(100000)
#showFft(t,s)
#plt.show()


#n = NoiseSource(0, 1, 100);
#f = LowPass(n, 0.01)
#s, t  = f.getSamples(10000);
#showFft(t, s)
#plt.plot(t,s)
#plt.show()
#fmo = ConstantSource(1, 1, 100)
#fmf = SignalSource(1,0.1, 100)
#fms = Operator(fmo, fmf)
#fm = FrequencyModulatedSine(1,1,100)
#fm.setModulator(fms)
#s, t = fm.getSamples(300)
#print s.shape
#plt.plot(t, s)

#plt.show()
