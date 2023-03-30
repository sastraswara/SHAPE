(
// Load gamelan files
~gamelanBuf = Dictionary();

PathName(~path +/+ "samples").entries.do { |path|
	var instrument, instrumentBuf;

	instrument = path.folderName.asSymbol;

	instrumentBuf = path.files.collect { |file|
		Buffer.readChannel(s, file.fullPath, channels: 1);
	};

	~gamelanBuf.add(instrument -> instrumentBuf);
};
)

// Create a scale with papat
(
[\saron, \peking, \demung].do { |key|
	var newkey;
	newkey = (key.asString ++ "Miring").asSymbol;

	~gamelanBuf.add(newkey ->
		~gamelanBuf[key].select { |buf, i|
			[0, 1, 3, 4, 5].includes(i);
		};
	);
};

['bonang-panerus', 'bonang-barung'].do { |key|
	var newkey;
	newkey = (key.asString ++ "Miring").asSymbol;

	~gamelanBuf.add(newkey ->
		~gamelanBuf[key].select { |buf, i|
			[0, 1, 3, 4, 5, 7, 8, 10, 11, 12].includes(i);
		};
	);
};
)

(
// Synth Def
SynthDef(\grainplay, {
	var sig, trig;
	trig = Dust.kr(\dens.ir(20));
	sig = GrainBuf.ar(1, trig, \gDur.ir(, buf, rate*BufRateScale.kr(buf));