package DTAG::LexInput;

# Define new type
my $t = type("t");

# Define variables
$t->fill('fill1' => 'noun', 'fill2' => 'verb', 'fill3' => undef);
print $t->print() . "\n";

