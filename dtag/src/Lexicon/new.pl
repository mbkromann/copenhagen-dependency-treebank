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

