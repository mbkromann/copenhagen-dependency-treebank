package DTAG::LexInput;
DTAG::Lexicon->new("test")->clear();

my $b = type("b");
my $c = type("c");

my $a1 = type("a1", "b", "c", "d");
my $a2 = lex("a2", "b", "c", "d");
my $a3 = trans("a3", "b", "c", "d");
DTAG::LexInput->lexicon()->compile();


foreach my $a ($a1,$a2,$a3) {
	print $a->print();
}

