DIR=data/$1/

rm -rf ${DIR}Alignment_NLP
mkdir -p ${DIR}Alignment_NLP

python modify_files.py ${DIR}Alignment/*.src
python modify_files.py ${DIR}Alignment/*.tgt

cp ${DIR}Alignment/*.atag ${DIR}Alignment_NLP
