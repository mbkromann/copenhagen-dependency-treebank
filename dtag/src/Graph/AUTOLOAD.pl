sub AUTOLOAD {
	use vars qw($AUTOLOAD);
	DTAG::Interpreter::error("non-existent method $AUTOLOAD")
		if ($AUTOLOAD !~ /::DESTROY$/);
	return undef;
}
