sub process_aedge_da_es {
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

	my $source = $alignment->graph($skey);

	# Process all 1-2 edges 
	if (scalar(@{$e->inArray()}) == 2 && scalar(@{$e->outArray()}) == 1) {
		my $out = $e->outArray()->[0];
		my $in1 = $e->inArray()->[0];
		my $in2 = $e->inArray()->[1];
		
		my $etype = $e->type();
		my $outtag = $source->node($out)->var($tag);
		my $in1tag = $graph->node($in1)->var($tag);
		my $in2tag = $graph->node($in2)->var($tag);

		if ($in1tag =~ /^V.*fin/ && $in2tag =~ /^V.*inf/) {
			# V <--> V1 V2
			my_edge_add($graph, Edge->new($in2, $in1, 'vobj'), "");
		} elsif ($etype eq "s") {
			my_edge_add($graph, Edge->new($in2, $in1, 'mod'), "");
		} elsif ($in1tag =~ /^ART/ && $in2tag =~ /^NC/) {
			# Ndef <--> DET N
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} elsif ($in1tag =~ /^NC/ && $in2tag =~ /^ADJ/) {
			# NN <--> N ADJ 
			my_edge_add($graph, Edge->new($in2, $in1, 'mod'), "");
		#} elsif ($in1tag =~ /^N/ && $in2tag =~ /^N/) {
		#	# N <--> N N
		#	my_edge_add($graph, Edge->new($in1, $in2, 'mod'), "");
		} elsif ($in2tag =~ /^PREP/) {
			# X <--> X P
			my_edge_add($graph, Edge->new($in2, $in1, 'pobj'), "");
		} elsif ($in1tag =~ /^PREP/ && $in2tag =~ /^(N|Art)/) {
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
			
		} else {
			# Default
			#my_edge_add($graph, Edge->new($in2, $in1, '???'));
		}
	}

	# Process all 1-3 edges
	if (scalar(@{$e->inArray()}) == 3 && scalar(@{$e->outArray()}) == 1) {
		my $out = $e->outArray()->[0];
		my $in1 = $e->inArray()->[0];
		my $in2 = $e->inArray()->[1];
		my $in3 = $e->inArray()->[2];
		
		my $etype = $e->type();
		my $outtag = $source->node($out)->var($tag);
		my $in1tag = $graph->node($in1)->var($tag);
		my $in2tag = $graph->node($in2)->var($tag);
		my $in3tag = $graph->node($in3)->var($tag);

		if ($in1tag eq "ART" && $in2tag eq "NC" && $in3tag eq "ADJ") {
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
			my_edge_add($graph, Edge->new($in3, $in1, 'mod'), "");
		}
	}		
}
