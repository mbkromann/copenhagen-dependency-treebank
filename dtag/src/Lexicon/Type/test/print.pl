package DTAG::LexInput;

my $a = Type->new("a");
my $a_a = Type->new("a_a", $a);
my $b = Type->new("b");
my $c = Type->new("c");
my $abc = Type->new("abc", $a, $b, $c);
my $d = Type->new("d", $abc, $a_a);

foreach my $var ($a, $a_a, $b, $c, $abc, $d) {
	printf $var->print(), "\n";
}

