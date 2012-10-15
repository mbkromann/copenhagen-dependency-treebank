#!/bin/bash


for file in Translog-II/*.xml ; do

    token=${file%.xml}
    token=${token/Translog-II/Alignment}
   ../bin/TokenizeCasmacat.pl -T $file -D $token

done
