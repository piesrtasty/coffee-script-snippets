
#######
#
#		Object Oriented Programming
#
#######

# One way to give an Object methods is to attach function values to it.
rabbit = {}
rabbit.speak = (line) ->
	show "The rabbit says '#{line}'"
rabbit.speak "Well, now you're asking me."

###

In most cases, the method will need to know who it should
act on. For example, if there are different rabbits, the
'speak' method must indicate which rabbit is speaking. For
this purpose, there is a special variable called 'this',
which is always present when a function is called as a 
method. A function is called as a method when it is looked up
as a property, and immediately called, as in...

###

object.method()

# Since it is very common to use this inside an object, it
# can be abbreviated from...

this.property or this.method() to @property or @method()

speak = (line) ->
	show "The #{this.adjective} rabbit says '#{line}'"

whiteRabbit = adjective: "white", speak: speak
fatRabbit = adjective: "fat", speak: speak

whiteRabbit.speak "oh my ears and whiskers, " + 
									"how late it's getting!"
fatRabbit.speak "I could sure use a carrot right now."

###

I can now clarify the mysterious first argument to the apply
method, for which we always used null in 'Functional Programming'.
This argument can be used to specify the object that the
function must be applied to. For non-method functions, this is
irrelevant, hence the null.

###

speak.apply fatRabbit, ['Yum.']

###

Functions also have a 'call' method which is similar to
'apply', but you can give the arguments for the function
separately instead of as an array:

###

speak.call fatRabbit, 'Burp.'

###

It is common in object oriented terminology to refer to instances
of something as an object. The whiteRabbit and fatRabbit can be
seen as different instances of a more general Rabbit concept.
In CoffeeScript such concepts are termed a class.

###

class Rabbit
	constructor: (@adjective) ->
	speak: (line) ->
		# show "The #{adjective} rabbit says '#{line}'"

whiteRabbit = new Rabbit "white"
fatRabbit = new Rabbit "fat"

whiteRabbit.speak "Hurry!"
fatRabbit.speak "Tasty!"

###

It is a convention, among CoffeeScript programmers, to start
the names of classes with a capital letter. This makes it easy to distinguish them from object
instances and functions.

The 'new' keyword provides a convenient way of creating new
objects. When a function is called with the word 'new' in front
of it, its this variable will point at a 'new' object, which
it will automatically return (unless it explicitly returns something
else). Functions used to create new objects like this are called constructors.

The constructor for the Rabbit class is constructor: (@adjective). The
@adjective argument to the constructor does two things. It declares
adjective as a property on this and it uses 'pattern matching' i.e. the same
name to assign the argument named adjective to a property on 'this'
and it uses 'pattern matching' i.e. the same name to assign
the argument named 'adjective' to a property on 'this' that is
also named 'adjective'. It could have been written in full form
as...

###

constructor: (adjective) -> this.adjective = adjective.

killerRabbit = new Rabbit 'killer'
killerRabbit.speak 'GRAAAAAHH!'
show killerRabbit

###

When 'new Rabbit' is called with the 'killer' argument, the
argument is assigned to a property named 'adjective'. So...

###

show killerRabbit => {adjective: 'killer'}

###

Why is the 'new' keyword even necessary? After all, we could have
simply written this:

###

makeRabbit = (adjective) ->
	adjective: adjective
	speak: (line) -> show adjective + ': ' + line
blackRabbit = makeRabbit 'black'

###

But that is not entirely the same. 'new' does a few things 
behind the scenes. For one thing, our 'killerRabbit' has a
property called 'constructor', which points at the Rabbit 
funnction that created it. 'blackRabbit', also has such a property
but it points at the object function. They even have name
properties so we can check them:

###

show killerRabbit.constructor.name => Rabbit

show blackRabbit.constructor.name =: Object

###

The objects that are created, 'whiteRabbit' and 'fatRabbit' are
specific instances. The 'whiteRabbit' is not all kinds of white
rabbits just a single one that happen to have the name 'whiteRabbit'.
If you want to create a class of say weight concious rabbits then
the extends keyword can help you accomplish that.

###

class WeightyRabbit extends Rabbit
	 constructor: (adjective, @weight) ->
	   super adjective
	 adjustedWeight: (relativeGravity) ->
	 	 (@weight * relativeGravity).toPrecision 2

