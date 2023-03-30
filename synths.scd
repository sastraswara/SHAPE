// Synth to play wavetable
SynthDef.new(\rebaban, {
	arg buf, freq=300, numBuffers=2, lagtime=0, curvelag=(-4),
	fc=1000, out=0, gate=1, rel=1, amp=0.8, atk=1, done=2, pan=0;

	var detuneSignal, bufpos, fin, sig,
	env, envgen;

	// Wavetable
	detuneSignal = LFNoise1.kr(0.2!8).bipolar(0.2).midiratio;
	bufpos = buf + LFNoise1.kr(0.5).range(0, numBuffers-1);
	fin = freq.varlag(lagtime, curvelag) * detuneSignal;
	sig = VOsc.ar(bufpos, fin);

	// Filter
	sig = LPF.ar(sig, freq: LFNoise2.kr(0.1).range(fc, 4*fc));

	// Envelope
	env = Env.asr(atk, 1, rel);
	envgen = EnvGen.kr(env, gate, doneAction: done);

	// Output
	sig = Splay.ar(sig);
	sig = LeakDC.ar(sig);
	sig = sig * envgen * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;