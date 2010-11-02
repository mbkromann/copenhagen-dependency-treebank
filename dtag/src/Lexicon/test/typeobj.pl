package DTAG::LexInput;

DTAG::Lexicon->new("test")->clear();

my $a = type("a");
my $b = type("b");
my $c = type("c");
DTAG::LexInput->lexicon()->compile();

print "a = " . DTAG::Lexicon::typeobj("a")->get_name() . "\n";
print "b = " . DTAG::Lexicon::typeobj("b")->get_name() . "\n";
print "c = " . DTAG::Lexicon::typeobj("c")->get_name() . "\n";
print "x = " . ((defined DTAG::Lexicon::typeobj("x")) ? "DEFINED" : "UNDEFINED") . "\n";

