# Annotate each node with:
#	* distance to root of sentence
# 	* number of in-edges
#	* number of out-edges
#	* number of edges
#	* yield

sub statistics {
	my $self = shift;

	# Define yields and depths hashes
	my $yields = {};
	my $depths = {};

	# Define vars
	$self->vars()->{'_yield'} = undef;
	$self->vars()->{'_yieldN'} = undef;
	$self->vars()->{'_height'} = undef;
	$self->vars()->{'_depth'} = undef;
	$self->vars()->{'_maxdepth'} = undef;
	$self->vars()->{'_maxinoutN'} = undef;
	$self->vars()->{'_inN'} = undef;
	$self->vars()->{'_outN'} = undef;
	$self->vars()->{'_inoutN'} = undef;


	# Process all non-comment nodes in the graph
	$self->yields($yields);
	for (my $n = 0; $n < $self->size(); ++$n) {
		my $node = $self->node($n);
		if ($node && ! $node->comment()) {
			# Find yield of node
			$node->var('_yield', join(";",
				map {join("-", @$_)} @{$yields->{$n}}));

			# Find depth of node
			$self->depths($depths, $n);
			$node->var('_depth', $depths->{$n});

			# Find number of edges in node
			$node->var('_inN', scalar(@{$node->in()}));
			$node->var('_outN', scalar(@{$node->out()}));
			$node->var('_inoutN', 
				$node->var('_inN') + $node->var('_outN')); 

		}
	}

	for (my $n = 0; $n < $self->size(); ++$n) {
		my $node = $self->node($n);
		if ($node && ! $node->comment()) {
			# Find maximal depth and edges
			my $maxdepth = $node->var('_depth');
			my $maxedges = $node->var('_inoutN'); 
			my $nodes = 0;
			foreach my $span (@{$yields->{$n}}) {
				for (my $i = $span->[0]; $i <= $span->[1]; ++$i) {
					++$nodes;
					$maxdepth = max($maxdepth,
						$self->node($i)->var('_depth') || 0);
					$maxedges = max($maxedges,
						$self->node($i)->var('_inoutN') || 0);
				}
			}
			$node->var('_maxinoutN', $maxedges);
			$node->var('_maxdepth', $maxdepth);
			$node->var('_yieldN', $nodes);
		}
	}
}

