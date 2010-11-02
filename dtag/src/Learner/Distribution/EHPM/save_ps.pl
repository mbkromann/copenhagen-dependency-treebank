sub save_ps {
	my $self = shift;
	my $file = shift;

	# Save data in file
	open(FILE, ">$file");

	# Find bounding box
	my $bbox = "";
	foreach my $s (@_) {
		$bbox = $s if ($s =~ /^\%\%BoundingBox:/);
	}

	# Open PSMath
	print FILE '%!PS-Adobe-2.0 EPSF-1.2' . "\n$bbox\n";
	print FILE <<'eof_data';

% Procedures for drawing boxes and dots
/box {
	3 index 3 index moveto
	3 index 1 index lineto
	1 index 1 index lineto
	1 index 3 index lineto closepath
	pop pop pop pop
} def
	
/dot {
	newpath 0.5 0 360 arc fill
} def

eof_data

	# Print contents
	print FILE join("\n",@_);

	# Close PSMath
	print FILE <<'eof_data';
% Print rectangle
0 0 100 100 box stroke

%%EOF
eof_data

	# Close file
	close(FILE);
}
