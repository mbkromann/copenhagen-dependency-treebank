package RegExp;

my $regexps = { };
my $regexpsf = { };

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Arguments
	my $self = [@_];

	# Create new object
	bless($self, $class);
	return $self;
}

sub match_node {
	my $self = shift;
	my $node = shift;
	my $regexp = $self->[1];
	my $field = $self->[2];
	my $sub;

	# Find node value
	my $value = $node->var($self->[0]);
	return undef if (! defined($value));

	# Find field and regexp
	if ($field) {
		my $re = '/^([^[]|\[[^]]*\]){' . $field .'}/';
		$sub = regexpf2code($re);
		$value = &$sub($value) . "";
		print "value=$value field=$field regexp = $re\n";
		return undef if (! defined($value));
	} 

	# Evaluate regexp
	$sub = regexp2code($regexp);
	return &$sub($value);
}

sub regexpf2code {
	my $regexp = shift;
	my $sub = $regexpsf->{$regexp};
	if (! $sub) {
		$sub = $regexpsf->{$regexp}
			= eval("sub { my \$s = shift; \$s =~ $regexp; return \$1; }");
	}
	return $sub;
}

sub regexp2code {
	my $regexp = shift;
	my $sub = $regexps->{$regexp};
	if (! $sub) {
		$sub = $regexps->{$regexp}
			= eval("sub { my \$s = shift; return \$s =~ $regexp; }");
	}
	return $sub;
}


