s.boot;
// Bus management
(
var outBus;
var numChannels;

// Set up number of outpus bus channel
numChannels = 8;
s.options.numOutputBusChannels = numChannels;

// Make subbus
~outBus = (0..numChannels-1).collect { |i|
	if (i.even) { s.outputBus.subBus(i, 2) };
};
~outBus = ~outBus.reject { |bus| bus.isNil };
)

// Path loading
(
// Initialize global variables
~path = PathName(thisProcess.nowExecutingPath).parentPath;

// Initialize MIDI Utilities
(~path +/+ "midiutil.scd").load;
)
(
// Load Synths
(~path +/+ "synths.scd").load;
)
(
// Load sonic events
(~path +/+ "drone-ca.scd").load;
)

// Make Cues
(
~cues = CuePlayer.new;
~cues.setCurrent(0);

// MIDI controlling cue
~cueMIDI = {
	MIDIdef.cc(\cue, { | val |
		if (val==127) {
			~cues.next;
			"Cue: ".post;
			~cues.current.postln;
		};
	}, 1, 0, ~deviceID.value("logic"));
};
~cueMIDI.value;

// Drone with cellular automata
~cues.put(1, {
	~runRebabDrone.value;
	~droneControl.value;
});

// Event 2
~cues.put(2, {
	~stopRebabDrone.value;
	~freeDroneControl.value;
	~cues.setCurrent(0);
});
)
)