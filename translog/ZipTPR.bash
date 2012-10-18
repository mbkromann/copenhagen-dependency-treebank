STUDY="ACS08 BD08 CFT12 HF12 BML12 JLG10 KTHJ08 LWB09 MS12 NJ12 RH12 SG12 TPR11 TPR12"

for dir in $STUDY; do 
  if [ -e "$dir/Translog-II/" ] ; then
    mkdir -p "tpr-db-one-zero/$dir/Translog-II/" 
    for file in $dir/Translog-II/*xml; do 
      echo "$file";
      zip "tpr-db-one-zero/$file.zip" $file
    done
   fi

  if [ -e "$dir/Alignment/" ] ; then
    mkdir -p "tpr-db-one-zero/$dir/Alignment/"   
    for file in $dir/Alignment/*; do
      echo "$file";
      zip "tpr-db-one-zero/$file.zip" $file
    done
   fi

  if [ -e "$dir/FixationCorrections/" ] ; then
    mkdir -p "tpr-db-one-zero/$dir/FixationCorrections/"   
    for file in $dir/FixationCorrections/*; do
      echo "$file";
      zip "tpr-db-one-zero/$file.zip" $file
    done
   fi

  if [ -e "$dir/projects/" ] ; then
    mkdir -p "tpr-db-one-zero/$dir/projects/"
    for file in $dir/projects/*; do
      echo "$file";
      zip "tpr-db-one-zero/$file.zip" $file
    done
   fi

done 

mkdir -p "tpr-db-one-zero/$dir/projects/"
zip "tpr-db-one-zero/MetaData.zip" MetaData
exit;

