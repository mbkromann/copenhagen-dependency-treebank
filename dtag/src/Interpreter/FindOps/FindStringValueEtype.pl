package FindStringValueEtype;
@FindStringValueEtype::ISA = qw(FindStringValue);

use overload
    '""' => \& pprint;

sub pprint {
	my $self = shift;
	my ($in, $out, $relpattern) = @{$self->{'args'}};
	return "etypes(" . $in . (defined($relpattern) ? 
		" " . $relpattern->pprint() : ",")
		. " " . $out . ")";
}

sub svalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my ($invar, $outvar, $relpattern) = @{$self->{'args'}};
	return undef if (! (defined($invar) && defined($outvar)));

	# Find key graph
	my $keygraph = $self->keygraph($graph, $bindings, $invar);
	return undef if (! defined($keygraph));

	# Find node id and node
	my $inid = $self->varbind($bindings, $bind, $invar);
    my $outid = $self->varbind($bindings, $bind, $outvar);
	return undef if (! (defined($inid) && defined($outid)));

	# Find node
	my $innode = $keygraph->node($inid);
	return undef if (! defined($innode));
	
	# Find edge types for all matching edges
	my @etypes = ();
	foreach my $e (@{$innode->in()}) {
		my $etype = $e->type();
		push @etypes, DTAG::Interpreter::strip_relation($etype)
			if ($e->out() == $outid 
				&& ((! defined($relpattern)) 
					|| $relpattern->match($keygraph, $etype)));
	}

	# Find value
	return join(" ", @etypes);
}


sub ask { 
	return 0; 
} 

