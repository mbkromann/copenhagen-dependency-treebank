sub print_box {
	my $self = shift;
	my $box = shift;

	#return 
	#	join("x",  map {
	#			"[" . join(",", 
	#				map {sprintf("%.4g", $_)} @$_) . "]"
	#		} @$box);

	# Process each dimension
	my @paths = ();
	my $branch = $self->branching();
	foreach my $range (@$box) {
		my ($min, $max) = @$range;
		my $dist = $max - $min;
		my $path = "c";
		while ($dist < 0.99999999) {
			$path .= int($min * $branch + 1 + 1e-15);
			$min = $min * $branch - int($min * $branch);
			$dist *= $branch;
		}
		push @paths, $path;
	}

	# Return path
	return "[" . join(",", @paths) . "]";
}
