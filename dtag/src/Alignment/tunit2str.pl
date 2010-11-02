sub tunit2str {
	my $tunit = shift;
	return join(" ", sort(@$tunit));
}

