package DTAG::LexInput;

# Define new type
my $t = type("t");

# Define variables
$t->gov('nmod' => 'noun', 'vmod' => 'verb', 'pmod' => undef);
print $t->print() . "\n";

