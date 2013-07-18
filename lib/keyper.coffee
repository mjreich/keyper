
_ = require 'underscore'

class Keyper 
  constructor: ->
    @_data = {}

  data: ->
    return @_data  

  getValue: (key) ->
    return @_data[key]
  
  setValue: (key, val) ->
    @_data[key] = val

  deleteValue: (key) ->
    delete @_data[key] if @_data[key]

  increment: (key) ->
    @_data[key] = 0 unless @_data[key]
    return unless _.isNumber(@_data[key])
    @_data[key] += 1

  decrement: (key) ->
    @_data[key] = 0 unless @_data[key]
    return unless _.isNumber(@_data[key])
    @_data[key] -= 1

  addValue: (key, val) ->
    @_data[key] = 0 unless @_data[key]
    return unless _.isNumber(@_data[key])
    @_data[key] += val

  subtractValue: (key, val) ->
    @_data[key] = 0 unless @_data[key]
    return unless _.isNumber(@_data[key])
    @_data[key] -= val

module.exports = Keyper