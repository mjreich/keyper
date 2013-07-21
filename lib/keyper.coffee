

_ = require 'underscore'

class Keyper 
  constructor: (data) ->
    @_data = data || {}

  _getData: (key) ->
    data = @_data
    key = key.replace(/\[(\w+)\]/g, ".$1") # convert indexes to properties
    key = key.replace(/^\./, "") # strip a leading dot
    a = key.split(".")
    while a.length
      n = a.shift()
      if _.isObject(data) and n of data
        data = data[n]
      else
        return
    data

  _setData: (key, value) ->
    keys = key.split "."
    data = @_data
    for key in keys
      data[key] = {} unless data[key]
      break if key is _.last(keys)  
      data = data[key]
    data[key] = value

  data: ->
    return @_data  

  setData: (data) ->
    @_data = data

  getValue: (key) ->
    return @_getData key
  
  setValue: (key, val) ->
    @_setData(key, val)

  keyExists: (key) ->
    return typeof @_getData(key) isnt "undefined"

  deleteValue: (key) ->
    delete @_data[key] if @_data[key]

  increment: (key) ->
    @_setData(key, 0) unless @_getData(key) 
    return unless _.isNumber(@_getData(key))
    @_setData(key, @_getData(key) + 1)

  decrement: (key) ->
    @_setData(key, 0) unless @_getData(key) 
    return unless _.isNumber(@_getData(key))
    @_setData(key, @_getData(key) - 1)

  addValue: (key, val) ->
    @_setData(key, 0) unless @_getData(key) 
    return unless _.isNumber(@_getData(key))
    @_setData(key, @_getData(key) + val)

  subtractValue: (key, val) ->
    @_setData(key, 0) unless @_getData(key) 
    return unless _.isNumber(@_getData(key))
    @_setData(key, @_getData(key) - val)

  push: (key, value) ->
    originalValue = @_getData(key)
    if not _.isArray(originalValue)
      @_setData(key, [])
      originalValue = @_getData(key)
    originalValue.push value
    @_setData(key, originalValue)

module.exports = Keyper