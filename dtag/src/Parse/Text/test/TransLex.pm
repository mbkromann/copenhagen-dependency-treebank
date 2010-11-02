package DTAG::LexInput;
DTAG::Lexicon->new("translex")->clear();

# Vocals and consonants
my $V = "aeiouyæøå";
my $C = "bcdfghjklmnpqrstvwxz";

# Define phonetic operators
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
	$lex->phonop('([^/]+)/([^/]+)', "s/\$1\\\$/\$2/");


# Define transformations

type('mand1')
	-> phon('mand')
	-> trans(
		'def'	=>	phon('en'),
		'pl'	=>	phon('^æ')->trans(
						'def'	=> phon('ene')));

type('ko1')
	-> phon('ko')
	-> trans(
		'def'	=> phon('en'),
		'pl'	=> phon('^ø', 'er')->trans(
						'def'	=> phon('ne')));
type('kø1') 
	-> phon('kø')
	-> trans(
		'def'	=> phon('en'),
		'pl'	=> phon('er')->trans(
						'def' 	=> phon('ne')));

type('pukkel1')
	-> phon('pukkel')
	-> trans(
		'def'	=> phon('-~e', 'en'),
		'pl'	=> phon('-~e', 'er')->trans(
						'def' 	=> phon('ne')));

type('pukl1') 
	-> phon('pukl')
	-> trans(
		'pres' 	=> phon('er')->trans(
						'pas' => phon('r/s')),
		'past' 	=> phon('ede')->trans(
						'pas' => phon('s')),
		'perf'	=> phon('et')->trans(
						'pas' => phon('')),
		'inf'	=> phon('e'),
		'geru'	=> phon('en')->trans(
						'part' => phon('de')));
type('træ1')
	-> phon('træ')
	-> trans(
		'def'	=> phon('et'),
		'def'	=> phon('er')->trans(
			'def'	=> phon('ne')));

type('træk1')
	-> phon('træk')
	-> trans(
		'pres' 	=> phon('~', 'er')->trans(
						'pas' => phon('r/s')),
		'past'	=> phon('^a')->trans(
						'pas' => phon('~', 'es')),
		'perf'	=> phon('^u', '~', 'et')->trans(
						'pas' => phon('')),
		'inf'	=> phon('~', 'e'),
		'geru' 	=> phon('~', 'en')->trans(
						'part' => phon('de')));

type('træk2')
	-> phon('træk')
	-> trans(
		'def' 	=> phon('~', 'et'),
		'pl'	=> phon('')->trans(
						'def' => phon('~', 'ene')));

type('trækker1')
	-> phon('trækker')
	-> trans(
		'def'	=> phon('en'),
		'pl'	=> phon('e')->trans(
			'def'	=> phon('-e', 'ne')));


