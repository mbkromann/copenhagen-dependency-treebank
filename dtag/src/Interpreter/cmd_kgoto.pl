my $kgoto_server = 0;

sub cmd_kgoto {
	my $self = shift;
	my $graph = shift;
	my $time = shift || 0;

	# Create server
	my $server = $graph->var("gvim");
	if (! $server) {
		print "Start new gvim\n";
		$server = $graph->var("gvim", "DTAG-keyview." . ++$kgoto_server);
		system("gvim --servername $server -geometry 80x24-0+0");
		system("gvim --servername $server --remote-send ':set ww=hl\n'");
	}

	# Create vim command
	my $vim = "1GdGi";
	for (my $i = 0; $i < $graph->size(); ++$i) {
		# Check time
		my $node = $graph->node($i);
		my $ntime = $node->var("time");
		print "ntime=$ntime time=$time\n";
		last if (defined($ntime) && $ntime > $time);
		my $nvim = $node->var("vim");
		$vim .= $nvim if (defined($nvim));
	}

	# Send vim command to server
	system("gvim --servername $server --remote-send '$vim'");
}
