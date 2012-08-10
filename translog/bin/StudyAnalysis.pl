
use strict;
use File::Find;
use File::Copy;
use File::Path qw(make_path remove_tree);
use File::stat;

if ($#ARGV !=1){
	print "Usage <command:[make|clean]> <Study_name | all>\n";
  	exit 1;
	
}

my $study_name = qw(ACS08 BD08 BML12 JLG10 KTHJ08 LWB09 MS12 NJ12 SG12 TPR11);

sub CopyData{
	my $study_name =shift;
	my @folders = ("Translog-II","Alignment");
	
	foreach my $folder (sort @folders){
		my $path = "../$study_name/$folder/";
		
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
				my $dir = "data/$study_name/$folder";
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
    my $study_name = shift;
    my $dir = "data/$study_name/Events/";
    my $trans_path = "data/$study_name/Translog-II/";
    if ( not -e $dir){
       make_path $dir or die "Directory creation failed: $!";
    }
    opendir(DIR,$trans_path);
    my @FILES= readdir(DIR);
    foreach my $file (@FILES){
    	if ($file=~ m/\.xml$/i){
    		my $temp_path = $trans_path.$file;
    		my $log_path = $temp_path;
    		$temp_path =~ s/\.xml$//;
           my $outp = $temp_path;
           $outp =~ s/Translog-II/Events/i;
           my $atag = $temp_path;
           $atag =~ s/Translog-II/Alignment_NLP/;
           if ( older_than($log_path,$outp.".Event.xml") 
           		and older_than($atag.".atag",$outp.".Event.xml")
           		and older_than($atag.".src",$outp.".Event.xml")
           		and older_than($atag.".tgt",$outp.".Event.xml")
           		)
           {
				next;
           }
           
            print "MergeAtag2Trl -T $log_path -A $atag -O $outp.Atag.xml\n";
            execute("perl ./MergeAtagTrl.pl -T $log_path -A $atag -O $outp.Atag.xml");
            
            print "FixMod2Trl -T $outp.Atag.xml -O $outp.Event.xml\n";
            execute("perl ./FixMod2Trl.pl -T $outp.Atag.xml -O $outp.Event.xml");
            execute("rm -f $outp.Atag.xml");
            print "\n";
        }
        
    }
    closedir(DIR);
}
sub Trl2TokenTables{
	my $study_name = shift;
	my $dir = "data/$study_name/Tables/";
	my $event_path = "data/$study_name/Events/";
	
	if ( not -e $dir){
       make_path $dir or die "Directory creation failed: $!";
    }
    opendir(DIR,$event_path);
    my @FILES= readdir(DIR);
    foreach my $file (@FILES){
    	
    	if ($file=~ m/\.Event\.xml$/i){
	    	my $temp_path = $event_path.$file;
	    	my $table_path = $temp_path; 
	    	$table_path =~ s/\.Event.xml$//;
	    	$table_path =~ s/Events/Tables/;
	    	if (older_than($temp_path,$table_path.".st")){
	    		next;
	    	}
	    	print "Token Tables -T $temp_path -O $table_path.{st,tt,fd,kd,pu,fu,au}\n"; 
	    	execute("perl ./Trl2ProgGraphTables.pl -T $temp_path -O $table_path");
	    	execute("perl ./Trl2TargetTokenTables.pl -T $temp_path > $table_path.tt");
	    	execute("perl ./Trl2TargetAUTables.pl -T $temp_path > $table_path.au");
	    }
    }
   closedir(DIR); 
}
sub ToSingleTreex{
	my $study_name = shift;
	my $dir = "data/$study_name/Treex/raw/";
	my $event_path = "data/$study_name/Events/";
	if ( not -e $dir){
       make_path $dir or die "Directory creation failed: $!";
    }
    opendir(DIR,$event_path);
    my @FILES= readdir(DIR);
    foreach my $file (@FILES){
    	if ($file=~ m/\.Event\.xml$/i){
    		my $temp_path = $event_path.$file;
    		$file =~ s/\.Event.xml$//;
    		my $new = $dir.$study_name."-".$file;
    		if (older_than($temp_path,$new.".treex.gz")){
    			next;
    		}
    		print "perl ./Trl2Treex.pl  -T $temp_path -O $new";
    		execute("perl ./Trl2Treex.pl -T $temp_path -O $new");
    	}
    }
    my $final_treex = "treex \\
    Misc::Translog::BuildTreesFromOffsetIndices \\
    Util::Eval document=\"\\\$doc->set_path(qw(data/$study_name/Treex))\" Write::Treex clobber=1 storable=0 \\
    -- data/$study_name/Treex/raw/*.treex.gz";
    #print $final_treex;
    execute($final_treex);
	closedir(DIR); 
}
sub FinalTreex{
	my $study_name = shift;
	my $final_treex = "treex \\
    Misc::Translog::BuildTreesFromOffsetIndices \\
    Util::Eval document=\"\\\$doc->set_path(qw(data/Treex))\" Write::Treex clobber=1 storable=0 \\
    -- data/Treex/raw/*.treex.gz";
	execute($final_treex);
}
sub AnnotateTrl{
	my $study_name = shift;
	my $dir = "data/$study_name/Alignment_NLP/";
	my $align_path = "data/$study_name/Alignment/";
	my $python_args = "";
	my $flag = 0;
	if ( not -e $dir){
       make_path $dir or die "Directory creation failed: $!";
    }
    opendir(DIR,$align_path);
    my @FILES= readdir(DIR);
    foreach my $file (@FILES){
		
    	my $temp_path = $align_path.$file;
    	my $new_path = $temp_path;
    	$new_path =~ s/Alignment/Alignment_NLP/;
    	
    	if ($temp_path=~ m/(\.src|\.tgt)$/i){
    		
    		if (older_than($new_path,$temp_path)){
    			$python_args = $python_args.$temp_path." ";
    				
    		}
    		
    		
    	}
    	elsif($temp_path=~ m/\.atag$/i){
    		if (older_than($new_path,$temp_path)){
    			copy($temp_path,$new_path) or die "Copy failed: $!";
    		}
    	}
    }
    if($python_args){
    	$python_args =~ s/^\s*(.*?)\s*$/$1/;
    	execute("python modify_files.py $python_args");
    }
    closedir(DIR);
}

sub Treex2Atag{

	my $study_name= shift;  
      execute("rm -r data/$study_name/Alignment-II");
      my $cmd = "treex \\
      Misc::Translog::RemakeWildZones \\
      Misc::Translog::Treex2Alignment \\
      -- data/$study_name/Treex/*.treex.gz";
      execute($cmd);

}

sub CheckRound{
	my $study_name = shift; 
	my $old_data = "data/$1/Alignment_NLP/";
	my $new_data = "data/$1/Alignment-II/";
	opendir(DIR,$old_data);
    my @FILES= readdir(DIR);
    foreach my $file (@FILES){
    	if ($file=~ m/\.atag$/i){
    		my $old_path = $old_data.$file;
    		my $new_path = $new_data.$file;
    		$old_path =~ s/\.atag$//;
    		$new_path =~ s/\.atag$//;
    		print "Comparing $old_path $new_path\n";
    		execute("perl ./CompareAtag.pl -C $old_path -A $new_path");
    	}
    	
    }
    closedir(DIR);
}

sub older_than{
	my ($file1,$file2)=@_;
	if (stat($file1) and not(stat($file2))){
		#print "X";
		return 0;	
	}
	elsif (stat($file2) and not(stat($file1))){
		#print "Y";
		return 1;	
	}
	elsif (stat($file1) and stat($file2)){
		if (stat($file1)->mtime < stat($file2)->mtime){
		#	print "Z";
			return 1;
		}
		else{
		#	print "A";
			return 0;
		}
	}
	#print "M";
	return 0;
	
}
sub execute {
	
	my @args = ( "bash", "-c", shift );
 	system(@args);
}

CopyData($ARGV[1]);
AnnotateTrl($ARGV[1]);
MergeEvents2Trl($ARGV[1]);
Trl2TokenTables($ARGV[1]);
ToSingleTreex($ARGV[1]);
Treex2Atag($ARGV[1]);