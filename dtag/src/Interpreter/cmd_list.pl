sub cmd_list {
	my $self = shift;
	my $cmd = shift || "";

	# Print matches
	if ($cmd =~ s/\s*-match(es)?\s*//) {
		# Print all matches
		my $matches = $self->{'matches'};
		my $i = 0;
		foreach my $f (sort(keys(%$matches))) {
			foreach my $m (@{$matches->{$f}}) {
				++$i;
				print $self->cmd_list_matchno($i, $f, $m) . "\n";
			}
		}
	}

	# Return
	return 1;
}
