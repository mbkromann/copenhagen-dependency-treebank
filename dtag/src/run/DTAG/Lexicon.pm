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
##  auto-inserted from: Lexicon/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Lexicon - DTAG lexicon class

=head1 DESCRIPTION

DTAG::Lexicon - dependency lexicon 

This package defines a lexicon which associates type names with type
references. Each lexicon is a hash table with names and types.

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Lexicon;
use strict;
use MLDBM qw(DB_File);
use DB_File;

# Require submodules
require Exporter;

# Setup class inheritance and exports
@DTAG::Lexicon::ISA = qw(Exporter);
@DTAG::Lexicon::EXPORT = qw(typeobj);

# Set parameters
my $maxrootlength = 20;		# Maximal stored length of phonetic root
my $mark = 0;				# Last mark (used for marking visited nodes)
my $marks = {};				# Mark hash
my $cachesize = 1000;		# Size of type cache


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/cache_clear.pl
## ------------------------------------------------------------

sub cache_clear {
	my $self = shift;

	$self->{'cache'} = [];
	$self->{'cache_indx'} = {};
	$self->{'cache_pos'} = 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/cache_del.pl
## ------------------------------------------------------------

sub cache_del {
	my $self = shift;
	my $pos = shift;

	# Delete type stored in current position of cache 
	my $oldtype = $self->{'cache'}[$pos];
	if (defined($oldtype)) {
		# Find name of type and corresponding position in cache
		my $oldname = $oldtype->get_name();
		my $oldpos = $self->{'cache_indx'}{$oldname} || -1;

		# Delete old type if $oldpos coincides with $pos (ie, no newer
		# reference exists in the cache)
		if ($oldpos == $pos) {
			delete $self->{'cache_indx'}{$oldname};
		}
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/clear.pl
## ------------------------------------------------------------

sub clear {
	my $self = shift;
	
	# Delete all tied lists in lexicon
	foreach my $list ('db_phon') {
		my $listobj = $self->{$list};
		while ($listobj->length()) {
			$listobj->pop();
		};
	}

	# Delete all tied hashes in lexicon
	foreach my $hash ('roots', 'types', 'phonhash', 'relations',
			'super', 'sub') {
		my $hashobj = $self->{$hash};
		while (my ($key, $value) = each(%$hashobj)) {
			delete $hashobj->{$key};
		}
	}

	# Delete phonsub, utypes, ntypes
	$self->{'phonsub'} = {};
	$self->{'utypes'} = {};
	$self->{'ntypes'} = {};

	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/close.pl
## ------------------------------------------------------------

sub close {
	my $self = shift;

	# Delete references to tied objects
	foreach my $var ('db_phon', 'db_root', 'db_type', 'db_phonh',
			'db_rel', 'db_super', 'db_sub') {
		$self->{$var} = undef;
	}

	# Untie tied objects
	foreach my $var ('roots', 'types', 'phonops', 'phonhash', 'relations', 
			'super', 'sub') {
		my $obj = $self->{$var};
		$self->{$var} = undef;
		untie(%$obj);
		$self->{$var} = undef;
	}

	# Delete all hash elements
	foreach my $hashname (keys(%$self)) {
		my $hash = $self->{$hashname};
		if (ref($hash) && UNIVERSAL::isa($hash, 'HASH')) {
			while (my ($key, $val) = each(%$hash)) {
				delete $hash->{$key};
			}
		}
		delete $self->{$hashname};
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/compile.pl
## ------------------------------------------------------------

sub compile {
	my $self = shift;

	# Retrieve hashes
	my $utypes = $self->{'utypes'};
	my $ntypes = $self->{'ntypes'};

	# Compile regular expressions in phonhash
	$self->compile_phonh();

	# Delete all new types from database
	while (my ($key, $value) = each(%$ntypes)) {
		# Find type and compile it
		delete $self->{'types'}{$key};
	}

	# Compile all new types in lexicon, and copy them into 'types'-hash
	while (my ($key, $value) = each(%$ntypes)) {
		# Find type and compile it
		$self->compile_type($value);
	}

	# Delete all types in the ntypes list
	$self->{'ntypes'} = {};

	# Compile subtypes, super types, and word counts
	$self->compile_subtypes();
	$self->compile_supertypes();
	#$self->compile_count();

	# Find undefined types

	# Print error message with undefined types
	if (%$utypes) {
		error("undefined types: " 
			. join(" ", sort(keys(%$utypes))));
	}

	# Clear cache
	$self->cache_clear();
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/compile_count.pl
## ------------------------------------------------------------

sub compile_count {
	my $self = shift;
	$| = 1;

	# Delete counts for all super types
	foreach my $type (keys(%{$self->{'sub'}})) {
		my $tobj = $self->{'types'}{$type};
		next() if (! defined($tobj));
		delete $tobj->{'count'};
		$self->set_type($type, $tobj);
	}

	# Go through all types
	foreach my $type (keys(%{$self->{'sub'}})) {
		$self->compile_count_type($type);
	}
}

sub compile_count_type {
	my $self = shift;
	my $type = shift;

	# Return 0 if type does not exist
	my $tobj = $self->{'types'}{$type};
	return 0 if (! defined($tobj));

	# Return count if stored for type
	my $count = $tobj->lvar('count');
	return ($count || 0) if (defined($count));

	# Compute count as sum of counts for all subtypes
	$count = 0;
	foreach my $sub (@{$self->subtypes($type)}) {
		$count += $self->compile_count_type($sub);
	}

	# Store count in type
	$tobj->lvar('count', $count);
	$self->set_type($type, $tobj);

	# Return sum
	return $count;
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/compile_phonh.pl
## ------------------------------------------------------------

sub compile_phonh {
	my $self = shift;
	my $phonhash = $self->{'phonhash'};
    my $phonsub = $self->{'phonsub'};

    # Compile regular expressions in phonhash into phonsub
    foreach my $op (keys %$phonhash) {
		my $code = 'sub { my $s = shift; $s =~ ' 
			.  $phonhash->{$op} 
			. '; return $s;}';
        $phonsub->{$op} = eval($code);
    }

	# Return
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/compile_subtypes.pl
## ------------------------------------------------------------

sub compile_subtypes {
	my $self = shift;
	my $subtypes = {};

	# Clear subtype and submatch hash
	foreach my $t (keys(%{$self->{'sub'}})) {
		delete $self->{'sub'}{$t};
	}

	# Process all type names in lexicon
	my ($supers, $super);
	foreach my $type (@{$self->types() || []}) {
		# Get super types for type
		$supers = typeobj($type)->get_super();

		# Record type as subtype of each super type
		foreach my $super (@$supers) {
			# Ensure entry in $sub exists
			$subtypes->{$super} = [] if (! defined($subtypes->{$super}));

			# Add type to subtype list
			push @{$subtypes->{$super}}, $type;
		}
	}

	# Record subtype-list for each type
	my $typeobj;
	foreach my $type (keys(%$subtypes)) {
		$self->{'sub'}{$type} = $subtypes->{$type};
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/compile_supertypes.pl
## ------------------------------------------------------------

sub compile_supertypes {
	my $self = shift;

	# Delete super type hash
	foreach my $type (keys(%{$self->{'super'}})) {
		delete $self->{'super'}{$type};
	}

	# Process all type names in lexicon
	foreach my $type (@{$self->types() || []}) {
		# Get super types for type
		$self->compile_supertype($type); 
	}
}

sub compile_supertype {
	my $self = shift;
	my $type = shift;

	# Fail if type is already compiled
	return 1 if ($self->{'super'}{$type});

	# Retrieve type, and fail if type does not exist
	my $typeobj = $self->get_type($type);
	return 0 if (! $typeobj);

	# Retrieve super types of $type
	my $supers = $typeobj->get_super();
	my $list = [];
	my $exists;
	foreach my $s (@$supers) {
		# Ensure that each super type has been compiled
		if (! $self->{'super'}->{$s}) {
			$exists = $self->compile_supertype($s) 
		} else {
			$exists = 1;
		}

		# Add super type and its super types to list
		push @$list, $s, @{$self->{'super'}->{$s}}
			if ($exists);
	}

	# Save super types of $type
	$self->{'super'}{$type} = [uniq(@$list)];

	# Return with success
	return 1;
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/compile_type.pl
## ------------------------------------------------------------

sub compile_type {
	my $self = shift;
	my $type = shift;
	my $name = $type->get_name() || "";

	# Return if type is compiled already
	return if ($name && $self->{'types'}{$name});

	# Compile all super types
	foreach my $s (@{$type->get_super()}) {
		my $stype = $self->{'ntypes'}{$s};
		$self->compile_type($stype)
			if ($stype);
	}

	# Find root string and transformations
	my @phon = @{$type->var('phon') || []};
	my $trans = $type->var('trans') || {};

	# Find transformed roots of lexical item
	if (scalar(@phon)) {
		# Find dynamic type strings
		my @phons = ([@phon]);
		foreach my $t (keys(%$trans)) {
			my @tphon = @{$trans->{$t}->var('phon') || []};
			push @phons, ($trans->{$t}->var('phon') || []);
		}

		# Calculate roots
		my @roots = $self->phonroots(@phons);

		# Store roots in type
		$type->var('_roots', [@roots]);

		# Enter roots into lookup hash
		if ($name) {
			foreach my $r (@roots) {
				my $list = $self->get_root($r);
				$list = [] if (ref($list) ne "ARRAY");
				push @$list, $name;
				$self->set_root($r, $list);
			}
		}
	}

	# Compile all local transformation types
	$trans = $type->lvar('trans') || DTAG::LexInput::hash();
	foreach my $t (keys(%{$trans->plus() || {}})) {
		$self->compile_type($trans->plus()->{$t});
	}

	# Compile match-functions
	if ($type->lvar('_match') && $name) {
		foreach my $s (@{$type->get_super()}) {
			my $stype = $self->get_type($s);
			my $submatches = $stype->submatches();
			if (! grep {$_ eq $s} @$submatches) {
				push @$submatches, $name;
				$stype->submatches($submatches);
				$self->set_type($s, $stype);
			}
		}
	}

	# Store compiled type
	if ($name) {
		$self->set_type($name, $type);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/copy_obj.pl
## ------------------------------------------------------------

sub copy_obj {
	my $self = shift;
	my $obj = shift;
	my $src = shift;

	# Copy object
	my $copy = undef;
	if (! ref($obj)) {
		# $obj is atomic: do nothing
		$copy = $obj;
	} elsif (UNIVERSAL::isa($obj, "ARRAY")) {
		# $obj is an array reference
		$copy = [];
		bless($copy, ref($obj)) if (ref($obj) ne "ARRAY");

		# Copy array elements
		for (my $i = 0; $i < scalar(@$obj); ++$i) {
			if (ref($src) && UNIVERSAL::isa($obj->[$i], "SrcVal")) {
				# Replace src value with 
				$copy->[$i] = $obj->[$i]->value($src);
			} else {
				$copy->[$i] = $self->copy_obj($obj->[$i], $src);
			}
		}
	} elsif (UNIVERSAL::isa($obj, "HASH")) {
		# $obj is a hash reference
		$copy = {};
		bless($copy, ref($obj)) if (ref($obj) ne "HASH");

		# Copy hash entries
		foreach my $key (keys(%$obj)) {
			if (ref($src) && UNIVERSAL::isa($obj->{$key}, "SrcVal")) {
				# Replace src value with its value
				$copy->{$key} = $obj->{$key}->value($src);
			} else {
				$copy->{$key} = $self->copy_obj($obj->{$key}, $src);
			}
		}
	} else {
		# $obj is some other blessed object
		$copy = $obj;
	}

	# Return copy
	return $copy;
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/copy_type.pl
## ------------------------------------------------------------

# $copy = $lexicon->copy_type($types, $source)

sub copy_type {
	my $self = shift;
	my $types = shift;
	my $source = shift;

	# Convert singular type into array
	$types = [ $types ]
		if (! UNIVERSAL::isa($types, 'ARRAY'));

	# Create empty copy
	my $copy = Type->new();

	# Find variables used in type
	my $vars = { '_super' => 1, '_name' => 1, '_roots' => 1 };
	foreach my $t (@$types) {
		$self->vars($t, $vars);
	}

	# Copy variable values into copy
	foreach my $v (keys(%$vars)) {
		my ($inh, $value) = $self->xvar($types, $v);
		$copy->var($v, $self->copy_obj($value, $source)) if (defined($value));
	}

	# Return copy
	return $copy;
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/error.pl
## ------------------------------------------------------------

sub error {
	print "\aERROR! " . join("", @_) . "\n";
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/get_phonop.pl
## ------------------------------------------------------------

sub get_phonop {
	my $self = shift;
	my $name = shift;
	return $self->{'phonops'}{$name};
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/get_root.pl
## ------------------------------------------------------------

sub get_root {
	my $self = shift;
	my $name = shift;
	return $self->{'roots'}{$name};
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/get_type.pl
## ------------------------------------------------------------

sub get_type {
	my $self = shift;
	my $name = shift;
	my $indx = $self->{'cache_indx'}{$name};
	my $pos = $self->{'cache_pos'} || 0;
	my $type;

	# Check whether type is in cache
	if (defined($indx)) {
		# Type is already stored in cache
		$type = $self->{'cache'}[$indx];
	} else {
		# Fetch type from tied hash
		$type = $self->{'types'}{$name};
	}

	# Update cache if $type is defined
	if (defined($type)) {
		# Delete old type at position $pos
		$self->cache_del($pos);

		# Store new type in cache
		$self->{'cache_indx'}{$name} = $pos;
		$self->{'cache'}[$pos] = $type;
		$pos = ($pos + 1) % ($self->{'cache_size'});
		$self->{'cache_pos'} = $pos;
	}

	# Return type
	return $type;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/intsct.pl
## ------------------------------------------------------------

sub intsct {
	my $self = shift;
	my $type1 = shift;
	my $type2 = shift;

	# Find intersection of $type1 and $type2
	if (grep {$_ eq $type2} ($type1, @{$self->{'super'}{$type1}})) {
		# $type1 is a subtype of $type2
		return $type1;
	} elsif (grep {$_ eq $type1} ($type2, @{$self->{'super'}{$type2}})) {
		# $type2 is a subtype of $type1
		return $type2;
	} else {
		# $type1 and $type2 are unrelated
		return undef;
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/isatype.pl
## ------------------------------------------------------------

sub isatype {
	my $self = shift;
	my $type = shift;
	my $tspec = shift;

	# Check whether $tspec is atomic or composite
	if (ref($tspec) && $tspec->isa("TypeOp")) {
		# Composite
		return $tspec->value($self, $type);
	} else {
		# Atomic
		return $self->super($type, $tspec);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/lookup.pl
## ------------------------------------------------------------

sub lookup {
	my $self = shift;
	my $input = shift;
	my @lex = ();

	# Find roots matching $input
	my @roots = ();
	my $rhash = $self->{'roots'};
	my $list;
	for (my $i = 1; $i <= $maxrootlength; ++$i) {
		my $substr = substr($input, 0, $i);
		$list = $rhash->{$substr};
		push @roots, @$list if $list;
	}
	@roots = uniq(@roots);

	# Find transformations matching $input
	$list = [];
	foreach my $root (@roots) {
		$self->lookup_type($input, $root, $list);
	}

	# Return ($lex1, $lex2, ...)
	return $list;
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/lookup_type.pl
## ------------------------------------------------------------

sub lookup_type {
	# Enter parameters
	my $self = shift;
	my $input = shift;
	my $typename = shift;
	my $type = typeobj($typename);
	my $list = shift || [];
	my $phon = shift || [];
	my $name = shift || $type->get_name(); 

	# Split type's phon-list into stem transformation and
	# concatenative morpheme, and find transformed stem.
	my ($sphon, $cphon) = $self->phon_split(@{$type->var('phon') || []});
	my $tstem = $self->phon2str(@$phon, @$sphon);

	# Input must match transformed stem plus some root; otherwise
	# just return
	my $match = 0;
	foreach my $root (@{$type->var('_roots') || []}) {
		my $str = $tstem . $root;
		if ($str eq substr($input, 0, length($str))) {
			$match = 1;
			last;
		}
	}
	return if (! $match);

	# Add type itself to list of matches if it matches $input
	my $str = $self->phon2str(@$phon, @$sphon, @$cphon);
	if ($str eq substr($input, 0, length($str))) {
		push @$list, [$str, $name];
	}
	
	# Proceed recursively with all transformed types
	my $trans = $type->var('trans');
	foreach my $t (sort(keys(%$trans))) {
		$self->lookup_type($input, $trans->{$t}, $list, 
			[@$phon, @$sphon, @$cphon], "$name|$t");
	}

	# Return list
	return $list;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/lookup_word.pl
## ------------------------------------------------------------

sub lookup_word {
	my $self = shift;
	my $input = shift;

	# Find lexemes matching beginning of input, and retrieve only
	# lexemes matching entire input
	my $list = [];
	foreach my $pair (@{$self->lookup($input)}) {
		push @$list, $pair->[1]
			if ($pair->[0] eq $input);
	}

	# Return
	return $list;
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/mark.pl
## ------------------------------------------------------------

sub mark {
	my $self = shift;
	my $type = shift;
	my $name = $type->get_name() || "";

	# Set mark, if argument provided
	if (@_) {
		$self->marks()->{$name} = shift;
	}

	# Return mark
	return $self->marks()->{$name} || -1;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/marks.pl
## ------------------------------------------------------------

sub marks {
	return $marks;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/name.pl
## ------------------------------------------------------------

sub name {
	my $self = shift;
	$self->{'name'} = shift if (@_);
	return $self->{'name'};
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/new.pl
## ------------------------------------------------------------

# phonops (phon = DB_File): phonetic substitutions (primary)
# roots (root = MLDBM): root morphemes for lexical types
# types (type = MLDBM): lexical types
# names (name = DB_File): type name to type number hash
# utypes (-): uncompiled types (temporary)???
# phonhash (-): phonetic operations (auto-generated)
# ntypes (-): new types (temporary)???
# phonsub (-): phonetic operations as subroutines

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Check filename argument 
	my $file = shift; 
	return error("Illegal lexicon name: $file\n") if (! $file);

	# Open DB databases
	my @dblist_phon;
	my %dbhash_phon;
	my %dbhash_root;
	my %dbhash_type;
	my %dbhash_rel;
	my %dbhash_super;
	my %dbhash_sub;
	my $db_phon = tie(@dblist_phon, 'DB_File', "$file.phon.db",
		O_RDWR|O_CREAT, 0666, $DB_RECNO)
		or return error("Cannot open DB_File $file.phon.db : $!");
	my $db_phonh = tie(%dbhash_phon, 'MLDBM', "$file.phonh.db")
		or return error("Cannot open DB_File $file.phonh.db : $!");
	my $db_root = tie(%dbhash_root, 'MLDBM', "$file.root.db")
		or return error("Cannot open DB_File $file.root.db : $!");
	my $db_type = tie(%dbhash_type, 'MLDBM', "$file.type.db")
		or return error("Cannot open DB_File $file.type.db : $!");
	my $db_rel = tie(%dbhash_rel, 'MLDBM', "$file.rel.db")
		or return error("Cannot open DB_File $file.rel.db : $!");
	my $db_super = tie(%dbhash_super, 'MLDBM', "$file.super.db")
		or return error("Cannot open DB_File $file.super.db : $!");
	my $db_sub = tie(%dbhash_sub, 'MLDBM', "$file.sub.db")
		or return error("Cannot open DB_File $file.sub.db : $!");

	# Create self
	my $self = { 
		'db_phon' => $db_phon,			# reference to phon-tier
		'db_root' => $db_root,			# reference to root-tier
		'db_type' => $db_type,			# reference to type-tier
		'db_phonh' => $db_phonh,		# reference to phonh-tier
		'db_rel' => $db_rel,			# reference to relation data
		'db_super' => $db_super,		# reference to super types
		'db_sub' => $db_sub,			# reference to sub types
		'phonops' => \@dblist_phon,		# phonops tied array-ref
		'roots' => \%dbhash_root,		# roots tied hash-ref
		'types' => \%dbhash_type,		# types tied hash-ref
		'phonhash' => \%dbhash_phon,	# compiled phonops tied hash-ref
		'relations' => \%dbhash_rel,	# relations to be learned
		'super' => \%dbhash_super, 		# all super types
		'sub' => \%dbhash_sub,			# all sub types
		'phonsub' => {},				# compiled phonop-procedures
		'utypes' => {},					# undefined types
		'ntypes' => {},					# new types
		'cache' => [],					# cache of types
		'cache_pos' => 0,				# cache position
		'cache_indx' => {},				# cache index
		'cache_size' => 1000, 			# cache size
	};

	# Specify class for new object
	bless ($self, $class);
	DTAG::LexInput::set_lexicon(0, $self);

	# Compile phon hashes
	$self->compile_phonh();

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/newmark.pl
## ------------------------------------------------------------

sub newmark {
	++$mark;
	$marks = {};
	return $mark;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/paradigm.pl
## ------------------------------------------------------------

sub paradigm {
	my $self = shift;
	my $type = typeobj(shift);
	my $name = shift || ($type ? $type->get_name() : "???");
	my $phons = shift || [];
	my $paradigm = shift || {};

	# Return if $type does not exist
	return $paradigm if (! $type);

	# Print all phoneme / type pairs associated with type
	$phons = [@$phons, @{$type->var('phon') || []}];
	my $phoneme = $self->phon2str(@$phons);
	
	# Add word to paradigm
	if (UNIVERSAL::isa($paradigm->{$phoneme}, 'ARRAY')) {
		push @{$paradigm->{$phoneme}}, $name;
	} else {
		$paradigm->{$phoneme} = [$name];
	}

	# Proceed recursively with all transformed types
	my $trans = $type->var('trans') || {};
	foreach my $t (sort(keys(%$trans))) {
		my $ttype = $trans->{$t};
		$self->paradigm($ttype, $name . "|$t", $phons, $paradigm);
	}

	# Return string representation
	return $paradigm;
}

sub paradigm_string {
	my $self = shift;
	my $type = shift;

	# Retrieve paradigm
	my $paradigm = $self->paradigm($type);

	# Convert paradigm to string
	my $str = "";
	foreach my $phon (sort(keys(%$paradigm))) {
		$str .= sprintf('%-20s %s' . "\n", 
			$phon, 
			join(" ", @{$paradigm->{$phon}})); 
	}

	# Return
	return $str;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/path2type.pl
## ------------------------------------------------------------

# $type ::= $lexicon->path2type($path, $source)


# $L->path2type("mand:n1|pl|def", undef)
# $L->path2type(["pl", "def"], {...mand:n1...})

sub path2type {
	my $self = shift;
	my $path = shift;
	my $source = shift || undef;

	# Convert path into array
	if (! UNIVERSAL::isa($path, 'ARRAY')) {
		$path = [split(/\|/, $path)];
	}

	# Find original root type
	my $root = undef;
	my $next = shift(@$path);
	if ($source) {
		# Copy transformed type
		$root = $self->copy_type(
			[$source, $source->var('trans')->{$next}], $source);

		# Name of transformed is name of source plus "|$next"
		$root->lvar('_name', 
			($source->lvar('_name') || '') . '|' . $next);

		# Super types of transformed are defined by xsuper
		$root->lvar('_super', $root->lvar('xsuper') || []);
	} elsif ($root = typeobj($next)) {
		# Copy lexical type
		$root = $self->copy_type($root);
	} else {
		return undef;
	}

	# Return result
	if (@$path) {
		# Path is still non-empty; root becomes new source
		return $self->path2type($path, $root);
	} else {
		# Path is empty: root is the result

		# Clean up: delete 'trans' and 'roots' variables, as they are
		# irrelevant in a compiled type (= $root)
		#$root->lvar('trans', undef);
		#$root->lvar('_roots', undef);
		#$root->lvar('_mark', undef);
		#$root->lvar('phon', undef);

		return $root;
	}
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/phon2str.pl
## ------------------------------------------------------------

# $lexicon->phon2str($phon1, ..., $phon1): $string

sub phon2str {
	my $lexicon = shift;
	my $phonsub = $lexicon->{'phonsub'};

	# Strings
	my @strs  = ();
	my $str   = '';		# read-write string

	# Process phonetic operations
	while (@_) {
		# Read next operation
		my $op = shift;

		# Rewrite operator by phonetic operator resolution
		my $newop = $phonsub->{$op};
		$op = $newop if (UNIVERSAL::isa($newop, 'CODE'));

		# Process phonetic operator
		if (UNIVERSAL::isa($op, 'CODE')) {
			$str = &$op($str);
		} elsif ($op =~ /s\/.*\/.*\//) {
			# Replacement-transformation
			eval('$str =~ ' . $op);
		} else {
			push @strs, $str;
			$str = $op;
		}
	}
	push @strs, $str;

	# Return result
	return join('', @strs);
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/phon_compile.pl
## ------------------------------------------------------------

sub phon_compile {
	my $self = shift;
	my $hash = $self->phonhash();
	my $phonsub = $self->{'phonsub'};

	while (@_) {
		my $phon = shift;
		my $key = $phon;
		foreach my $op (@{$self->phonops()}) {
			eval('$phon =~ ' . $op);
		}
		if ($phon ne $key) {
			$hash->{$key} = $phon;
		}
	}
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/phon_split.pl
## ------------------------------------------------------------

# $lexicon->phon_split($phon1, ..., $phon1): (\@stemtrans, \@root)

sub phon_split {
	my $lexicon = shift;
	my $phonsub = $lexicon->{'phonsub'};

	# Strings
	my @strans = ();
	my @root = ();

	# Process phonetic operations
	while (@_) {
		# Read next operation
		my $op = shift;

		# Rewrite operator by phonetic operator resolution
		my $newop = $phonsub->{$op} || $op;

		# Process phonetic operator
		if (UNIVERSAL::isa($newop, 'CODE') || $newop =~ /s\/.*\/.*\//) {
			# Stem transformation
			push @strans, $op;
		} else {
			unshift @_, $op;
			last;
		}
	}

	# Return result
	return ([@strans], [@_]);
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/phonhash.pl
## ------------------------------------------------------------

sub phonhash {
	my $self = shift;
	return $self->{'phonhash'};
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/phonop.pl
## ------------------------------------------------------------

sub phonop {
	my $self = shift;
	my $src = shift;
	my $dst = shift;

	# Escape "/" in $src and $dst
	$src =~ s/\//\\\//g;
	$dst =~ s/\//\\\//g;

	# Create new replacement-pattern
	my $pattern = 's/^' . $src . '$/' . $dst . '/';

	# Add new pattern to phonops-list
	push @{$self->{'phonops'}}, $pattern;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/phonops.pl
## ------------------------------------------------------------

sub phonops {
	my $self = shift;
	$self->{'phonops'} = shift if (@_);
	return $self->{'phonops'};
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/phonroots.pl
## ------------------------------------------------------------

# phonroots($lexicon, [phons], [tphons1], [tphons2], ...)

sub phonroots {
	my $self = shift;
	my $phons = shift;
	my $roots = { };
	my $hash = $self->{'phonsub'};

	# Add root
	my $base = $self->phon2str(@$phons);
	$roots->{$base} = 1;

	# Process 
	foreach my $tphons (@_) {
		# Find root-changing phons
		my @rphons = ();
		foreach my $p (@$tphons) {
			if ($hash->{$p} || $p =~ '/^s\/.*\/.*\/$/') {
				push @rphons, $p;
			} else {
				last;
			}
		}

		# Add root
		my @myphons = (@$phons, @rphons);
		$self->phon_compile(@myphons);
		my $root = $self->phon2str(@myphons);
		if ($root !~ /^$base.*$/o) {
			$roots->{$self->phon2str(@myphons)} = 1;
		}
	}

	# Return roots
	return uniq(sort(keys(%$roots)));
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/print.pl
## ------------------------------------------------------------

sub print {
	my $string = "";

	# Print all types in the lexicon
	foreach my $type (sort(keys %{DTAG::LexInput->lexicon()->{'types'}})) {
		$string .= DTAG::LexInput->lexicon()->{'types'}{$type}->print() . "\n\n";
	}

	# Return
	return $string;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/set_phonop.pl
## ------------------------------------------------------------

sub set_phonop {
	my $self = shift;
	my $name = shift;
	my $phonop = shift;

	return $self->{'phonops'}{$name} = $phonop;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/set_root.pl
## ------------------------------------------------------------

sub set_root {
	my $self = shift;
	my $name = shift;
	my $root = shift;

	return $self->{'roots'}{$name} = $root;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/set_type.pl
## ------------------------------------------------------------

sub set_type {
	my $self = shift;
	my $name = shift;
	my $type = shift;

	# Delete type from cache, if it has been cached
	my $pos = $self->{'cache_indx'}{$name};
	$self->cache_del($pos) if (defined($pos));

	# Set new type, and return
	return $self->{'types'}{$name} = $type;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/subtypes.pl
## ------------------------------------------------------------

sub subtypes { 
	my $self = shift;
	my $type = shift;
	return $self->{'sub'}{$type} || [];
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/super.pl
## ------------------------------------------------------------

sub super {
	my $self = shift;
	my $type = typeobj(shift);
	my $name = shift;
	my $mark = @_ ? shift : $self->newmark();
	
	# Return 0 if $type does not exist, or if $type already bears $mark
	return 0 if (! $type);

	# Return 1 if $type has name $name
	if ($type->get_name() eq $name) {
		return 1;
	}

	# Examine super types
	if ($self->mark($type) != $mark) {
		foreach my $s (@{$type->get_super()}) {
			if ($self->super($s, $name, $mark)) {
				return 1;
			}
		}
		$self->mark($type, $mark);
	}

	# Otherwise return 0
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/supertypes.pl
## ------------------------------------------------------------

sub supertypes {
	my $self = shift;
	my $type = shift;
	return $self->{'super'}{$type} || [];
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/typeobj.pl
## ------------------------------------------------------------

sub typeobj {
	my $arg = shift;

	if (ref($arg) && UNIVERSAL::isa($arg, "Type")) {
		return $arg;
	} elsif ($arg) {
		my $lexicon = DTAG::LexInput->lexicon();
		return $lexicon->get_type($arg) 
			|| $lexicon->{'ntypes'}{$arg};
	} else {
		return undef;
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/types.pl
## ------------------------------------------------------------

sub types {
	my $self = shift;

	# Return list with all types
	return [sort(keys(%{$self->{'types'}}))];
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/typespec.pl
## ------------------------------------------------------------

sub typespec {
	my $input = shift;
	my $obj1 = shift;
	
	# Left argument not provided
	if (! defined($obj1)) {
		my ($obj, $rest) = typespecl($input);
		if (!defined($obj)) {
			return (undef, $input);
		} elsif ($rest =~ /^([-+|].+)$/) {
			return typespec($1, $obj);
		} else {
			return ($obj, $rest);
		}
	}

	# Left argument provided
	else {
		# Input starts with binary operator "-+|"
		if ($input =~ /^([-+|])(.+)$/) {
			my $op = $1;
			my ($obj2, $rest2) = typespecl($2);
			return (defined($obj1) && defined($obj2))
				? typespec($rest2, 
					($op eq "+") 
						? TPlusOp->new($obj1, $obj2)
						: ($op eq "-") 
							? TMinusOp->new($obj1, $obj2)
							: TOrOp->new($obj1, $obj2))
				: (undef, $input);
		} else {
			return defined($obj1)
				? ($obj1, $input)
				: (undef, $input);
		}
	} 
}

sub typespecl {
	my $input = shift;

	# Input starts with "("
	if ($input =~ /^\((.+)$/) {
		my ($obj, $rest) = typespec($1);
		if ($rest =~ /^\)(.*)$/) {
			return ($obj, $1);
		} else {
			return (undef, $input);
		}
	}

	# Input starts with "-"
	elsif ($input =~ /^-(.+)$/) {
		my ($obj, $rest) = typespecl($1);
		return defined($obj) 
			? (TNegOp->new($obj), $rest)
			: (undef, $input);
	}

	# Input starts with ' or "
	elsif ($input =~ /^'([^']*)'(.*)$/) {
		return ($1, $2);
	} elsif ($input =~ /^"([^"]*)"(.*)$/) {
		return ($1, $2);
	}

	# Input is a type name
	elsif ($input =~ /^([^-+|)(]+)(.*)$/) {
		return ($1, $2);
	}

	# Faulty input
	else {
		return (undef, $input);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/uniq.pl
## ------------------------------------------------------------

sub uniq {
	my $hash = {};
	my @uniq;

	while (@_) {
		my $arg = shift;
		if (! $hash->{$arg}) {
			push @uniq, $arg;
			$hash->{$arg} = 1;
		}
	}

	return @uniq;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/vars.pl
## ------------------------------------------------------------

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

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/xvar.pl
## ------------------------------------------------------------

# ($valtype, $value) = $lexicon->xvar($types, $var, $valtype, $value, $mark)

sub xvar {
	my $self = shift;
	my $types = shift;
	my $var = shift;
	my $typename;

	# Examine whether $types is a single type or a type chain
	my $type;
	my $chain = [];
	if (UNIVERSAL::isa($types, 'ARRAY')) {
		$types = [@$types];
		$typename = pop(@$types);
		$type = typeobj($typename);
		$chain = $types;
	} else {
		$typename = $types;
		$type = typeobj($typename);
	}

	# Find $valtype and $value
	my $valtype = @_ ? ((~ 8) & shift) : 0;
	my $value = @_ ? shift : undef;
	my $mark = @_ ? shift : $self->newmark();

	# Exit if type does not exist
	if (! $type) {
		return ($valtype, $value);
	}

	# Exit if type already has mark, or update mark
	if ($self->mark($type) == $mark) {
		return ($valtype, $value);
	} else {
		$self->mark($type, $mark);
	}

	# Retrieve local value
	my $lvaltype = 0;
	my $lvalue = $type->lvar($var);
	my $inherit = 1;
	if (defined $lvalue) {
		if (! (ref($lvalue) && UNIVERSAL::isa($lvalue, "ValOp"))) {
			$lvaltype = 1;
		} elsif ($lvalue->isa("ListVal")) {
			$lvaltype = 2;
		} elsif ($lvalue->isa("SetVal")) {
			$lvaltype = 3;
		} elsif ($lvalue->isa("HashVal")) {
			$lvaltype = 4;
		}

		# Exit if local value is of wrong type
		if ((($valtype & 7) != ($lvaltype & 7)) && (($valtype & 7) != 0)) {
			warn("Warning: inheritance type mismatch in variable $var of type " 
				. $type->get_name());
			return ($valtype, $value);
		} 

		# Update inheritance information, if $lvalue is VarOp
		if ($lvaltype > 1) {
			$inherit = $lvalue->inherit();
			$lvaltype |= ($inherit & 2) ? 32 : 16;
			$inherit &= 1;
		} else {
			$inherit = 0;
		}

		# Update $valtype if $lvaltype is more specific
		$valtype |= ($lvaltype & 7) if (! ($valtype & 7));
		$valtype |= 8;
		$valtype |= ($lvaltype & 48) if (! ($valtype & 48));
	}

	# Local atomic value: return result
	if (($lvaltype & 7) == 1) {
		return ($valtype, $lvalue);
	} 

	# Local complex value: initial update with local value
	if (($lvaltype & 7) > 1) {
		$value = $lvalue->preset($value);
	}

	# Call super types until value defined, if inheritance is on
	my $svaltype = $lvaltype || $valtype;
	if ($inherit) {
		# Find immediate super types
		#my @super = @{$type->get_super()};
		my @super = reverse(@{$type->get_super()});
		if (@$chain) {
			push @super, $chain;
		}

		# Process immediate super types
		foreach my $s (@super) {
			# Skip processing if we have singular inheritance where
			# super has just changed value, or if atomic value returned
			last if (($svaltype & 8) && ((($svaltype & 7) == 1) || 
				($svaltype & 16)));

			# Find super value
			($svaltype, $value) = $self->xvar($s, $var, $svaltype, $value, 
				$mark);

			# Update $valtype if $svaltype is more specific
			$valtype |= ($svaltype & 7) if (! ($valtype & 7));
			$valtype |= ($svaltype & 8);
			$valtype |= ($svaltype & 48) if (! ($valtype & 48));
		
		}
	}

	# Final update with local value
	if (($lvaltype & 7) > 1) {
		$value = $lvalue->postset($value);
	}

	# Return
	return ($valtype, $value);
}


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


1;
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


1;
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


1;
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


1;
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


1;
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


1;

1;

1;
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
##  auto-inserted from: Lexicon/CostOps/HEADER.pl
## ------------------------------------------------------------

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


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/AndOp.pl
## ------------------------------------------------------------

package AndOp;
@AndOp::ISA = qw(CostOp);

sub match_node {
	my $self = shift;
	my $node = shift;

	foreach my $arg (@$self) {
		return 0 if (! $arg->match_node($node));
	}
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/CardOp.pl
## ------------------------------------------------------------

package CardOp;
@CardOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/ChildOp.pl
## ------------------------------------------------------------

package ChildOp;
@ChildOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/DepOp.pl
## ------------------------------------------------------------

package DepOp;
@DepOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/DiffOp.pl
## ------------------------------------------------------------

package DiffOp;
@DiffOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/DistOp.pl
## ------------------------------------------------------------

package DistOp;
@DistOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/EqOp.pl
## ------------------------------------------------------------

package EqOp;
@EqOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/GovOp.pl
## ------------------------------------------------------------

package GovOp;
@GovOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/GtOp.pl
## ------------------------------------------------------------

package GtOp;
@GtOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/IsOp.pl
## ------------------------------------------------------------

package IsOp;
@IsOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/IslandOp.pl
## ------------------------------------------------------------

package IslandOp;
@IslandOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/LeftOp.pl
## ------------------------------------------------------------

package LeftOp;
@LeftOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/LsiteOp.pl
## ------------------------------------------------------------

package LsiteOp;
@LsiteOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/LtOp.pl
## ------------------------------------------------------------

package LtOp;
@LtOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/MulOp.pl
## ------------------------------------------------------------

package MulOp;
@MulOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/NeOp.pl
## ------------------------------------------------------------

package NeOp;
@NeOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/NotOp.pl
## ------------------------------------------------------------

package NotOp;
@NotOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/OrOp.pl
## ------------------------------------------------------------

package OrOp;
@OrOp::ISA = qw(CostOp);

sub match_node {
	my $self = shift;
	my $node = shift;

	foreach my $arg (@$self) {
		return 1 if ($arg->match_node($node));
	}
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/ParentOp.pl
## ------------------------------------------------------------

package ParentOp;
@ParentOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/RightOp.pl
## ------------------------------------------------------------

package RightOp;
@RightOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/SelfOp.pl
## ------------------------------------------------------------

package SelfOp;
@SelfOp::ISA = qw(CostOp);


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/CostOps/SemOp.pl
## ------------------------------------------------------------

package SemOp;
@SemOp::ISA = qw(CostOp);

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


1;
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


1;
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


1;
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


1;
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


1;
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


1;

1;

1;

1;
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
##  auto-inserted from: Lexicon/Objects/CompOp.pl
## ------------------------------------------------------------

package CompOp;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Arguments
	my $type = shift;
	my $hash = { };
	while (@_) {
		$hash->{shift} = shift;
	}

	# Create new object
	my $self = [$type, $hash];
	bless($self, $class);
	return $self;
}

sub type {
	my $self = shift;
	$self->[0] = shift if (@_);
	return $self->[0];
}

sub comps {
	my $self = shift;
	$self->[1] = shift if (@_);
	return $self->[1];
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Objects/FillOp.pl
## ------------------------------------------------------------

package FillOp;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Arguments
	my $type = shift;
	my $srcpath = shift;
	my $govpath = shift;

	# Create new object
	my $self = [$type, $srcpath, $govpath];
	bless($self, $class);
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Objects/RegExpOp.pl
## ------------------------------------------------------------

package RegExp;

my $regexps = { };
my $regexpsf = { };

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Arguments
	my $self = [@_];

	# Create new object
	bless($self, $class);
	return $self;
}

sub match_node {
	my $self = shift;
	my $node = shift;
	my $regexp = $self->[1];
	my $field = $self->[2];
	my $sub;

	# Find node value
	my $value = $node->var($self->[0]);
	return undef if (! defined($value));

	# Find field and regexp
	if ($field) {
		my $re = '/^([^[]|\[[^]]*\]){' . $field .'}/';
		$sub = regexpf2code($re);
		$value = &$sub($value) . "";
		print "value=$value field=$field regexp = $re\n";
		return undef if (! defined($value));
	} 

	# Evaluate regexp
	$sub = regexp2code($regexp);
	return &$sub($value);
}

sub regexpf2code {
	my $regexp = shift;
	my $sub = $regexpsf->{$regexp};
	if (! $sub) {
		$sub = $regexpsf->{$regexp}
			= eval("sub { my \$s = shift; \$s =~ $regexp; return \$1; }");
	}
	return $sub;
}

sub regexp2code {
	my $regexp = shift;
	my $sub = $regexps->{$regexp};
	if (! $sub) {
		$sub = $regexps->{$regexp}
			= eval("sub { my \$s = shift; return \$s =~ $regexp; }");
	}
	return $sub;
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Objects/SrcVal.pl
## ------------------------------------------------------------

package SrcVal;

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Argument
	my $path = shift;
	my $self = [$path];
	bless($self, $class);
	return $self;
}

sub value {
	my $self = shift;
	my $src = shift;
	my @path = ($self->[0] eq '') ? () : split(/\|/, $self->[0]);

	# Process path
	while (@path) {
		my $child = shift(@path);
		if (UNIVERSAL::isa($src, 'ARRAY') && $child =~ /[0-9]+/) {
			$src = $src->[0+$child];
		} elsif (UNIVERSAL::isa($src, 'HASH')) {
			$src = $src->{$child};
		} else {
			return undef;
		}
	}
	
	# Return value
	return DTAG::Lexicon->copy_obj($src);
}
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


1;
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


1;
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


1;
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


1;
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


1;
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


1;

1;

1;

1;
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
##  auto-inserted from: Lexicon/Type/HEADER.pl
## ------------------------------------------------------------

# This package defines a simple type in the lexicon, with the
# following variables:
#
#	name: the name of the type
#	super: a list of immediate super types
# 	variables: a hash of variable-value pairs
#
# and the following procedures:
#
#	$type->new := new type
#	$type->is(typedef) := 0/1: 
#	$type->super(type) := 0/1;
#	$type->join(types) := type;
#	$type->variables := variable hash;
#	$type->value(variable) := value;
#
# and the following creators used in lexica:
#
# 	type($name, $super1, ..., $superN)
#	lex($name, $super1, ..., $superN)
# 	map($name, $super1, ..., $superN)
#
# and the following modifiers:
#
# 	$type->super($tname1, ..., $tnameN)
# 	$type->phon($string)
#	$type->comp($edge1 => $tdef1, ..., $edgeN => $tdefN)
#	$type->land($tdef1, ..., $tdefN)
#	$type->cost($cfunc1, ..., $cfuncN)
#	$type->map($type1/listref1, ..., $typeN/listrefN)
#

package Type;
use strict;

my $undef = Type->new("__undef__");


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/agov.pl
## ------------------------------------------------------------

# $type->agov('=', $edge1=>$type1, ...)


sub agov {
	my $self = shift;
	return $self->set_hash('agov', 3, @_);
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/comp.pl
## ------------------------------------------------------------

# $self = $self->comp('=', $edge1=>$type1, ...)

sub comp {
	my $self = shift;
	return $self->set_hash('comp', 3, @_);
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/cost.pl
## ------------------------------------------------------------

# $type->cost('=', $name1=>$costf1, ...)


sub cost {
	my $self = shift;
	return $self->set_hash('cost', 3, @_);
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/destroy.pl
## ------------------------------------------------------------

# type->new($lexicon): Create new type in lexicon $lexicon

sub destroy {
	my $self = shift;

	# Delete all values in $self
	foreach my $key (keys %$self) {
		delete $self->{$key};
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/fill.pl
## ------------------------------------------------------------

# $type->fill('=', $edge1=>$type1, ...)


sub fill {
	my $self = shift;
	return $self->set_hash('fill', 3, @_);
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/get_name.pl
## ------------------------------------------------------------

sub get_name {
	my $self = shift;
	return $self->{'_name'};
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/get_sub.pl
## ------------------------------------------------------------

# get_sub := list of subtypes

sub get_sub {
	my $self = shift;
	return $self->{'_sub'};
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/get_super.pl
## ------------------------------------------------------------

# get_super := list of super types

sub get_super {
	my $self = shift;
	return $self->{'_super'};
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/gov.pl
## ------------------------------------------------------------

# $type->gov('=', $edge1=>$type1, ...)


sub gov {
	my $self = shift;
	return $self->set_hash('agov', 3, @_);
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/is.pl
## ------------------------------------------------------------

sub is {
	my $type = shift;
	my $typespec = shift;
	my $lexicon = shift || DTAG::LexInput->lexicon();
	return $lexicon->isatype($type, $typespec);
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/land.pl
## ------------------------------------------------------------

# $type->land('=', $edge1=>$type1, ...)


sub land {
	my $self = shift;
	return $self->set_hash('land', 3, @_);
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/lexicon.pl
## ------------------------------------------------------------

sub lexicon {
	return DTAG::LexInput::lexicon();
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/lvar.pl
## ------------------------------------------------------------

sub lvar {
	my $self = shift;
	my $var = shift;

	# Set value if specified
	if (@_) {
		my $val = shift;
		if (defined($val)) {
			$self->{$var} = $val;
		} else {
			delete($self->{$var});
		}
	}

	# Retrieve value
	return $self->{$var};
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/match.pl
## ------------------------------------------------------------

sub match {
	my $self = shift;
	$self->lvar('_match', @_);
	return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/new.pl
## ------------------------------------------------------------

# type->new($name, $super1, ..., $superN): 
# 		Create new type with name $name and super types $super1,...,$superN

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = { '_super' => [] };

	# Specify class for new object
	bless ($self, $class);

	# Initialize name and new parents
	$self->set_name(shift) if (@_);
	$self->set_super(@_) if (@_);
	
	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/phon.pl
## ------------------------------------------------------------

# $type->phon($phon1, ..., $phonN):

sub phon {
	my $self = shift;

	# Compile $phon1 ... $phonN
	$self->lexicon()->phon_compile(@_);

	# Set list
	return $self->set_list('phon', @_);
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/print.pl
## ------------------------------------------------------------

# $string = $type->print: print $type and return result in $string

sub print {
	my $self = shift;

	# Variable names
	my @vars = ();
	foreach my $v (sort(keys(%$self))) {
		push(@vars, $v)
			if ($v !~ /^_.*$/);
	}

	# Print name of self and parents
	my $string = $self->get_name() 
		. ": super=[" . join(" ", 
			map {get_name(typeobj($_) || $undef)} @{$self->get_super()}) 
		. "]"
		. " lvars=[" 
		. join(" ", map {"$_=" . $self->lvar($_)} @vars)
		. "]\n";
	
	# Return
	return $string
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/set_hash.pl
## ------------------------------------------------------------

# $self->set_hash($var, $inheritance, $key1 => $val1, ...)

sub set_hash {
	my $self = shift;
	my $var = shift;

	# Set inheritance
	my $inherit = shift;
	if ((! ref($_[0])) && ($_[0] eq '=')) {
		$inherit = 0;
		shift;
	}

	# Build plus hash and minus list
	my $hash = {};
	my $minus = [];
	while (@_) {
		my ($key, $value) = (shift, shift);
		if (defined($value)) {
			$hash->{$key} = $value;
		} else {
			push @$minus, $key;
		}
	}

	# Create hash object
	$self->lvar($var, DTAG::LexInput::hash($hash, $minus, $inherit));

	# Return
	return $self;
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/set_list.pl
## ------------------------------------------------------------

# $type->phon($var, $inheritance, $phon1, ..., $phonN):
sub set_list {
	my $self = shift;
	my $var = shift;

	# Set inheritance
	my $inherit = 1;
	if ((! ref($_[0])) && ($_[0] eq '=')) {
		$inherit = 0;
		shift;
	}

	# Initialize value
	$self->lvar($var, DTAG::LexInput::list([@_], [], $inherit));

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/set_name.pl
## ------------------------------------------------------------

sub set_name {
	my $self = shift;
	$self->{'_name'} = shift;
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/set_sub.pl
## ------------------------------------------------------------

sub set_sub {
	my $self = shift;
	$self->{'_sub'} = shift;
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/set_super.pl
## ------------------------------------------------------------

sub set_super {
	my $self = shift;
	$self->{'_super'} = [@_];
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/setvar.pl
## ------------------------------------------------------------

sub setvar {
	my $self = shift;
	$self->lvar(@_);
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/submatches.pl
## ------------------------------------------------------------

sub submatches {
	my $self = shift;
	$self->{'_subm'} = shift if (@_);
	return $self->{'_subm'};
} 

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/super.pl
## ------------------------------------------------------------

sub super {
	my $self = shift;
	$self->{'_super'} = [@_];
	return $self;
} 

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/trans.pl
## ------------------------------------------------------------

# $type->trans('=', $name1=>$trans1, ...)


sub trans {
	my $self = shift;
	return $self->set_hash('trans', 3, @_);
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/typeobj.pl
## ------------------------------------------------------------

sub typeobj {
	my $name = shift;
	return DTAG::Lexicon::typeobj($name);
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/var.pl
## ------------------------------------------------------------

sub var {
	my $self = shift;
	my $var = shift;

	# Set value of local variable, if specified
	if (@_) {
		$self->lvar($var, shift);
	}

	# Retrieve value of variable
	my ($t, $value) = DTAG::Lexicon->xvar($self, $var);
	return $value;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/Type/vars.pl
## ------------------------------------------------------------

sub vars {
	my $self = shift;
	return [ grep !/^_/, sort(keys(%$self)) ];
}
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


1;
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


1;
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


1;
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


1;
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


1;
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


1;

1;

1;

1;
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
##  auto-inserted from: Lexicon/TypeOps/TMinusOp.pl
## ------------------------------------------------------------

package TMinusOp;
@TMinusOp::ISA = qw(TypeOp);

# Value of $x-$y
sub value {
	my $self = shift;
	my $lexicon = shift;
	my $type = shift;

	# Return 0 if $x is 0
	if (! $lexicon->isatype($type, $self->[0])) {
		return 0;
	}
	
	# Return 0 if $y is 1
	if ($lexicon->isatype($type, $self->[1])) {
		return 0;
	} 

	# Else return 1
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/TypeOps/TNegOp.pl
## ------------------------------------------------------------

package TNegOp;
@TNegOp::ISA = qw(TypeOp);

# Value of !$x
sub value {
	my $self = shift;
	my $lexicon = shift;
	my $type = shift;

	# Invert result from $x
	return 
		($lexicon->isatype($type, $self->[0])) ? 0 : 1;
}


sub print {
	my $self = shift;
	my @args = ();
	foreach my $arg (@$self) {
		if (ref($arg) && $arg->isa("TypeOp")) {
			push @args, "$arg";
		} else {
			push @args, "$arg";
		}
	}
	my $name = lc(ref($self));
	$name =~ s/op$//g;
	return $name . "(" . join(", ", @args) . ")";
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/TypeOps/TOrOp.pl
## ------------------------------------------------------------

package TOrOp;
@TOrOp::ISA = qw(TypeOp);

# Value of $x|$y
sub value {
	my $self = shift;
	my $lexicon = shift;
	my $type = shift;

	# Return 1 if $x is 1
	return 1 if($lexicon->isatype($type, $self->[0]));
	
	# Return 1 if $y is 1
	return 1 if($lexicon->isatype($type, $self->[1]));

	# Else return 0
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/TypeOps/TPlusOp.pl
## ------------------------------------------------------------

package TPlusOp;
@TPlusOp::ISA = qw(TypeOp);

# Value of $x+$y
sub value {
	my $self = shift;
	my $lexicon = shift;
	my $type = shift;

	# Return 0 if $x is 0
	return 0 if(! $lexicon->isatype($type, $self->[0]));
	
	# Return 0 if $y is 0
	return 0 if(! $lexicon->isatype($type, $self->[1]));

	# Else return 1
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Lexicon/TypeOps/TypeOp.pl
## ------------------------------------------------------------

package TypeOp;
use overload 
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
		if (ref($arg) && $arg->isa("TypeOp")) {
			push @args, "$arg";
		} else {
			push @args, "$arg";
		}
	}
	my $name = lc(ref($self));
	$name =~ s/op$//g;
	return $name . "(" . join(", ", @args) . ")";
}


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


1;
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


1;
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


1;
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


1;
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


1;
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


1;

1;

1;

1;
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
##  auto-inserted from: Lexicon/ValOps/HashVal.pl
## ------------------------------------------------------------

package HashVal;
@HashVal::ISA = qw(ValOp);

use overload
    '""' => \& print;

sub preset {
	my $self = shift;
	my $value = shift;

	# Check that $value is a hash reference
	if (ref($value) ne "HASH") {
		$value = { };
	}

	# Add all pairs in plus-hash
	my $plus = $self->plus();
	foreach my $key (keys %$plus) {
		if (! (exists $value->{$key})) {
			$value->{$key} = $plus->{$key};
		}
	}

	# Return value
	return $value;
} 

sub postset {
	my $self = shift;
	my $value = shift;

	# Delete all keys in minus-list
	foreach my $key (@{$self->minus()}) {
		delete $value->{$key};
	}

	# Return value
	return $value;
}

sub print {
    my $self = shift;

	# Print 
	return "hash([" 
		. join(",", map {"$_=" . $self->plus()->{$_}} 
			sort(keys(%{$self->plus()}))) 
		. "]-[" 
		.  join(",", @{$self->minus()}) . "], " 
		.  $self->inherit() . ")";
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/ValOps/ListVal.pl
## ------------------------------------------------------------

package ListVal;
@ListVal::ISA = qw(ValOp);

sub preset {
	my $self = shift;
	my $value = shift;

	# Check that $value is a list reference
	if (ref($value) ne "ARRAY") {
		$value = [ ];
	}

	# Return value
	return $value;
} 

sub postset {
	my $self = shift;
	my $value = shift;

	# Add plus-members
	push @$value, @{$self->plus()};

	# Subtract minus-members
	if (scalar(@{$self->minus()})) {
		for (my $i = 0; $i < scalar(@$value); ) {
			my $elem = $value->[$i];
			if (grep {$_ eq $elem} @{$self->minus()}) {
				# Delete element $i
				splice(@$value, $i, 1);
			} else {
				++$i;
			}
		}
	}

	# Return list
	return $value;
}


## ------------------------------------------------------------
##  auto-inserted from: Lexicon/ValOps/SetVal.pl
## ------------------------------------------------------------

package SetVal;
@SetVal::ISA = qw(ValOp);

sub preset {
	my $self = shift;
	my $value = shift;

	# Check that $value is a list reference
	if (ref($value) ne "ARRAY") {
		$value = [ ];
	}

	# Return value
	return $value;
} 

sub postset {
	my $self = shift;
	my $value = shift;

	# Add plus-members
	foreach my $elem (@{$self->plus()}) {
		# Add element to list if non-existent
		if (! grep {$_ eq $elem} @$value) {
			push @$value, $elem;
		}
	}

	# Subtract minus-members
	if (scalar(@{$self->minus()})) {
		for (my $i = 0; $i < scalar(@$value); ) {
			my $elem = $value->[$i];
			if (grep {$_ eq $elem} @{$self->minus()}) {
				# Delete element $i
				splice(@$value, $i, 1);
			} else {
				++$i;
			}
		}
	}

	# Return list
	return $value;
}



## ------------------------------------------------------------
##  auto-inserted from: Lexicon/ValOps/ValOp.pl
## ------------------------------------------------------------

package ValOp;

use overload
	'""' => \& print;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

	# Arguments
	my $plus = shift;
	my $minus = @_ ? shift : [];
	my $inh = @_ ? shift : 0;

    my $self = [$plus, $minus, $inh];
    push @$self, @_;
    bless($self, $class);
	return $self;
}

sub plus {
	my $self = shift;

	if (@_) {
		$self->[0] = shift;
	}

	return $self->[0];
}

sub minus {
	my $self = shift;

	if (@_) {
		$self->[1] = shift;
	}

	return $self->[1];
}

sub inherit {
	my $self = shift;

	if (@_) {
		$self->[2] = shift;
	}

	return $self->[2];
}

sub print {
	my $self = shift;
	my $type = ref($self);
	$type = "list" if ($type eq "ListVal");
	$type = "set" if ($type eq "SetVal");

	# Print 
	return "$type([" . join(",", @{$self->plus()}) . "]-[" . 
		join(",", @{$self->minus()}) . "], " . $self->inherit() . ")";
}
		
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


1;
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


1;
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


1;
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


1;
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


1;
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


1;

1;

1;

1;

1;
