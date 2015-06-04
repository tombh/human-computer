# A Zlib decompression library in just 3k!
inflate = require 'tiny-inflate'

# To save bandwidth when receiving large JSON objects from the API, Zlib compression is used. We
# use a tiny JS implementation of Zlib's inflate protocol (3kb unminified!) to inflate in the
# browser. In order to send Zlib compressed data over HTTP it must be first Base64 encoded.
class Decompress
  # Convert an array of bytes (typically deflated data) to a string
  @ab2str: (buffer) ->
    str = ''
    bytes = new Uint8Array(buffer)
    for i in [0...bytes.length]
      str += String.fromCharCode(bytes[i])
    str

  # Convert a string to an array of bytes suitable for inflation
  @str2ab: (string) ->
    array = new Array string.length
    for i in [0...string.length]
      array[i] = string.charCodeAt(i)
    new Uint8Array array

  @decompress: (base64EncodedString, decompressedSize) ->
    # Use the browser's native Base64 decoder
    base64Decoded = window.atob base64EncodedString
    compressedBuffer = Decompress.str2ab base64Decoded
    outputBuffer = new Uint8Array(decompressedSize)
    # Call out to the tiny-inflate library to inflate the data
    inflate(compressedBuffer, outputBuffer)
    Decompress.ab2str outputBuffer

module.exports = Decompress
