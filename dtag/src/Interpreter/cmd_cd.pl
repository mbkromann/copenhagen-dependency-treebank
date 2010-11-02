sub cmd_cd {
	my $self = shift;
	my $dir = (shift) || "";

	# Change to new directory
	my $HOME = $ENV{'HOME'} || ".";
	$dir =~ s/~/$ENV{'HOME'}/g;
	chdir($dir);
	$self->cmd_shell("pwd");

	# Return
	return 1;
}
