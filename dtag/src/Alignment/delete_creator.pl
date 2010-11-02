sub delete_creator {
	my $self = shift;
	my $creator1 = shift || -100;
	my $creator2 = shift || $creator1;

    # Delete all edges with given creator interval
    my $edges = $self->edges();
    for (my $e = 0; $e < scalar(@$edges); ++$e) {
        # Delete all automatically created edges
        my $edge = $edges->[$e];
		my $creator = $edge->creator();
        if ($creator1 <= $creator && $creator <= $creator2) {
            # Delete edge and decrement edge counter
            $self->del_edge($e);
            --$e;
        }
    }
}

