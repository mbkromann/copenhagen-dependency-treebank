package FindActionDTAG;
@FindActionDTAG::ISA = qw(FindAction);

sub commands {
	my ($self, $graph, $binding) = @_;

   	# Replace variables with bindings
	my $cmds = [];
	foreach my $oplist (@{$self->{'args'}}) {
		my $cmd = "";
		foreach my $op (@$oplist) {
			$cmd .= $op->value($graph, $binding);
		}
		push @$cmds, $cmd;
	}
	return $cmds;
}

sub string {
	my ($self, $graph, $binding) = @_;
	return join("; ", @{$self->commands($graph, $binding)});
}

sub do {
	my ($self, $graph, $binding, $interpreter) = @_;
	foreach my $cmd (@{$self->commands($graph, $binding)}) {
		$interpreter->do($cmd);
	}
}

sub print {
	my $self = shift;
	my @cmds = ();
	foreach my $cmd (@{$self->{'args'}}) {
		push @cmds, join(",", @$cmd);
	}
	return join("§", @cmds);
}
