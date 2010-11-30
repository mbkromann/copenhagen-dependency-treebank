sub cmd_relhelp {
	my $self = shift;
	my $graph = shift;
	my $name = shift;
	my $printex = shift;

	# Find relation name
	my $relsetname = $graph->var("relset") || $self->var("relset");
	my $relset = $self->var("relsets")->{$relsetname} || undef;
	if (! defined($relset)) {
		error("Current graph has no associated relation set"
			. " (see relset command)");
		return 1;
	} 

	# Retrieve relation from relset
	my $relation = $relset->{$name};
	if (! defined($relation)) {
		error("Relation $name undefined in current relset!");
		return 0;
	}

	my ($sname, $lname, $iparents, $tparents,
			$ichildren, $sdescr, $ldescr, $ex, $deprecated,
			$lineno, $see, $connectives) 
		= map {$relation->[$_]} 
			($REL_SNAME, $REL_LNAME, $REL_IPARENTS, $REL_TPARENTS,
			$REL_ICHILDREN, $REL_SDESCR, $REL_LDESCR, $REL_EX,
			$REL_DEPRECATED, $REL_LINENO, $REL_SEE, $REL_CONN);
	
	# Print help information for relation
	print "\n$sname = $sdescr"
		. ($sname ne $lname ? " (long name: $lname)" : "") 
		. " [row $lineno]\n";
	print "\nDEFINITION: $ldescr\n" if (defined($ldescr));
	print "\nTYPICAL CONNECTIVES: $connectives\n" if ($connectives);
	if ($name ne $sname && $name ne $lname) {
		print "\nTHE RELATION $name IS DEPRECATED!\n";
	}

	print "\nSUPER TYPES:\n" .
		join("", map {countname($relset, $_)}
			sort(keys(%$iparents))) . "\n" if (defined($iparents) &&
			%$iparents);
	print "SUBTYPES:\n" .
		join("", map {countname($relset, $_)} 
			sort(keys(%$ichildren))) . "\n" if (defined($ichildren) &&
			%$ichildren);
	my $seealso = [split(/\s+/, $see || "")];
	print "SEE ALSO:\n" .
		join("", map {countname($relset, $_)} 
			@$seealso) . "\n" if (@$seealso);
	my $confusion = [@{$self->{'confusion'}{$relsetname}{$sname} || [0,0,0,0]}];
	my $confcount = shift(@$confusion);
	my $agreement = join("/", shift(@$confusion), shift(@$confusion),
		shift(@$confusion));
	print "CONFUSION ($confcount nodes, $agreement full/unlabeled/label agreement):\n    "
		. join(" ", @$confusion) . "\n";

	# Examples
	if (defined($ex)) {
		$ex = encode_utf8(decode_utf8($ex));
		# Print examples on screen
		print "\nEXAMPLES:\n" if ($printex);

		# Create example graph
		my $exlist = ["$ex"];
		$ex =~ s/([^\n])\n([^\n])/$1 $2/g;
		my @examples = split("\n+", $ex);
		print "\t" . join("\n\n\t", @examples) . "\n\n" if ($printex);
		push @$exlist, @examples;
		$self->cmd_example($graph, shift(@examples), 1);
		my $egraph = $self->graph();
		$egraph->var("example", $exlist);
		foreach my $example (@examples) {
			$self->cmd_example($egraph, "-add " . $example, 1);
		}

		# Create viewer for example graph if non-existent
		$egraph->mtime("");
		my $exfpsfile = $self->var("exfpsfile");
		if (! $exfpsfile) {
			# Creating new example viewer
			$self->do("viewer -e");
		} elsif (! `ps e -w | grep $exfpsfile | grep -v grep`) {
			# Reopening closed example viewer
			$self->do("viewer");
		} else {
			# Reusing example viewer
			my $exfpsfile = $self->var("exfpsfile");
			$egraph->fpsfile($exfpsfile);
		}
		$self->cmd_return($egraph);

		# Close example graph
		$self->var("examplegraph", $egraph);
		if ($egraph->var("example")) {
#			$self->cmd_save($egraph, undef, "/tmp/example.$$.tag");
			$self->cmd_close($egraph);
		}
	}

	# Return
	return 1;
}

sub countname {
	my $relset = shift;
	my $name = shift;
	my $count = $relset->{$name}->[$REL_TCHILDCNT];
	my $descr = $relset->{$name}->[$REL_SDESCR];
	$count = 0 if (! defined($count));
	$descr = "" if (! defined($descr));
	return "    $name = $descr" . ($count == 0 ? "" : " ($count)") .  "\n";
}
