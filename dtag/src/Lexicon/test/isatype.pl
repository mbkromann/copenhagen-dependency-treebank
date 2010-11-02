package DTAG::LexInput;

DTAG::Lexicon->new("test")->clear();
type("a");
type("b");
type("c");
type("ab", "a", "b");
type("bc", "b", "c");
type("ac", "a", "c");
type("abc", "ab", "bc", "ac");
DTAG::LexInput->lexicon()->compile();

# Test procedure: $type, $typespec, $answer
sub mytest {
	my $type = shift;
	my $typespec = shift;
	my $answer = shift;

	print "isa($type, $typespec) = $answer = " 
		. DTAG::Lexicon->isatype($type, DTAG::Lexicon::typespec($typespec)) .  "\n";
}

# Atomic type specifications
mytest("a", "a", 1);
mytest("a", "b", 0);
mytest("x", "a", 0);

# 1-argument type specifications
mytest("a", "-a", 0);
mytest("b", "-a", 1);
mytest("ab", "-a", 0);

# 2-argument type specifications
mytest("a", "a+b", 0);
mytest("a", "a-b", 1);
mytest("a", "a|b", 1);

mytest("b", "a+b", 0);
mytest("b", "a-b", 0);
mytest("b", "a|b", 1);

mytest("ab", "a+b", 1);
mytest("ab", "a-b", 0);
mytest("ab", "a|b", 1);

# 3-argument type specifications
mytest("abc", "a+b+c", 1);
mytest("abc", "(a+b)+c", 1);
mytest("abc", "a+(b+c)", 1);

mytest("abc", "a-(b+c)", 0);
mytest("a", "a-(b+c)", 1);
mytest("ab", "a-(b+c)", 1);

mytest("ab", "a-(b|c)", 0);
mytest("a", "a-(b|c)", 1);
mytest("x", "a-(b|c)", 0);

mytest("abc", "a|(b+c)", 1);
mytest("bc", "a|(b+c)", 1);
mytest("b", "a|(b+c)", 0);

mytest("a", "a+(b-c)", 0);
mytest("ab", "a+(b-c)", 1);
mytest("abc", "a+(b-c)", 0);

mytest("ac", "a-(b-c)", 1);
mytest("ab", "a-(b-c)", 0);
mytest("abc", "a-(b-c)", 1);
mytest("b", "a-(b-c)", 0);

mytest("ac", "a|(b-c)", 1);
mytest("bc", "a|(b-c)", 0);
mytest("b", "a|(b-c)", 1);

mytest("b", "a+(b|c)", 0);
mytest("ac", "a+(b|c)", 1);
mytest("abc", "a+(b|c)", 1);

mytest("ac", "a-(b|c)", 0);
mytest("a", "a-(b|c)", 1);
mytest("x", "a-(b|c)", 0);

mytest("c", "a|(b|c)", 1);
mytest("bc", "a|(b|c)", 1);
mytest("x", "a|(b|c)", 0);

