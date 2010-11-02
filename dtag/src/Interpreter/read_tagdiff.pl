sub read_tagdiff {
	my $self = shift;
	my $graph = shift;
	my $diff = shift;
	my $output = [];

	sub savecmd {
		my $l = shift;
		my $c = shift;
		my $x = shift;
		my $y = shift;
		if ($c) {
			push @$l, [$c, $x, $y];
		}
	}

	sub readrange {
        my $range = shift;
        if ($range =~ /^([0-9]+)$/) {
            return ($1 - 1, $1);
        } elsif ($range =~ /^([0-9]+),([0-9]+)$/) {
            return ($1 - 1, $2);
        }
    }

	sub diffnode {
		my $s = shift;
		my $g = shift;
		my $tagline = shift;
		my $node = Node->new();
		if ($tagline =~ /^\s*<W(.*)>(.*)<\/W>\s*$/) {
			my $input = $2;
			my $varstr = $1;
			$node->input($input);
			$node->in([]);
			$node->out([]);
			my $vars = $s->varparse($g, $varstr, 0);
			foreach my $var (keys(%$vars)) {
				$node->var($var, $vars->{$var});
			}
		} else {
			print "ERROR: Cannot parse node specification:\n";
			print $tagline, "\n";
		}
		return $node;
	}

	# Read diff lines
	open(DIFF, "<$diff"); 
	my ($cmd, $a, $b);
	while (my $line = <DIFF>) {
		chomp($line);

		if ($line =~ /^[0-9]/) {
			# Command line: save old command
			savecmd($output, $cmd, $a, $b);

			# Initialize new command
			$a = [];
			$b = [];
			if ($line =~ /^([0-9]+)a([0-9,]+)$/) {
				$cmd = ["a", $1 - 1, $1 - 1, readrange($2)];	
			} elsif ($line =~ /^([0-9,]+)c([0-9,]+)$/) {
				$cmd = ["c", readrange($1), readrange($2)];
			} elsif ($line =~ /^([0-9,]+)d([0-9]+)$/) {
				$cmd = ["d", readrange($1), $2 - 1, $2 - 1];
			}
		} elsif ($line =~ /^< (.*)$/) {
			# Left line
			push @$a, diffnode($self, $graph, $1);
		} elsif ($line =~ /^> (.*)$/) {
			# Right line
			push @$b, diffnode($self, $graph, $1);
		} elsif ($line =~ /^---$/) {
		} else {
			print "ERROR: Unknown diff line:\n";
			print $line, "\n";
		}
	}
	savecmd($output, $cmd, $a, $b);
	close(DIFF);
	return $output;
}
