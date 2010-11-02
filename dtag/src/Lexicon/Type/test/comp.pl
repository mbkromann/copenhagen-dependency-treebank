package DTAG::LexInput;

# Define new type
my $t = type("t");

# Define phon, land variables
$t->comp('subj' => 'noun', 'dobj' => 'noun');
print $t->print() . "\n";

