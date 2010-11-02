sub cmd_option {
	my $self = shift;
	my $option = shift;
	my $value = shift;
	$value =~ s/\s*$//;

	if (defined($value)) {
		# Set option (if value given)
		$self->option($option, $value);
	}#} else {
		# Print option
		$value = $self->option($option);
		$value = 'undef' if (! defined($value));
		print "option $option=", $value, "\n";
	#}

	# Exit
	return 1;
}
