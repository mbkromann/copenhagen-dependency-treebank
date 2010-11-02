DTAG::Lexicon->new("test")->clear();

# Vocals and consonants
my $V = "aeiouyæøå";
my $C = "bcdfghjklmnpqrstvwxz";

my $lex = DTAG::LexInput->lexicon();

    # -~e: undouble last double consonant and remove second-last 'e',
    # eg: fakkel => fakl, pukkel => pukl, 
    $lex->phonop('-~e', "s/([$C]){2}e([$C])\\\$/\\\$1\\\$2\/");
 
    # -e: remove second-last 'e': barsel => barsl
    $lex->phonop('-e', "s/e([$C])\\\$/\\\$1/");

    # ~: double consonant
    $lex->phonop('~', "s/([$C])\\\$\/\\\$1\\\$1\/");

    # ^X: replace last vocal with X
    $lex->phonop('\^(.*)', "s/[$V]([$C]*)\\\$/\$1\\\$1/");

    # X/Y: replace ending X with Y
    $lex->phonop('([^/]+)/([^/]+)', "s/\$1\\\$/\$2/");

	$lex->phon_compile('^a');
	$lex->phon_compile('^u');
	$lex->phon_compile('^æ');
	$lex->phon_compile('^ø');
	$lex->phon_compile('v/j');
	$lex->phon_compile('-~e');
	$lex->phon_compile('-e');
	$lex->phon_compile('~');
	$lex->phon_compile('r/s');
	$lex->compile();

# Test values
my $values = {
	'mand|mænd' => [['mand'], ['^æ'], ['en']],
	'flyv|fløj' => [['flyv'], ['^ø', 'v/j'], ['^ø', 'v/j', 'et']],
	'pukkel|pukl' => [['pukkel'], ['-~e', 'er'], ['-~e', 'er', 'ne']],
	'lyt|lytt' => [['lyt'], ['~', 'er'], ['~', 'ede']],
	'lav' => [['lav'], ['er'], ['er', 'r/s']],
	'tal|tæl' => [['tæl'], ['^a', 'te'], ['^a', 't']],
	'traf|truff|træf' => [['træf'], ['^a'], ['^u', '~', 'et']],
	'tidsel|tidsl' => [['tidsel'], ['-e', 'er'], ['-e', 'er', 'ne']],
};

# Process values
foreach my $key (sort(keys(%$values))) {
	my $list = $values->{$key};
	my $str = "";
	foreach my $arg (@$list) {
		$str .= "[" . join(', ', @$arg) . "] ";
	}
	print "$key = " . join('|', $lex->phonroots(@$list))
		. ' = ' . $str . "\n";
}


