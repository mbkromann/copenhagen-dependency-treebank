package FindType;
@FindType::ISA = qw(FindProc);

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

sub print {
	my $self = shift;
	return $self->pprint();
}
