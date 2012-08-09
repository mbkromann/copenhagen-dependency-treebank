
use strict;
use File::Find;
use File::Copy;
use File::Path qw(make_path remove_tree);
use File::stat;

if ($#ARGV !=1){
	print "Usage $ARGV[0] <command:[make|clean]> <Study_name | all>\n";
  	exit 1;
	
}

my $STUDY = qw(ACS08 BD08 BML12 JLG10 KTHJ08 LWB09 MS12 NJ12 SG12 TPR11);

sub CopyData{
	my $study =shift;
	my @folders = ("Translog-II","Alignment");
	
	foreach my $folder (sort @folders){
		my $path = "../$study/$folder/";
		
		my $pattern = "\.xml";
		if ($folder eq "Alignment"){$pattern = "(\.src|\.tgt|\.atag)";}
		opendir(DIR, $path);
		my @FILES= readdir(DIR); 
	
		foreach my $file (@FILES){
			
			if ($file=~ m/$pattern$/i){
				my $full_path = $path.$file;
				my $new_path =$full_path;
				$new_path =~ s/\.\./data/;
						
				if (older_than($full_path,$new_path)){
					
					next;	
				}
				my $dir = "data/$study/$folder";
				if ( not -e $dir){
					make_path $dir or die "Directory creation failed: $!";
				}
        		print "cp  $full_path $new_path \n";
        		copy($full_path,$new_path) or die "Copy failed: $!";		
			}
		
		}
		closedir(DIR);
			
	}
	
	
}
sub MergeEvents2Trl{
	
}






sub older_than{
	my ($file1,$file2)=@_;
	if (stat($file1) and stat($file2)){
		if (stat($file1)->mtime < stat($file2)->mtime){
			return 1;
		}
	}
	return 0;
}
CopyData ($ARGV[1]);