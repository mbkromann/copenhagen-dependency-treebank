sub cmd_print {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $follow = shift;

	# Update follow or print file
	if ($follow) {
		$file = $graph->fpsfile() || $self->fpsfile();
	} else {
		$graph->psfile($file) if ($file);
		$file = $graph->psfile();
	}
	# print "printing $graph to $file\n" if (! $self->quiet());

	# Print file
	if ($file) {
		my $ps = $graph->postscript($self) || "\n";
		my $tmpfile = $file . ".utf8";
		my $tmpfile2 = $file . ".final";
		#open(PSFILE, ">:encoding(iso-8859-1)", $file . "~") 
		#open(PSFILE, ">:utf8", $tmpfile) 
		#print "Printing $tmpfile $tmpfile2 $file\n";
		open(PSFILE, ">", $tmpfile) 
			|| return error("cannot open file $file for printing!");
		print PSFILE $ps;
		close(PSFILE);
		my $iconv = $self->{'options'}{'iconv'} || 'cat';
		my $cmd = $iconv . " $tmpfile > $tmpfile2";
		system("cp $tmpfile $tmpfile2");
		system($cmd);
		system("cp $tmpfile2 $file");
		system("rm $tmpfile");
		system("rm $tmpfile2");
	}

	# Return
	return 1;
}
