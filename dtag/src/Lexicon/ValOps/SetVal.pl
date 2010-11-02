package SetVal;
@SetVal::ISA = qw(ValOp);

sub preset {
	my $self = shift;
	my $value = shift;

	# Check that $value is a list reference
	if (ref($value) ne "ARRAY") {
		$value = [ ];
	}

	# Return value
	return $value;
} 

sub postset {
	my $self = shift;
	my $value = shift;

	# Add plus-members
	foreach my $elem (@{$self->plus()}) {
		# Add element to list if non-existent
		if (! grep {$_ eq $elem} @$value) {
			push @$value, $elem;
		}
	}

	# Subtract minus-members
	if (scalar(@{$self->minus()})) {
		for (my $i = 0; $i < scalar(@$value); ) {
			my $elem = $value->[$i];
			if (grep {$_ eq $elem} @{$self->minus()}) {
				# Delete element $i
				splice(@$value, $i, 1);
			} else {
				++$i;
			}
		}
	}

	# Return list
	return $value;
}


