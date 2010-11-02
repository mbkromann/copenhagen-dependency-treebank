#!/usr/bin/perl

use CPAN;

# Print instructions
print "\n" .
'This script installs all the Perl packages needed by DTAG, using
the Perl CPAN installer which accesses the www.cpan.org archive. In
order to run the install script, you must have root privileges and
internet access. Make sure you can open a new window in X Windows,
otherwise the installation of Term::ReadLine::Gnu will fail (check
your DISPLAY variable and your xhost command). Please answer any
questions that the CPAN installer may ask you during the installation.

Alternatively, you can install the modules manually (refer to the
manpage for "CPAN").' ."\n\n";

# Wait for key press
print "Press return to continue or abort with ctrl-C\n";
<>;
print "\n";

# install my favorite programs if necessary:
for $modname (qw(Cwd Data::Dumper Exporter File::Basename IO IO::File
		MLDBM Math::CDF Parse::RecDescent PerlIO Term::ANSIColor Term::ReadKey
		Term::ReadLine::Gnu Term::ReadLine BerkeleyDB DB_File
		XML::Writer XML::Parser)) {
	# Lookup module at CPAN
 	my $mod = CPAN::Shell->expand('Module',$modname);

	# Determine whether module should be installed: Is it up-to-date? 
	# Is it already installed (perhaps in an older version)? Does the
	# user want an update?
	my $install = 0;
	if ($mod && ! $mod->inst_file()) {
		$install = 1;
	} elsif ($mod && ! $mod->uptodate()) {
		printf 
			"Module %s is installed as %s, could be updated to %s from CPAN\n", 
			$mod->id(), $mod->inst_version(), $mod->cpan_version();
		printf "Install module (yes/no)? ";
		my $reply = <>;
		$install = 1 if ($reply =~ /^[Yy]/);
	}

	# Install module, if necessary
	if ($install) {
		print $mod->install() 
			? printf("Installation of module %s succeeded!\n", $modname)
			: printf("Installation of module %s failed!\n", $modname);
	} else {
		printf("Module %s is already installed.\n", $modname);
	}
}

