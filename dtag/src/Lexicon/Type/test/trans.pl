package DTAG::LexInput;

# Define new type
my $t = type("t");

# Define phon, land variables
$t->trans('trans1' => 'noun', 'trans2' => 'verb', 'trans3' => undef);
print $t->print() . "\n";

