#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
  echo "Usage $0 <command:[make|clean]> <Study_name | all>"
  exit
fi

STUDY="ACS08 BD08 BML12 JLG10 KTHJ08 LWB09 MS12 NJ12 SG12 TPR11"


## copy translog and Alignment data from TPR-DB to data subfolder
function CopyData()
{


    for file in ../$1/Translog-II/*.xml
    do
        new=${file/\.\./data}
        if [ $file -ot $new ]; then 
          continue 
        fi
        mkdir -p data/$1/Translog-II
        echo "cp  $file $new"
        cp -r  $file $new
    done

    for file in ../$1/Alignment/*.{src,tgt,atag}
    do
        new=${file/\.\./data}
        if [ $file -ot $new ]; then 
#          echo "skipped $file"
          continue
        fi
        echo "cp  $file $new"
        mkdir -p data/$1/Alignment
        cp -r  $file $new
    done

}


## merge atag and translog files and produce *.Event.xml file 
function MergeEvents2Trl()
{
    mkdir -p data/$1/Events
    for file in data/$1/Translog-II/*.xml
    do
        root=${file%.xml}
        outp=${root/Translog-II/Events}
        atag=${root/Translog-II/Alignment_NLP}

## If Source is older than Target do nothing
        if [ $file -ot "$outp.Event.xml" ] && 
           [ "$atag.atag" -ot "$outp.Event.xml" ] && 
           [ "$atag.src"  -ot "$outp.Event.xml" ] && 
           [ "$atag.tgt"  -ot "$outp.Event.xml" ] ; then 
#          echo "skipped $file and $atag.atag"
          continue
        fi

        echo "MergeAtag2Trl -T $file -A $atag -O $outp.Atag.xml"
        ./MergeAtagTrl.pl -T $file -A $atag -O "$outp.Atag.xml"

        echo "FixMod2Trl   -T "$outp.Atag.xml" -O $outp.Event.xml"
        ./FixMod2Trl.pl -T "$outp.Atag.xml" -O  "$outp.Event.xml"

        rm -f $outp.Atag.xml

        echo "";
    done
}

## read Event.xml files and produce token tables
function Trl2TokenTables ()
{

    mkdir -p data/$1/Tables

    for file in data/$1/Events/*Event.xml
    do
        root=${file%.Event.xml}
        tabs=${root/Events/Tables}

        if [ $file -ot "$tabs.st" ]; then 
#          echo "skipped $file"
          continue
        fi

        echo "Token Tables -T $file -O $tabs.{st,tt,fd,kd,pu,fu,au}"
        ./Trl2ProgGraphTables.pl -T $file -O $tabs
        ./Trl2TargetTokenTables.pl -T $file > $tabs.tt
        ./Trl2TargetAUTables.pl -T $file > $tabs.au

    done    
}


## produce Treex files 
function ToSingleTreex ()
{

# raw conversion into Treex 
    mkdir -p data/Treex/raw
    for file in data/$1/Events/*Event.xml
    do
        root=${file%.Event.xml}
        root=`expr "$root" : '.*/\(.*\)'`
        new="data/Treex/raw/$1-$root"

        if [ $file -ot "$new.treex.gz" ]; then 
          continue
        fi

        echo "./Trl2Treex.pl  -T $file -O $new"
        ./Trl2Treex.pl -T "$file" -O "$new"
    done    

## finalize Treex, build trees and store in data/Treex folder
    treex \
    Misc::Translog::BuildTreesFromOffsetIndices \
    Util::Eval document="\$doc->set_path(qw(data/Treex))" \
    Write::Treex clobber=1 storable=0 \
    -- data/Treex/raw/$1*.treex.gz
}

#function finalizeTreex ()
#{
#
#    for file in data/Treex/raw/$1*.treex.gz
#    do
#        new=${file/raw/}
#        flag=0
#        if [ "$file" -nt "$new" ]; then flag=1; fi
#    done
#
#    if [ $flag == 1 ]; then 
#      treex \
#      Misc::CopenhagenDT::BuildTreesFromOffsetIndices \
#      Util::Eval document="\$doc->set_path(qw(data/Treex))" \
#      Write::Treex clobber=1 storable=0 \
#      -- data/Treex/raw/$1*.treex.gz
#    fi
#}

function AnnotateTrl ()
{
    mkdir -p data/$1/Alignment_NLP
    flag=0
    for file in data/$1/Alignment/*atag
    do
        new=${file/Alignment/Alignment_NLP}
        if [ "$file" -nt "$new" ]; then flag=1; fi
    done

    if [ $flag == 1 ]; then 
        rm -rf data/$1/Alignment_NLP/*

        python modify_files.py data/$1/Alignment/*.src 
        python modify_files.py data/$1/Alignment/*.tgt

        cp data/$1/Alignment/*.atag data/$1/Alignment_NLP
   fi
}

####################################
function Treex2Atag ()
{

## Regenerate atag file
      treex \
      Misc::Translog::Treex2Alignment \
      -- data/Treex/$1*.treex.gz

## check whether old and new atag files contain same information
    for file in data/$1/Alignment-II/*atag
    do
      file=${file%.atag}
      atag=${file/Alignment-II/Alignment_NLP}

      echo "Comparing $file $atag"
      ./CompareAtag.pl -C $file -A $atag
    done
}




## clean workspace (data folder)
if [ "$1" == "clean" ]; then
    if [ "$2" == "all" ]; then 
       echo "remove data/*"
       rm -rf data/* 
    else 
       echo "remove data/$2"
       rm -rf data/$2 
    fi
    exit;

## make treex and token tables 
elif [ "$1" == "make" ]; then  
    if [ "$2" == "all" ]; then STUDY=$STUDY
    else STUDY=$2;
    fi

    for study in $STUDY 
    do 
      echo "make copy $study "
      CopyData $study;
      echo "make annotation $study "
      AnnotateTrl $study; 
      echo "make events $study "
      MergeEvents2Trl $study; 
      echo "make tables $study "
      Trl2TokenTables $study;
      echo "make treex $study "
      ToSingleTreex $study

    done
    exit;

## convert Events to treex
elif [ "$1" == "treex" ]; then  
    if [ "$2" == "all" ]; then STUDY=$STUDY
    else STUDY=$2;
    fi

    for study in $STUDY ; do ToSingleTreex $study ; done

    exit;

## produce Tables  
elif [ "$1" == "tables" ]; then
    if [ "$2" == "all" ]; then STUDY=$STUDY
    else STUDY=$2;
    fi

    for study in $STUDY ; do Trl2TokenTables $study; done

    exit;

## check if treex information consistent
elif [ "$1" == "check" ]; then  
    if [ "$2" == "all" ]; then STUDY=$STUDY
    else STUDY=$2;
    fi

    for study in $STUDY ; do Treex2Atag $study; done

    exit;

else echo "Usage $0 <make | clean> <Study_name | all>"
fi

