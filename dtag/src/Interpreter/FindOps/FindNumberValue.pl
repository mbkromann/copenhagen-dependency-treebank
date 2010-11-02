package FindNumberValue;
@FindNumberValue::ISA = qw(FindValue);

use overload
    '""' => \& pprint;
	    
sub unbound {
	my $self = shift;
	my $unbound = shift;
	return $unbound;
}

sub nvalue {
	my $self = shift;
	return $self->{'args'}[0];	
}

sub value {
	my ($self, $graph, $bindings, $bind) = @_;
	return $self->nvalue($graph, $bindings, $bind);
}

sub pprint {
	my $self = shift;
	return $self->{'args'}[0];
}
