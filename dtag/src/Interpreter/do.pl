
sub do {
	my $self = shift;
	my $cmdstr = shift;
	my $history = shift;
	my $success = undef;

	# Log command
	my $cmdlog = $self->var("cmdlog");
	if (defined($cmdlog) && ! $self->quiet()) {
		my $time = time() - ($self->var("cmdlog.time0") || 0);
		print $cmdlog encode_utf8("$time:\t$cmdstr\n");
	}

	# ---------- COMMANDS IN SORTED ORDER ----------

	# Find list of commands to process
	my $commands = [];
	if ($cmdstr =~ /^\s*macro/) {
		# Macros are always interpreted as a single command
		push @$commands, $cmdstr;
	} else {
		if ($cmdstr eq "") {
			push @$commands, "";
		} else {
			push @$commands, split(";;", $cmdstr);
		}
	}

	# Process commands
	my $todo = $self->var('todo');
	my $cmd;
	while (defined($cmd = shift(@$commands))) {
		my $graph = $self->graph();
		# Command ends with backslash
		if ($cmd =~ /\\\s*$/) {
			# Prepend command to following command
			$cmd =~ s/\\\s*$//;
			if (@$commands) {
				$commands->[0] = $cmd . " " . $commands->[0];
			} elsif (@$todo) {
				$todo->[0] = $cmd . " " . $todo->[0];
			}

			# Goto next command in loop
			next();
		}

		# Exit if $cmd is undefined (ctrl-D)
		if (! defined($cmd)) {
			$cmd = "exit";
			print "\n";
			$success = $self->cmd_exit($graph);
		}

		# Ignore comments starting with '#'
		$success = 1 
			if ($cmd =~ /^\s*#.*$/);

		# Update graph: <return>
		$success = $self->cmd_return($graph)
			if ($cmd =~ /^\s*$/);

		# Replace: =$replacement
		$success = $self->cmd_replace($graph, $1)
			if ($cmd =~ /^=(.*)\s*$/);

		# Macro: macro $macro $cmd
		$success = $self->cmd_macro($1, $2) 
			if ($cmd =~ /^\s*macro\s+(\w+)\s+(.*)$/ ||
				$cmd =~ /^\s*macro\s+(\w+)\s*$/);

		# Unix shell: ! $cmd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*!\s*(.*)$/);

		# Replace variables in command
		my $DTAGHOME = $ENV{'DTAGHOME'} || '$DTAGHOME';
		my $CDTHOME = $ENV{'CDTHOME'} || '$CDTHOME';
		my $HOME = $ENV{'HOME'} || '$HOME';
		$cmd =~ s/\$DTAGHOME/$DTAGHOME/g;
		$cmd =~ s/\$CDTHOME/$CDTHOME/g;
		$cmd =~ s/\$HOME/$HOME/g;

		# Help search relation command: ??$relation
		$success = $self->cmd_relhelpsearch($graph, $1) 
			if ($cmd =~ /^\s*\?\?(\S+)\s*$/);

		# Help relation command: ?$relation
		$success = $self->cmd_relhelp($graph, $2, $1) 
			if ($cmd =~ /^\s*\?(!)?([^?]\S+)\s*$/);

		# UNIX commands recognized by DTAG: ls mkdir rmdir rm pwd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*((mkdir|rmdir|rm|pwd)(\s+.*)?)$/);
		$success = $self->cmd_shell("ls --color " . ($1 || ""))
			if ($cmd =~ /^\s*ls(\s+.*)?$/);

		# Adiff: adiff $file1 ... $fileN
		$success = $self->cmd_adiff($graph, $1)
			if ($cmd =~ /^\s*adiff\s+(.*)$/);

		# Afilter: afilter $alignmentfile
		$success = $self->cmd_afilter($graph, $1)
			if ($cmd =~ /^\s*afilter\s+(\S+)\s*$/);

		# Alearn: alearn $options
		$success = $self->cmd_alearn($graph, $1) 
			if ($cmd =~ /^\s*alearn\s*(.*)\s*$/);

		# Align: align $nodes $type $nodes
		$success = $self->cmd_align($graph, $1, defined($3) ? $3 : "", $4)
			if (UNIVERSAL::isa($self->graph(), 'DTAG::Alignment') && (
				$cmd =~ /^\s*align\s+([a-z]?[0-9\.+-]+)\s+((\S+)\s+)?([a-z]?[\.0-9+-]+)\s*$/
				|| $cmd =~ /^\s*([a-z]?[\.0-9+-]+)\s+((\S+)\s+)?([a-z]?[\.0-9+-]+)\s*$/));

		# Alignment: alignment $file1 ... $fileN
		$success = $self->cmd_alignment($1)
			if ($cmd =~ /^\s*alignment\s+(.*)$/);

		# Aparse: aparse $alignmentfile
		$success = $self->cmd_aparse($graph, $1, "da-en")
			if ($cmd =~ /^\s*aparse\s+(\S+)\s*$/);
		$success = $self->cmd_aparse($graph, $2, $1)
			if ($cmd =~ /^\s*aparse\s+-(\S+)\s+(\S+)\s*$/);

		# As.example: as.example [$vars] [$from] [$to]
		$success = $self->cmd_as_example($graph, $2, $4)
			if ($cmd =~ /^\s*as.example\s*(\s+([^-+0-9]\S+))?(\s+(.*))?\s*$/);

		# Autoalign: autoalign $alexicon
		$success = $self->cmd_autoalign($graph, $2)
			if ($cmd =~ /^\s*autoalign\s*(\s+(.+))?\s*$/);

		# Autoevaluate: autoevaluate
		# start autoevaluation using current graph as gold standard
		$success = $self->cmd_autoevaluate($graph, $2)
			if ($cmd =~ /^\s*autoevaluate(\s+(\S+))?\s*$/);

		# Autogloss: autogloss [-atag $atagfile] [mapfile1] [mapfile2] ...
		$success = $self->cmd_autogloss($graph, $2, $3) 
			if ($cmd =~ /^\s*autogloss(\s+-atag\s+(\S*))?\s*(.*)$/);

		# Replace: autoreplace [-corpus] $rel1 $rel2 ...
		$success = $self->cmd_autoreplace($graph, $1, $2)
			if ($cmd =~ /^\s*autoreplace\s+(-corpus\s+)?(.*)$/);

		# Autotag: autotag $tag $filepattern
		if ($cmd =~ /^\s*autotag\s+-pos\s+([+-]?[0-9]+)\s*$/) {
			$self->autotag_setpos($graph, $1, -1);
			$self->cmd_autotag_next($graph);
			$success = 1;
		} elsif ($cmd =~ /^\s*autotag\s+-offset\s+([+-])?([0-9]+)\s*$/) {
			$self->cmd_offset($graph, $1, $2);
			my $pos = ($graph->var('autotagpos') || 0) - 1;
			$graph->var('autotagpos', $pos);
			$self->cmd_autotag_next($graph);
			$success = 1;
		} elsif ($cmd =~ /^\s*autotag\s+-off\s*$/) {
			$self->autotag_off($graph);
			$success = 1;
		} elsif ($cmd =~ /^\s*autotag\s+(\S+)(\s+(-matches))?(\s+(.*\S))?\s+$/) {
			$success = $self->cmd_autotag($graph, $1, $5, $3);
		}

		# Autotag assignment: "<value" and "pos<value"
		if ($cmd =~ /^<(.*)$/) {
			$success = $self->cmd_autotag_next($graph, $1)
		} elsif ($cmd =~ /^([+-]?[0-9]+)<(.*)$/) {
			$self->autotag_setpos($graph, $1);
			$success = $self->cmd_autotag_next($graph, $2);
		}
		
		# Change directory: cd $dir
		$success = $self->cmd_cd($1)
			if ($cmd =~ /^\s*cd\s+(.*\S)\s*$/);

		# Clear: clear [-tag|-lex|-edges]
		$success = $self->cmd_clear($graph, $2) 
			if ($cmd =~ /^\s*clear( (-lex|-tag|-edges))?\s*$/);

		# Close: close
		$success = $self->cmd_close($graph, $2)
			if ($cmd =~ /^\s*close(\s+(-all))?\s*$/);

		# Told: told [$name]
		$success = $self->cmd_told($2, $3) 
			if ($cmd =~ /^\s*told(@(\S+))?\s*$/);

		# Command log: cmdlog $file
		$success = $self->cmd_cmdlog($1)
			if ($cmd =~ /^\s*cmdlog\s+(.*\S)\s*$/);

		# Comment: comment $pos $dtag_code
		$success = $self->cmd_comment($graph, $1, $2) 
			if ($cmd =~ /^\s*comment\s*([0-9]+)?\s+(.*)$/);

		# Confusion: confusion [-add] $name $file...
		$success = $self->cmd_confusion($2, $3, $1) 
			if ($cmd =~ /^\s*confusion(\s+-add)?\s+(\S+)\s+(.*)$/);

		# Corpus: corpus $files
		$success = $self->cmd_corpus($1) 
			if ($cmd =~ /^\s*corpus(\s+.*)?$/);
		$success = $self->cmd_corpus_apply($1) 
			if ($cmd =~ /^\s*corpus-apply\s+(.*)$/);


		# Debug 
		if ($cmd =~ /^\s*debug\s*/) {
			$self->{'debug'} = 1;
			$success = 1;
		}

		# Delete node/edge/alignment edge: del $node[-$node] [$etype $node]
		#	"del 12"
		#	"del 12 land 13"
		# 	"del a12"
		#	"del 12..27"
		$success = $self->cmd_del($graph, $1, $3, $4) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') && (
				$cmd =~ /^\s*del\s+([+-]?[0-9]+(\.\.[+-]?[0-9]+)?)\s+(\S+)\s+([+-]?[0-9]+)\s*$/ ||
				$cmd =~ /^\s*del\s+([+-]?[0-9]+(\.\.[+-]?[0-9]+)?)\s*$/));
		$success = $self->cmd_del_align($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment') &&
				$cmd =~ /^\s*del\s+([a-z]-?[0-9]+)\s*$/);
		if ($cmd =~ /^\s*del\s+-on\s*$/) {
			$success = 1;
			print "Turning node deletion on\n";
			$graph->{'block_nodedel'} = 0;
		}
		if ($cmd =~ /^\s*del\s+-off\s*$/) {
			print "Turning node deletion off\n";
			$success = 1;
			$graph->{'block_nodedel'} = 1;
		}
		
		# Diff: diff $file
		$success = $self->cmd_diff($graph, $2)
			if ($cmd =~ /^\s*diff\s*(\s(\S*))?\s*$/);

		# Display: display $psfile
		$success = $self->cmd_display($graph, $1)
			if ($cmd =~ /^\s*display\s+(\S+)\s*$/);

		# Delete incoming edges at node: edel $node
		$success = $self->cmd_edel($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') && 
				$cmd =~ /^\s*edel\s+([+-]?[0-9]+)\s*$/);
		$success = $self->cmd_del($graph, $1, $2, $3, 1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') && (
				$cmd =~ /^\s*edel\s+([+-]?[0-9]+)\s+(\S+)\s+([+-]?[0-9]+)\s*$/));

		# Echo: echo $string
		$success = $self->cmd_echo($2, $3)
			if ($cmd =~ /^\s*echo(@(\S+))?\s(.*)$/);

		# Edges: edges $node
		$success = $self->cmd_edges($graph, $1)
			if ($cmd =~ /^\s*edges\s+(\S+)\s*$/
				|| $cmd =~ /^([a-z]?[0-9]+)\s*$/);

		# Edgesep: edgesplit regexp
		$success = $self->cmd_edgesplit($1) 
			if ($cmd =~ /^\s*edgesplit\s+(.*)$/);

		# Efilter: efilter ±label... ±
		$success = $self->cmd_efilter($graph, $1)
			if ($cmd =~ /^\s*efilter((\s+[+-]\S*)+)\s*$/);

		# Etypes: etypes -$type $type1 $type2 ...
		$success = $self->cmd_etypes($graph, $2, $3, $1)
			if ($cmd =~ /^\s*etypes\s+(-add\s+)?-(\S+)\s+(.*)$/ ||
				$cmd =~ /^\s*etypes\s*$/);

		# Edit node/edge: edit $node [$var[=$value]]
		#	"edit 12 gloss=him"
		#	"edit 12 in=12:subj|13:land"
		$success = $self->cmd_edit($graph, $1, $2) 
			if ($cmd =~ /^\s*edit\s+([+-]?[0-9]+)\s*(.*)\s*$/);

		# Errordef: errordef [-node|-edge] $name $code
		$success = $self->cmd_errordef($graph, $2, $3, defined($5) ? $5 : "") 
			if ($cmd =~ /^\s*errordef(\s+(-node|-edge))?\s+(\S+)(\s+(.*))?$/);

		# Errordefs: errordefs $name
		$success = $self->cmd_errordefs($graph, $1) 
			if ($cmd =~ /^\s*errordefs(\s+(\S+))?\s*$/);

		# Errors: errors [$node[-$node]]
		$success = $self->cmd_errors($graph, $2, defined($4) ? $5 : $2) 
			if ($cmd =~ /^\s*errors(\s+([+-]?[0-9]+)(\s*(-)\s*([-+]?[0-9]+))?)?\s*$/);

		# Gedit: gedit $lineno
		$success = $self->cmd_gedit($graph, $2) 
			if ($cmd =~ /^\s*gedit(\s+([0-9]+))?\s*$/);

		# Example: ex $specification
		$success = $self->cmd_example($graph, $1) 
			if ($cmd =~ /^\s*example\s+(.*)$/);

		# Exit: exit 
		#     : quit
		$success = $self->cmd_exit($graph, $1)
			if ($cmd =~ /^\s*exit(!)?\s*$/ || $cmd =~ /^\s*quit(!)?\s*$/);

		# Find: find $pattern
		$success = $self->cmd_find($graph, $1) 
			if ($cmd =~ /^\s*find\s+(.*\S)\s*$/);

		# Fixations fixations $fixgraphid $durattr $graphattr $fixattr
		$success = $self->cmd_fixations($graph, $1, $2, $3, $5)
			if ($cmd =~ /^\s*fixations\s+(\S+)\s+(\S+)\s+(\S+)(\s+(\S+))?\s*$/);

		# Follow: follow [$file]
		$success = $self->cmd_follow($graph, $1)
			if ($cmd =~ /^\s*follow\s*(\S*)\s*$/);

		# Format: format $var $regexp
		$success = $self->cmd_format($graph, $1, $2)
			if ($cmd =~ /^\s*format\s+([^ ]*)\s+(.*)$/ 
				|| $cmd=~ /^\s*format\s+([^ ]*)$/);

		# Frame: frame ... (ignored)
		$success = $self->cmd_title($graph, $3)
			if ($cmd =~ /^\s*frame((\s+-[^ ]+)*)\s+([^-].*)\s*$/);

		# Goto: goto [-next|-prev|$match]
		$success = $self->cmd_goto($graph, $1)
			if ($cmd =~ /^\s*goto\s+(.+)\s*$/);

		# Graph: graphs
		$success = $self->cmd_graphs($graph) 
			if ($cmd =~ /^\s*graphs\s*$/);

		# Help: help [$command]
		$success = $self->cmd_help($1) 
			if ($cmd =~ /^\s*help\s*(\S*)\s*$/);

		# Inalign: inalign 
		$success = $self->cmd_inalign($graph, $1, $3, $2)
			if ($cmd =~ /^\s*inalign\s+([0-9+]+)\s+(\S+)\s+([0-9+]+)\s*$/);
		$success = $self->cmd_inalign($graph, $1, $2, "")
			if ($cmd =~ /^\s*inalign\s+([0-9+]+)\s+([0-9+]+)\s*$/);

		# Inline: inline $pos $dtag_code
		$success = $self->cmd_inline($graph, $1, $2) 
			if ($cmd =~ /^\s*inline\s+([0-9]+)\s+(.*)$/);

		# Kgoto: kgoto $time
		$success = $self->cmd_kgoto($graph, $1) 
			if ($cmd =~ /^\s*kgoto\s+([0-9.]+)$/);

		# Kplay: kplay $time
		$success = $self->cmd_kplay($graph, $2, $5, $6) 
			if ($cmd =~ /^\s*kplay(\s+-speed=([0-9.]+))?(\s+(([0-9.]+)-)?([0-9.]+))?\s*$/);

		# Layout: layout $options
		$success = $self->cmd_layout($graph, $1)
			if ($cmd =~ /^\s*layout\s*(.*)\s*$/);

		# Lexicon: lexicon $name
		$success = $self->cmd_lexicon($1)
			if ($cmd =~ /^\s*lexicon\s+(\S*)\s*$/);

		# Load: load [-tag|-lex|-match] [-multi] [$file]
		$success = $self->cmd_load($graph, $2, $4, $3)
			if ($cmd =~ /^\s*load\s*((-lex|-tag|-atag|-key|-fix|-eye|-match|-tiger|-malt|-conll|-emalt)\s+)?(-multi\s+)?(\S*)\s*$/);

		# Lookup: lookup "$string"$
		$success = $self->cmd_lookup($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
				&& $cmd =~ /^\s*lookup\s+"(.*)"\s*$/);
		$success = $self->cmd_lookup($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
				&& $cmd =~ /^\s*lookup\s+(.*)\s*$/);
		$success = $self->cmd_lookup_align($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment') 
				&& $cmd =~ /^\s*lookup\s+(.*)\s*$/);

		# Lookup word: lookupw "$string"$
		$success = $self->cmd_lookupw($graph, $1) 
			if ($cmd =~ /^\s*lookupw\s+"(.*)"\s*$/);
		$success = $self->cmd_lookupw($graph, $1) 
			if ($cmd =~ /^\s*lookupw\s+(.*)\s*$/);

		# Macros: macros
		$success = $self->cmd_macros($1, $2) 
			if ($cmd =~ /^\s*macros\s*$/);

		# Maptags: maptags [-map $mapfile] $invar $outvar
		$success = $self->cmd_maptags($graph, $2, $3, $4)
			if ($cmd =~ /^\s*maptags(\s+-map\s+(\S+))?\s+(\S+)\s+(\S+)\s*$/);

		# Matches: matches
		$success = $self->cmd_matches($1)
			if ($cmd =~ /^\s*matches\s*(.*)$/);

		# Merge: merge $fileglob
		$success = $self->cmd_merge($graph, $1) 
			if ($cmd =~ /^\s*merge\s+(.+)$/);

		# Move node: move $pos1 $pos2
		$success = $self->cmd_move($graph, $1, $2)
			if ($cmd =~ /^\s*move\s+([0-9]+)\s+([0-9]+)\s*$/);

		# Multiedit: multiedit $node1-$node2 ...

		# New: new (create new graph)
		$success = $self->cmd_new()
			if ($cmd =~ /^\s*new\s*$/);

		# Noerror: mark noerror $2 for node $1 
		$success = $self->cmd_noerror($graph, $1, $3)
			if ($cmd =~ /^\s*noerror\s+([+-]?[0-9]+)(\s+(\S+))?\s*$/);

		# Next: next ... (shorthand for "goto next...")
		$success = $self->cmd_goto($graph, $cmd)
			if ($cmd =~ /^\s*next/);

		# Noedge: noedge $node
		$success = $self->cmd_noedge($graph, $1)
			if ($cmd =~ /^\s*noedge\s+([0-9]+)\s*$/);

		# Note: note $node $text
		$success = $self->cmd_note($graph, $1, $2)
			if ($cmd =~ /^\s*note\s+([0-9]+)\s*(.*)$/);

		# Note: notes
		$success = $self->cmd_notes($graph)
			if ($cmd =~ /^\s*notes\s*$/);

		# Offset: offset [=+-]$offset
		$success = $self->cmd_offset($graph, $2, $3)
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
				&& $cmd =~ /^\s*offset(\s+([-+=])?([0-9]+|end))?\s*$/);
		$success = $self->cmd_offset_align($graph, $1)
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment')
				&& $cmd =~ /^\s*offset((\s+([-+=])?([a-z]-?[0-9]+))*)\s*$/);
		$success = $self->cmd_offset_align($graph, "auto")
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment')
				&& $cmd =~ /^\s*offset\s+-auto\s*$/);

		# ok: ok
		$success = $self->cmd_ok($graph) 
			if ($cmd =~ /^\s*ok\s*$/);

		# Option: option $option=$value
		$success = $self->cmd_option($1, $2)
			if ($cmd =~ /^\s*option\s+(\S+)\s*=\s*(\S.*)\s*$/
				|| $cmd =~ /^\s*option\s+(\S+)\s+(\S.*)\s*$/
				|| $cmd =~ /^\s*option\s+(\S+)\s*$/);

		# Offset and show: oshow $offset
		#if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
		#		&& $cmd =~ /^\s*oshow(\s+([-+=])?([0-9]+))?\s*$/) {
		#	my ($sign, $offset) = ($2, $3);
		#	$success = $self->cmd_offset($graph, $sign, $offset);
		#	$success = $self->cmd_show($graph, " 0");
		#}
		
		if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
			$cmd =~ /^\s*oshow(\s+[+-]?[0-9]+)\s*$/) {
			my $offset = $1;
		}

		# Tell: tell [-name=$name] $file
		$success = $self->cmd_tell($2, $3) 
			if ($cmd =~ /^\s*tell(@(\S+))?\s+(\S+)\s*$/);

		# parse2dtag: parse2dtag $ifile $ofile
		$success = $self->cmd_parse2dtag($1, $2) 
			if ($cmd =~ /^\s*parse2dtag\s+(\S+)\s+(\S+)\s*$/);

		# Partag: partag $key
		$success = $self->cmd_partag($graph, $1)
			if ($cmd =~ /^\s*partag\s+(\S*)\s*$/);

		# Patch: patch [-$key] $difffile
		$success = $self->cmd_patch($graph, $2, $3) 
			if ($cmd =~ /^\s*patch\s+(-([a-z])\s+)?(.*\S)\s*$/);

		# Pause: pause
		$success = $self->cmd_pause()
			if ($cmd =~ /^\s*pause\s*$/);

		# Perl: perl [$expr]
		$success = $self->cmd_perl($4, $3, $1, $2)
			if ($cmd =~ /^\s*perl\s*(-v)?\s*(-corpus)?\s*(-file)?\s+(.*)\s*$/);

		# Prev: prev* (shorthand for "goto prev*")
		$success = $self->cmd_goto($graph, $cmd)
			if ($cmd =~ /^\s*prev/);

		# Print: print [$file]
		$success = $self->cmd_print($graph, $3, 0, $2)
			if ($cmd =~ /^\s*print\s*((-i|-p)\s+)*(\S*)\s*$/);

		# Parse step: pstep $number
		$success = $self->cmd_pstep($graph, $2)
			if ($cmd =~ /^\s*pstep(\s+([-+0-9]+))?\s*$/);

		# Redirect: redirect <$file>
		$success = $self->cmd_redirect($2)
			if ($cmd =~ /^\s*redirect(\s+(\S+))?\s*$/);

		# Relations: relations
		$success = $self->cmd_relations($graph, $2)
			if ($cmd =~ /^\s*relations\s*(\s+([^ ]*))?$/);

		# Relset: relset $name [$csvfile]
		$success = $self->cmd_relset($graph, $2, $4) 
			if ($cmd =~ /^\s*relset(\s+(\S+))?(\s+(\S+))?\s*$/);

		# Relset2latex: relset2latex $filename [$type] ...
		$success = $self->cmd_relset2latex($graph, $2, $3) 
			if ($cmd =~ /^\s*relset2latex(\s+-file=(\S+))?\s+(.*)$/);

		# Resume: resume
		$success = $self->cmd_resume($graph, $2)
			if ($cmd =~ /^\s*resume(\s+([0-9]+))?\s*$/);

		# Save: save [$file]
		$success = $self->cmd_save($graph, $2, $3)
			if ($cmd =~ /^\s*save\s*(\s+(-lex|-tag|-atag|-alex|-xml|-malt|-match|-conll|-table)\s+)?(\S*)\s*$/);

		# Save: save -corpus $tablefile
		$success = $self->cmd_save_table($graph, $1, @{$self->{'corpus'}})
			if ($cmd =~ /^\s*save\s+-corpus\s*(\S+)\s*$/);

		# Script: script [$file]
		if ($cmd =~ /^\s*script\s+-q\s+(\S.*\S)\s*$/) {
			my $quiet = $self->quiet();
			$self->quiet(1);
			$success = $self->cmd_script($graph, $1);
			$self->quiet($quiet);
		} elsif ($cmd =~ /^\s*script\s*(\S.*\S)\s*$/) {
			$success = $self->cmd_script($graph, $1);
		}

		# Segment: segment $node [segment|segment|...] 
		$success = $self->cmd_compound($graph, $1, $2, $3)
			if ($cmd =~ /^\s*segment\s+([a-z])?([0-9]+)(.*)$/);
	
		# Server: server $directory
		$success = $self->cmd_server($1)
			if ($cmd =~ /^\s*server\s*(\S*)\s*$/);

		# Shell: shell $cmd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*shell\s+(.*)$/);

		# Shift: shift $anode $offset
		$success = $self->cmd_shift($graph, $1, $2, $3)
			if ($cmd =~ /^\s*shift\s+([a-z])([0-9]+)\s+([-+]?[0-9]+)\s*$/);

		# Show: show [-component] $imin1[-$imax1] $imin2[-$imax2]
		# $success = $self->cmd_show($graph, $3, $5)
		if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
			$cmd =~ /^\s*show(\s+(-c(omponent)?|-y(ield)?))?((\s+[+-]?[0-9]+(-[0-9]+)?)*)\s*$/) {
			$success = $self->cmd_show($graph, $5, $2);
		}
		if (UNIVERSAL::isa($graph, 'DTAG::Alignment') &&
			$cmd =~ /^\s*show(\s+(-c(omponent)?|-y(ield)?))?((\s+[+-]?[a-z][0-9]+(-[0-9]+)?)*)\s*$/) {
			$success = $self->cmd_show_align($graph, $5, $2);
		}

		# Sleep: sleep $time
		$success = $self->cmd_sleep($1) 
			if ($cmd =~ /^\s*sleep\s+([0-9]*(\.[0-9]*)?)\s*$/);

		# Step: step
		$success = $self->cmd_resume($graph, 1)
			if ($cmd =~ /^\s*step\s*$/);

		# Style: style $id $options
		$success = $self->cmd_style($graph, $1, $3) 
			if ($cmd =~ /^\s*style\s+(\S+)(\s+(.+))?\s*$/);

		# Table: table [-name=$name] $string
		$success = $self->cmd_table($2, $3)
			if ($cmd =~ /^\s*table(\s+-name=(\S+))?\s(.*)$/);

		# Text: text $i1 $i2
		$success = $self->cmd_text($graph, $2, $4, 0)
			if ($cmd =~ /^\s*text(\s+([+-=]?[0-9]+)(\s*\.\.\s*([+-=]?[0-9]+))?)?\s*$/);

		# Text: textn $i1 $i2
		$success = $self->cmd_text($graph, $2, $4, 1)
			if ($cmd =~ /^\s*textn(\s+([+-=]?[0-9]+)(\s*\.\.\s*([+-=]?[0-9]+))?)?\s*$/);

		# Title: title $title
		$success = $self->cmd_title($graph, $1)
			if ($cmd =~ /^\s*title\s+(.+)\s*$/);

		# Touch graph: touch
		$success = $self->cmd_touch($graph)
			if ($cmd =~ /^\s*touch\s*$/);

		# Transfers: transfers [-save $dir] [-clear] $files
		$success = $self->cmd_transfers($graph, $1, $3, $4) 
			if ($cmd =~ /^\s*transfers(\s+-clear)?(\s+-save\s+(\S+))?(.*)$/);

		# Undiff (reset diff): undiff
		$success = $self->cmd_undiff($graph)
			if ($cmd =~ /^\s*undiff\s*$/);

		# Unix shell: unix $cmd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*unix\s+(.*)$/);

		# User name: user [-f $file] $name
		$success = $self->cmd_user($1) 
			if ($cmd =~ /^\s*user\s+(.*\S)\s*$/);

		# Vars: vars [+$var[:$abbrev]] [-$var] ... 
		#	var +gloss:g +lexeme:x -glss
		if ($cmd =~ /^\s*vars\s+-sloppy\s*$/) {
			$graph->{'vars.sloppy'} = 1;
			$self->cmd_vars($graph, "");
			$success = 1;
		} elsif ($cmd =~ /^\s*vars\s+-strict\s*$/) {
			$graph->{'vars.sloppy'} = 0;
			$self->cmd_vars($graph, "");
			$success = 1;
		} elsif ($cmd =~ /^\s*vars(\s+)?(.*)?\s*$/) {
			$success = $self->cmd_vars($graph, $2) 
		}

		# View: view
		$success = $self->cmd_view($graph, $1, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
				$cmd =~ /^\s*view\s*([+-]?[0-9]+)?\s*$/);
		$success = $self->cmd_view($graph, $1, $2) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
				$cmd =~ /^\s*view\s+([0-9]+)-([0-9]+)\s*$/);
		$success = $self->cmd_view_align($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment') &&
				$cmd =~ /^\s*view\s+([a-z][0-9]+)\s*$/);

		# Viewer: viewer
		$success = $self->cmd_viewer($graph, $2) 
			if ($cmd =~ /^\s*viewer(\s+(-e(xample)?|-a(ll)?))?\s*$/);

		# Webmap
		$success = $self->cmd_webmap($graph, $2)
			if ($cmd =~ /^\s*webmap(\s+(\S.*))?$/);

	# ---------- MACROS ----------

		# Macro
		if ($cmd =~ /^\s*(\w+)\s*$/ || $cmd =~ /^\s*(\w+)\s+(.*)\s*$/) {
			my ($x1, $x2) = ($1, $2);
			$x2 = "" if (! defined($x2));
			my $cmd = $self->{'macros'}{$x1};
			my $cmd2 = $cmd || "";
			if ($cmd && $cmd2 =~ /{ARGS}/) {
				$cmd2 =~ s/{ARGS}/$x2/g;
			} elsif ($cmd) {
				$cmd2 .=  " " . ($x2 || "");
			}
			my $fname = $graph->file() || "UNTITLED";
			$cmd2 =~ s/{FILE}/$fname/g;
			if ($cmd) {
				$self->do($cmd2);
				$success = 1;
			}
		}

	# ---------- SPECIAL COMMANDS THAT MUST GO AT THE END ----------


		# Add node: [node] [$pos] $input [$var=$value] ...
		#	"node Han t=XP g=He x=han123 m=han"
		#	" Han t=XP g=He x=han123 m=han"
		if ($cmd =~ /^\s*node\s+-off\s*$/) {
			$success = 1;
			$graph->{'block_nodeadd'} = 1;
		} 
		if ($cmd =~ /^\s*node\s+-on\s*$/) {
			$success = 1;
			$graph->{'block_nodeadd'} = 0;
		}
		$success = $self->cmd_node($graph, $1, $2, $3) 
			if ((! $success) && UNIVERSAL::isa($graph, 'DTAG::Graph') &&
				($cmd =~ /^\s*node\s*([+-]?[0-9]+)?\s+(\S+)((\s+\S+=\S+)*)\s*$/ ||
				$cmd =~ /^\s+()(\S+)\s+((\S+=\S+\s*)*)\s*$/ ||
				((! $success) && $cmd =~ /^\s+()(\S+)()\s*$/)));
	
		# Add edge: [edge] $nodein $etype $nodeout
		#	"edge 12 subj 23"
		#	"12 land 23"
		$success = $self->cmd_edge($graph, $1, $2, $3) 
			if (UNIVERSAL::isa($self->graph(), 'DTAG::Graph') && (
				$cmd =~ /^\s*([+-]?[0-9]+)\s+(\S+)\s+([+-]?[0-9]+)\s*$/ || 
				$cmd =~ /^\s*edge\s+([+-]?[0-9]+)\s+(\S+)\s+([+-]?[0-9]+)\s*$/));

		# Unrecognized input
		error("unrecognized command: $cmd") if (! defined($success));

		# Save command in history, if successful and requested
		$self->term()->addhistory($cmd) if (defined($success) && $history);
	}
}
