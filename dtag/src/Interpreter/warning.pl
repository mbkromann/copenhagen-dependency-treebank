sub warning {
	print "\aWARNING! " . join("", @_) . "\n";
	return 0;
}
