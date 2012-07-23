#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
  echo "Usage $0 <command:[make|clean]> <Study_name | all>"
  exit
fi


function CopyData()
{

    mkdir -p data/$1/Translog-II
    mkdir -p data/$1/Alignment

    for file in ../$1/Translog-II/*.xml
    do
        new=${file/\.\./data}
        if [ $file -ot $new ]; then 
#          echo "skipped $file"
          continue
        fi
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
        cp -r  $file $new
    done

}


function MergeEvents2Trl()
{
    mkdir -p data/$1/Events
    for file in data/$1/Translog-II/*.xml
    do
        root=${file%.xml}
        outp=${root/Translog-II/Events}

        if [ $file -ot "$outp.Event.xml" ]; then 
#          echo "skipped $file"
          continue
        fi

        atag=${root/Translog-II/Alignment}
        echo "./MergeAtagTrl.pl -T $file -A $atag -O $outp.Atag.xml"
        ./MergeAtagTrl.pl -T $file -A $atag -O "$outp.Atag.xml"

        echo "./FixMod2Trl.pl   -T "$outp.Atag.xml" -O $outp.Event.xml"
        ./FixMod2Trl.pl -T "$outp.Atag.xml" -O  "$outp.Event.xml"

        rm -f $outp.Atag.xml

        echo "";
    done
}

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


function ToSingleTreex ()
{
    mkdir -p data/Treex/raw
    for file in data/$1/Events/*Event.xml
    do
        root=${file%.Event.xml}
        root=`expr "$root" : '.*/\(.*\)'`
        new="data/Treex/raw/$1-$root"

        if [ $file -ot "$new.treex.gz" ]; then 
#          echo "skipped $file"
          continue
        fi

        echo "./Trl2Treex.pl  -T $file -O $new"
        ./Trl2Treex.pl -T $file -O "$new"
    done    
}

function fineTreex ()
{

    if [ "data/Treex/raw/$1*.treex.gz" -nt "data/Treex/$1*.treex.gz" ]; then 
      treex \
      Misc::CopenhagenDT::BuildTreesFromOffsetIndices \
      Util::Eval document="\$$doc->set_path(qw(data/Treex))" \
      Write::Treex clobber=1 storable=0 \
      -- data/Treex/raw/$1*.treex.gz
    fi
}

function AnnotateTrl ()
{
    mkdir -p data/$1/Alignment_NLP
    for file in data/$1/Alignment/*atag
    do
        new=${file/Alignment_NLP}
        flag=0
        if [ "$file" -nt "$new" ]; then flag=1; fi
    done

    if [ $flag == 1 ]; then 
        rm -rf data/$1/Alignment_NLP/*

        python modify_files.py data/$1/Alignment/*.src
#        python modify_files.py data/$1/Alignment/*.tgt

        cp data/$1/Alignment/*.atag data/$1/Alignment_NLP
   fi
}

STUDY="ACS08 BD08 BML12 JLG10 KTHJ08 LWB09 MS12 NJ12 SG12 TPR11"

if [ "$1" == "clean" ]; then
    if [ "$2" == "all" ]; then rm -rf data/* 
    else rm -rf data/$2 
    fi
elif [ "$1" == "make" ]; then  
    if [ "$2" == "all" ]; then STUDY="*" 
#     STUDY="ACS08 BD08 BML12 JLG10 KTHJ08 LWB09 MS12 NJ12 SG12 TPR11"
    else STUDY=$2;
    fi
else echo "Usage $0 <make | clean> <Study_name | all>"
fi

    for study in $STUDY 
    do 
      echo "make copy $study "
      CopyData $study;
      echo "make events $study "
      MergeEvents2Trl $study; 
      echo "make tables $study "
      Trl2TokenTables $study;
      echo "make treex $study "
      ToSingleTreex $study
      echo "make final $study "
      fineTreex $study;
#        ./AnnotateTrl.bash ACS08

    done
