package DTAG::LexInput;
DTAG::Lexicon->new("test")->clear();

# Define new type
my $t = type("t");

# Define phon variable
$t->phon('af', 'be', 'tal', 'ing');
print $t->print() . "\n";

