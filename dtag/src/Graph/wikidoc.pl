my $WIKIDOC_SUBDIRS = 500;

sub wikidoc {
	my $self = shift;
	my $tagvar = shift || 'msd';
	my $wikidir = shift || "treebank.dk/map";
	my $exdir = shift || $wikidir;
	my $termexcount = shift || 10;
	my $excount = shift || $termexcount;
	my $mincount = shift || 5;
	my $url = shift || "..";

	# Set parameters for wiki files
	my $mapdep = "MapDep";
	my $exfile = "$exdir/examples.lst";
	my $exprefix = "ex";

	# Initialize class index
	my $instancelist = [];
	my $counts = {};

	# Create directories
	for (my $i = 0; $i < $WIKIDOC_SUBDIRS; ++$i) {
		my $subdir = sprintf("%03i", $i);
		`mkdir -p $exdir/$subdir $wikidir/$subdir`;
	}

	# Index edges in graph
	my $words = 0;
	$self->do_edges(sub 
		{	# Read parameters
			my $e = shift; 
			my $G = shift;
			my $var = shift;

			# Find edge type, and length 1 and 2 tags
			my $type = $e->type();
			my $inode = $G->node($e->in());
			my $onode = $G->node($e->out());
			my $i1 = substr($inode->var($var) || "", 0, 1);
			my $i2 = substr($inode->var($var) || "", 0, 2);
			my $o1 = substr($onode->var($var) || "", 0, 1);
			my $o2 = substr($onode->var($var) || "", 0, 2);
			my $iw = $inode->input();
			my $ow = $onode->input();
			$iw = "" if ($i2 ne "U=");
			$ow = "" if ($o2 ne "U=");

			# Clean up edge type
			$type =~ s/^[:;,+]//g;
			$type =~ s/\/.*$//g;
			$type =~ s/[¹²³]//g;

			# Ignore edge if type or word classes are empty, if edge
			# type starts with "<" or "[", or if edge type is on
			# the excluded list
			my $t = substr($type, 0, 1);
			return if (! ($type && $i1 && $i2 && $o1 && $o2));
			return if (! $self->is_dependent($e));

			# Find kwic-entry, cframe and subgraph
			my $lang = $self->lang($e->in());

			# Create instance
			my $instance = [$i2, $iw, $type, $o2, $ow, $lang, $e];
			push @$instancelist, $instance;

			# Create list of super types
			my $class = $self->wikidoc_class($instance);
			my @super = @{$self->wikidoc_super_all($class)};

			# Count all classes and superclasses
			foreach my $c ($class, @super) {
				++$counts->{$c};
			}

			# Print type
			print $type . " ";
			print "\n"
				if ($words++ % 15 == 0);
		}, $self, $tagvar);

	# Find graph structure for all classes with at least $mincount instances
	my $superclasses = {};
	my $subclasses = {};
	my $instances = {};
	foreach my $class (sort(keys(%$counts))) {
		# Skip class if it has less than $mincount instances
		next() if ($counts->{$class} < $mincount);
		$instances->{$class} = [];

		# Index all direct superclasses
		$superclasses->{$class} = [] if (! exists $superclasses->{$class});
		foreach my $super (@{$self->wikidoc_super($class)}) {
			$subclasses->{$super} = [] if (! exists $subclasses->{$super});
			push @{$superclasses->{$class}}, $super;
			push @{$subclasses->{$super}}, $class;
		}
	}

	# Find instances for all classes with at least $mincount instances
	foreach my $instance (@$instancelist) {
		my $class = $self->wikidoc_class($instance);
		foreach my $super (@{$self->wikidoc_super_all($class)}) {
			if ($instances->{$super}) {
				push @{$instances->{$super}}, $instance;
			}
		}
	}

	# Find all terminal classes
	my $terminal = {};
	foreach my $class (keys(%$instances)) {
		$terminal->{$class} = 1 if (!$subclasses->{$class});
	}

	# Simplify the graph by merging a class with its subclasses
	# if they have the same number of instances; use subclass name as
	# new name
	sub merge {
		my ($class, $subclass, $superclasses, $subclasses, $instances, $terminal) = @_;

		# Replace all instances of $class with $subclass in super
		# classes of $class
		foreach my $super (@{$superclasses->{$class}}) {
			my $newsub = {};
			map {$newsub->{$_} = 1} @{$subclasses->{$super}};
			$newsub->{$subclass} = 1;
			delete $newsub->{$class};
			$subclasses->{$super} = [sort(keys(%$newsub))];
		}

		# Add superclasses of $class as super classes of $subclass,
		# and remove $class as super class
		my $newsuper = {};
		map {$newsuper->{$_} = 1} (@{$superclasses->{$class}}, 
			@{$superclasses->{$subclass}});
		delete $newsuper->{$class};
		delete $newsuper->{$subclass};
		$superclasses->{$subclass} = [sort(keys(%$newsuper))];
		delete $superclasses->{$class};

		# Add subclasses of $class as sub classes of $subclass,
		# and remove $subclass as subclass
		my $newsub = {};
		map {$newsub->{$_} = 1} (@{$subclasses->{$subclass}},
			@{$subclasses->{$class}});
		delete $newsub->{$subclass};
		delete $newsub->{$class};
		$subclasses->{$subclass} = [sort(keys(%$newsub))];
		delete $subclasses->{$class};

		# Delete $class from all tables
		delete $instances->{$class};
		delete $terminal->{$class};
	}
	my $moremerge = 0;
	my $mergecount = 0;
	while ($moremerge) {
		print "merge cycle #", ++$mergecount, "\n";
		$moremerge = 0;
		foreach my $super (keys(%$subclasses)) {
			foreach my $class (@{$subclasses->{$super}}) {
				if (exists $instances->{$class} 
						&& exists $instances->{$super} 
						&& scalar(@{$instances->{$class}}) 
							== scalar(@{$instances->{$super}})) {
					print "merge: $super $class "
						. ($terminal->{$class} && $terminal->{$super} 
							? " terminal" : "") . "\n"
						if ($super =~ /XP/ || $class =~ /XP/);
					merge($super, $class, $superclasses, $subclasses, 
						$instances, $terminal);
					$moremerge = 1;
				}
			}
		}
	}
	

	# Map procedure: identify dependent, then governor, then edge type
	# At each DepGovType node, we have the following choices:
	#     - refine Dep (show possible subdeps with frequencies)
	#     - refine Gov (show possible subgovs with frequencies)
	#     - refine Type (show possible subtypes with frequencies)
	#	  - refine language
	#     - show N random examples

	# Read examples from file
	my $examples = {}; 
	my $examples_hash = {};
	my $excounter = 0;
	if (-f $exfile) {
		# Read examples from file
		open(IFH, "<$exfile");
		my $line = <IFH>;
		chomp($line);
		$excounter = $line;
		while ($line = <IFH>) {
			# Read example line
			chomp($line);
			my $example = [split(/\t/, $line)];
			my ($class, $file, $source, $text) = @$example;
			print "old example: ", join("\t", @$example), "\n";

			# Record example
			$examples->{$class} = []
				if (! exists $examples->{$class});
			push @{$examples->{$class}}, $example;
			$examples_hash->{$class . ":" . $text} = $example;
		}
	}

	sub shuffle {
		srand;
    	my @new = ();
    	for(@_){
       		my $r = rand @new+1;
       		push(@new, $new[$r]);
        	$new[$r] = $_;
		}
		return @new;
    }

	# Generate examples randomly for terminal classes
	my $done = {};
	foreach my $tclass (keys(%$terminal)) {
		# Ensure that examples exist, and generate random list of examples
		$examples->{$tclass} = [] if (! exists $examples->{$tclass});
		my @shuffled = shuffle(@{$instances->{$tclass}});
		$done->{$tclass} = 1;

		# Generate desired number of examples
		my $n = $termexcount - scalar(@{$examples->{$tclass}});
		while ($n > 0 && @shuffled) {
			# Generate example from instance
			my $instance = shift(@shuffled);
			my $edge = $instance->[$#$instance];
			my $source = $self->source($edge->in());
			my $subgraph = $self->subgraph($edge);
			my $text = $subgraph->text(" ");

			# Use example if it hasn't been used before
			if (! $examples_hash->{$tclass . ":" . $text}) {
				# Generate file name and record example
				my $file = cdtfile("", $exprefix . sprintf("%04d", $excounter) 
					. "-" .  classname($tclass));
				++$excounter;
				my $example = [$tclass, $file, $source, $text];
				push @{$examples->{$tclass}}, $example;
				$examples_hash->{$tclass . ":" . $text} = $example;

				# Save example in file
				print "new example: ", join("\t", @$example), "\n";
				open(EX, ">$exdir/$file.tag");
				print EX "<!-- " . join("\t", @$example) . "-->\n";
				print EX $subgraph->print_tag();
				close(EX);

				# Decrement example counter
				--$n;
			}
		}
	}

	# Generate examples randomly for non-terminal classes: eg, if class
	# has subclasses s1,s2,s3 (ordered by their instance count) and we 
	# need 5 examples, we randomly pick example from s1,s2,s3,s1,s2
	my $incomplete = 1;
	while ($incomplete) {
		$incomplete = 0;
		foreach my $class (sort(keys(%$instances))) {
			# Skip class if it is done 
			next() if ($done->{$class});
			print "TERMINAL $class!!!\n" if ($terminal->{$class});
			
			# Skip class if one of its subclasses is not done
			my @subs = @{$subclasses->{$class}};
			if (grep {! $done->{$_}} @subs) {
				$incomplete = 1;
				next();
			}

			# Order examples from subclasses randomly
			my $hash = {};
			my $nsubs = scalar(@subs);
			for (my $i = 0; $i <= $#subs; ++$i) {
				# Shuffle examples by recording example $j for subclass 
				# $i under integer $j * nsubs + $i
				my $sub = $subs[$i];
				my @exlist = @{$examples->{$sub}};
				for (my $j = 0; $j <= $#exlist; ++$j) {
					$hash->{$j * $nsubs + $i} = $exlist[$j];
				}
			}
			my @shuffled = (
				@{$examples->{$class} || []}, 
				map {$hash->{$_}} sort(keys(%$hash)));

			# Pick the desired number of examples
			my $n = max(scalar(@{$examples->{$class} || []}), 
				min(scalar(@shuffled), $excount));
			$hash = {};
			my $exlist = $examples->{$class} = [];
			for (my $i = 0; $i <= $#shuffled && $n > 0; ++$i) {
				my $example = [@{$shuffled[$i]}];
				$example->[0] = $class;
				my $file = $example->[1];
				if (! $hash->{$file}) {
					push @$exlist, $example;
					$hash->{$file} = $example;
					--$n;
				}
			}
			$done->{$class} = 1;
		}
	}

	# Write example file $exfile
	if (open(EX, ">$exfile")) {
		print EX $excounter, "\n";
		foreach my $class (sort(keys(%$examples))) {
			# Only print terminal classes
			next() if (! $terminal->{$class});
			foreach my $example (@{$examples->{$class}}) {
				if ($example) {
					print EX join("\t", @$example) . "\n";
				} else {
					print "Undefined example for $class\n";
				}
			}
		}
		close(EX);
	} else {
		error("Cannot open $exfile for writing!");
	}

	# Create map files
	sub dimension {
		my $cls = shift;
		my $dm = shift;
		my @lst = split('_', $cls);
		return $lst[$dm] || "";
	}

	sub classname {
		my $cls = shift;
		$cls =~ s/:/./g;
		return($cls);
		#my @lst = split('_', $cls);
		#return join("_", map {$_ || '_'} @lst);
	}

	sub wiki_url {
		my ($link, $text) = @_;
		return "<a href=\"$link\">$text</a>";
	}

	sub supf {
		my $url = shift;
		my $mapdep = shift;
		my $class = shift;
		my $list = shift;
		my $dim = shift;
		return join(" ", sort(map { 
			wiki_url(cdtfile($url, $mapdep . classname($_) . ".html"), dimension($_, $dim) || "ANY") }
				@$list));	
	}

	sub subf {
		my $url = shift;
		my $mapdep = shift;
		my $instances = shift;
		my $class = shift;
		my $list = shift;
		my $dim = shift;
		return join(" ", map {
			wiki_url(cdtfile($url, $mapdep . classname($_) . ".html"), 
				dimension($_, $dim)) 
				. sprintf("<sub>%d%%</sub>", scalar(@{$instances->{$_}}) /
					scalar(@{$instances->{$class}}) * 100)
			} sort {scalar(@{$instances->{$b}}) <=>
				scalar(@{$instances->{$a}})} @$list);
	}

	foreach my $class (keys(%$instances)) {
		# Retrieve
		# Categorize superclasses
		my $superlist = [[], [], [], [], []];
		foreach my $super (@{$superclasses->{$class}}) {
			map {push @{$superlist->[$_]}, $super} 
				wikidoc_subclass_dim($class, $super);
		}
		my $supdeps = supf($url, $mapdep, $class, $superlist->[0], 0);
		my $suprels = supf($url, $mapdep, $class, $superlist->[1], 1);
		my $supgovs = supf($url, $mapdep, $class, $superlist->[2], 2);
		my $suplangs = supf($url, $mapdep, $class, $superlist->[3], 3);

		# Categorize subclasses
		my $sublist = [[], [], [], [], []];
		foreach my $sub (@{$subclasses->{$class}}) {
			map {push @{$sublist->[$_]}, $sub} 
				wikidoc_subclass_dim($sub, $class);
		}

		my $subdeps = subf($url, $mapdep, $instances, $class, $sublist->[0], 0);
		my $subgovs = subf($url, $mapdep, $instances, $class, $sublist->[2], 2);
		my $sublangs = subf($url, $mapdep, $instances, $class, $sublist->[3], 3);
		my $subcomps = subf($url, $mapdep, $instances, $class, [grep {$self->is_complement(dimension($_, 1))} @{$sublist->[1]}], 1);
		my $subadjs = subf($url, $mapdep, $instances, $class, [grep {$self->is_adjunct(dimension($_, 1))} @{$sublist->[1]}], 1);
		my $subrels = ($subcomps ? "<p><b>complement:</b><br> " . $subcomps .  "<br>\n" : "")
			. ($subadjs ? "<p><b>adjunct:</b><br>" . $subadjs . "\n" : "");

		#print "no super: $class instances=" 
		#	.  scalar(@{$instances->{$class}}) 
		#	. ($terminal->{$class} ? " terminal" : "")
		#	. "\n"
		#	if (! @{$superclasses->{$class}});

		my ($dependent, $relation, $governor, $language) = 
			map {dimension($class, $_)} (0, 1, 2, 3);

		# Examples
		my $examplestring = "";
		foreach my $example (@{$examples->{$class}}) {
			my ($class, $file, $source, $text) = @$example;
			if ($text && $source && $file) {
				$examplestring .=
					"<p><b>text:</b> $text</p>\n\n" .
					"<img src=\"$url$file.png\">\n\n" .
					"<p><b>source:</b> $source</p>\n\n" .
					"<hr>\n";
			}
		}
		
		# Print wiki
		my $mapdepfile = cdtfile("$wikidir", $mapdep .  classname($class) . ".html");

		open(WIKI, "> $mapdepfile");
		print WIKI "<html>\n"
			. "<head>\n"
			. "<META http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">\n"
			. "<body>\n"
			. "<h2>$mapdep" . classname($class) . ": " . join(" + ", grep {$_} (
			$dependent ? "dependent $dependent" : "",
			$relation ? "relation $relation" : "",
			$governor ? "governor $governor" : "",
			$language ? "language $language" : ""))
			. " (" . scalar(@{$instances->{$class}}) . " instances)</h2>\n\n";
		print WIKI "<table rules=\"all\" frame=\"all\"><tr><th></th><th>Dependent</th><th>Governor</th><th>Relation</th><th>Language</th></tr>\n";
		print WIKI "<tr><th>Super</th><td>$supdeps</td><td>$supgovs</td><td>$suprels</td><td>$suplangs</td></tr>\n";
		print WIKI "<tr><th>Sub</th><td>$subdeps</td><td>$subgovs</td><td>$subrels</td><td>$sublangs</td></tr></table>\n";
		print WIKI "\n\n<h3>Examples</h3>\n";
		print WIKI $examplestring;
		print WIKI "</body></html>\n";
		close(WIKI);
	}
	
	$self->var('wikidoc_term', $terminal);
	$self->var('wikidoc_sup', $superclasses);
	$self->var('wikidoc_sub', $subclasses);
	$self->var('wikidoc_inst', $instances);
	$self->var('wikidoc_ex', $examples);


	print "classes=", scalar(keys(%$instances)), 
	" instances=", scalar(@$instancelist), 
	" terminal=", scalar(keys(%$terminal)), "\n";
	# classes=4140 instances=3714 terminal=2927
	# classes=928 instances=3714 terminal=188
	# classes=740 instances=3714 terminal=126
	# classes=453 instances=3714 terminal=126
	# classes=2862 instances=89907 terminal=571
	# classes=1576 instances=89907 terminal=478

}

sub wikidoc_subclass_dim {
	my ($a, $b) = @_;
	my @cls = split('_', $a);
	my @sbcls = split('_', $b);
	my @dms = ();
	for (my $i = 0; $i <= $#cls || $i <= $#sbcls; ++$i) {
		push @dms, $i 
			if (($cls[$i] || "") ne ($sbcls[$i] || ""));
	}
	return @dms;
}

sub wikidoc_class {
	my $self = shift;
	my $instance = shift;
	my ($i2, $iw, $type, $o2, $ow, $lang) = @$instance;
	$i2 =~ s/[^A-Za-z]//g;
	$o2 =~ s/[^A-Za-z]//g;
	$type =~ s/\|.*$//g;
	$type =~ s/[^A-Za-z:]//g;
	$iw =~ s/[^A-Za-z]//g; 
	$ow =~ s/[^A-Za-z]//g;
	$lang =~ s/[^A-Za-z]//g;

	my $class = join("_", 
		($iw ? $i2 . "." . $iw : $i2), 
		$type,
		($ow ? $o2 . "." . $ow : $o2), 
		$lang);
	#print $class, "\n";
	return $class;
}

sub wikidoc_super {
	my $self = shift;
	my $class = shift;
	my ($i, $t, $o, $l) = split('_', $class);

	my $super = [];
	push @$super, join("_", wikidoc_superw($i), $t, $o, $l) if ($i);
	push @$super, join("_", $i, "", $o, $l) if ($t);
	push @$super, join("_", $i, $t, wikidoc_superw($o), $l) if ($o);
	push @$super, join("_", $i, $t, $o, "") if ($l);
	
	#print "super($class): " . join(" ", @$super) . "\n";
	return $super;
}

sub wikidoc_super_all {
	my $self = shift;
	my $class = shift;
	my $supers = shift || {};

	if (! $supers->{$class}) {
		$supers->{$class} = 1;
		foreach my $s (@{$self->wikidoc_super($class)}) {
			$self->wikidoc_super_all($s, $supers);
		}
	}
	return [sort(keys(%$supers))];
}

sub wikidoc_superw {
	my $wclass = shift;
	$wclass =~ /^([^.]*)(\.(.*))?$/;
	my ($tag, $word) = ($1 || "", $3 || "");

	# Word present
	return "" if (length($tag) == 0);
	return $tag if (length($word) != 0);
	return "" if (length($tag) == 1);
	return substr($tag, 0, 1);
}

sub cdtfile {
	# Compute file hash
	my ($dir, $file) = @_;
	my $hash = 0;
	foreach (split //, $file) {
		$hash = $hash*33 + ord($_);
	}

	# Compute file name
	return sprintf("%s/%03d/%s", $dir, $hash % $WIKIDOC_SUBDIRS, $file);
}
