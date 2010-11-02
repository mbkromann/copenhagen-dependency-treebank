# --------------------------------------------------

=head1 NAME

DTAG::LexInput - DTAG module defining operators used in lexicon files

=head1 DESCRIPTION

DTAG::LexInput - package which defines the operators that can be used
in a lexicon file.

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::LexInput;

# Require submodules
require Exporter;

# Setup class inheritance and exports
@LexInput::ISA = qw(Exporter);
@LexInput::EXPORT = qw(and atype card child comp cost dep diff dist
	fill gov hash is island left lex list lsite not or parent
	phon right self sem set source trans type);

# Create new lexicon object and share it with the Type package
my $lexicon = undef;


