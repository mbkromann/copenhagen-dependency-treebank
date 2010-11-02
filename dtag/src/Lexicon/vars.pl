sub vars {
	my $self = shift;
	my $node = typeobj(shift);
	my $vars = @_ ? shift : { };

	# Find vars in local node
	map {$vars->{$_} = 1} @{$node->vars()};
	
	# Find vars in super nodes
	foreach my $s (@{$node->get_super()}) {
		$self->vars($s, $vars);
	}

	# Return keys
	return [ keys(%$vars) ];
}
