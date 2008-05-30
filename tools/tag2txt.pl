#!/usr/bin/perl

sub tag2txt {
	my $out = shift;

	# Find TAG files and open outputfile
	open(OTXT, ">$out.txt");
	open(OREF, ">$out.ref");

	# Process each TAG file
	while (my $file = <STDIN>) {
		# Open TAG file
		chomp($file);
		if (! -e "$file") {
			$file =~ s/\.tag/-auto.tag/g;
		}

		open(TAG, "<$file");
		$file =~ /.*\/([0-9]+)-.*\.tag/;
		my $fid = $1;
		my $num = "";

		# Process TAG file
		my $linepos = -1;
		while (my $line = <TAG>) {
			++$linepos;

			# Check whether $line is a word
			if ($line =~ /^.*>(.*)<\/W>\s*/) {
				# Find word
				my $word = lc($1);
				chomp($word);
				$word =~ s/ //g;

				# Print word to files
				print OTXT "$word\n";
				print OREF "$fid:$linepos:$word\n";
			}
		}

		# Close TAG file
		close(TAG);
	}

	# Close files
	close(OTXT);
	close(OREF);
}

tag2txt(@ARGV);
