sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = { };
    bless ($self, $class);

	# Set defaults
	$self->lexicon(undef);
	$self->var('options', {});
	$self->term(Term::ReadLine->new("Terminal"));
	$self->nextcmd("");
	$self->pslabels("msd|gloss");
	$self->fpsfile("/tmp/dtag-$$-$viewer.ps");
	$self->var('goto_context', 5);
	$self->var('loop_count', 0);
	$self->var('matches', {});
	$self->init_layout();
	$self->interactive(1);
	$self->var("tag_segment_ends", sub { $_[0] =~ /<\/[sS]>/ });
	$self->var("todo", []);
	$self->var("relsets", {});

	# Create empty graph
	$self->{'graphs'} = [DTAG::Graph->new($self)];
	$interpreter = $self;

	# Initialize graph
    return $self;
}
