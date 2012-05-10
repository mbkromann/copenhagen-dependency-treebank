#!/usr/bin/perl -w 

use strict;
use Getopt::Long;
use Encode;

my $directory;
my $useAdditionalData;
my $help;

my $hunalign = "/srv/tools/hunalign-1.1/src/hunalign/hunalign -utf -realign -text";
# dictionary format: one entry per line, possibly multi word entries, "src-entry @ trg-entry"
my $hunalignDictionary = "/srv/tools/hunalign-1.1/data/null.dic";
my $moses = "/srv/tools/moses/scripts/training/train-factored-phrase-model.perl --alignment grow-diag-final-and --parallel --last-step 3";

if (
    ! &GetOptions(
         'd=s' => \$directory,
         'dict=s' => \$hunalignDictionary,
         'add!' => \$useAdditionalData,
         'h!' => \$help)
    ||
         ($help || ! defined $directory) 
    ){
    print "\nusage: $0 
       -d    <path-to-directory> (required) - directory containing files to be aligned
       -dict <dictionary> - possible hunalign dictionary to be used in sentence alignment
       -add  include additional data if present
       -h    help\n\n";
    exit(1);
}

die "directory does not exist: $directory" unless -d $directory;
die "hunalign dictionary does not exist: $hunalignDictionary" unless -e $hunalignDictionary;

$directory =~ s/\/$//;

# get file prefixes
my @filePrefixes;
foreach(`ls $directory/*.SourceTok`){
    if(/([^\/]+)\.SourceTok$/){
	my $pre = $1;
	die "Error: .SourceTok or .FinalTok file does not exists or is empty for $pre" unless -s "$directory/$pre.SourceTok" && -s "$directory/$pre.FinalTok";
	push(@filePrefixes, $pre);
    }
    else{
	die "could not process file path: $_";
    }
}

# create working dir
my $workdir = "$directory/work-dir";
system("rm -rf $workdir") if -e $workdir;
die "Could not create working directory: $workdir" unless mkdir $workdir;
printf STDERR "Found %d files.\nWorking in $workdir\n", scalar @filePrefixes;

# sentence align files, and merge into one SourceTok and one FinalTok file
print STDERR "Doing sentence alignment ...";
&sentenceAlign();
print STDERR " done!\n";

# word align
print STDERR "Doing giza alignment ...";
system("nohup $moses --root-dir $workdir --model-dir $workdir --corpus $workdir/sentalign -f SourceTok -e FinalTok > $workdir/LOG-giza 2>1");
print STDERR " done!\n";

# map back to original files
print STDERR "Mapping alignments back to original files ...";
&mapAlignments();
print STDERR " done!\n";





sub sentenceAlign(){

    my $srcSentAlignFile = "$workdir/sentalign.SourceTok";
    my $trgSentAlignFile = "$workdir/sentalign.FinalTok";
    my $recordSentAlignFile = "$workdir/sentalign.record";
    open(S, ">$srcSentAlignFile");
    open(T, ">$trgSentAlignFile");
    open(R, ">$recordSentAlignFile");
    binmode(S, ":utf8");
    binmode(T, ":utf8");
    LOOP: foreach my $pre (@filePrefixes){
	my $fileName1 = "$directory/$pre.SourceTok";
	my $fileName2 = "$directory/$pre.FinalTok";

	die "Files for sentence alignment do not exist or are empty: $fileName1 $fileName2" unless -s $fileName1 && -s $fileName2;
	
	my @align = `$hunalign $hunalignDictionary $fileName1 $fileName2 2>> $workdir/LOG-hunalign`;
	
	my $str1 = "";
	my $str2 = "";
	my $alignStr = "$directory/$pre\n";
	foreach (@align){
	    # empty line aligned to empty line (probably doc final newline), just skip
	    if(/^\t\t[-.\d]+$/){
		next;
	    }
	    elsif(/^([^\t]+)\t([^\t]+)\t[-.\d]+$/){
		my $sent1 = $1;
		my $sent2 = $2;
		#check for giza appliance
		unless(&checkPair($sent1, $sent2)){
		    print STDERR "WARNING: File skipped due to sentence pair not comforming to giza demands in $pre: $_";
		    next LOOP;
		}
		# merged sentences are separated by ' ~~~ ' in hunalign
		my @sent1split = split / [~]{3} /, $sent1;
		my @sent2split = split / [~]{3} /, $sent2;
		$str1 .= (join " ", @sent1split) . "\n";
		$str2 .= (join " ", @sent2split) . "\n";
		foreach (@sent1split){
		    $alignStr .= (s/(\s+)/$1/g + 1) . "-";
		}
		$alignStr =~ s/-$/ /;
		foreach (@sent2split){
		    $alignStr .= (s/(\s+)/$1/g + 1) . "-";
		}
		$alignStr =~ s/-$/\n/;
	    }
	    else{
		print STDERR "WARNING: File skipped due to encountered null linked sentence for $pre: $_";
		next LOOP;
	    }
	}

	print S $str1;
	print T $str2;
	print R $alignStr;
	
    }
    close(S);
    close(T);
    close(R);

}

sub checkPair(){
    my $str1 = shift;
    my $str2 = shift;
    # word longer than 1000 chars
    if($str1 =~ /\S{1001}/ || $str2 =~ /\S{1001}/){
	return 0;
    }
    my $str1len = s/(\s+)/$1/g + 1;
    my $str2len = s/(\s+)/$1/g + 1;
    # sentence length over 99 words or ratio higher than 9
    if($str1len > 99 || $str2len > 99 || $str1len/$str2len > 9 || $str2len/$str1len > 9){
	return 0;
    }
    return 1;
}


sub mapAlignments(){
    open(R, "$workdir/sentalign.record") || die "Could not open sentence alignment record $workdir/sentalign.record: $!";
    open(A, "$workdir/aligned.grow-diag-final-and") || die "Could not open sentence alignment record $workdir/aligned.grow-diag-final-and: $!";
    my $offset1 = 0;
    my $offset2 = 0;
    while(<R>){
	if(/\//){
	    s/\s*$//;
	    close(O);
	    open(O, ">$_.giza") ||  die "Could not open output alignment file $_.giza: $!";
	    $offset1 = 0;
	    $offset2 = 0;
	}
	elsif(/^([-\d]+) ([-\d]+)$/){
	    my $len1 = $1;
	    my $len2 = $2;
	    foreach(split/\s+/, <A>){
		if(/^(\d+)-(\d+)$/){
		    printf O "%d-%d\n", $1 + $offset1, $2 + $offset2;
		}
		else{
		    die "Unexpected word alignment format: $_";
		}
	    }
	    # move offset by sentence lengths
	    foreach(split/-/, $len1){
		$offset1 += $_;
	    }
	    foreach(split/-/, $len2){
		$offset2 += $_;
	    }
	}
	else{
	    die "Unexpected record: $_";
	}
    }
    close(O);
    close(R);
    close(A);
}


