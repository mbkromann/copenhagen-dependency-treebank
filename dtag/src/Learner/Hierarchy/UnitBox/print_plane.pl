sub print_plane {
	my $self = shift;
	my $plane = shift;

	return join(" ", map {$_->[0] . ':[' 
		. sprintf("%.4g", $_->[1]) . "," 
		. sprintf("%.4g", $_->[2]) . "]"}
		@$plane);
}
