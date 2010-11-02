sub str2tunit {
	my $tunits = shift;
	my $str = shift;
	my ($n) = split(/ /, $str);
	return $tunits->{$n}
}

