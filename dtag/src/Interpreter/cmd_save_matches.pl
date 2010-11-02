sub cmd_save_matches {
	my $self = shift;
	my $file = shift;

	# Open tag file
	open("MATCH", "> $file") 
		|| return error("cannot open match-file for writing: $file");

	# Find keys
	my $matches = $self->{'matches'};
	my $keyhash = {};
	my $varkeys = {};
	foreach my $file (keys(%$matches)) {
		foreach my $match (@{$matches->{$file}}) {
			map {$keyhash->{$_} = 1 if ($_ =~ /^\$/)} keys(%$match);
			map {
				if ($_ =~ /^\$/) {
					my $k = $match->{'vars'}{$_};
					$k = "" if (! defined($k));
					my $k0 = $varkeys->{$_};
					$k0 = $k if (! defined($k));
					warning("Key mismatch for key $_: $k vs. $k0")
						if ($k ne $k0);
					$varkeys->{$_} = $k;
				}
			} keys(%$match);
		}
	}
	my @keylist = sort(keys(%$keyhash));

	# Write MATCH file
	print MATCH "\"file\"\t\"" 
		. join("\"\t\"", map {
			my $k = $varkeys->{$_}; 
			$_ . ($k ne "" ? "@" . $k : "")} @keylist) . "\"\n";
	foreach my $file (sort(keys(%$matches))) {
		my $mgraph = $self->graph($self->gid2index($file));
		my $filename = ($mgraph && $mgraph->file()) ? 
			$mgraph->file() : $file;
		#print "mgraph=$mgraph filename=$filename\n";
		foreach my $match (@{$matches->{$file}}) {
			my $varkeys = $match->{'vars'} || {};
			print MATCH "\"$filename\"\t\""
				. join("\"\t\"",
					map {my $m = $match->{$_}; defined($m) ? $m : ""} @keylist) . "\"\n";
		}
	}

	# Close file
	close("MATCH");
	print "saved match-file $file\n" if (! $self->quiet());

	# Return
	return 1;
}
