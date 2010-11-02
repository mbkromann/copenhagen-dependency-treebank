=item $align->postscript() = $postscript

Return PostScript representation $postscript for alignment graph.

=cut


sub postscript {
	my $self = shift;
	my $interpreter = shift;

	# Variables
	my $node_edges = $self->var('nodes');
	my $nodes = { };
	my $ps = "% Nodes\n";
	my $setup = " ";

	# Boundaries
	my $boundaries = $self->var('autoalign') || [];
	my ($outkey, $o1, $o2, $inkey, $i1, $i2) = @$boundaries;

	# Draw nodes in each graph and number them
	my $node = 0;
	my $left = 0;
	foreach my $g (sort(keys(%{$self->graphs()}))) {
		# Create new column
		$ps .= "\n% Column $g\nnewcolumn\n";

		# Find graph object
		my $graph = $self->var('graphs')->{$g};
		if (! $graph) {
			DTAG::Interpreter::error("non-existent graph for key $g");
			next();
		}

		# Process all included nodes in graph
		my $onode = $node;
		my $imin = $self->var('imin')->{$g} || 0;
		my $imax = $self->var('imax')->{$g} || ($graph->size() - 1);
		for (my $i = $imin; $i <= $imax; ++$i) {
			my $nodeobj = $graph->node($i);
			my $r = $self->abs2rel($g, $i);
			if ($nodeobj && ! $nodeobj->comment()) {
				# Add node to graph
				$nodes->{"$g$i"} = $node++;
				my $label = $self->var("compounds")->{$g . $i} 
					|| $nodeobj->var("compound") 
					|| $nodeobj->var("romanized") 
					|| $nodeobj->input() || "";
				my $format = "";
				my $nedges = $node_edges->{"$g$i"};
				$format = " 3" if (! ( defined($nedges) && @$nedges));
				$format = " 4" if (! $self->node_in_autowindow($g, $i));
				$label = $left ? "$g$r    $label" : "$label    $g$r";
				$ps .= psstr($label) . "$format node\n";
			}
		}

		# Count number of nodes in column
		$setup .= ($node-$onode) . " ";
		$left = 1;
	}

	# Make setup
	my $title = $self->var('title') || "";
	$ps = "% Setup graph\n[$setup] setup\n" 
		. "/title {($title) 6} def\n\n"
		. "/formats [{1 0 0 setrgbcolor}\n"
		. "\t{0 0 1 setrgbcolor}\n"
		. "\t{1 0 0 setrgbcolor 1 setfontstyle setupfont}\n"
		. "\t{0.8 setgray}\n"
		. "\t{1 0.5 0.5 setrgbcolor}\n"
		. "\t{1 setfontstyle setupfont}\n"
		. "] def\n\n"
		. $ps . "\n% Edges\n";

	# Draw alignment edges
	foreach my $edge (@{$self->{'edges'}}) {
		my $type = $edge->type();
		my $inps = enodes($nodes, $edge->inArray(), $edge->inkey());
		my $outps = enodes($nodes, $edge->outArray(), $edge->outkey());
		my $creator = $edge->creator();
		my $format = "";
		$format = " 1" if ($creator == -100);
		$format = " 2" if ($creator >= 0);
		$format = " 5" if ($creator <= -101);
		$format = " 4" if (! $self->edge_in_autowindow($edge));
		$format = $edge->format() if (defined($edge->format()));

		if (defined($inps) && defined($outps)) {
			$ps .=  "$inps $outps" . psstr($type || "") . "$format edge\n";
		} else {
			# Ignore edge silently
			# DTAG::Interpreter::warning("illegal edge " .  $edge->string());
		}
	} 

	# Return entire PostScript file
	return $psheader->{'align'}
		. $ps . "\n" . $pstrailer->{'align'};
}

sub enodes {
	my $nodes = shift;
	my $enodes = shift;
	my $key = shift;
	my $s = "";

	# Compute PostScript representation of $enodes
	my $ok = 1;
	my $ps = join(" ", 
		map {
			my $node = $nodes->{"$key$_"}; 
			return undef if (! defined($node));
			$node;
		} @$enodes);

	# Return list or integer, as appropriate
	return scalar(@$enodes) == 1 ? $ps : "[$ps]";
} 

sub psstr {
	my $input = shift;
	$input = "" if (! defined($input));
	$input =~ s/\)/\\\)/;
	$input =~ s/\(/\\\(/;
	$input =~ s/\&gt;/>/;
	$input =~ s/\&lt;/</;

	return "(" . $input . ")";
}

