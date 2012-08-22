
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

