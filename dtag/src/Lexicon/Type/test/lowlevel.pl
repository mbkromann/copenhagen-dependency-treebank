package DTAG::LexInput;

DTAG::Lexicon->new("test")->clear();

my $a = Type->new("a", "b", "c", "d");

# Print type name, change, print again
print "name = " . $a->get_name() . "\n";
$a->set_name("b");
print "name = " . $a->get_name() . "\n";

# Print super classes, change, print again
print "super = " . join(" ", @{$a->get_super()}) . "\n";
$a->set_super("x", "y", "z");
print "super = " . join(" ", @{$a->get_super()}) . "\n";

# Print representation of $a
print "print = " . $a->print() . "\n";

# 


