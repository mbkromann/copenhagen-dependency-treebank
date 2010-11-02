package FindPATH;
@FindPATH::ISA = qw(FindOp);

sub vars {
	return [0,2];
}

sub match {
}

sub path {
	my $self = shift;
	my $graph = shift;
	my $binding = shift;
	my $bind = shift;
}

sub pprint {
	my $self = shift;
	my $type = ref($self);
	my $neg = ($self->{'neg'}) ? "!" : "";

	my $path = DTAG::Interpreter::dumper($self->{'args'}[1]);
	$path =~ s/^\$VAR1 = (.*);$/$1/;

	return "$neg$type(" . $self->{'args'}[0]  . ",$path," 
		. $self->{'args'}[2] . ")";
}
