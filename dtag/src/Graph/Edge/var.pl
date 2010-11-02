=item $edge->var($var, $value) = $value

Get/set value $value for variable $var in edge.

=cut

sub var {
	my $self = shift;
	my $var = shift;
	my $vars = $self->vars();

	# Supply new value
	if (@_) {
		my $value = shift;

		# Add variable, if non-existent
		if ($vars !~ /§$var=/) {
			$vars .= "$var=$value§";
		} else {
			# Replace variable value
			$vars =~ s/§$var=[^§]*§/§$var=$value§/;
		}

		# Return value
		$self->vars($vars);
		return $value;
	}

	# Dirty Perl hack needed to reset $1 to ""
	my $e = "";
	$e =~ /^(\s*)$/;

	# Find existing value
	$vars =~ /§$var=([^§]*)§/;
	return $1 || "";
}

