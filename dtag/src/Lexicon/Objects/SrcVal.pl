package SrcVal;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Argument
	my $path = shift;
	my $self = [$path];
	bless($self, $class);
	return $self;
}

sub value {
	my $self = shift;
	my $src = shift;
	my @path = ($self->[0] eq '') ? () : split(/\|/, $self->[0]);

	# Process path
	while (@path) {
		my $child = shift(@path);
		if (UNIVERSAL::isa($src, 'ARRAY') && $child =~ /[0-9]+/) {
			$src = $src->[0+$child];
		} elsif (UNIVERSAL::isa($src, 'HASH')) {
			$src = $src->{$child};
		} else {
			return undef;
		}
	}
	
	# Return value
	return DTAG::Lexicon->copy_obj($src);
}
