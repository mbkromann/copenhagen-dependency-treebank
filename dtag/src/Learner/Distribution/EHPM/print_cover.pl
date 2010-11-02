sub print_cover {
	my $self = shift;
	my $cover = shift;

	my @pboxes = ();
	foreach my $p (@$cover) {
		my $pbox = $p->var('printbox')
			|| $p->var('printbox',
				$self->hierarchy()->print_box($p->space_box()));
		push @pboxes, $pbox;
	}

	return "[" . join(",", @pboxes) . "]";
}
