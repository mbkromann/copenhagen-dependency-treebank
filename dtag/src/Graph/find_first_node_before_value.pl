# Find last node where $node->attr() <= $val, using binary search
sub find_first_node_before_value {
	my $self = shift;
	my $attr = shift;
	my $value = shift;
	my $nodes = shift || $self->nodes_with_attr($attr);

	# Initialize
	my $first = 0;
	my $last = $#$nodes;
	my $nval;
	return undef 
		if ($last < 0 || ! defined($value));
	return undef
		if (defined($nval = $self->nodevar_checked($first, $attr)) && $nval > $value);
	return $last
		if (defined($nval = $self->nodevar_checked($last, $attr)) && $nval <= $value);

	# Binary search	
	my $mid = int(($first + $last) / 2);
	while ($mid != $first)  {
		$nval = $self->nodevar_checked($mid, $attr);
		return undef if (! defined($nval));
		if ($nval <= $value) {
			# [$mid] <= $value < [$last]
			$first = $mid;
		} else {
			# [$first] <= $value < [$mid]
			$last = $mid;
		}
		$mid = int(($first + $last) / 2);
	}

	# Return
	return $mid;
}

sub nodevar_checked {
	my $self = shift;
	my $node = shift;
	my $var = shift;
	return undef if (! defined($node));
	my $n = $self->node($node);
	return undef if (! defined($n));
	my $v = $n->var($var);
	return $v;
}
