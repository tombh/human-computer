/**
 * Taken from: https://gist.github.com/jonnyreeves/2595747
**/

var slice = Array.prototype.slice;

// Simple logging shim which allows log messages to be filtered and redirected to a logging solution
// of your choice when debugging.
var Logger = {

	DEBUG: 1,
	INFO: 2,
	WARN: 4,
	ERROR: 8,
	OFF: 99,

	// Handles incoming log messages.
	logFunc: null,

	// Current log level.
	level: null,

	debug: function () {
		if (this.logFunc && Logger.DEBUG >= this.level) {
			this.logFunc.apply(null, slice.call(arguments).splice(0, 0, Logger.INFO));
		}
	},

	info: function () {
		if (this.logFunc && Logger.INFO >= this.level) {
			this.logFunc.apply(null, [Logger.INFO].concat(slice.call(arguments)));
		}
	},

	warn: function () {
		if (this.logFunc && Logger.WARN >= this.level) {
			this.logFunc.apply(null, [Logger.WARN].concat(slice.call(arguments)));
		}
	},

	error: function () {
		if (this.logFunc && Logger.ERROR >= this.level) {
			this.logFunc.apply(null, [Logger.ERROR].concat(slice.call(arguments)));
		}
	}
};

// Returns a String which represents the supplied log level value.
Logger.getLevelName = function(level) {
	switch (level) {
		case Logger.INFO:
			return "INFO";
		case Logger.DEBUG:
			return "DEBUG";
		case Logger.WARN:
			return "WARN";
		case Logger.ERROR:
			return "ERROR";
		default:
			return "";
	}
};

// Aliases.
Logger.log = Logger.info;

// Default configuration
Logger.level = Logger.ERROR;

Logger.logFunc = function(msgLvl) {
	var hdlr = console.log;

	// Delegate through to custom error loggers if present.
	if (msgLvl === Logger.WARN && console.warn) {
		hdlr = console.warn;
	} else if (msgLvl == Logger.ERROR && console.error) {
		hdlr = console.error;
	}

	hdlr.apply(console, slice.call(arguments, [1]));
};

module.exports = Logger;
