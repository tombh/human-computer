# Simple logging shim which allows log messages to be filtered and redirected to a logging solution
# of your choice when debugging.
#
# Taken from: https://gist.github.com/jonnyreeves/2595747

slice = Array::slice

Logger =
  DEBUG: 1
  INFO: 2
  WARN: 4
  ERROR: 8
  OFF: 99
  logFunc: null
  level: null
  debug: ->
    if @logFunc and Logger.DEBUG >= @level
      @logFunc.apply null, slice.call(arguments).splice(0, 0, Logger.INFO)
  info: ->
    if @logFunc and Logger.INFO >= @level
      @logFunc.apply null, [ Logger.INFO ].concat(slice.call(arguments))
  warn: ->
    if @logFunc and Logger.WARN >= @level
      @logFunc.apply null, [ Logger.WARN ].concat(slice.call(arguments))
  error: ->
    if @logFunc and Logger.ERROR >= @level
      @logFunc.apply null, [ Logger.ERROR ].concat(slice.call(arguments))

# Returns a String which represents the supplied log level value.
Logger.getLevelName = (level) ->
  switch level
    when Logger.INFO
      'INFO'
    when Logger.DEBUG
      'DEBUG'
    when Logger.WARN
      'WARN'
    when Logger.ERROR
      'ERROR'
    else
      ''
  return

# Aliases.
Logger.log = Logger.info
# Default configuration
Logger.level = Logger.ERROR

Logger.logFunc = (msgLvl) ->
  hdlr = console.log
  # Delegate through to custom error loggers if present.
  if msgLvl == Logger.WARN and console.warn
    hdlr = console.warn
  else if msgLvl == Logger.ERROR and console.error
    hdlr = console.error
  hdlr.apply console, slice.call(arguments, [ 1 ])

module.exports = Logger