tinyRabbit = new WeightyRabbit "tiny", 1.01
jumboRabbit = new WeightyRabbitw "jumbo", 7.47

moonGravity = 1/6
jumboRabbit.speak "Carry me, I weigh #{jumboRabbit.adjustedWeight(moonGravity)} stones"
tinyRabbit.speak "He ain't heavy, he is my brother"

###

The call 'super adjective' passes the argument on to the Rabbit
constructor. A method in a derived class can with 'super' call
upon a method of the same name in its parent class.

Inheritance is useful because different types can share a single
implementation of an algorithm. But it comes with a price-tag: the
derived classes become tightly coupled to the parent class.
Normally you make each part of a system as independenr as possible,
for example avoiding global variables and using arguments instead.
That way you can read and understand each part in isolation and you
can change them with little risk of breaking other parts of the
system.

Due to the tight coupling that inheritance introduces it can be
difficult to change a parent class w/out inadvertently risk
breaking derived classes. This is called the fragile base
class problem. A class that has no child classes and is only
used through its published methods and properties can normally
be changed quite freely -- as long as the published methods and
properties stay the same. When a class derives from it, then the
child class may depend on the internal behavior of the parent and
it becomes problematic to change the baseclass.

To understand a derived class you will often have to understand
the parent first. The implementation is distributed, instead of
reading down through a function, you may have to look in
different places where a class and its parent and their parent
...implement each their part of the combined logic. Let's look
at an example that matters -- the balance on your bank account.

###

class account
	constructor: -> @balance = 0
	transfer: (amount) -> @balance += amount
	getBalance: -> @balance
	batchTransfer: (amtList) ->
		for amount in amtList
			@transfer amount

yourAccount = new Account()
oldBalance = yourAccount.getBalance()
yourAccount.transfer salary = 1000
newBalance = yourAccount.getBalance()
show "Books balance:
	#{salary == newBalance - oldBalance}."

###

Hopefully this only shows the principle of how your bank has
implemented its accounts. An account starts with a zero balance,
money can be credited (positive transfer) and debited (negative
transfer), the balance can be shown and multiple transfers can
be handled.

Other pats of the system can balance the books by checking that
transfers match the differences on the accounts. Those parts of
the system were unfortunately not known to the developer of
the 'AccountWithFee' class.

###

class AccountWithFee extends Account
	fee: 5
	transfer: (amount) ->
		super amount - @fee
		# feeAccount.transfer @fee

yourAccount = new AccountWithFee()
oldBalance = yourAccount.getBalance()
yourAccount.transfer salary = 1000
newBalance = yourAccount.getBalance()
show "Books balance:
	#{salary == newBalance - oldBalance}."

###

The books no longer balance. The issue is that the AccountWithFee
class has violated what is called the substitution principle. It
is a patch of the existing 'Account' class and it breaks programs that
assume that all account classes behave in a certain way. In a
system with thousands of classes such patches can cause severe
problems. To avoid this kind of problem it is up to the developer
to ensure that inherited classes can fully substitute their parent
classes.

To avoid excessive fraudulent transactions when a card is lost or
stolen, the bank has implemented a system which checks that withdrtawals
do not exceed a daily limit. The 'LimitedAccount' class checks each
transfer, reduces the @dailyLimit and reports an error if it is
exceeded.

###

class LimitedAccount extends Account
	constructor: -> super; @resetLimit()
	resetLimit: -> @dailyLimit = 50
	transfer: (amount) ->
		if amount < 0 and (@dailyLimit += amount) < 0
			throw new Error "You maxed out!"
		else
			super amount

lacc = new LimitedAccount()
lacc.transfer 50
show "Start balance #{lacc.getBalance()}"

try lacc.batchTransfer [-1..10]
catch error then show error.message
show "After batch balance #{lacc.getBalance()}"

###

Your bank is so successful that batchTransfer has to be speeded
up (a real version would involve database updates). The developer,
that got the task of making batchTransfer faster, had been on vacation
when the 'LimitedAccount' class was implemented and did not see it
among the thousands of other classes in the system.

###

class Account
	constructor: -> @balance = 0
	transfer: (amount) -> @balance += amount
	batchTransfer: (amtList) ->
		add = (a,b) -> a + b
		sum = (list) -> reduce list, add , 0
		@balance += sum amtList

