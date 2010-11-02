sub cmd_user {
	my $self = shift;
	my $user = shift;

	if ($user =~ /^-f\s+(\S+)\s*$/) {
		my $userfile = $1;
		if ( -r $userfile) {
			my $username = `cat $userfile` || "none";
			chomp($username);
			$self->var("user", $username);
		}
	} elsif ($user =~ /^\s*(\S+)\s*$/) {
		$self->var("user", $user);
	}
	print "User: " . $self->var("user") . "\n";
	return 1;
}
