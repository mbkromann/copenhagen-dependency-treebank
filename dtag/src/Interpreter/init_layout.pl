sub init_layout {
	my $self = shift;

    # Supply default layout procedures in interpreter:
    # stream|nstyles|estyles|pos|nhide|ehide
    my $sub = sub { return 0 };
    foreach my $t ('stream', 'nhide', 'ehide', 'pos') {
        if (! defined($self->{'layout'}{$t})) {
            $self->{'layout'}{$t} = $sub;
        }
    } 
    $sub = sub { return [] }; 
    foreach my $t ('nstyles', 'estyles') {
        if (! defined($self->{'layout'}{$t})) {
            $self->{'layout'}{$t} = $sub;
        }
    }

	# Return
	return 1;
}
