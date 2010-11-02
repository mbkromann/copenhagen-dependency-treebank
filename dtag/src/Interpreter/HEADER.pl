# --------------------------------------------------

=head1 NAME

DTAG::Interpreter - DTAG command line interface

=head1 DESCRIPTION

DTAG::Interpreter - command line interface in DTAG

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Interpreter;

# Pragmas
use strict;

# Required modules
use Term::ANSIColor;
use Term::ReadLine;
use Term::ReadKey;
use Data::Dumper;
use Parse::RecDescent;
use LWP::Simple;
use XML::Writer;
use XML::Parser;
use PerlIO;
use IO qw(File);
use File::Basename;
use Encode qw(decode decode_utf8 from_to);
use Time::HiRes qw(time sleep);
use Encode;

# Required DTAG modules 
require DTAG::Lexicon;
require DTAG::LexInput;
require DTAG::Learner;

# Interpreted Perl: arg-list
my @perl_args = ();

# Variables
my $graphid = 0;
my $interpreter = undef;
my $viewer = 0;
my $tiger_dependency = 1;
my ($L, $G, $I);

# Signals
sub catch_signal {
	my $signame = shift;
	die "DTAG: detected signal $signame\n";
}
$SIG{INT} = \&catch_signal;

# Fields in relation names
# Relation = [$shortname, $longname, 
#   @immediateparents, @transitiveparents, @immediatechildren,
#   $shortdescription, $longdescription, $examples,
#   $supertypes, $lineno, $see]
my $REL_SNAME = 0;
my $REL_LNAME = 1;
my $REL_IPARENTS = 2;
my $REL_TPARENTS = 3;
my $REL_ICHILDREN = 4;
my $REL_SDESCR = 5;
my $REL_LDESCR = 6;
my $REL_EX = 7;
my $REL_DEPRECATED = 8;
my $REL_STYPES = 9;
my $REL_LINENO = 10;
my $REL_CHILDCNT = 11;
my $REL_TCHILDCNT = 12;
my $REL_SEE = 13;
my $REL_CONN = 14;


# Debugging
my $debug_relset = undef;
#open(my $debug_relset, ">:encoding(utf8)", "/tmp/dtag.relset.dbg");

