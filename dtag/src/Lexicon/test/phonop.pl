DTAG::Lexicon->new("test")->clear();

# Vocals and consonants
my $V = "aeiouyæøå";
my $C = "bcdfghjklmnpqrstvwxz";

# Define phonetic operators
$| = 1;
my $lex = DTAG::LexInput::lexicon();

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
	$lex->phonop('([^/]+)>([^/]+)', "s/\$1\\\$/\$2/");

my $pasp1 = 's/([^' . $V . '])$/$1e/g';
my $pasp2 = '([^' . $V . '])>$1e';

my $values = {
	'mænd' => ['mand', '^æ'],
	'laver' => ['lav', 'er'],
	'lytter' => ['lyt', '~', 'er'],
	'mand' => ['mand', '', '^æ'],
	'mændene' => ['mand', '^æ', '', 'ene'],
	'laves' => ['lav', 'er', 'r>s'],
	'talte' => ['tæl', '^a', 'te'],
	'sprukket' => ['spræk', '^u', '~', 'et'],
	'fakler' => ['fakkel', '-~e', 'er'],
	'tidsler' => ['tidsel', '-e', 'er'],

	'fandtes' => ['fandt', $pasp1, 's'],
	'huskedes' => ['huskede', $pasp1, 's'],
	'sås' => ['så', $pasp1, 's'],

	'fandtes' => ['fandt', $pasp2, 's'],
	'huskedes' => ['huskede', $pasp2, 's'],
	'sås' => ['så', $pasp2, 's'],
};

foreach my $w (sort(keys(%$values))) {
	my @phon = @{$values->{$w}};
	$lex->phon_compile(@phon);	
	$lex->compile();
	print $w 
		. ' = ' .  $lex->phon2str(@phon) 
		. ' = [' . join(', ', @phon) . ']' . "\n";
}


