sub ps_boxes_colour {
	my $self = shift;

	# Print boxes 
	my $s = "% Print box fills\n";
	my $cover = $self->cover();
	my $n = scalar(@$cover) + 1;
	my $k = max(2, int(log($n) / log(3)));

	# Print boxes
	for (my $i = ($#$cover - 1); $i >= 0; --$i) {
		my $red = (($i + 1) % $k) / $k;
		my $blue = (int(($i + 1) / $k) % $k) / $k;
		my $green = (int(($i + 1) / $k / $k) % $k) / $k;

		my $box = $cover->[$i]->space_box();
		$s .= "$red $green $blue setrgbcolor "
			. ($box->[0][0] * 100) . " "
			. ($box->[1][0] * 100) . " "
			. ($box->[0][1] * 100) . " "
			. ($box->[1][1] * 100) 
			. " box fill\n";
	}

	# Return string
	return $s . "0 setgray\n\n";
}

