=item $node->varstr($var, $perlexpr) = $perlexpr

Get/set value for variable $var, using a string $perlexpr evaluated
as a Perl expression.

=cut

sub varstr {
	my $self = shift;
	my $var = shift;

	# Write new value
	$self->{$var} = shift if (@_);

	# Return value
	return dumpstr($self->{$var});
}


