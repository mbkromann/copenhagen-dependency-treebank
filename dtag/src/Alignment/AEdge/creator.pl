# creator:
#	+n = user_id
#   -n = automatic confirmed n times
# 	-100 = automatic unconfirmed
#   -101 = hard default (only overridden by user)

sub creator {
	my $self = shift;
	$self->[6] = shift if (@_);
	return $self->[6] || 0;
}
