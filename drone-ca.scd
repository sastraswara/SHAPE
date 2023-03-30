// Event: Play Drone of 30 synths that play cluster
// The cluster evolves based on the celullar automata
// Function to create wave table
(
~createWTable = {
	var wt, wtbuf, nframe;

	nframe = 1024;

	// 4 wave shapes in an array
	wt = Array.fill(4, {
		// Function to generate the wavetable per array
		var numSegments, dataPoints, timePoints, curveValues;
		var env;

		numSegments = rrand(4, 20);
		dataPoints = ({ rrand(0, 1) }.dup(numSegments-1) * [1, -1]).scramble;
		timePoints = { exprand(1, 20) }.dup(numSegments);
		curveValues = { rrand(-20, 20) }.dup(numSegments);

		// make the wavetable
		env = Env(
			levels: [0]++dataPoints++[0], // wave start and end with 0
			times: timePoints,
			curve: curveValues
		);

		// Return it
		env.asSignal(nframe).asWavetable;
	});

	// Load wave shapes array into a buffer
	wtbuf = Buffer.allocConsecutive(4, s, 2*nframe);
	wtbuf.do { | buffer, i | buffer.loadCollection(wt[i]) };

	// Return the buffer
	wtbuf;
};

// Scales and Tuning
~makeLaras = {
	var pelogfreq, pelogratio, pelogBem, pelogBarang,
	pelogBemPat, pelogBarangPat, laras, pelogRes;

	// Laras
	pelogfreq = [572, 614, 680, 792, 840, 910, 1008];
	pelogratio = (pelogfreq / pelogfreq[0]).ratiomidi;

	pelogRes = Tuning.new(
		tuning: pelogratio,
		octaveRatio: 2.01,
		name: \pelogRespati
	);

	// Scale
	pelogBem = ([1, 2, 3, 5, 6] - 1);
	pelogBemPat = ([1, 2, 4, 5, 6] - 1);
	pelogBarang = ([2, 3, 5, 6, 7] - 1);
	pelogBarangPat = ([2, 4, 5, 6, 7] - 1);

	// Build scale and put it in a dictionary
	laras = Dictionary();

	laras.add(\pelogBem -> Scale.new(
		degrees: pelogBem,
		pitchesPerOctave: 7,
		tuning: pelogRes,
		name: \pelogBem
	));

	laras.add(\pelogBemPat -> Scale.new(
		degrees: pelogBemPat,
		pitchesPerOctave: 7,
		tuning: pelogRes,
		name: \pelogBemPat
	));

	laras.add(\pelogBarang -> Scale.new(
		degrees: pelogBarang,
		pitchesPerOctave: 7,
		tuning: pelogRes,
		name: \pelogBarang
	));

	laras.add(\pelogBarangPat -> Scale.new(
		degrees: pelogBarangPat,
		pitchesPerOctave: 7,
		tuning: pelogRes,
		name: \pelogBarangPat
	));

	// Return the scale dictionary
	laras;
};

// Convert degree of laras to frequency
~degLarasToFreq = { | laras, degree |
	laras.degreeToFreq(degree, 12.midicps, 1);
};

// Create Wave Table and Laras
~wt = ~createWTable.value;
~laras = ~makeLaras.value;

// Create CA pattern
~pca = Pca1(Array.fill(30, {
	| i | if(i==20) { 1 } { 0 };
}), 90, inf).asStream;


// Create array of rebab
~runRebabDrone = {
	~synthArr = Array.fill(30, { | i |
		Synth(\rebaban, [
			\buf, ~wt,
			\freq, ~degLarasToFreq.value(~laras[\pelogBem], i),
			\amp, 0.05,
			\gate, 1,
			\rel, 3,
			\atk, 2,
			\pan, i.linlin(0, 29, -1, 1),
			\done, 0,
			\out, ~outBus[0]
		]);
	});
};

~stopRebabDrone = {
	~synthArr.do { | synth |
		synth.set(\done, 2);
		synth.set(\gate, 0);
	};
};

// MIDI Function
~droneControl = {
	// Live Logic
	MIDIdef.cc(\pedal, { | val, num, chan |
		switch(num)
		{ 6 } {
			// Update CA
			var pcaArr;
			if (val==127) {
				pcaArr = ~pca.next;
				pcaArr.do { | gate, i | ~synthArr[i].set(\gate, gate); };
				pcaArr.postln;
			};
		};
	}, srcID: ~deviceID.value("logic"));

	// NanoKontrol
	MIDIdef.cc(\slider, { | val, num, chan |
		switch(num)
		{ 0 } {
			~synthArr.do { |synth|
				synth.set(\amp, val.linlin(0, 127, 0, 0.2));
			};
			"Volume drone: ".post; val.postln;
		};
	}, srcID: ~deviceID.value("nano"));
};

~freeDroneControl = {
	MIDIdef(\pedal).free;
	MIDIdef(\slider).free;
};
)