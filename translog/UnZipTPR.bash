STUDY="ACS08 BD08 CFT12 HF12 BML12 JLG10 KTHJ08 LWB09 MS12 NJ12 RH12 SG12 TPR11 TPR12"

for zip in tpr-db-one-zero/*/*/*zip; do 
  echo "$zip";
  unzip $zip -d tpr-db-one-zero
  rm -f $zip
done

unzip "tpr-db-one-zero/MetaData.zip" MetaData
