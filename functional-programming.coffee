### Coffee Script utility snippets organized by category ###

# Iterators

forEach = (array, action) ->
	for element in array
		action element
	# return (if not stated, last value returned)
forEach ['wampeter', 'Foma', 'Granfalloon'], show

# A return statement at the end of forEach will make
# it return undefined.

# By using an anonymous function, something just like
# a for loop can be written as:
sum = (numbers) ->
	total = 0
	forEach numbers, (number) -> total += number
	total
show sum [1, 10, 100]

# When this array is created by evaluating some expression,
# there is no need to store it in a variable, because it can
# be passed to forEach directly. For example....

paragraphs = email.split '\n'
for paragraph in paragraphs
		handleParagraph paragraph

# Can be written as

forEach email.split('\n'), handleParagraph

###

forEach takes an algorithm, 'going over an array' in this 
case, and abstracts it. The 'gaps' in the algorithm, in this
casem what to do for each of the elements, are filled by
functions which are passed to the algorithm function.

* Functions that operate on other functions are called
higher-order functions.

They can be used to generalise many algorithms that regular
functions can not easily describe.

Being able to write what we want to do instead of how we do
it means we are working at a higher level of abstraction.

###

# Another useful type of higher-order function modifies the
# function value it is given:

negate = (func) ->
		(x) -> not func x

isNotNaN = negate isNotNaN
show isNotNaN NaN

###

The function returned by negate feeds the argument it is
given to the original function func, and then negates the
result.

What if the function you want to negate takes more than
one argument?

You can get access to any arguments passed to a function
with the arguments array.

How do you call a function when you do not know how many
arguments you have?

Functions have a method called apply, which is used for
situations like this. It takes two arguments. 

The role of the first argument will be discussed in 
"Object Orientation", for now we just use null there.

The second argument is an array containing the arguments
that the function must be applied to.

Now you know the underlying arguments mechanism remember that
you can also use splats...

###

show Math.min.apply null, [5, 6]

negate = (func) ->
	-> not func.apply null, arguments

negate = (func) ->
	(args...) -> not func args...

# Let's look at a few more basic algorithms related to arrays
# The sum function is really a variant of an algorithm which
# is usually called reduce or foldl:

reduce = (array, combine, base) ->
	forEach array, (element) ->
		base = combine base, element
	base

add = (a, b) -> a + b
sum = (numbers) -> reduce numbers, add, 0
show sum [1, 10, 100]

###

reduce combines an array into a single value by repeatedly
using a function that combines an element of the array with
a base value. This is exactly what sum did, so it can be made
shorter by using reduce...expcept that addition is an operator
and not a function in CoffeeScript, so we first had to put it
into a function.

Write a function countZeroes, which takes an array of numbers
as its argument and returns the amount of zeroes that occur in it
Use reduce.

Then, write the higher-order function count, which takes an array
and a test function as arguments, and returns the amount of
elements in the arrray for which the test function returned true.
Re-implement countZeroes using this function.

###

countZeroes = (array) ->
	counter = (total, element) ->
		total++ if element is 0
		total
	reduce array, counter, 0

bits = [1, 0, 1, 0, 0, 1, 1, 1, 0]
show countZeroes bits

# Here is the solution that uses a count function, with a
# function that produces equality-testers included to make
# the final countZeroes function even shorter.

count = (test, array) ->
	reduce array, ((total, element) ->
		total + if test element then 1 else 0), 0

equals = (x) ->
	(element) -> x == element

countZeroes = (array) ->
	count equals(0), array

show countZeroes bits

###

Another generally useful 'fundamental' algorithm
related to arrays is called map.

It goes over an array, applying a function to every element,
just like forEach. But instead of discarding the values
returned by function, it builds up a new array from these
values.

###

map = (array, func) ->
	result = []
	forEach array, (element) ->
		result.push func element
	result

show map [0.01, 2, 9.89, Math.PI], Math.round

# Leave out result, since forEach already returns it
map = (array, func) ->
	forEach array, (element) ->
		func element

