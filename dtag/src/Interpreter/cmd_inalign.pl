sub cmd_inalign {
	my $self = shift;
	my $graph = shift;
	my $from = map_align_offset(shift, $graph->offset());
	my $to = map_align_offset(shift, $graph->offset());
	my $label = shift;
	$label = "" if (! defined($label));

	# Store alignment edge in graph (in toggle fashion, so it is
	# deleted if it already exists)
	if (exists $graph->{'inalign'}{"$from $to $label"}) {
		delete $graph->{'inalign'}{"$from $to $label"};
	} else {
		$graph->{'inalign'}{"$from $to $label"} = 1;
	}

	# Return
	return 1;
}

sub map_align_offset {
	my $spec = shift;
	my $offset = shift;
	my $result = "";
	while (length($spec) > 0) {
		if ($spec =~ s/^(-?[0-9]+)//) {
			$result .= ($1 + $offset);
		} else {
			$spec =~ s/^([^0-9-]+)//g;
			$result .= $1;
		}
	}
	return $result;
}
