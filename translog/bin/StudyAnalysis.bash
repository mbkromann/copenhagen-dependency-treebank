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
}

function FinalTreex ()
{

## finalize Treex, build trees and store in data/Treex folder
    treex \
    Misc::Translog::BuildTreesFromOffsetIndices \
    Util::Eval document="\$doc->set_path(qw(data/Treex))" \
    Write::Treex clobber=1 storable=0 \
    -- data/Treex/raw/$1*.treex.gz

    rm -f data/Treex/raw/$1*.treex.gz
}

function AnnotateTrl ()
{
    mkdir -p data/$1/Alignment_NLP
    flag=0
    for file in data/$1/Alignment/*{src,tgt}
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

#Text01=`ls data/{BML12,NJ12,KTHJ08,TPR11,MS12,SG12}/Events/*1.Event.xml`
#Text02=`ls data/{BML12,NJ12,KTHJ08,MS12,SG12}/Events/*2.Event.xml`
#Text03=`ls data/{BML12,NJ12,KTHJ08,TPR11,MS12,SG12}/Events/*3.Event.xml`
#Text08=`ls data/{BD08,BML12,NJ12,TPR11,MS12,SG12}/Events/*3.Event.xml`
#Text04=`ls data/{ACS08}/Events/*1.Event.xml`
#Text05=`ls data/{ACS08}/Events/*2.Event.xml`
#Text06=`ls data/{ACS08}/Events/*3.Event.xml`
#Text07=`ls data/{ACS08}/Events/*4.Event.xml`
#Text09=`ls data/{LWB09}/Events/*1.Event.xml`
#Text10=`ls data/{LWB09}/Events/*2.Event.xml`
#Text11=`ls data/{LWB09}/Events/*3.Event.xml`
#Text12=`ls data/{JLG10}/Events/*1.Event.xml`
#Text13=`ls data/{JLG10}/Events/*2.Event.xml`
#Text14=`ls data/{JLG10}/Events/*3.Event.xml`
#Text15=`ls data/{JLG10}/Events/*4.Event.xml`
#Text16=`ls data/{JLG10}/Events/*5.Event.xml`
#Text17=`ls data/{JLG10}/Events/*6.Event.xml`
#Text18=`ls data/{BML12,NJ12,MS12,SG12}/Events/*5.Event.xml`
#Text19=`ls data/{BML12,NJ12,MS12,SG12}/Events/*6.Event.xml`
#Text20=`ls data/{ACS08}/Events/*5.Event.xml`

function TextMap ()
{

    if   [ $1 == Text01 ] ; then 
        TextStudies=`ls -m data/{BML12,NJ12,KTHJ08,TPR11,MS12,SG12}/Events/*1.Event.xml`
    elif [ $1 == Text02 ] ; then 
        TextStudies=`ls -m data/{BML12,NJ12,KTHJ08,MS12,SG12}/Events/*2.Event.xml`
    elif [ $1 == Text03 ] ; then
        TextStudies=`ls -m data/{BML12,NJ12,KTHJ08,TPR11,MS12,SG12}/Events/*3.Event.xml`
    elif [ $1 == Text08 ] ; then
        TextStudies=`ls -m data/{BML12,NJ12,TPR11,MS12,SG12}/Events/*3.Event.xml` 
        TextStudies="${TextStudies},`ls -m data/BD08/Events/*1.Event.xml`"
    elif [ $1 == Text04 ] ; then
        TextStudies=`ls -m data/ACS08/Events/*1.Event.xml`
    elif [ $1 == Text05 ] ; then
        TextStudies=`ls -m data/ACS08/Events/*2.Event.xml`
    elif [ $1 == Text06 ] ; then
        TextStudies=`ls -m data/ACS08/Events/*3.Event.xml`
    elif [ $1 == Text07 ] ; then
        TextStudies=`ls -m data/ACS08/Events/*4.Event.xml`
    elif [ $1 == Text09 ] ; then
        TextStudies=`ls -m data/LWB09/Events/*1.Event.xml`
    elif [ $1 == Text10 ] ; then
        TextStudies=`ls -m data/LWB09/Events/*2.Event.xml`
    elif [ $1 == Text11 ] ; then
        TextStudies=`ls -m data/LWB09/Events/*3.Event.xml`
    elif [ $1 == Text12 ] ; then
        TextStudies=`ls -m data/JLG10/Events/*1.Event.xml`
    elif [ $1 == Text13 ] ; then
        TextStudies=`ls -m data/JLG10/Events/*2.Event.xml`
    elif [ $1 == Text14 ] ; then
        TextStudies=`ls -m data/JLG10/Events/*3.Event.xml`
    elif [ $1 == Text15 ] ; then
        TextStudies=`ls -m data/JLG10/Events/*4.Event.xml`
    elif [ $1 == Text16 ] ; then
        TextStudies=`ls -m data/JLG10/Events/*5.Event.xml`
    elif [ $1 == Text17 ] ; then
        TextStudies=`ls -m data/JLG10/Events/*6.Event.xml`
    elif [ $1 == Text18 ] ; then
        TextStudies=`ls -m data/{BML12,NJ12,MS12,SG12}/Events/*5.Event.xml`
    elif [ $1 == Text19 ] ; then
        TextStudies=`ls -m data/{BML12,NJ12,MS12,SG12}/Events/*6.Event.xml`
    elif [ $1 == Text20 ] ; then
        TextStudies=`ls -m data/ACS08/Events/*5.Event.xml`
    fi 
}

AllTexts="Text01 Text02 Text03 Text08 Text04 Text05 Text06 Text07 Text09 Text10 Text11 Text12 Text13 Text14 Text15 Text16 Text17 Text18 Text19 Text20"


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
        FinalTreex $study

    done
    exit;

## convert Events to treex
elif [ "$1" == "copy" ]; then  
    if [ "$2" == "all" ]; then STUDY=$STUDY
    else STUDY=$2;
    fi

    for study in $STUDY ; do CopyData $study ; done

    exit;

## convert Events to treex
elif [ "$1" == "treex" ]; then  
    if [ "$2" == "all" ]; then STUDY=$STUDY
    else STUDY=$2;
    fi

    for study in $STUDY ; do ToSingleTreex $study ; FinalTreex $study; done

    exit;

## produce Tables  
elif [ "$1" == "tables" ]; then
    if [ "$2" == "all" ]; then STUDY=$STUDY
    else STUDY=$2;
    fi

    for study in $STUDY ; do Trl2TokenTables $study; done

    exit;

## Multiple files in treex 
elif [ "$1" == "text" ]; then  
    if [ "$2" == "all" ]; then STUDY=$AllTexts;
    else STUDY=$2;
    fi

    for text in $STUDY ; do 
        TextStudies="";
        TextMap $text
        echo "Assemble recordings for: $text"
        ./Trl2Treex.pl -O "data/Treex/raw/$text" -T "$TextStudies" 
        FinalTreex $text
    done

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

