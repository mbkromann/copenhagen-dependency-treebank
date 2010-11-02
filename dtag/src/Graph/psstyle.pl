=item $graph->psstyle($default, $context, $styles) = $ps

Return PostScript string $ps associated with style list $styles, given
style context $context and object $default defining default style
values. 

=cut

sub psstyle {
	my $self = shift;
	my $default = shift;
	my $context = shift;
	my $arg = shift;

	# Create list of styles
	my $styles = (ref($arg) eq 'ARRAY') ? $arg : [];

	# Concatenate PostScript commands associated with styles
	my $ps = "";
	foreach my $s (@$styles) {
		my $style = $self->style($default, $s);
		if ($style) {
			$ps .= $style->{$context};
		}
	}
	$ps =~ s/\s*$//;

	# Ensure PostScript string has been stored as PostScript style
	if ($ps && ! $self->{'psstyles'}{$ps}) {
		$self->{'psstyleno'} += 1;
		$self->{'psstyles'}{$ps} = $self->{'psstyleno'};
	}

	# Return PostScript style number
	return $ps ? " " . $self->{'psstyles'}{$ps} : "";
}
	
