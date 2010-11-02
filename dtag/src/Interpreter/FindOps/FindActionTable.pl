package FindActionTable;
@FindActionTable::ISA = qw(FindAction);

sub do {
	my $self = shift;
	my $binding = shift;
	my $interpreter = shift;
	my $ask = shift;

   	# Replace variables with bindings
	foreach my $op (@{$self->{'args'}}) {	
		foreach my $var (keys(%$binding)) {
			my $val = $binding->{$var};
			$var = '\\' . $var;
			$op =~ s/$var/$val/g;
		}
		print "    Operation: $op\n" if ($ask);
		$interpreter->do($op);
	}
}
