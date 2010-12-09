sub cmd_user {
	my $self = shift;
	my $user = shift;
	$user = "" if (! defined($user));

	# Try to set user from $ENV{'USER'}
	my $username = $self->var("user");
	$username = $ENV{'USER'} if (! defined($username));

	# Try to read user from command options
	if ($user =~ /^\s*-f\s+(\S+)\s*$/) {
		my $userfile = $1;
		if (-r $userfile) {
			$username = `cat $userfile` || $ENV{'user'} || "none";
			chomp($username);
		} else {
			warning("Non-existent file $userfile");
		}
	} elsif ($user =~ /^\s*(\S+)\s*$/) {
		$username = $user;
	}

	# Set username
	$username =~ s/\s+//g;
	$ENV{'CDTUSER'} = $username;
	$self->var("user", $username);

	# Print user and exit
	print "User: " . $self->var("user") . "\n";
	return 1;
}
