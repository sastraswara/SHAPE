(
MIDIClient.init;
MIDIIn.connectAll;

// MIDI Input testing
// Comment out when it is not needed

MIDIdef.cc(\test, { | val, num, chan, src |
	"Value: ".post; val.postln;
	"Num: ".post; num.postln;
	"Channel: ".post; chan.postln;
	"Source: ".post; src.postln;
});


// Get devices ID
~deviceID = { | name |
	var controller;

	controller = MIDIClient.sources.detect { | source |
		source.name.containsi(name);
	};

	// return midi devices id
	controller.uid;
};
)