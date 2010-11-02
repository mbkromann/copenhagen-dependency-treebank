sub cmd_errordef {
	my ($self, $graph, $type, $error, $sub) = @_;

	# Determine error type: -node or -edge
	$type = (($type || "") eq "-edge") ? "edge" : "node";

	# Ensure error definitions exist in both graph and interpreter
	my $gerrordefs = $graph->errordefs();
	my $ierrordefs = $self->{'errordefs'};

	# Create subroutine object
	my $substr = $type eq "node"
		? "sub { my \$I = shift; my \$G = shift; my \$n = shift; "
			. " my \$egov = \$G->govedge(\$n); "
			. " my \$gov = \$G->node(\$egov ? \$egov->out() : undef); "
			. $sub . " }"
		: "sub { my \$I = shift; my \$G = shift; my \$e = shift; "
			. " my \$etype = \$e->type(); "
			. " my \$eout = \$G->node(\$e->out()); "
			. " my \$ein = \$G->node(\$e->in()); "
			. $sub . " }";
	my $subobj = eval($substr);
	error("Perl errors in $type-errordef \"$error\": $sub\n$@") if ($@);

	# Clear from error definitions if subroutine empty
	if ($sub =~ /^\s*$/ || ! $subobj) {
		print "Deleting $type-error definition \"$error\"\n";
		delete $ierrordefs->{$type}{$error};
		delete $gerrordefs->{$type}{$error};
	} else {
		# Save subroutine object in error list
		my $errorlevel = $self->{'errordefid'}++;
		$ierrordefs->{$type}{$error} = [$errorlevel, $subobj, $sub];
		$gerrordefs->{$type}{$error} = [$errorlevel, $subobj, $sub];
	}

	# Sort subroutines
	$ierrordefs->{'@' . $type} = sort_errordefs($ierrordefs->{$type});
	$gerrordefs->{'@' . $type} = sort_errordefs($gerrordefs->{$type});

	# Return
	return 1;
}

sub sort_errordefs {
	# Sort numerically according to increasing error level, then alphabetically
	my $hash = shift;
	return [sort {
			($hash->{$a}[0] <=> $hash->{$b}[0])
			|| $a cmp $b
		} (keys(%$hash))];
}