# Leave out func arguments
map = (array, func) ->
	forEach array, func

# Leave out forEach arguments
map = forEach

###

The rules are this:

1. Paragraphs are separated by blank lines.
2. A paragraph that starts with a '%' symbol is a header. The more '%' symbols
   the smaller the header.
3. Inside paragraphs, pieces of text can be emphasized by putting them between asterisks.
4. Footnotes are written between braces.


1. Split the file into paragraphs by cutting it at every empty line.
2. Remove the '%' characters from header paragraphs and mark them as headers.
3. Process the text of the paragraphs themselves, splitting them into normal parts,
   emphasized parts, and footnotes.
4. Move all the footnotes to the bottom of the document, leaving numbers in their place.
5. Wrao each piece into the correct HTML tags
6. Combine everything int a single HTML document.

###

recluseFile = readTextFile '06-RecluseFile.text'

# Step 1

paragraphs = recluseFile.split "\n\n"
show "Found #{paragraphs.length} paragraphs."

###

Write a function processParagraph that, when given a paragraph string as its argument,
checks whether this paragraph is a header. If so, it strips the '%' characters and counts
their number. Then it returns an object with two properties, content (the text inside
the paragraph) and type (the tag to wrap it in) -> 'p' for regular paragraphs, 'h1' for
headers with one '%' and 'hx' for headers with x '%' characters.

###

processParagraph = (paragraph) ->
	header = 0
	while paragraph[0] == '%'
		paragraph = paragraph.slice 1
		header++
	type: if header == 0 then 'p' else 'h' + header,
	content: paragraph

show processParagraph paragraphs[0]

paragraphs = map recluseFile.split('\n\n'),
								 processParagraph
show paragraphs[0..2]


###

Build a function splitParagraph which, given a paragraph string, returns an array
of paragraph fragments (have type and content properties). 

###

splitParagraph = (text) ->
	# Find character position or end of text
	indexOrEnd = (character) ->
		index = text.indexOf character
		if index == -1 then text.length else index

	# Return and remove text upto next special character or end of text
	takeNormal = ->
		end = reduce map(['*', '{'], indexOrEnd),
											Math.min, text.length
		part = text.slice 0, end
		text = text.slice end

# Return and remove text upto character
takeUpTo = (character) ->
	end = text.indexOf character, 1
	if end == -1
		throw new Error 'Missing closing ' + '"' + character + '"'

	part = text.slice 1, end
	text = text.slice end + 1
	part

fragments = [];

while text != ''
	if text[0] == '*'
		fragments.push
			type: 'emphasized',
			content: takeUpTo '*'
	else if text[0] == '{'
		fragments.push
			type: 'footnote',
			content: takeUpTo '}'
	else
		fragments.push
			type: 'normal',
			content: takeNormal()
fragments

# The map produces am array of positions where the given characters were found, or the
# end of the string if they were not found, and the reduce takes the minimum of them,
# which is the next point in the string that we have to look at.# Checkout the project

# If you'd write that w/out mapping and reducing you'd get something like this:

takeNormalAlternative = ->
	nextAsterisk = text.indexOf '*'
	nextBrace = text.indexOf '{'
	end = text.length
	if nextAsterisk != -1
		end = nextAsterisk
	if nextBrace != -1 and nextBrace < end
		end = nextBrace
	part = text.slice 0, end
	text = text.slice end
	part

# Can now wire processParagraph to also split the text inside the paragraphs, modify
# the above as follows

processParagraph = (paragraph) ->
	header = 0
	while paragraph[0] == '%'
		paragraph = paragraph.slice 1
		header++
	type: if header == 0 then 'p' else 'h' + header,
	content: splitParagraph paragraph
# Adhoc test
recluseFile = readTextFile '06-RecluseFile.text'
paragraphs = map recluseFile.split('\n\n'),
								 processParagraph
show paragraphs, 3

# Mapping that over the array of paragraphs gives us an array of paragraph objects, which
# in turn contain arrays of fragment objects. The next thing to do is to take out the
# fotnotes, and put references to them in their place.

