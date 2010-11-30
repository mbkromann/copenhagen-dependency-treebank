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
##  auto-inserted from: Parse/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 DTAG::Parse

=head2 NAME

DTAG::Parse - DTAG parses (subclass of DTAG::Graph)

=head2 DESCRIPTION

DTAG::Parse - subclass of Graph which defines a parse

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Parse;
use DTAG::Graph;
@ISA = ("DTAG::Graph");
use strict;



## ------------------------------------------------------------
##  auto-inserted from: Parse/freeze.pl
## ------------------------------------------------------------

=item $parse->freeze()

Freeze temporary nodes and edges in graph???

=cut

sub freeze {
	my $self = shift;
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/graph.pl
## ------------------------------------------------------------

sub graph {
	my $self = shift;

	# Create new graph
	my $graph = DTAG::Graph->new();

	# Save segments in graph
	foreach my $segment (@{$self->segments()}) {
		
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/input.pl
## ------------------------------------------------------------

=item $parse->input($input) = $input

Get/set input associated with text.

=cut

sub input {
	my $self = shift;
	if (@_) {
		my $input = $self->{'input'} = shift;
		$self->now($input->time0());
	}
	return $self->{'input'};
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/new.pl
## ------------------------------------------------------------

=item Parse->new() = $parse

Create new Parse object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = {
	};

	# Specify class for new object
	bless ($self, $class);

	# Initialize
	$self->parseops([]);
	$self->open_lexemes([]);

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/open_lexemes.pl
## ------------------------------------------------------------

=item $parse->open_lexemes($open) = $open

Get/set list of open lexemes.

=cut

sub open_lexemes {
	my $self = shift;
	$self->{'open_lexemes'} = shift if (@_);
	return $self->{'open_lexemes'};
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/parseop.pl
## ------------------------------------------------------------

=item $parse->parseop($i) = $parseop

Return the $i'th parsing operation.

=cut

sub parseop {
	my $self = shift;
	my $i = shift;
	return $self->parseops()->[$i][0];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/parseop_add.pl
## ------------------------------------------------------------

=item $parse->parseop_add($parseop, $rank) = $parse

Add a new parse operation $parseop with rank $rank.

=cut

sub parseop_add {
	my $self = shift;
	my $parseops = $self->parseops();

	# Read parameters
	my $parseop = shift;
	my $rank = shift;
	$rank = $self->parserank(scalar(@$parseops)-1) + 1
		if (! defined($rank));

	# Add parsing operation
	push @$parseops,
		[$parseop, $rank];
	$self->parseops([sort {$a->[1] <=> $b->[1]} @$parseops]);

	# Return 
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/parseops.pl
## ------------------------------------------------------------

=item $parse->parseops($parseops) = $parseops

Get/set list of parsing operations.

=cut

sub parseops {
	my $self = shift;
	$self->{'parseops'} = shift if (@_);
	return $self->{'parseops'};
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/parserank.pl
## ------------------------------------------------------------

=item $parse->parserank($i) = $rank

Return rank of parsing operation $i.

=cut

sub parserank {
	my $self = shift;
	my $i = shift;
	return $self->parseops()->[$i][1];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/pop_op.pl
## ------------------------------------------------------------

=item $parse->pop_op() = $top

Return top object on stack. ???

=cut

sub pop_op {
	my $self = shift;
	$self->stackhash(undef);
	return pop(@{$self->stack()});
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/push_op.pl
## ------------------------------------------------------------

=item $parse->push_op($op) = $parse

Push new operation onto stack.

=cut

sub push_op {
	my $self = shift;
	push @{$self->stack()}, shift; 
	$self->stackhash(undef);
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/read_segment.pl
## ------------------------------------------------------------

=item $parse->read_segments



=cut

sub read_segments {
	my $self = shift;
	my $n = abs(shift || 1);

	# Check that input stream exists
	my $input = $self->input();
	return error("No input stream provided for parse") 
		if (! defined($input));
	my $time1 = $self->time1();

	# Find open lexemes
	my $openlex = $self->open_lexemes();

	# Find segments
	my $segments = [];
	while ($n > 0) {
		# Find all lexemes starting at this position
		my $lexemes = $input->lookup($time1);
		push @$openlex, @$lexemes;

		# Find segment end
		my $time2 = 1e100;
		if (@$openlex) {
		} else {
			# No open lexemes: resort to $input->next_lexeme()
		}

		# Decrement $n
		--$n;
	}	
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/segments.pl
## ------------------------------------------------------------

sub segments {
	my $self = shift;
	$self->{'segments'} = shift if (@_);
	return $self->{'segments'};
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/stack.pl
## ------------------------------------------------------------

sub stack {
	my $self = shift;
	if (@_) {
		$self->{'stack'} = shift;
		$self->stackhash(undef);
	}
	return $self->{'stack'};
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/stackhash.pl
## ------------------------------------------------------------

sub stackhash {
	my $self = shift;
	$self->{'stackhash'} = shift if (@_);
	return $self->{'stackhash'};
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/time1.pl
## ------------------------------------------------------------

sub time1 {
	my $self = shift;
	$self->{'time1'} = shift if (@_);
	return $self->{'time1'};
}
## ------------------------------------------------------------
##  start auto-insert from directory: .svn
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: tmp
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: tmp
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: .svn
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: Input
## ------------------------------------------------------------
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
##  auto-inserted from: Parse/Input/HEADER.pl
## ------------------------------------------------------------

# This package defines an object representing an input stream (text/speech)

package Input;
use strict;

## ------------------------------------------------------------
##  start auto-insert from directory: .svn
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: tmp
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: tmp
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: .svn
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: Input
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: Lexeme
## ------------------------------------------------------------
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
##  auto-inserted from: Parse/Lexeme/HEADER.pl
## ------------------------------------------------------------

# This package defines an object representing a lexeme.

package Lexeme;
use strict;


# Static variable names used in name2array conversion 
my ($LEXEME_TIME0, $LEXEME_TIME1, $LEXEME_STREAM, $LEXEME_TYPENAME,
		$LEXEME_INPUT, $LEXEME_TYPE, $LEXEME_NOISE) 
	= (0 .. 6);



## ------------------------------------------------------------
##  auto-inserted from: Parse/Lexeme/input.pl
## ------------------------------------------------------------

=item $lexeme->input($input) = $input

Get/set input associated with lexeme.

=cut

sub input {
	my $self = shift;
	$self->[$LEXEME_INPUT] = shift if (@_);
	return $self->[$LEXEME_INPUT];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Lexeme/new.pl
## ------------------------------------------------------------

=item Lexeme->new() = $lexeme

Create new lexeme.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = [];

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Lexeme/noise.pl
## ------------------------------------------------------------

=item $lexeme->noise($noise) = $noise

Get/set lexeme noise variable.

=cut

sub noise {
	my $self = shift;
	$self->[$LEXEME_NOISE] = shift if (@_);
	return $self->[$LEXEME_NOISE];
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Lexeme/stream.pl
## ------------------------------------------------------------

=item $lexeme->stream($stream) = $stream

Get/set lexeme stream variable.

=cut

sub stream {
	my $self = shift;
	$self->[$LEXEME_STREAM] = shift if (@_);
	return $self->[$LEXEME_STREAM];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Lexeme/time0.pl
## ------------------------------------------------------------

=item $lexeme->time0($time0) = $time0

Get/set starting time of lexeme. 

=cut

sub time0 {
	my $self = shift;
	$self->[$LEXEME_TIME0] = shift if (@_);
	return $self->[$LEXEME_TIME0];
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Lexeme/time1.pl
## ------------------------------------------------------------

=item $lexeme->time1($time1) = $time1

Get/set ending time of lexeme.

=cut

sub time1 {
	my $self = shift;
	$self->[$LEXEME_TIME1] = shift if (@_);
	return $self->[$LEXEME_TIME1];
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Lexeme/type.pl
## ------------------------------------------------------------

=item $lexeme->type($type) = $type

Get/set lexeme type object.

=cut

sub type {
	my $self = shift;
	$self->[$LEXEME_TYPE] = shift if (@_);
	return $self->[$LEXEME_TYPE];
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Lexeme/typename.pl
## ------------------------------------------------------------

=item $lexeme->typename($typename) = $typename

Get/set lexeme type name.

=cut

sub typename {
	my $self = shift;
	$self->[$LEXEME_TYPENAME] = shift if (@_);
	return $self->[$LEXEME_TYPENAME];
}

## ------------------------------------------------------------
##  start auto-insert from directory: .svn
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: tmp
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: tmp
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: .svn
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: Lexeme
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: Link
## ------------------------------------------------------------
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
##  auto-inserted from: Parse/Link/HEADER.pl
## ------------------------------------------------------------

# This package defines an object representing a link between segments.

package Link;
use strict;

# Static variable names
my ($LINK_IN, $LINK_OUT, $LINK_TYPENAME, $LINK_DELETE) = (0 .. 3);



## ------------------------------------------------------------
##  auto-inserted from: Parse/Link/delete.pl
## ------------------------------------------------------------

=item $link->delete($delete) = $delete

Get/set deletion variable of link, which indicates whether the link
should be deleted or added to the graph.

=cut

sub delete {
	my $self = shift;
	$self->[$LINK_DELETE] = shift if (@_);
	return $self->[$LINK_DELETE];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Link/in.pl
## ------------------------------------------------------------

=item $link->in($in) = $in

Get/set in-segment of link.

=cut

sub in {
	my $self = shift;
	$self->[$LINK_IN] = shift if (@_);
	return $self->[$LINK_IN];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Link/new.pl
## ------------------------------------------------------------

=item Link->new() = $link

Create new Link object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = []; 

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Link/out.pl
## ------------------------------------------------------------

=item $link->out($out) = $out

Get/set out-segment of link.

=cut

sub out {
	my $self = shift;
	$self->[$LINK_OUT] = shift if (@_);
	return $self->[$LINK_OUT];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Link/typename.pl
## ------------------------------------------------------------

=item $link->typename($typename) = $typename

Get/set typename of link.

=cut

sub typename {
	my $self = shift;
	$self->[$LINK_TYPENAME] = shift if (@_);
	return $self->[$LINK_TYPENAME];
}
## ------------------------------------------------------------
##  start auto-insert from directory: .svn
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: tmp
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: tmp
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: .svn
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: Link
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: Segment
## ------------------------------------------------------------
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
##  auto-inserted from: Parse/Segment/HEADER.pl
## ------------------------------------------------------------

# This package defines an object representing a segment.

package Segment;
use strict;

# Static variable names
my ($SEGMENT_LEXEMES, $SEGMENT_ACTIVE, $SEGMENT_SPAN,
		$SEGMENT_OPTIMAL, $SEGMENT_TIME0, $SEGMENT_TIME1, $SEGMENT_LISTENERS,
		$SEGMENT_TYPENAME)
	= (0 .. 7);


## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/active.pl
## ------------------------------------------------------------

=item $segment->active($active) = $active

Get/set list of active lexemes starting at segment.

=cut

sub active {
	my $self = shift;
	$self->[$SEGMENT_ACTIVE] = shift if (@_);
	return $self->[$SEGMENT_ACTIVE];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/lexemes.pl
## ------------------------------------------------------------

=item $segment->lexemes($lexemes) = $lexemes

Get/set list of lexemes starting at segment.

=cut

sub lexemes {
	my $self = shift;
	$self->[$SEGMENT_LEXEMES] = shift if (@_);
	return $self->[$SEGMENT_LEXEMES];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/listeners.pl
## ------------------------------------------------------------

=item $segment->listeners($listeners) = $listeners

Get/set list of listeners for segment.

=cut

sub listeners {
	my $self = shift;
	$self->[$SEGMENT_LISTENERS] = shift if (@_);
	return $self->[$SEGMENT_LISTENERS];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/new.pl
## ------------------------------------------------------------

=item Segment->new() = $segment

Create new segment.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = []; 

	# Specify class for new object
	bless ($self, $class);

	# Initialize object
	$self->lexemes([]);
	$self->active([]);
	$self->span([]);

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/optimal.pl
## ------------------------------------------------------------

=item $segment->optimal($optimal) = $optimal

Get/set optimal lexeme associated with segment.

=cut

sub optimal {
	my $self = shift;
	$self->[$SEGMENT_OPTIMAL] = shift if (@_);
	return $self->[$SEGMENT_OPTIMAL];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/span.pl
## ------------------------------------------------------------

=item $segment->span($span) = $span

Get/set list of links that span over $segment. ???

=cut

sub span {
	my $self = shift;
	$self->[$SEGMENT_SPAN] = shift if (@_);
	return $self->[$SEGMENT_SPAN];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/time0.pl
## ------------------------------------------------------------

=item $segment->time0($time0) = $time0

Get/set starting time of segment.

=cut

sub time0 {
	my $self = shift;
	$self->[$SEGMENT_TIME0] = shift if (@_);
	return $self->[$SEGMENT_TIME0];
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/time1.pl
## ------------------------------------------------------------

=item $segment->time1($time1) = $time1

Get/set ending time of segment.

=cut

sub time1 {
	my $self = shift;
	$self->[$SEGMENT_TIME1] = shift if (@_);
	return $self->[$SEGMENT_TIME1];
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Segment/typename.pl
## ------------------------------------------------------------

=item $segment->typename($typename) = $typename

Get/set segment type name.

=cut

sub typename {
	my $self = shift;
	$self->[$SEGMENT_TYPENAME] = shift if (@_);
	return $self->[$SEGMENT_TYPENAME];
}

## ------------------------------------------------------------
##  start auto-insert from directory: .svn
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: tmp
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: tmp
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: .svn
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: Segment
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: Text
## ------------------------------------------------------------
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
##  auto-inserted from: Parse/Text/HEADER.pl
## ------------------------------------------------------------

# This package defines an object representing a text input (with
# multiple streams)

package Text;
use strict;

my ($TEXT_INPUTS, $TEXT_LEXICONS, $TEXT_LEXICON, $TEXT_TIME1) = (0..3);

# Maximal length of lexeme
my $LEXEME_MAXLEN = 1000;
my $LOOKAHEAD = 100;

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/input.pl
## ------------------------------------------------------------

=item $text->input($stream, $input) = $input

Get/set input $input for stream $stream.

=cut


# $input = [[$time0, $time1, $string], ...]

sub input {
	my $self = shift;
	my $stream = shift;
	return undef if (! defined($stream));

	# Set input
	my $inputs = $self->inputs();
	if (@_) {
		$inputs->{$stream} = shift;
		$self->[$TEXT_TIME1] = undef;
	}

	# Get input
	return $inputs->{$stream};
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/inputs.pl
## ------------------------------------------------------------

=item $text->inputs($inputs) = $inputs

Get/set input hash associated with text.

=cut

sub inputs {
	my $self = shift;
	if (@_) {
		$self->[$TEXT_INPUTS] = shift;
		$self->[$TEXT_TIME1] = undef;
	}
	return $self->[$TEXT_INPUTS];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/lexicon.pl
## ------------------------------------------------------------

=item $text->lexicon($lexicon) = $lexicon

Get/set default lexicon for text.

=cut

sub lexicon {
	my $self = shift;
	$self->[$TEXT_LEXICON] = shift if (@_);
	return $self->[$TEXT_LEXICON];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/lexicon_stream.pl
## ------------------------------------------------------------

=item $text->lexicon_stream($stream, $lexicon) = $lexicon

Get/set lexicon for stream $stream.

=cut

sub lexicon_stream {
	my $self = shift;
	my $stream = shift || 0;

	$self->[$TEXT_LEXICONS]{$stream} = shift if (@_);
	return $self->[$TEXT_LEXICONS]{$stream} || $self->lexicon();
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/lexicons.pl
## ------------------------------------------------------------

=item $text->lexicons($lexicons) = $lexicons

Get/set lexicon hash for this text.

=cut

sub lexicons {
	my $self = shift;
	$self->[$TEXT_LEXICONS] = shift if (@_);
	return $self->[$TEXT_LEXICONS];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/lookahead.pl
## ------------------------------------------------------------

=item $text->lookahead($lookahead) = $lookahead

Get/set lookahead for text.

=cut

sub lookahead {
	my $self = shift;
	$LOOKAHEAD = shift || 1 if (@_);
	return $LOOKAHEAD;
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/lookup.pl
## ------------------------------------------------------------

=item $text->lookup($time, $stream) = $lexemes

Return list of all lexemes starting at time $time in stream $stream.

=cut

sub lookup {
	my $self = shift;
	my $time = shift;
	my $stream = shift;

	# Find streams
	my $streams = defined($stream) ?  [$stream] : $self->streams();

	# Find substring of input starting at time $time
	my $lexemes = [];
	foreach $stream (@$streams) {
		my $text = substr($self->input($stream) || "", $time, $LEXEME_MAXLEN);
		my $lexicon = $self->lexicon_stream($stream);
		if (! $lexicon) {
			DTAG::Interpreter::error("No lexicon specified in Text->lookup");
			return [];
		}

		# Apply lexicon to all nodes with time0 = $time
		my $list = $lexicon->lookup(lc($text));
		foreach my $pair (@$list) {
			my $lexeme = Lexeme->new();
			$lexeme->time0($time);
			$lexeme->time1($time + length($pair->[0]));
			$lexeme->input($pair->[0]);
			$lexeme->typename($pair->[1]);
			$lexeme->stream($stream);
			push @$lexemes, $lexeme;
		}
	}

	# Return found lexemes
	return $lexemes;
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/new.pl
## ------------------------------------------------------------

=item Text->new() = $text

Create new Text object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = [];

	# Specify class for new object
	bless ($self, $class);
	$self->inputs({});

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/next_lexeme.pl
## ------------------------------------------------------------

=item $text->next_lexeme($time) = $next

Return starting time for next lexeme after time $time.

=cut

sub next_lexeme {
	my $self = shift;
	my $time = shift;
	my $next = $time + 1;
	return ($next >= $self->time1()) ? $next : undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/streams.pl
## ------------------------------------------------------------

=item $text->streams($time0, $time1) = $streams

Return list of stream names occurring in the text after $time0
and before $time1.

=cut

sub streams {
	my $self = shift;
	my $time0 = shift;
	my $time1 = shift;

	return [sort(keys(%{$self->inputs()}))];
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/time0.pl
## ------------------------------------------------------------

=item $text->time0() = $time0

Return starting time of text.

=cut

sub time0 {
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Parse/Text/time1.pl
## ------------------------------------------------------------

=item $text->time1() = $time1

Return ending time of text.

=cut

sub time1 {
	my $self = shift;

	# Find cached value
	my $time1 = $self->[$TEXT_TIME1];
	return $time1 if (defined($time1));

	# Find length of longest input stream
	$time1 = 0;
	foreach my $s (@{$self->streams()}) {
		my $len = length($self->input($s));
		$time1 = $len if ($len > $time1);
	}

	# Return length of longest input stream
	$self->[$TEXT_TIME1] = $time1;
	return $time1;
}
## ------------------------------------------------------------
##  start auto-insert from directory: .svn
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: tmp
## ------------------------------------------------------------
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
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
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
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
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
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: tmp
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: .svn
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: Text
## ------------------------------------------------------------


1;

