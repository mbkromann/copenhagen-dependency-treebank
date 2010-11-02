# --------------------------------------------------

=head1 DTAG::Alignment

=head2 NAME

DTAG::Alignment - DTAG alignment graphs

=head2 DESCRIPTION

DTAG::Alignment - creating, manipulating and drawing alignments

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Alignment;
require DTAG::Interpreter;
use strict;

# Graph identifier
my $alignment_id = 0;

# PostScript 
my $pstrailer = {};
my $psheader = {};

sub readfile {
    my $file = shift;
    my $string = "";

    # Read file
    open(IFH, $file) 
		|| return DTAG::Interpreter::error("cannot read file $file in Alignment->readfile\n" .
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
$psheader->{'align'}  = readfile("$src/align.header");
$pstrailer->{'align'} = readfile("$src/align.trailer");


