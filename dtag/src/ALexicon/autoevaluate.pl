sub autoevaluate {
	my $self = shift;
	my $alignment = shift;
	my $copy = shift;

	# Parameters
	my $outkey = "a";
	my $inkey = "b";
	my $outgraph = $alignment->graph($outkey);
	my $ingraph = $alignment->graph($inkey);
	my $accepted = {};
	my $recalled = {};
	my $covered = {};

	# Create empty copy of alignment
	if (! defined($copy)) {
		$copy = DTAG::Alignment->new();
		$copy->var('graphs', $alignment->graphs());
	}
	$copy->var('alexicon', $self);
	print $copy->write_atag();

	# Order all edges in graph in components
	my $components = {};
	my ($min, $max) = ({}, {});
	foreach my $edge (@{$alignment->edges()}) {
		if (! exists $components->{$edge}) {
			# Find component for edge and add it to hash
			my $component = $alignment->component($edge);

			$min->{$component} = {};
			$max->{$component} = {};
			foreach my $e (@$component) {
				$components->{$e} = $component 
					if (! exists $components->{$e});

				# Find min-max for outkey
				$min->{$component}{$e->outkey()} 
					= min(@{$e->outArray()},
						$min->{$component}{$e->outkey()});
				$max->{$component}{$e->outkey()} 
					= max(@{$e->outArray()},
						$max->{$component}{$e->outkey()});

				# Find min-max for inkey
				$min->{$component}{$e->inkey()} 
					= min(@{$e->inArray()},
						$min->{$component}{$e->inkey()});
				$max->{$component}{$e->inkey()} 
					= max(@{$e->inArray()},
						$max->{$component}{$e->inkey()});
			}
		}
	}

	# Assign min to deletion edges
	foreach my $edge (@{$alignment->edges()}) {
		if ($edge->outkey() eq $edge->inkey()) {
			my $component = $components->{$edge};
			if ($edge->outkey() eq $outkey) {
				# Find min{in} for out-out edge
				$min->{$component}{$inkey} = 1e30;
				for (my $o = min(@{$edge->outArray()}) ; $o >= 0; --$o) {
					my $oedges = $alignment->node($outkey, $o);
					if (@$oedges) {
						$min->{$component}{$inkey} =
							min($min->{$component}{$inkey},
								map {
									($_->inkey() eq $inkey)
										? @{$_->inArray()} : 1e30}
								@$oedges);
						last() if ($min->{$component}{$inkey} < 1e30);
					}
				}
				$min->{$component}{$inkey} = 0
					if ($min->{$component}{$inkey} == 1e30);
			} elsif ($edge->inkey() eq $inkey) {
				# Find min{out} for in-in edge
				$min->{$component}{$outkey} = 1e30;
				for (my $i = min(@{$edge->inArray()}) ; $i >= 0; --$i) {
					my $iedges = $alignment->node($inkey, $i);
					if (@$iedges) {
						$min->{$component}{$outkey} =
							min($min->{$component}{$outkey},
								map {
									($_->outkey() eq $outkey)
										? @{$_->outArray()} : 1e30}
								@$iedges);
						last() if ($min->{$component}{$outkey} < 1e30);
					}
				}
				$min->{$component}{$outkey} = 0
					if ($min->{$component}{$outkey} == 1e30);
			} else {
				# A weird edge that is neither inkey nor outkey
				$min->{$component}{$outkey} = 0;
				$min->{$component}{$inkey} = 0;
			}
		}
	}
	# Sort components
	my $C = {};
	map {$C->{$_} = $_} values(%$components);
	my $sorted_components = [
		sort {
			($min->{$a}{$outkey} <=> $min->{$b}{$outkey}) 
				|| ($min->{$a}{$inkey} <=> $min->{$b}{$inkey})
		} values(%$C)
	];

	# Process components and edges in order
	foreach my $component (@$sorted_components) {
		foreach my $edge (@$component) {
			# print $edge->string() . "\n";

			# Auto-offset and autoalign copy
			$copy->auto_offset();
			$self->autoalign($copy);

			# Look for edge in copy
			my $match;
			foreach my $e (@{$copy->node($edge->outkey(), 
					$edge->outArray()->[0])}) {
				# Change " ! " label to ""
				$e->type("") if ($e->type() eq " ! ");
				if ($e->string() eq $edge->string()) {
					# Print 
					print "ok: " . $e->string() . "\n";

					# Set match and change creator
					$match = $e;
					$e->creator(-1);

					# Set recalled and accepted hashes
					map {$recalled->{$e->outkey() . $_} = 1;
						$accepted->{$e->outkey() . $_} = 1;
						$covered->{$e->outkey() . $_} = 1} 
						@{$e->outArray()};
					map {$recalled->{$e->inkey() . $_} = 1;
						$accepted->{$e->inkey() . $_} = 1;
						$covered->{$e->inkey() . $_} = 1} 
						@{$e->inArray()};

					# Skip all other edges
					last();
				}
			}

			# Add edge manually if it wasn't created automatically
			if (! $match) {
				# Print 
				print "add: " . $edge->string() . "\n";

				# Set recalled hashes
				map {$covered->{$edge->outkey() . $_} = 1;
					$recalled->{$edge->outkey() . $_} = 1
						if (@{$copy->node($edge->outkey(), $_)})} 
					@{$edge->outArray()};
				map {$covered->{$edge->inkey() . $_} = 1;
					$recalled->{$edge->inkey() . $_} = 1
						if (@{$copy->node($edge->inkey(), $_)})} 
					@{$edge->inArray()};

				# Store edge
				$copy->add_edge($edge);
				$self->train_edge($copy, $edge);
			}
		}
	}

	# Print precision and recall
	my $ncovered = scalar(keys(%$covered));
	my $nrecalled = scalar(keys(%$recalled));
	my $naccepted = scalar(keys(%$accepted));

	print "nodes=$ncovered analyzed=$nrecalled correct=$naccepted\n";
	printf "recall=%.1f%% precision=%.1f%% F-score=%.1f%%\n", 
		(100 * $naccepted / $ncovered),
		(100 * $naccepted / $nrecalled),
		(200 * $naccepted / 
			($nrecalled + $ncovered));

	# Reset autoaligner
	$copy->var('autoalign', 0);
	$copy->var('offsets', {});
	$copy->var('imax', {});
	$copy->var('imin', {});

	# Return copy
	return $copy;
}
