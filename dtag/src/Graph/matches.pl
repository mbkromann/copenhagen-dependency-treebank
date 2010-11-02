=item $graph->matches($interpreter)

Return hash containing all nodes in $graph which the interpreter
$interpreter has marked as matches from a "find" query. 

=cut

sub matches {
	my $self = shift;
	my $inter = shift;

	# Find matched nodes in interpreter
	my $match = {};
	if ($inter) {
		# Find list of matches
		my $m = 
			$inter->{'matches'}{$self->id() || ""}
			|| $inter->{'matches'}{$self->file() || ""}
			|| [];
		my $irm = $inter->{'replace_match'};
		my $irmf = $irm ? $irm->{$self} : undef;
		$m = $irmf if ($irmf);

		# Process list of matches
		foreach my $b (@$m) {
			map {$match->{$b->{$_}} = 1} keys(%$b);
		}
	}

	# Return hash with matched nodes
	return $match;
}
