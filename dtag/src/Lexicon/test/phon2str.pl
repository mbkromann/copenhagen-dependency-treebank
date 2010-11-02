# Vocals and consonants
my $V = "aeiouy���";
my $C = "bcdfghjklmnpqrstvwxz";
DTAG::Lexicon->new('test');

my $values = {
	'm�nd' => ['mand', "s/[$V]([$C]*)\$/�\$1/"],
	'laver' => ['lav', 'er'],
	'lytter' => ['lyt', "s/([$C])\$/\$1\$1/", 'er'],
	'mand' => ['mand', '', "s/[$V]([$C]*)\$/�\$1/"],
	'm�ndene' => ['mand', "s/[$V]([$C]*)\$/�\$1/", '', 'ene'],
	'laves' => ['lav', 'er', 's/r$/s/'],
	'talte' => ['t�l', "s/[$V]([$C]*)\$/a\$1/", 'te'],
	'sprukket' => ['spr�k', "s/[$V]([$C]*)\$/u\$1/", "s/([$C])\$/\$1\$1/", 
					'et'],
};

foreach my $w (sort(keys(%$values))) {
	my @phon = @{$values->{$w}};
	print $w 
		. ' = ' .  ( DTAG::LexInput->lexicon()->phon2str(@phon) )
		. ' = [' . join(', ', @phon) . ']' . "\n";
}

