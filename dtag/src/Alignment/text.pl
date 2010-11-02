=item $graph->text($separator, $maxlen) = $text

Return the first $maxlen characters of text in the graph, inserting
$separator between the text of individual nodes. $maxlen defaults to
the length of the entire graph, and $separator defaults to "".

=cut

sub text {
	my $self = shift;
	my $sep = shift || "";
	my $maxlen = shift;

	# Compute the first $maxlen chars of text of graph with separator $sep
	my $text = "";
	my $size = $self->size();
	my $first = 1;
	for (my $i = 0; $i < $size; ++$i) {
		# Add text
		my $node = $self->node($i);
		if (! $node->comment()) {
			$text .= $sep if (! $first);
			$text .= $node->input();
			$first = 0;
		}

		# Exit if $text size exceeds $max
		last() if ($maxlen && length($text) > $maxlen);
	}

	# Return text
	return $text;
}
