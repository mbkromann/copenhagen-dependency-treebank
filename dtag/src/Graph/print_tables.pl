sub print_tables {
	my $self = shift;
	my $nodecount = shift || 0;
	my $nodeattributes = shift || [];
	my $edgeattributes = shift || [];
	my $globalvars = shift || {};
	my $nodes2id = shift || {};
	my $prefix = shift || "";

	# Add node variables to node attribute list
	add_attributes($nodeattributes, "id", "line", "sentence", "token", sort(keys(%{$self->vars()})));

	# Add file name
	$globalvars->{'node:file'} = $self->file()
		if ($self->file());

	# Write nodes line by line
	my $sent = 0;
	my $nodes = "";
	for (my $n = 0; $n < $self->size(); ++$n) {
		my $N = $self->node($n);
		if (! $N->comment()) {
			# Compute node ids and attributes
			$nodes2id->{$prefix . $n} = $prefix . $nodecount++;
			my $input = $N->input();
			$globalvars->{'node:id'} = $nodes2id->{$prefix . $n};
			$globalvars->{'node:line'} = $n;
			$globalvars->{'node:sentence'} = $sent;
			$globalvars->{'node:token'} = $input;

			# Create node table row
			$nodes .= create_R_table_row($nodeattributes, $N, $globalvars, 'node:');
		} elsif ($N->input() =~ /^\s*<[sS]>\s*$/) {
			++$sent;
		}
	}

	# Add edge variables to edge attribute list
	add_attributes($edgeattributes, "in", "out", "label", "primary");

	# Write edges line by line
	my $edges = "";
	for (my $i = 0; $i < $self->size(); ++$i) {
		my $N = $self->node($i);
		if (! $N->comment()) {
			# Process in-edges at node
			foreach my $e (@{$N->in()}) {
				# Find attributes
				$globalvars->{'edge:in'} = $nodes2id->{$prefix . $e->in()};
				$globalvars->{'edge:out'} = $nodes2id->{$prefix . $e->out()};
				$globalvars->{'edge:label'} = $e->type();
				$globalvars->{'edge:primary'} = $self->is_dependent($e) ? "TRUE" : "FALSE";
				
				# Create edge table row
				$edges .= create_R_table_row($edgeattributes, $e, $globalvars, 'edge:')
					if (defined($globalvars->{'edge:in'}) && defined($globalvars->{'edge:out'})); 
			}
		}
	}

	# Return
	return ($nodes, $edges, $nodecount, $nodeattributes, $edgeattributes);
}

sub quote_R {
	my $s = shift;

	# Do not quote numbers of booleans
	return $s
		if ($s =~ /^-?[0-9]+[.,]?[0-9]*$/);
	return "T" if ($s eq "TRUE");
	return "F" if ($s eq "FALSE");

	# Rewrite strings
	$s =~ s/&quot;/"/g;
	$s =~ s/	/\\0x0b/g;
	$s =~ s/"/""/g;
	return "\"" . $s . "\"";
}

sub add_attributes {
	my $attrs = shift;
	foreach my $attr (@_) {
		push @$attrs, $attr
			if (! grep {$_ eq $attr} @$attrs);
	}
}


sub create_R_table_row {
	my ($attributes, $vars, $globalvars, $type) = @_;
	my $row = "";

	# Create table row
	my $sep = "";
	foreach my $attr (@$attributes) {
		my $value = $globalvars->{$type . $attr};
		$value = $vars->var($attr) if (! defined($value) && 
			(! exists $globalvars->{$type . $attr}) &&
			defined($vars));
		$row .= defined($value) 
			? $sep . quote_R($value)
			: $sep . "NA";
		$sep = "\t";
	}
	$row .= "\n";
	return $row;
}
