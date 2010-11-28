sub cmd_user {
	my $self = shift;
	my $user = shift;

	# Try to set user from $ENV{'USER'}
	my $username = $ENV{'USER'} || "unknown";

	# Try to read user from command options
	if ($user =~ /^-f\s+(\S+)\s*$/) {
		my $userfile = $1;
		if ( -r $userfile) {
			$username = `cat $userfile` || "none";
			chomp($username);
		} else {
			warning("Non-existent file $userfile\n");
		}
	} elsif ($user =~ /^\s*(\S+)\s*$/) {
		$username = $user;
	}

	# Set username
	$self->var("user", $username);

	# Print user and exit
	print "User: " . $self->var("user") . "\n";
	return 1;
}
