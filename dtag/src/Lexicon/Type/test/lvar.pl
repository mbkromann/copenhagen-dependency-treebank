package DTAG::LexInput;


my $a = Type->new("a", "b", "c");

# Get variable values "a" and "b"
print "a = UNDEFINED = " . ((defined $a->lvar("a")) ? "DEFINED" : "UNDEFINED") . "\n";
print "b = UNDEFINED = " . ((defined $a->lvar("b")) ? "DEFINED" : "UNDEFINED") . "\n";

# Set values of "a" and "b"
print "a = 1 = " . $a->lvar("a", 1) . "\n";
print "b = 2 = " . $a->lvar("b", 2) . "\n";
print "a = 1 = " . $a->lvar("a") . "\n";
print "b = 2 = " . $a->lvar("b") . "\n";

# Undefine values of "a" and "b"
print "a = = " . $a->lvar("a", undef) . "\n";
print "b = = " . $a->lvar("b", undef) . "\n";
print "a = UNDEFINED = " . ((defined $a->lvar("a")) ? "DEFINED" : "UNDEFINED") . "\n";


