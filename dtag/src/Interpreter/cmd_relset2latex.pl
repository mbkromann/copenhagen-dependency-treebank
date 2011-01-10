my $relset_example_id = 0;
my $relset_undef = "\\relax";
my $relset_indent = "\\mytab";
my $relset_cmdsummary = "";
my $relset_example_prefix = "";

sub cmd_relset2latex {
	my $self = shift;
	my $graph = shift;
	my $filename = shift;
	my $relations = shift || "ANY";

	# Find relset
	my $relset = $graph->relset();
	if (! defined($relset)) {
		error("No relset for the current graph!");
		return 1;
	}
		
	# Provide default filename if missing
	my $relsetname = $graph->relsetname();
	if (! $filename) {
		$filename = "$relsetname-relations.tex";
	}

	# Set example filename
	$relset_example_prefix = "$filename";
	$relset_example_prefix =~ s/\.tex$//g;

	# Open file 
	$relset_example_id = 0;
	$relset_cmdsummary = "";
	print "printing relset to $filename\n";
	open(my $ofh, ">:encoding(UTF-8)", $filename);
	
	# Print call to overview
	my $ofile = "$filename";
	$ofile =~ s/.tex$//g;
	$ofile .= "-overview.tex";
	print $ofh "\n\n\t\\overviewfile{$ofile}\n\n";

	# Open confusion table
	my $confusion = $self->{'confusion'}{$relsetname};

	# Visit nodes depth-first
	my $visited = {};	
	my $tovisit = [];
	foreach my $relspec (split(/\s+/, $relations)) {
		# Find nodes to visit
		if ($relspec =~ /^([^-]+)-?.*$/) {
			push @$tovisit, $1;
		} else {
			# Find all short names in the relset
			my $snames = {};
			map {$snames->{$_->[0]} = 1 if (ref($_) eq "ARRAY")} 
				values(%$relset); 
			$tovisit = [
				sort {scalar(keys(%{$relset->{$a}[3]}))
					<=> scalar(keys(%{$relset->{$b}[3]}))}
						keys(%$snames)];
		}

		# Compile $relspec
		my $type = $self->query_parser()->Type(\$relspec);
		if (! $type) { 
			error("Cannot parse type specification $relspec"); 
			return 1;
		}
		
		# Iterate over all relations
		foreach my $relation (@$tovisit) {
			$self->relset2latex_visit($graph, $ofh, $relset, $confusion, $relation, $type, $visited, "");
		}
	}

	# Close file
	close($ofh);

	# Print overview
	open(my $ovfh, ">:encoding(UTF-8)", $ofile);
	print $ovfh "\\begin{overview}{$relations}\n\n$relset_cmdsummary\\end{overview}\n";
	close($ovfh);
}

