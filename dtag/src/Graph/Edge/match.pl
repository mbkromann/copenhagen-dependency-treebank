=item $edge->match($typedef) = $boolean

Test whether $edge matches type definition $typedef, which must be a
regular expression or an atomic name. 

=cut

sub match {
	my $self = shift;
	my $typedef = shift;

	if ($typedef =~ /^\/.*\/$/) {
		# Regular expression
		my $name = $self->type();
		return 1 if (eval("\$name =~ $typedef"));
	} else {
		# Atomic name
		return 1 if ($self->type() eq $typedef);
	}

	return 0;
}
