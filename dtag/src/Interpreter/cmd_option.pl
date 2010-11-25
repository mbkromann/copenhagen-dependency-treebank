sub cmd_option {
	my $self = shift;
	my $option = shift;
	my $value = shift;
	$value =~ s/\s*$// if (defined($value));

	if (defined($value)) {
		# Set option (if value given)
		$self->option($option, $value);
	} elsif ($option eq "*") {
		foreach my $opt (sort(keys(%{$self->{"options"}}))) {
			$self->cmd_option($opt);
		}
	} else {
		# Print option
		$value = $self->option($option);
		$value = 'undef' if (! defined($value));
		print "option $option=", $value, "\n";
	}

	# Exit
	return 1;
}
