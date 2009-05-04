# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#


## ------------------------------------------------------------
##  auto-inserted from: LexInput/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::LexInput - DTAG module defining operators used in lexicon files

=head1 DESCRIPTION

DTAG::LexInput - package which defines the operators that can be used
in a lexicon file.

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::LexInput;

# Require submodules
require Exporter;

# Setup class inheritance and exports
@LexInput::ISA = qw(Exporter);
@LexInput::EXPORT = qw(and atype card child comp cost dep diff dist
	fill gov hash is island left lex list lsite not or parent
	phon right self sem set source trans type);

# Create new lexicon object and share it with the Type package
my $lexicon = undef;



## ------------------------------------------------------------
##  auto-inserted from: LexInput/and.pl
## ------------------------------------------------------------

#	and($x1, ..., $xN) := abs($x1) * ... * abs($xN)

sub and {
	return AndOp->new(@_);
}

sub AND {
	return AndOp->new(@_);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/atype.pl
## ------------------------------------------------------------

sub atype {
	return type(undef, @_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/card.pl
## ------------------------------------------------------------

#	card($x) := numeric value of x, cardinality of set
sub card {
	return CardOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/child.pl
## ------------------------------------------------------------

#	child($x) := all children matching $x

sub child {
	return ChildOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/comp.pl
## ------------------------------------------------------------

# comp($type, $edge1=>$comp1, ...)

sub comp {
	return CompOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/cost.pl
## ------------------------------------------------------------

sub cost {
	return CostOp->new(shift);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/cost_eq.pl
## ------------------------------------------------------------

sub cost_eq {
	return EqOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/cost_gt.pl
## ------------------------------------------------------------

sub cost_gt {
	return GtOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/cost_lt.pl
## ------------------------------------------------------------

sub cost_lt {
	return LtOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/cost_mul.pl
## ------------------------------------------------------------

sub cost_mul {
	return MulOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/cost_ne.pl
## ------------------------------------------------------------

sub cost_ne {
	return NeOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/dep.pl
## ------------------------------------------------------------

# 	dep($type) := all dependents matching $type
sub dep {
	return DepOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/diff.pl
## ------------------------------------------------------------

# 	diff($type, $type1, $type2) := all super types of $type1
# 		dominated by $type, but not dominating $type2
sub diff {
	return DiffOp->new(shift, shift, shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/dist.pl
## ------------------------------------------------------------

#	dist($node) := distance to $node, measured as intervening words 
sub dist {
	return DistOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/fill.pl
## ------------------------------------------------------------

# fill($type, $srcpath, $govpath)

sub fill {
	return FillOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/gov.pl
## ------------------------------------------------------------

# 	gov($type) := all governors matching $type
sub gov {
	return GovOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/hash.pl
## ------------------------------------------------------------

sub hash {
	return HashVal->new(@_);
} 

## ------------------------------------------------------------
##  auto-inserted from: LexInput/is.pl
## ------------------------------------------------------------

# 	is($node, $type) := 1 if $node has type $type, 0 otherwise
sub is {
	return IsOp->new(shift, shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/island.pl
## ------------------------------------------------------------

# 	island($type) := all nodes that extract through a child edge of 
#		type $type
sub island {
	return IslandOp->new(shift);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/left.pl
## ------------------------------------------------------------

# 	left($type) := all left landed nodes matching $type
sub left {
	return LeftOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/lex.pl
## ------------------------------------------------------------

sub lex {
	return type(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/lexicon.pl
## ------------------------------------------------------------

sub lexicon {
	return $lexicon;
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/list.pl
## ------------------------------------------------------------

sub list {
	return ListVal->new(@_);
} 

## ------------------------------------------------------------
##  auto-inserted from: LexInput/lsite.pl
## ------------------------------------------------------------

# 	lsite($type) := all landing sites matching $type
sub lsite {
	return LsiteOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/not.pl
## ------------------------------------------------------------

#	not($x) := 1 if abs($x) = 0, 0 otherwise

sub not {
	return NotOp->new(@_);
}

sub NOT {
	return NotOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/or.pl
## ------------------------------------------------------------

#	or($x1, ..., $xN) := abs($x1) + ... + abs($xN)

sub or {
	return OrOp->new(@_);
}

sub OR {
	return OrOp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/parent.pl
## ------------------------------------------------------------

#	parent($x) := all parents matching $x

sub parent {
	return ParentOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/phon.pl
## ------------------------------------------------------------

sub phon {
	return type()->phon(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/regexp.pl
## ------------------------------------------------------------

sub regexp {
	return RegExp->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/right.pl
## ------------------------------------------------------------

# 	right($type) := all right landed nodes matching $type
sub right {
	return RightOp->new(shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/self.pl
## ------------------------------------------------------------

# 	self() := node itself
sub self {
	return SelfOp->new();
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/sem.pl
## ------------------------------------------------------------

# 	sem($node, $type) := {$node} if it has semantic type $t, empty set
# 		otherwise
sub sem {
	return SemOp->new(shift, shift);
}


## ------------------------------------------------------------
##  auto-inserted from: LexInput/set.pl
## ------------------------------------------------------------

sub set {
	return SetVal->new(@_);
} 

## ------------------------------------------------------------
##  auto-inserted from: LexInput/set_lexicon.pl
## ------------------------------------------------------------

sub set_lexicon {
	my $self = shift;
	my $lex = shift;

	if (ref($lex) && UNIVERSAL::isa($lex, 'DTAG::Lexicon')) {
		$lexicon = $lex;
	} else {
		print "Illegal lexicon: $lex\n";
	}
	return $lexicon;
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/source.pl
## ------------------------------------------------------------

sub source {
	return SrcVal->new(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/trans.pl
## ------------------------------------------------------------

sub trans {
	return type(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: LexInput/type.pl
## ------------------------------------------------------------

sub type {
	my $name = $_[0];
	my $type = Type->new(@_);
	my $lexicon = lexicon();

	# Register type name in types-hash, if name is defined
	if (defined($name)) {
		# Print warning if type already exists with that name
		warn("Warning: type $name already declared; old definition deleted.")
			if ((exists $lexicon->{'ntypes'}{$name})
				|| (exists $lexicon->{'types'}{$name}));

		# Register type
		$lexicon->{'ntypes'}{$name} = $type;
	}

	# Return type
	return $type;
}

1;
