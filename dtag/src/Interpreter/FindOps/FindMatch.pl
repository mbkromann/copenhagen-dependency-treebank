package FindMatch;
@FindMatch::ISA = qw(FindProc);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}



