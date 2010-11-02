package CostOp;
use strict;

use overload 
	'<'  => \&cost_lt,
	'>'  => \&cost_gt,
	'!=' => \&cost_ne,
	'==' => \&cost_eq,
	'*'  => \&cost_mul,
	'""' => \&print;
	
sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	my $self = [];
	push @$self, @_;
	bless($self, $class);
	return $self;
}

sub print {
	my $self = shift;
	my @args = ();
	foreach my $arg (@$self) {
		if (ref($arg) && $arg->isa("CostOp")) {
			push @args, $arg->print();
		} else {
			push @args, $arg;
		}
	}
	my $name = lc(ref($self));
	$name =~ s/op$//g;
	return $name . "(" . join(", ", @args) . ")";
}


sub cost {
	my $lexicon = shift;
	my $graph = shift;
	my $node = shift;

	return 0;
}

sub cost_eq {
	return EqOp->new(shift, shift);
}


sub cost_ne {
	return NeOp->new(shift, shift);
}

sub cost_lt {
	return LtOp->new(shift, shift);
}

sub cost_gt {
	return GtOp->new(shift, shift);
}

sub cost_str {
	my $self = shift;
	return ref($self);
}

sub cost_mul {
	return MulOp->new(shift, shift);
}

