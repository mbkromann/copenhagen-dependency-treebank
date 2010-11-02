sub cmd_kplay {
	my $self = shift;
	my $graph = shift;
	my $speed = shift || 1;
	my $time0 = shift || 0;
	my $time1 = shift || 25;

	# Calculate step size in seconds 
	my $updatesPerSec = 5;
	my $step = $speed / $updatesPerSec;

	my $systime0 = time();
	for (my $t = $time0; $t < $time1; $t += $step) {
		$self->cmd_kgoto($graph, $t);
		sleep(1.0 / $updatesPerSec);
	}
}
