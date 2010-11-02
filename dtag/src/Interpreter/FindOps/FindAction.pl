package FindAction;

use overload
    '""' => \& print;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}

sub ask {
	return 1;
}

sub close {
}

sub print {
	my $self = shift;
	return "" . $self;
}
