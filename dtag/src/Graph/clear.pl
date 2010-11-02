=item $graph->clear()

Delete all nodes and edges from graph.

=cut

sub clear {
    my $self = shift;
    
    $self->nodes([]);
    #$self->vars({});
	$self->boundaries([]);
	$self->position(0);
	$self->input("");
	$self->var('imin', -1);
	$self->var('imax', -1);
}   