extractFootnotes = (paragraphs) ->
	footnotes = []
	currentNote = 0
	replaceFootnote = (fragment) ->
		if fragment.type == 'footnote'
			++currentNote
			footnotes.push fragment
			fragment.number = currentNote
			type: 'reference', number: currentNote
		else
			fragment

	forEach paragraphs, (paragraph) ->
		paragraph.content = map paragraph.content,
														replaceFootnote
	footnotes

# HTML generation functions

linkObject = 
	name: 'a'
	attributes:
		href: 'http://www.gokgs.com/'
	content: ['Play Go!']

tag = (name, content, attributes) ->
	name: name
	attributes: attributes
	content: content

# As tag is primitive we write shortcuts for common types of elements...

link = (target, text) ->
	tag "a", [text], href: target

show link "http://www.gokgs.com/", "Play Go!"

htmlDoc = (title, bodyContent) ->
	tag "html", [tag("head", [tag "title"], [title]]),
							 tag "body", bodyContent

show htmlDoc "Quote", "In his house at R'lyeh " +
											"dead Cthulu waits dreaming."

# Write an image function which, when given the location of an image file, will create
# an img HTML element

image = (src) ->
	tag 'img', [], src: src

# The final product will need to be reduced to a string, but building this string from
# the data structures we have been producing is straightforward apart from transforming

