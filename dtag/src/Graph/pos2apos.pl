sub pos2apos {
	my $self = shift;
	my $pos = shift;

	# Decompose position
	$pos =~ /^([+=-])?([0-9]+)$/;
	my $o = $1 || "+";
	my $n = $2 || "0";

	# Calculate absolute position
	if ($o eq "+") {
		return $self->offset() + $n;
	} elsif ($o eq "-") {
		return $self->offset() - $n;
	} elsif ($o eq "=") {
		return $n;
	} else {
		DTAG::Interpreter::error("Invalid argument $pos to Graph->pos2apos()");
		return undef;
	}
}	
