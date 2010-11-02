sub save_file {
	my $self = shift;
	my $file = shift;
	my $data = shift;

	# Save data in file
	open(FILE, ">$file");
	print FILE $data;
	close(FILE);
}
	
