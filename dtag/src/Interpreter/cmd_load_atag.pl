sub cmd_load_atag {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Disable viewer and close current graph, if unmodified
	my $noview = $self->var("noview");
	$self->var("noview", 1);
	my $viewer = $self->{'viewer'};
	$self->cmd_load_closegraph($graph) if ($graph);

	# Create new graph 
	my $alignment = DTAG::Alignment->new($self);
	$alignment->file($file);
	my $lastgraph = $graph;

	# Read ATAG file line by line
	open("ATAG", "< $file") 
		|| return error("cannot open atag-file for reading: $file");
	$self->{'viewer'} = 0;
	my $lineno = 0;
	my @graphs = ($alignment);
    while (my $line = <ATAG>) {
        chomp($line);

		# Process file
		if ($line =~ 
				/^<alignFile key="([a-z])" href="([^"]*)".*\/>$/) {
			# <alignFile> tag
			my $key = $1;
			my $afile = $2;

			# Translate relative path name into absolute
			my $basedir = dirname($file);
			if ($afile =~ /^\./) {
				$afile = "$basedir/$afile";
			}

			# Load aligned file and fail if loading failed
			$self->cmd_load($lastgraph, "", $afile);
			$graph = $self->graph();
			if ($graph == $lastgraph) {
				error("failed to load file $afile in alignment file $file");
				$self->{'viewer'} = $viewer;
				close("ATAG");
				return 1;
			}

			# Add graph to alignment
			$alignment->add_graph($key, $graph);
			$graph->var("imin", 0);
			$graph->var("imax", $graph->size());
			push @graphs, $graph;

			# Specify follow psfile
			$graph->fpsfile($self->fpsfile($key))
				if ($self->fpsfile($key));
		} elsif ( $line =~
				/^<align out="([^"]+)" type="([^"]*)" in="([^"]+)" creator="([0-9-]+)".*\/>$/ 
			|| $line =~
				/^<align out="([^"]+)" type="([^"]*)" in="([^"]+)".*\/>$/ ) {
			# Create alignment edge
			my $out = $1;
			my $type = $2;
			my $in = $3;
			my $creator = $4;

			# Replace spaces with "+"
			$out =~ s/ /+/g;
			$in =~ s/ /+/g;

			# Create edge
			$self->cmd_align($alignment, $out, $type, $in, $creator, 0, $lineno);
		} elsif ($line =~ /^<compound node=\"([^"]+)">(.*)<\/compound>$/) {
			$alignment->{'compounds'}{$1} = $2;
		} elsif ($line =~ /<\/?DTAGalign>/) {
			# Do nothing
		} else {
			print "ignored: $line\n" if (! $self->quiet());
		}
		$lineno++;
	}

	# Close ATAG file
	close("ATAG");

	# Push alignment on top of graph stack
	$self->{'viewer'} = $viewer;
	push @{$self->{'graphs'}}, $alignment;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# View alignments
	$self->var("noview", $noview);
	foreach my $g (@graphs) {
		$self->cmd_return($g);
	}
	return $alignment;
}



