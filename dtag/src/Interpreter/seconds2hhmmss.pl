sub seconds2hhmmss {
	my $seconds = shift;

	return sprintf("%02i:%02i:%02i", 
		int($seconds / 3600), int($seconds / 60) % 60, int($seconds) % 60);
}
