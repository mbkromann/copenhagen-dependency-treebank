sub print_osdt {
	my $self = shift;
	my $id = shift;
	my $index = shift;
	
	# Find source and target graphs
	my $sgraph = $self->{'graphs'}{"a"};
	my $tgraph = $self->{'graphs'}{"b"};
	my $snodes = {};
	my $tnodes = {};

	# Encode source graph
	my $source = $sgraph->print_osdt("source: ", 0, 0, $snodes);
	my $views = $snodes->{'_views'};
	my $nodes = $snodes->{'_nodes'};
	my $target = $tgraph->print_osdt("target: ", $views, $nodes, $tnodes);
	$views = $tnodes->{'_views'};
	$nodes = $tnodes->{'_nodes'};

	# Encode target graph
	my $s = $source . $target . "LAYER" . $views++ . " \"word alignments\" 0=\"type\" 1=\"creator\"\n";

	foreach my $e(@{$self->edges()}) {
		my $type = $e->type();
		my $creator = $e->creator();
		$type = " 0=\"$type\"" if (defined($type));
		$creator = " 1=\"$creator\"" if (defined($creator));
		$s .= "  NODE" . $nodes++ . "$type$creator\n";

		# Find nodes
		my $enodes = [];
		foreach my $in (@{$e->inArray()}) {
			push @$enodes, ($e->inkey() eq "a") 
				? $snodes->{$in} : $tnodes->{$in};
		}
		foreach my $out (@{$e->outArray()}) {
			push @$enodes, ($e->outkey() eq "a") 
				? $snodes->{$out} : $tnodes->{$out};
		}
		$enodes = [uniq(sort(@$enodes))];

		# Print edges
		foreach my $enode (@$enodes) {
			$s .= "  EDGE " . ($nodes - 1) . "<" . "$enode\n";
		}
	}

	print $s;
	return $s;
}

