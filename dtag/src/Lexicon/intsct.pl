sub intsct {
	my $self = shift;
	my $type1 = shift;
	my $type2 = shift;

	# Find intersection of $type1 and $type2
	if (grep {$_ eq $type2} ($type1, @{$self->{'super'}{$type1}})) {
		# $type1 is a subtype of $type2
		return $type1;
	} elsif (grep {$_ eq $type1} ($type2, @{$self->{'super'}{$type2}})) {
		# $type2 is a subtype of $type1
		return $type2;
	} else {
		# $type1 and $type2 are unrelated
		return undef;
	}
}
