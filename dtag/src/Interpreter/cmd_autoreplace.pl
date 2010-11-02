sub cmd_autoreplace {
	my $self = shift;
	my $graph = shift;
	my $corpus = shift || "";
	my @relations = split(/\s+/, shift);

	# Check arguments
	if (scalar(@relations) == 0) {
		error('Usage: autoreplace [-corpus] $relation1 $relation2 ...');
		return 1;
	}

	# Execute find query
	my $erel = "/^(" . join("|", @relations) . ')$/';
	$erel = $relations[0] if ($#relations == 0);
	my $query = "$corpus\$dep $erel \$gov";
	print "query=\"$query\"\n";
	$self->cmd_find($graph, $query);

	# Create edge type hash
	my $relhash = {};
	map {$relhash->{$_} = 1} @relations;

	# Process matches
	my $matches = $self->{'matches'};
	$self->{'replace_files'} = ['', sort(keys(%$matches))];
	$self->{'replace_matches'} = [''];
	$self->{'replace_hash'} = $relhash;
	$self->{'replace_times'} = [];
	$self->cmd_replace($graph);
}