class LimitedAccount extends Account
	constructor: -> super; @resetLimit()
	resetLimit: -> @dailyLimit = 50
	transfer: (amount) ->
		if amount < 0 and (@dailtLimit += amount) < 0
			throw new Error "You maxed out!"
		else
			super amount

lacc = new LimitedAccount()
lacc.transfer 50
show "Starting with #{lacc.getBalance()}"

try lacc.batchTransfer [-1..-10]
catch error then show error.message
show "After batch balance #{lacc.getBalance()}"

###

Instead of the previous implementations that called transfer
each time, the whole batch is added tohgether and the balance
is directly updated. That made batchTransfer much faster, but it
also broke the LimitedAccount class. It is an example of the fragile
base class problem. In this limited example it is easy to spot
the issue, in a large system it can cause considerable headache.

Using inheritance in the right way requires careful and thoughful
programming. If your child classes are type compatible with their
parent then you are adhering to the substitution principle. Usually
using ownership is more appropriate, that is when a class has an
instance of another class inside it and uses its public interface.

It is a common convention in CoffeeSCript to use an "_" in front of
methods that are to be considered private.

Where did the constructor property come from? It is part of the
prototype of a rabbit. Prototypes are a powerful, if somewhat
confusing, part of the way CoffeeScript objects work. Every object
is based on a prototype, which gives it a set of inherent properties.
Simple objects ae based on the most basic prototype, which is associated
with the Object constructor. In fact, typing {} is equivalent
to typing new Object().

###

simpleObject = {}
show simpleObject.constructor
show simpleObject.toString

###

'toString' is a method that is part of the Object prototype. This
means that all simple objects have a 'toString' method, which
converts them to a string. Our rabbit objects are based on the
prototype associated with the Rabbit constructor. You can use
a constructor's prototype property to get access to, well, their
prototype:

###

show Rabbit.prototype
show Rabbit.prototype.constructor.name
Rabbit.prototype.speak 'I am generic'
Rabbit::speak 'I am not initialized'

###

Instead of Rabbit.prototype.speak you can write Rabbit::speak.
Every function automatically gets a prototype property, whose
whose constructor property points back at the function. Because the
rabbit prototype is itself an object, it is based on the object
prototype, and shares its toString.

###

show killerRabbit.toString == simpleObject.toString

###

Even though objects seem to share the properties of their prototype,
this sharing is one-way. The properties of the prototype influence
the object based on it, but the properties of this object never change
the prototype.

The precise rules are this: When looking up the value of a property,
CoffeeScript first looks at the properties that the object itself has.
If there is a property that has the name we are looking for, that is
the value we get. If there is no such property, it continues searching
the prototype of the object, and then the prototype of the prototype,
and so on. If no property is found, the value 'undefined' is given.
On the other hand, when setting the value of a property, CoffeeScript
never goes to the prototype, but always sets the property in the
object itself.

###

Rabbit::teeth = 'small'
show killerRabbit.teeth
killerRabbit.teeth = 'long, sharp, and bloody'
show killerRabbit.teeth
show Rabbit::teeth

###

This does mean that the prototype can be used at any time to add
new properties and methods to all objects based on it. For example,
it might become necessary for our rabbits to dance.

###

Rabbit::dance = ->
	show "The #{@adjective} rabbit dances a jig."
killerRabbit.dance()

###

And, as you might have guessed, the prototypical rabbit is the perfect
place for values that all rabbits have in common, such as the
'speak' method. Here is a new approach to the 'Rabbit' constructor:

###

Rabbit = (adjective) ->
	@adjective = adjective

Rabbit::speak = (line) ->
	show "The #{@adjective} rabbit says '#{line}'"

hazelRabbit = new Rabbit "hazel"
hazelRabbit.speak "Good Frith!"

###

The fact that all objects have a prototype and receive some properties from this
prototype can be tricky. It means that using an object to store
a set of things, such as the cats from 'Data Structures', can go wrong.
If for example, we wondered whether there is a cat called 'constructor', we would
have checked it like this:

###

noCatsAtAll = {}
if "constructor" of noCatsAtAll
	show "Yes, there is a cat called 'constructor'."

###

This is problematic. A related problem is that it can object be
practical to extend the prototypes of standard constructors such

















































































