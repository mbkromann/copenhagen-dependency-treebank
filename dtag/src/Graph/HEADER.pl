# --------------------------------------------------

=head1 DTAG::Graph

=head2 NAME

DTAG::Graph - DTAG dependency graphs

=head2 DESCRIPTION

DTAG::Graph - creating, manipulating and drawing dependency graphs

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Graph;
require DTAG::Interpreter;
require Encode;
use strict;

# Graph identifier
my $DEFAULT_LOOKAHEAD = 50;

# PostScript 
my $pstrailer = {};
my $psheader = {};

sub readfile {
    my $file = shift;
    my $string = "";

    # Read file
    open(IFH, $file) 
		|| return DTAG::Interpreter::error("cannot read file $file in Graph->readfile\n" .
			"check that DTAGHOME is set correctly!");
    while (<IFH>) {
        $string .= $_;
    }
    close(IFH);

    # Return string
    return $string;
}

# PostScript prologues
my $src = $ENV{DTAGHOME} || "/opt/dtag/";
print "PostScript files loaded from $src\n";
$psheader->{'arcs'}  = readfile("$src/arcs.header");
$pstrailer->{'arcs'} = readfile("$src/arcs.trailer");

# Default edges used in the treebank
my $etypes = 
	{
		'comp' => [],
		'adj' => [],
		'land' => [],
		'other' => []
	};

