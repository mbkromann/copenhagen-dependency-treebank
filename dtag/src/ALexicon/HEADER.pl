# --------------------------------------------------

=head1 DTAG::ALexicon

=head2 NAME

DTAG::ALexicon - DTAG alignment lexicon

=head2 DESCRIPTION

DTAG::ALexicon - manipulating alignment lexicons

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::ALexicon;
require DTAG::Interpreter;
use strict;

# Create new dummy lexical entry for identical words
my $alex_identity = ALex->new();
$alex_identity->out([]);
$alex_identity->in([]);
$alex_identity->type('');
$alex_identity->pos(1);
$alex_identity->neg(0);

# Create new dummy lexical entry for m-n aligned words
my $alex_parallel = ALex->new();
$alex_parallel->out([]);
$alex_parallel->in([]);
$alex_parallel->type('');
$alex_parallel->pos(1);
$alex_parallel->neg(0);

# Dummy subroutine always returning false
my $dummysub = sub {return 0};

# Maximal number of entries in hash before word is considered a
# function word
my $FUNCTIONWORD_MAXCOUNT = 500;