escapeHTML = (text) ->
	replacements = [[/&/g, '&amp;']
									[/"/g, '&quot;']
									[/</g, '&lt;']
									[/>/g, '&gt;']]
	forEach replacements, (replace) ->
		text = text.replace replace[0], replace[1]
	text

# The replace method of strings creates a new string in which all occurences of the pattern
# in the first argument are replaced by the second argument, so 'Borobuduk'

# To turn an HTML element into a string, we can use a recursive function like this:

renderHTML = (element) ->
	pieces = []

	renderAttributes = (attributes) ->
		result = []
		if attributes
			for name of attributes
				result.push ' ' + name + '="' + 
					escapeHTML(attributes[name]) + '"'
		result.join ''

	render = (element) ->
		# Text node
		if typeof element is 'string'
			pieces.push escapeHTML element
		# Empty Tag
		else if not element.content or
								element.content.length == 0
			pieces.push '<' + element.name + 
				renderAttributes(element.attributes) + '/>'
		# Tag with content
		else
			pieces.push '<' + element.name + 
				renderAttributes(element.attributes) + '>'
			forEach element.content, render
			pieces.push '</' + element.name + '>'

show renderHTML link 'http://www.nedroid.com',
										 'Drawinfs!'

body = [tag('h1', ['The Test']),
				tag('p', ['Here is a paragraph ' +
									'and an image...']),
				image('../img/ostrich.jpg')]
doc = htmlDoc 'The Test', body
show renderHTML doc
# Type 'stopServer()' or Ctrl-c when done.
viewServer renderHTML doc

###

Writee a function renderFragmenr, and use that to
implement another function, renderParagraph, which takes
a paragraph object (with the footnotes already fillec out),
and produces the correct HTML elemenr (which might be a paragraph,
or a header, depending on the type property of the paragraph
object).

###

# This function might come in useful for rendering the footnote references

footnote = (number) -> 
	tag 'sup'
		[link '#footnote' + number, string number]

###

A sup tag will show its content as 'superscript'. The target
of the link will be something like '#footnote1'. Links that
contain a '#' character refer to 'anchors' within a page,
and in this case we will use them to make it so that clicking
on the footnote link will take the reader to the bottom of
the page.

The tag to render emphasized fragments with is <enm>, and 
normal text can be rendered without any extra tags.

###

renderFragment = (fragment) ->
	if fragment.type == 'reference'
		footnote fragment.number
	else if fragment.type == 'emphasized'
		tag 'em', [fragment.content]
	else if fragment.type == 'normal'
		fragment.content

renderParagraph = (paragraph) ->
	tag paragraph.type,
		map paragraph.content, renderFragment

show renderParagraph paragraphs[7]

###

A rendering function for the footnotes. To make the '#footnote1'
links work, an anchor must be incuded with every footnote. In
HTML, an anchor is specified with an a element, which is also
used for links. In this case, it needs a 'name' attribute,
instead of an 'href'

###

renderFootnote = (footnote) ->
	anchor = tag "a", [],
		name: "footnote" + footnote.number
	number = "[#{footnote.number}]"
	tag "p", [tag("small",
		[anchor, number, footnote.content])]

# Here, then, is the function which, when given a file in the
# correct format and a document title, returns an HTML document

renderFile = (file, title) ->
	paragraphs = map file.split('\n\n'),
									 processParagraph
	footnotes = map extractFootnotes(paragraphs),
									renderFootnote
	body = map paragraphs,
						 renderParagraph
	body = body.concat footnotes
	renderHTML htmlDoc title, body

page = renderFile recluseFile, 'The Book of Programming'
show page
# Type 'stopServer()' or Ctrl-C when done.
viewServer page

###

Thhe concat method of an array can be used to concatenate
another array to it, similar to what the + operator does
with strings.

In the following chapters, elementary functiosn such as map
and reduce will be available via Underscore.

In some functional programming languages operators are
functions, for example in Pure you can write 
foldl (+) 0 (1..10); the same in CoffeeScript is 
reduce [1..10], ((a, b) -> a + b), 0. A way to shorten this is
by defining an object that is indexed by an operator in a
string.

###

op = {
				'+':	(a, b) -> a + b
				'==':	(a, b) -> a == b
				'!':	(a) -> !a
				# and so on ...
			}

show reduce [1..10], op['+'], 0

# The list of operators is quite long, so its questionable
# whether such a data structure improves readability compared
# to:

add = (a, b) -> a + b
show reduce [1..10], add, 0

###

If we need something like 'equals' or 'makeAddFunction', in
which one of the arguments already has a value, we are back
to writing a new function again.

For these cases, it is useful to use 'partial application'. 
To do this you want to create a new function that already
knows some of its argumentys, and treats any additional
arguments it is passed as coming after these fixed arguments.

A simple implementation of of 'partial application':

###

partial = (func, a...) ->
	(b...) -> func a..., b...

f = (a,b,c,d) -> show "#{a} #{b} #{c} #{d}"
g = partial f, 1, 2
g 3, 4

# The return value of partial is a function where the
# a.... arguments have been applied. When the returned
# function is called the b... arguments are appended to
# the arguments of func.

equals10 = partial op['=='], 10
show map [1, 10, 100], equals10

# Unlike traditional functional definitions, Underscore
# defines its arguments as array before action. That means
# we can not simply say:

square = (x) -> x * x
show map [[10, 100], [12, 16], [0, 1]],
				 partial map, square # Incorrect

# Since the square function needs to be the second argument of
# the inner map. But we can define another partial function
# that reverses its arguments:

partialReverse = (func, a) -> (b) -> func b, a

mapSquared = partialReverse map, square
show map [[10, 100], [12, 16], [0, 1]], mapSquared

# However it is again worthwhile to consider whether the intent
# of the program is clearer when the functions are defined 
# directly:

show map [[10, 100], [12, 16], [0, 1]],
	(sublist) -> map sublist, (x) -> x * x

###

A trick that can be useful when you want to combine funtions
is function composition. At the start of this chapter I
showed a function 'negate', which applies the boolean not
operator to the result of calling a function:

###

negate = (func) ->
		(args...) -> not func args...

###

This is a special case of a general pattern: call 
function A, and then apply function B to the result.
Composition is a common concept in mathematics. It can be caught
in a higher-order function like this:

###

compose = (func1, func2) ->
	(args...) -> func1 func2 args...

isUndefined = (value) -> value is undefined
isDefined = compose ((v) -> not v), isUndefined
show 'isDefined Math.PI = ' + isDefined Math.PI
show 'isDefined Math.PIE = ' + isDefined Math.PIE
