sub process_aedge_da_it {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Debug
	#print $e->string() . "\n";	

	# Check inkey and outkey
	return if (! ($e->outkey() eq $skey && $e->inkey() eq $tkey));

	# Color all non 1-1 edges
	#if (scalar(@{$e->inArray()}) > 1 || scalar(@{$e->outArray()}) > 1) {
	#	foreach my $n (@{$e->inArray()}) {
	#		my $node = $graph->node($n);
	#		$node->var('styles', 'red') if ($node);
	#	}
	#}

	# Process all 1-2 edges 
	if (scalar(@{$e->inArray()}) == 2 && scalar(@{$e->outArray()}) == 1) {
		my $out = $e->outArray()->[0];
		my $in1 = $e->inArray()->[0];
		my $in2 = $e->inArray()->[1];
		
		if ($graph->node($in1)->var($tag) =~ /^VB/
				&& ($graph->node($in2)->var($tag) =~ /^VB/
					|| $graph->node($in2)->input() =~ /ed$/)) {
			# V <--> V1 V2
			my_edge_add($graph, Edge->new($in2, $in1, 'vobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^D/
				&& $graph->node($in2)->var($tag) =~ /^N/) {
			# Ndef <--> DET N
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^N/
				&& $graph->node($in2)->var($tag) =~ /^N/) {
			# N <--> N N
			my_edge_add($graph, Edge->new($in1, $in2, 'mod'), "");
		} elsif ($graph->node($in2)->var($tag) =~ /^IN/) {
			# X <--> X P
			my_edge_add($graph, Edge->new($in2, $in1, 'pobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^IN/
				&& $graph->node($in2)->var($tag) =~ /^[ND]/) {
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} else {
			# Default
			#my_edge_add($graph, Edge->new($in2, $in1, '???'));
		}
	}
}
