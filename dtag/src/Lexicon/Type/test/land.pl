package DTAG::LexInput;

# Define new type
my $t = type("t");

# Define phon, land variables
$t->land('land1' => 'noun', 'land2' => 'verb', 'land3' => undef);
print $t->print() . "\n";

