my @strings = (
	"abcde",
	"(a+b)|d",
	"a+b|d", "(a+b)|d", "a+(b|d)",
	"-a+b|d", "(-a)+b|d", "(-a+b)|d", "-a+(b|d)",
	"-a",
	"a+b", "a-b", "a|b", 
	"(a)", "(a+b)",
	"a-b+c|d", "-a+b|d",
	"-(a+b|d)", "-(a+(b+c))|(d+e)",
	"-(((a+b)))|d", 
	"-(a+b)|d",
	"QUOTED TYPES",
	'-"-abc"',
	'"-abc"',
	'-"abc"',
	'-"-abc+|"+"a-b+cde|"',
	"-'-abc+|'+'a-b+cde|'",
	"ERRORS",
	"((()))+b", "(a+b|c", "a+)b|c", "(", "(a",
	);

foreach my $string (@strings) {
	my ($obj, $rest) = DTAG::Lexicon::typespec($string);
	$obj = defined($obj) ? $obj : "ERROR";
	print ($rest ? "*" : "");
	print (ref($obj) || "string");
	print ": $string === $obj :: $rest\n";
}



