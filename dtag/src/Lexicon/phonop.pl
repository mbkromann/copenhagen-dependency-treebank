sub phonop {
	my $self = shift;
	my $src = shift;
	my $dst = shift;

	# Escape "/" in $src and $dst
	$src =~ s/\//\\\//g;
	$dst =~ s/\//\\\//g;

	# Create new replacement-pattern
	my $pattern = 's/^' . $src . '$/' . $dst . '/';

	# Add new pattern to phonops-list
	push @{$self->{'phonops'}}, $pattern;
}
