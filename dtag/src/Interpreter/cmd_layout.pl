sub cmd_layout {
	my $self = shift;
	my $graph = shift;
	my $opt = shift;

	# Remove -edge or -node specification
	my $lparent = $self;
	$lparent = $graph if ($graph && $opt =~ s/^-graph\s*//);
	$lparent->{'layout'} = {} if ($opt =~ s/^-clear\s*//);

	# Perform layout action
	if ($opt =~ /^-vars\s+(\S+)\s*$/) {
		# vars: -vars $list
		$lparent->{'layout'}{'vars'} = $1;
	} elsif ($opt =~ /^-var\s+(\S+)\s+sub\s+(.*)$/) {
		# var: -var $var sub $code
		$lparent->{'layout'}{'var'}{$1} = eval("sub $2");
	} elsif ($opt =~ /^-var\s+(\S+)\s+(.*)$/) {
		# var: -var $var $regexp
		$lparent->{'layout'}{'var'}{$1} 
			= eval("sub {my \$v = shift(); \$v = \"\" if (!  defined(\$v)); \$v =~ $2; \$v}");
	} elsif ($opt =~ /^-stream\s+(.*)$/) {
		# stream: -stream $code
		$lparent->{'layout'}{'stream'} 
			= eval("sub { my \$G = shift; my \$n = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-nstyles\s+(.*)$/) {
		# node styles: -nstyles $code
		$lparent->{'layout'}{'nstyles'} 
			= eval("sub { my \$G = shift; my \$n = shift; my \$l= shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-pos\s+(.*)$/) {
		# edge position: -pos $code
		$lparent->{'layout'}{'pos'} 
			= eval("sub { my \$G = shift; my \$e = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-estyles\s+(.*)$/) {
		# edge styles: -estyles $code
		$lparent->{'layout'}{'estyles'} 
			= eval("sub { my \$G = shift; my \$e = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-nhide\s+(.*)$/) {
		# hide: -nhide $code
		$lparent->{'layout'}{'nhide'}
			= eval("sub { my \$G = shift; my \$n = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-ehide\s+(.*)$/) {
		$lparent->{'layout'}{'ehide'}
			= eval("sub { my \$G = shift; my \$e = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-pssetup\s+"(.*)"\s*$/) {
		$lparent->{'layout'}{'pssetup'} = $1;
	} else {
		return 0;
	}

	# Return
	return 1;
}
