my $OLDSTDOUT;
my $NEWSTDOUT;

sub cmd_redirect {
	my $self = shift;
	my $file = shift;

	#!/usr/bin/perl
	
	if (defined($file)) {
		# Save old STDOUT
		if (! defined($OLDSTDOUT)) {
			open $OLDSTDOUT, ">&STDOUT" or die "Can't dup STDOUT: $!";
		}

		# Close old file STDOUT
		if (defined($NEWSTDOUT)) {
			close($NEWSTDOUT);
			$NEWSTDOUT = undef;
		}

		# Open new STDOUT
		print STDERR "Redirecting STDOUT to $file\n";
		open $NEWSTDOUT, '>', $file or die "Can't open new STDOUT: $!";
		open STDOUT, ">&", $NEWSTDOUT or die "Can't redirect STDOUT: $!";
		select STDOUT; $| = 1;    # make unbuffered
	} else {
		if ($OLDSTDOUT) {
			open STDOUT, ">&", $OLDSTDOUT or die "Can't dup \$oldout: $!";
			print "Redirecting to original STDOUT\n";
		}

		# Close old file STDOUT
		if (defined($NEWSTDOUT)) {
			close($NEWSTDOUT);
			$NEWSTDOUT = undef;
		}
	}

	return 1;
}
