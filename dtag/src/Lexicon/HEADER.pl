# --------------------------------------------------

=head1 NAME

DTAG::Lexicon - DTAG lexicon class

=head1 DESCRIPTION

DTAG::Lexicon - dependency lexicon 

This package defines a lexicon which associates type names with type
references. Each lexicon is a hash table with names and types.

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Lexicon;
use strict;
use MLDBM qw(DB_File);
use DB_File;

# Require submodules
require Exporter;

# Setup class inheritance and exports
@DTAG::Lexicon::ISA = qw(Exporter);
@DTAG::Lexicon::EXPORT = qw(typeobj);

# Set parameters
my $maxrootlength = 20;		# Maximal stored length of phonetic root
my $mark = 0;				# Last mark (used for marking visited nodes)
my $marks = {};				# Mark hash
my $cachesize = 1000;		# Size of type cache

