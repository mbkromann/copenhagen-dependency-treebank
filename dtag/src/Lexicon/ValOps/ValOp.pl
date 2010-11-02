package ValOp;

use overload
	'""' => \& print;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

	# Arguments
	my $plus = shift;
	my $minus = @_ ? shift : [];
	my $inh = @_ ? shift : 0;

    my $self = [$plus, $minus, $inh];
    push @$self, @_;
    bless($self, $class);
	return $self;
}

sub plus {
	my $self = shift;

	if (@_) {
		$self->[0] = shift;
	}

	return $self->[0];
}

sub minus {
	my $self = shift;

	if (@_) {
		$self->[1] = shift;
	}

	return $self->[1];
}

sub inherit {
	my $self = shift;

	if (@_) {
		$self->[2] = shift;
	}

	return $self->[2];
}

sub print {
	my $self = shift;
	my $type = ref($self);
	$type = "list" if ($type eq "ListVal");
	$type = "set" if ($type eq "SetVal");

	# Print 
	return "$type([" . join(",", @{$self->plus()}) . "]-[" . 
		join(",", @{$self->minus()}) . "], " . $self->inherit() . ")";
}
		
