package DTAG::LexInput;


my $a = Type->new("a", "b", "c");

# Set values of "a" and "b"
print "a = 1 = " . $a->lvar("a", 1) . "\n";
print "b = 2 = " . $a->lvar("b", 2) . "\n";

# Print variables
print "variables = " . join(" ", @{$a->vars()}) . "\n";
