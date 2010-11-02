=item $text->streams($time0, $time1) = $streams

Return list of stream names occurring in the text after $time0
and before $time1.

=cut

sub streams {
	my $self = shift;
	my $time0 = shift;
	my $time1 = shift;

	return [sort(keys(%{$self->inputs()}))];
}
