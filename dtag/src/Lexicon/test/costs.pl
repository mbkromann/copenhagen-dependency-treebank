package DTAG::LexInput;

my @tests = (
	"self()",
	"dep('t')",
	"left('t')",
	"right('t')",
	"gov('t')",
	"lsite('t')",
	"island('t')",
	"sem('n', 't')",
	
	"is('n', 't')",
	"dist('n')",

	"card('x')",
	"AND('x1', 'x2', 'x3', 'x4')",
	"OR('x1', 'x2', 'x3', 'x4')",
	"NOT('x')",

	"self() < dep('a')",
	"self() > dep('b')",
	"self() != dep('a')",
	"dep('a') == left('b')",

	"AND(dep('a'), left('b'))",
	"card(dep('a'))",
	"left('word')",
	"right('word')",
	"dep('word')",
	"diff('a', 'b', 'c')",
	
	"parent('t')",
	"child('t')",
	"dep('b') * dep('a')",
	"dep('a') * dist('a')",
	"dep('a') * int(5)",
	"5 * dep('a')",
);

my $i = 0;
foreach my $test (@tests) {
	++$i;
	my $obj = eval("$test");
	print "$i. $test = " . $obj . "\n";
}

