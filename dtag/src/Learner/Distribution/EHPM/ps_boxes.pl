sub ps_boxes {
	my $self = shift;

	# Print boxes 
	my $s = "% Print box outlines\n";
	my $cover = $self->cover();
	for (my $i = $#$cover; $i >= 0; --$i) {
		my $box = $cover->[$i]->space_box();
		$s .= ($box->[0][0] * 100) . " "
			. ($box->[1][0] * 100) . " "
			. ($box->[0][1] * 100) . " "
			. ($box->[1][1] * 100) 
			. " box stroke\n";
	}

	# Return string
	return $s . "\n";
}

