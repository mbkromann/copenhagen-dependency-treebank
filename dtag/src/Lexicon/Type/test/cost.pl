package DTAG::LexInput;

# Define new type
my $t = type("t");

# Define phon, land variables
$t->cost('cost1' => 'noun', 'cost2' => 'verb', 'cost3' => undef);
print $t->print() . "\n";