sub relset2latex_visit {
	my $self = shift;
	my $graph = shift;
	my $ofh = shift;
	my $relset = shift;
	my $confusion = shift;
	my $relname = shift;
	my $type = shift;
	my $visited = shift;
	my $indent = shift;

	# Do not revisit already visited relations
	return if ($visited->{$relname});
	$visited->{$relname} = 1;

	# Do not visit relations with blank names
	return if ($relname =~ /^\s*$/);

	# Only process relations that match $type
	return if (! $type->match($graph, $relname, $relset));
	#print $relname . "\n";

	# Retrieve relation data
	my $relation = $relset->{$relname};
	return if (! $relation);
	my ($sname, $lname, $iparents, $tparents, $ichildren, $sdescr, 
		$ldescr, $ex, $deprecated, $lineno, $see, $connectives) 
			= map {$relation->[$_]} ($REL_SNAME, $REL_LNAME,
				$REL_IPARENTS, $REL_TPARENTS, $REL_ICHILDREN, $REL_SDESCR,
				$REL_LDESCR, $REL_EX, $REL_DEPRECATED, $REL_LINENO, $REL_SEE,
				$REL_CONN);
																			   
	# Print examples
	my @examples = ();
	foreach my $example (split(/\n+/, $ex)) {
		my $exfile = $relset_example_prefix 
			. sprintf("-%04d", ++$relset_example_id);
		open(EXAMPLE, ">:encoding(UTF-8)", "$exfile.dtag");
		print EXAMPLE "example -nopos $example\n";
		close(EXAMPLE);
		push @examples, "$exfile.pdf";
	}

	# Print relation
	print $ofh "\\begin{relation}\n";
	print $ofh "	\\relname{" . texreldef($sname, $relset) . "}{";
	print $ofh "\\isa{" . join(" ", map {texrelref($_, $relset)}
			sorted_relations($relset, keys(%$iparents))) . "}"
		if (%$iparents);
	print $ofh "}{\\lineno{$lineno}}%\n";
	my @sdescrx = ();
	push @sdescrx, "\\xlong{" . texrel($lname) . "}"
		if ($lname ne "" && $lname ne $sname);
	push @sdescrx, "\\deprecated{" . texrel($deprecated) . "}"
		if ($deprecated ne "");
	my $texsdescr = tex(ucfirst($sdescr));
	if (@sdescrx) {
		print $ofh "	\\sdescrx{$texsdescr}{" 
			. join(", ", @sdescrx) . "}%\n";
	} else {
		print $ofh "	\\sdescr{$texsdescr}%\n";
	}
	print $ofh "	\\begin{ldescription}\n\t\t"
		. tex(ucfirst($ldescr)) . "\n\\end{ldescription}\n" if ($ldescr);
	print $ofh "	\\connectives{$connectives}%\n"
		if ($connectives);
	print $ofh "	\\tparents{" .  join(" ", map {texrelref($_, $relset) 
			. "%\n"} 
		sorted_relations($relset, grep {! $iparents->{$_}} keys(%$tparents)))
			. "}\n" if (%$tparents);
	print $ofh "	\\subtypes{" . join(" ", map {texrelref($_, $relset)} 
			sorted_relations($relset, keys(%$ichildren))) . "}%\n" 
		if (%$ichildren);
	print $ofh "	\\related{" . join(" ", map {texrelref($_, $relset)} 
		sorted_relations($relset, split(/\s+/, $see))) . "}%\n" if ($see);
	my $confuse = [@{$confusion->{$sname} || []}];
	if (@$confuse) {
		print $ofh "	\\confusions{" . shift(@$confuse) . "}{";
		foreach my $c (@$confuse) {
			$c =~ /^([0-9]+)\%=(.*)$/;
			print $ofh "\\confuse{$1}{" . texrelref($2, $relset) . "}" 
				if (defined($1) && defined($2));
		}
		print $ofh "}\n";
	}
	$relset_cmdsummary .= "	\\cmdsummary{$indent}{" . texrelref($sname, $relset) . "}{"
		. tex($sdescr) . "}%\n";
	print $ofh "	\\begin{examples}\n"
		. join("", map {"\t\t\\exfig{$_}\n"} @examples)
		. "\t\\end{examples}\n" if (@examples);
	print $ofh "\\end{relation}\n\n";

	# Visit child relations in original order
	foreach my $subrel (sorted_relations($relset, keys(%$ichildren))) {
		$self->relset2latex_visit($graph, $ofh, $relset, $confusion, $subrel, $type, $visited,
		$indent . $relset_indent);
	}
}

sub texrel {
	my $rel = shift;
	$rel =~ s/\s+//g;
	my $texcmd = shift || "\\rel";
	return tex($rel) if ($rel eq "");
	return $texcmd . "{" . tex($rel) . "}";
}

sub texrelref {
	my $rel = shift;
	my $relset = shift;
	my $texcmd = shift || "\\relref";
	return tex($rel) if ($rel eq "" || $rel eq "\\relax");
	my $relation = $relset->{$rel};
	my $lineno = $relation ? $relation->[$REL_LINENO] : undef;
	return defined($lineno) 
		? texrel($rel, $texcmd ."{rel" . $lineno . "}") 
		: texrel($rel);
} 

sub texreldef {
	return texrelref(shift, shift, "\\reldef");
}

sub tex {
	my $s = shift;
	$s =~ s/\$/\\\$/g;
	$s =~ s/{/\\{/g;
	$s =~ s/}/\\}/g;
	$s =~ s/#/\\#/g;
	$s =~ s/&/\\&/g;
	$s =~ s/~/\\~/g;
	$s =~ s/%/\\%/g;
	$s =~ s/_/\\_/g;
	return (length($s) != 0) ? $s : $relset_undef;
}

sub sorted_relations {
	my $relset = shift;
	my @relations = @_;
	return sort(@relations);
	#return sort {relation_lineno($relset, $a) <=> relation_lineno($relset, $b)} 
	#	@relations;
}

sub relation_lineno {
	my $relset = shift;
	my $relname = shift;
	my $relation = $relset->{$relname};
	return 1e20 if (! $relation);
	return $relation->[$REL_LINENO];
}

