sub filter {
	my $self = shift;
	my $data = shift;
	my $box = shift || $self->box();

	# Filter data through box
	my ($i, $ok);
	my $included = [];
	my $excluded = [];
	foreach my $d (@$data) {
		# Check each dimension of $d
		$ok = 1;
		for (my $i = 0; $i < scalar(@$box); ++$i) {
			if (! grep {$_ eq $box->[$i]} 
					($d->[$i], @{$lexicon->{'super'}{$d->[$i]} || []})) {
				$ok = 0;
				last();
			}
		}

		# Save example if it survived filter
		if ($ok) {
			push @$included, $d;
		} else {
			push @$excluded, $d;
		}
	}

	# Return list of included and excluded data
	return [$included, $excluded];
}
