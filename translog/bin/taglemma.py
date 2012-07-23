'''
Created on 04-Jul-2012

@author: abhijit

Tree tagger is a POS tagger and Lemmatizer for spanish, german and portuguese
'''
import os
import codecs
from nltk import pos_tag
from nltk.stem.wordnet import WordNetLemmatizer 

def get_lemma_english(word,tag):
    #Obtains Base woed
    lmtz=WordNetLemmatizer()
    
    
    pos=tag[0]
    if(pos=="V" or pos=="N" or pos=="J" or pos=="R"):
        #for adjective
        if(pos=="J"):
            pos="a"
        return lmtz.lemmatize(word, pos.lower())    
    else:
        return word
def do_tagging_english(sentence):
    word_tag_lemma=[]
    tokens=sentence.split()
    tagged_words=pos_tag(tokens)
    for word,tag in tagged_words:
        lemma=get_lemma_english(word, tag)
        lemma = lemma.decode("utf-8")
        word = word.decode("utf-8")
        
        if(word.__contains__(" ")):
            word_part=word.split(" ")
            for i in range(len(word_part)):
                word_tag_lemma.append(list(word_part[i],tag,lemma,str(i+1)))
        else:

            word_tag_lemma.append([word,tag,lemma])
    return word_tag_lemma
      
def do_tagging_treetagger(sentence,language,treetagger_path):
    word_tag_lemma=[]
    command="echo \""+sentence+"\"|"+treetagger_path+"/cmd/tree-tagger-"+language+"-utf8 >tempfile"
    flag=os.system(command)
    if(flag==0):
        with codecs.open("tempfile","r" ,"utf-8") as f:
            lines = (line.rstrip('\n') for line in f) 
            for line in lines:
                
                info=line.split("\t")
                #tokenizer incompatibility
                
                if(info[0].__contains__(" ")):
                    info_part=info[0].split()
                    for i in range(len(info_part)):
                        word_tag_lemma.append([info_part[i],info[1],info[2],str(i+1)])
                else:
                    word_tag_lemma.append(info)
    try:     
        os.system("rm -rf tempfile")
    except:
        print "no file created"
    return word_tag_lemma
        

     
#print do_tagging_treetagger(text, "portuguese", "/home/critt/Desktop/Tagger")

