# This package defines an object representing a text input (with
# multiple streams)

package Text;
use strict;

my ($TEXT_INPUTS, $TEXT_LEXICONS, $TEXT_LEXICON, $TEXT_TIME1) = (0..3);

# Maximal length of lexeme
my $LEXEME_MAXLEN = 1000;
my $LOOKAHEAD = 100;
