# --------------------------------------------------

=head1 NAME

DTAG::Learner::EHPM
	
=cut

# --------------------------------------------------

package DTAG::Learner::EHPM;
use strict;

# Specify super class
use base 'DTAG::Learner::Distribution';

# Specify default posterior function of partition
my $mlog_posterior_function = sub {
	my $self = shift;
	my $partition = shift;

	# Return Minimum Description Length posterior probability of partition
	return 
		$self->mlog_likelihood($partition)
		+ log($self->total() || 1) / 2;
};

