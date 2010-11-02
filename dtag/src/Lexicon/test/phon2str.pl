# Vocals and consonants
my $V = "aeiouyæøå";
my $C = "bcdfghjklmnpqrstvwxz";
DTAG::Lexicon->new('test');

my $values = {
	'mænd' => ['mand', "s/[$V]([$C]*)\$/æ\$1/"],
	'laver' => ['lav', 'er'],
	'lytter' => ['lyt', "s/([$C])\$/\$1\$1/", 'er'],
	'mand' => ['mand', '', "s/[$V]([$C]*)\$/æ\$1/"],
	'mændene' => ['mand', "s/[$V]([$C]*)\$/æ\$1/", '', 'ene'],
	'laves' => ['lav', 'er', 's/r$/s/'],
	'talte' => ['tæl', "s/[$V]([$C]*)\$/a\$1/", 'te'],
	'sprukket' => ['spræk', "s/[$V]([$C]*)\$/u\$1/", "s/([$C])\$/\$1\$1/", 
					'et'],
};

foreach my $w (sort(keys(%$values))) {
	my @phon = @{$values->{$w}};
	print $w 
		. ' = ' .  ( DTAG::LexInput->lexicon()->phon2str(@phon) )
		. ' = [' . join(', ', @phon) . ']' . "\n";
}

