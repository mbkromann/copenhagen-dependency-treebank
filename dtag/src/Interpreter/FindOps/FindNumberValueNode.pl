package FindNumberValueNode;
@FindNumberValueNode::ISA = qw(FindNumberValue);

use overload
    '""' => \& pprint;

sub vars {
	return [0];
}

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$unbound->{$self->{'args'}[0]} = 1;
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my $node = $args->[0];
	return $self->{'args'}[0];
}

sub nvalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my $nodevar = $self->{'args'}[0];
	my $value = $self->varbind($bindings, $bind, $nodevar);

	#print "  self=" . DTAG::Interpreter::dumper($self) . "\n";
	#print "  bindings=" . DTAG::Interpreter::dumper($bindings) . "\n";
	#print "  bind=" . DTAG::Interpreter::dumper($bind) . "\n";
	#print "  nodevar=" . DTAG::Interpreter::dumper($nodevar) . "\n";
	#print "  value=" . DTAG::Interpreter::dumper($value) . "\n";
	return defined($value) ? $value : -1;
}

