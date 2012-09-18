
forEach = (array, action) ->
	for element in array
		action element
	# return (if not stated, last value returned)

### 

Reduce

reduce combines an array into a single value by repeatedly
using a function that combines an element of the array with
a base value.

###

reduce = (array, combine, base) ->
	forEach array, (element) ->
		base = combine base, element
	base

###

Return an array with the names of the (non-hidden) properties
that an object has:

###

Object::allProperties = ->
	for own property of this
		property

###

For loop to search only the properties of an object (ignore
inherited properties from prototype)

###

forEachOf = (object, action) ->
	for own property, value of object
		action property, value

###

Avoid exception of object with property called 'hasOwnProperty'

* Instead of using the method found in the object itself, we
	get the method from the 'Object' prototype, and then use
	'call' to apply it to the right object.

* Ultimately just use CoffeeScript's "own" keyword

###

forEachIn = (object, action) ->
	for property of object
		if (object::hasOwnProperty.call(object, property))
			action property, object[property]


###

* Browsers in the Geko family (Firefox) give every object a hidden
  property named '__proto__', which points to the prototype of that
  object.

* The method 'propertyIsEnumerable' return 'false' for hidden
	properties, and can be used to filter out strange things like
	'__proto__'

------------------------------------------------------------------

When you want to approach an object as just a set of properties...

###  

class Dictionary
	constructor: (@values = {}) ->

	store: (name, value) ->
		@values[name] = value

	lookup: (name) ->
		@values[name]

	contains: (name) ->
		Object::hasOwnProperty.call(@values, name) and
		Object::propertyIsEnumerable.call(@values, name)

	each: (action) ->
		for own property, value of @values
			action property, value


































