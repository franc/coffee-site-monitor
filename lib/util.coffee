util = require("util")

util.asyncForEach = (array, fn, callback) ->
  completed = 0
  callback() if array.length is 0
  len = array.length
  i = 0

  while i < len
    fn array[i], ->
      completed++
      callback()  if completed is array.length
    i++

module.exports = util