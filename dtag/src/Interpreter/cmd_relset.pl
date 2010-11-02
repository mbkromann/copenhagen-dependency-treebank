use utf8;

sub cmd_relset {
	my $self = shift;
	my $graph = shift;
	my $name = shift;
	my $file = shift;

	# Print current relset if no file is given
	if (! defined($name)) {
		print "Current relset: " . $self->var("relset") . "\n";
		return 1;
	} 

	if (! defined($file)) {
		if (! exists $self->var("relsets")->{$name}) {
			print "Unknown relset: $name\n";
			return 1;
		}
		print "Current relset: " . $self->var("relset", $name) . "\n";
		$graph->var("relset", $name);
		return 1;
	}

	# Open csv file (replacing ~ with home dir)
	print "Loading relation set \"$name\" from $file\n";
	if ($file =~ /^https?:\/\//) {
		my $cmd = "wget -q -O /tmp/dtag.wget2 '$file'";
		print $cmd . "\n" if ($debug_relset);
		system($cmd);
		system("iconv -f utf8 -t utf8//TRANSLIT /tmp/dtag.wget2 > /tmp/dtag.wget");
		$file = "/tmp/dtag.wget";
	} else {
		$file =~ s/^~/$ENV{HOME}/g;
	}
	open("CSV", "<:encoding(utf8)", $file)
		|| return error("cannot open csv-file for reading: $file $!");
	#CORE::binmode("CSV", $self->binmode()) if ($self->binmode());
	
	# Create relations object
	my $relations = {"_name_" => $name, "_file_" => $file};
	
	# Read relations Text::CSV_XS;
	#require Text::CSV;
	require Text::CSV_XS;
	my $csv = Text::CSV_XS->new ({ 'binary' => 1 })
		or error("Cannot use CSV: " . Text::CSV_XS->error_diag());
	my $classes = [];

	# Skip first line
	$csv->getline("CSV");
	my $lineno = 1;
	my $errorclasses = {};
	while (my $row = $csv->getline("CSV")) {
		# Read line from relations CSV file
		++$lineno;

		$row = [map {decode_utf8($_)} @$row];

		# Read fields
		for (my $i = 0; $i < 15; ++$i) {
            $row->[$i] = "" if (! defined($row->[$i]));
        }
		my ($comment, $shortname, $longname, $deprecatednames, 
			$supertypes, $shortdescription, $longdescription, $seealso, 
			$examples, $connectives) = @$row;
		$longname = $shortname if ((! defined($longname)) || $longname =~ /^\s*$/);

		# Skip line if short name or long name are undefined
		next if (! (defined($shortname) && defined($longname)));

		# Create relation object
		my $relation = [$shortname, $longname, 
			undef, {}, {},
			$shortdescription, $longdescription, $examples,
			$deprecatednames, $supertypes, $lineno, 0, 0, $seealso,
			$connectives];
		
		# Add relation to relations table under its different names
		$errorclasses->{"\"" . $shortname . "\" (line " . $lineno . ")"} = 1
			if ($shortname ne "" && exists $relations->{$shortname});
		$errorclasses->{"\"" . $longname . "\" (line " . $lineno . ")"} = 1
			if ($longname ne "" && exists $relations->{$longname});
		push @$classes, $shortname, $longname;
		$relations->{$shortname} = $relation;
		$relations->{$longname} = $relation;
		map {
			$relations->{$_} = $relation
		 		if (! exists $relations->{$_});
			push @$classes, $_
		} split(/\s+/, $deprecatednames);
		if ($lineno < 10 && $debug_relset) {
			print $debug_relset "csv-relations: "
				. $relations->{$shortname}[7] . "\n";
		}
	}
	close(CSV);

	# Compile relation hierarchy
	foreach my $relation (@$classes) {
		add_relation_nodes($relations, $relation);
	}

	# Save relations
	$self->var("relsets")->{$name} = $relations;
	$self->var("relset", $name);
	$graph->var("relset", $name);

	# Print multiply defined classes
	print join("", map {"ERROR: class $_ already defined\n"}
		sort(keys(%$errorclasses)));

	# Return
	return 1;
}

# Return short name for relation
sub add_relation_nodes {
	my $relations = shift;
	my $relation = shift;
	my $nesting = shift || 0;

	# Do nothing if relation does not exist
	return undef if (! exists $relations->{$relation});

	# Find short name for type
	my $rellist = $relations->{$relation};
	
	# Return short name if parent types already defined
	my $name = $rellist->[$REL_SNAME];
	return $name if (defined($rellist->[$REL_IPARENTS]));

	# Find short names for immediate parents, making sure that they
	# have been added as relations first
	my $iparents = $rellist->[$REL_IPARENTS] = {};
	foreach my $parent (split(/\s+/, $rellist->[$REL_STYPES] || "")) {
		# Make sure that parent exists
		my $pshort = add_relation_nodes($relations, $parent, $nesting + 1);
		next if (! (defined($pshort) && $pshort ne ""));

		# Add parent to relation's iparents
		$rellist->[$REL_IPARENTS]{$pshort} = 1;

		# Add relation to parent's child relations
		my $plist = $relations->{$pshort};
		$plist->[$REL_ICHILDREN]->{$name} = 1;

		# Increment count for parent
		$relations->{$pshort}[$REL_CHILDCNT]++;

		# Add all parent's tparents to this relations' tparents
		my $tparents = $rellist->[$REL_TPARENTS];
		map {	$tparents->{$_} = 1; 
				$relations->{$_}[$REL_TCHILDCNT]++;
			} ($pshort, keys(%{$plist->[$REL_TPARENTS]}));
	}

	# Return short name
	return $name;
}

