import matplotlib.pyplot as plt
import numpy as np

class SignalSource:
	def __init__(self, f, a, rate):
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
		return np.sin(phases)

class Filter:
	def __init__(self, i, a):
		self.i = i
		self.l = 0
		self.a = a

	def getSamples(self, n):
		#t = self.getTimeSteps(n)
		s, t = self.i.getSamples(n)
		f = self.filter(s, t)
		return f, t

	def filter(self, s, t):
		return  s, t

class LowPass(Filter):
	def filter(self, s, t):
		output = np.zeros(s.shape)
		for i in range(len(s)):
			self.l = self.l*(1-self.a)+self.a*s[i]
			output[i]=self.l

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

	def getSamples(self, n):
		timeSteps = self.getTimeSteps(n)
		frequencies,t = self.m.getSamples(n)
		phases = 2.0*np.pi*np.multiply(frequencies, timeSteps)
		return self.compute(phases), timeSteps


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
		return np.sin(phases+pm)


def dB(v):
	return 10.0*np.log10(v)
	

def showFft(t, s):
	ftd = np.fft.fftshift(np.fft.fft(s))
	plt.plot(dB(np.abs(ftd)))
	plt.show()
	print "plotted"

rb = PhaseModulatedSine(20, 1,100000)
rbNoise = NoiseSource(0, 0.1, 100000)
rbNoiseLp = LowPass(rbNoise, 0.1)
rb.setModulator(rbNoiseLp)
s, t = rb.getSamples(100000)
showFft(t,s)
plt.show()


n = NoiseSource(0, 1, 100);
f = LowPass(n, 0.1)
s, t  = f.getSamples(10000);
showFft(t, s)
plt.plot(t,s)
plt.show()
#fmo = ConstantSource(1, 1, 100)
#fmf = SignalSource(1,0.1, 100)
#fms = Operator(fmo, fmf)
#fm = FrequencyModulatedSine(1,1,100)
#fm.setModulator(fms)
#s, t = fm.getSamples(300)
#print s.shape
#plt.plot(t, s)

#plt.show()
