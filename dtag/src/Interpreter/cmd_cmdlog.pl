sub cmd_cmdlog {
	my $self = shift;
	my $file = shift;

	# Insert user name
	my $user = $self->var("user") || "none";
	if ($file =~ /{USER}/) {
		$file =~ s/{USER}/$user/g;
	}
	my $HOME = $ENV{'HOME'};
	$file =~ s/\s*\~\//$HOME\//g;

	# Open file for appending
	my $fh;
	my $date = `date +'%Y.%m.%d-%H.%M'` || "???";
	chomp($date);
	$file = $file . "-$date";
	if (open($fh, ">>", $file)) {
		autoflush $fh 1;
		$self->var("cmdlog", $fh);
		$self->var("cmdlog.time0", time());
		print $fh "# open cmdlog: $date\n";
		return 1;
	}

	error("Cannot open file $file for appending");
	return 0;
}
