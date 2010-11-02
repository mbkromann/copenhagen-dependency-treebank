package DTAG::LexInput;
DTAG::Lexicon->new("test")->clear();

# Define type hierarchy
my $a = type("a", "0");
my $b = type("b");
my $c = type("c", "a", "b");
my $d = type("d", "a");
my $e = type("e", "b");
my $f = type("f", "c");
my $g = type("g", "e");
my $h = type("h", "d", "f", "g");
DTAG::LexInput->lexicon()->compile();

# Test super() with type names
print DTAG::Lexicon->super("a", "a") . " = 1\n";
print DTAG::Lexicon->super("b", "a") . " = 0\n";
print DTAG::Lexicon->super("h", "a") . " = 1\n";
print DTAG::Lexicon->super("h", "f") . " = 1\n";
print DTAG::Lexicon->super("h", "0") . " = 0\n";
print DTAG::Lexicon->super("0", "a") . " = 0\n";
print DTAG::Lexicon->super("0", "a") . " = 0\n";
print DTAG::Lexicon->super("f", "e") . " = 0\n";
print DTAG::Lexicon->super("f", "b") . " = 1\n";

# Test super() with object references
print DTAG::Lexicon->super($a, "a") . " = 1\n";
print DTAG::Lexicon->super($b, "a") . " = 0\n";
print DTAG::Lexicon->super($h, "a") . " = 1\n";
print DTAG::Lexicon->super($h, "f") . " = 1\n";
print DTAG::Lexicon->super($h, "0") . " = 0\n";
print DTAG::Lexicon->super(0, "a") . " = 0\n";
print DTAG::Lexicon->super(0, "a") . " = 0\n";
print DTAG::Lexicon->super($f, "e") . " = 0\n";
print DTAG::Lexicon->super($f, "b") . " = 1\n";


