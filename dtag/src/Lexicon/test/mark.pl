package DTAG::LexInput;

my $L = DTAG::Lexicon->new("test");
$L->clear();

my $a = type("a");

print "1 = " . $L->mark($a, DTAG::Lexicon->newmark()) . "\n";
print "2 = " . $L->mark($a, DTAG::Lexicon->newmark()) . "\n";
print "2 = " . $L->mark($a) . "\n";

