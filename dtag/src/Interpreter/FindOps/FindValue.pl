package FindValue;
@FindValue::ISA = qw(FindProc);

use overload
    '""' => \& pprint;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}

sub pprint {
	return "FindValue";
}

sub clone {
	my $self = shift;
	my $clone = { 'args' => [@{$self->{'args'}}] };
	bless($clone, ref($self));
	return $clone;
}

sub value {
	return undef;
}

