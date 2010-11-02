sub error {
	print "\aERROR! " . join("", @_) . "\n";
	return 0;
}
