#!/usr/bin/python
'''
This program modifies annotates raw XML files with POS tags, Lemma and Dependency Info 
'''
import codecs
import re
import sys
import os
import shutil

from nltk import sent_tokenize
from xml.dom.minidom import parseString
from xml.dom.minidom import Document



'''
new packages
'''
from taglemma import do_tagging_treetagger, do_tagging_english

'''''''''''''''''''''''''''''''''''''''
some initialization
'''''''''''''''''''''''''''''''''''''''
tree_tagger_path = os.environ['TAGGER_PATH']    
original_attrib_list=[]
token_list=[]
tags=[]
lemmas=[]

sentence_break=[]



'''''''''''''''''''''''''''''''''''''''
functions
'''''''''''''''''''''''''''''''''''''''

def reset_data():
    token_list[:]=[]
    
    tags[:]=[]
    original_attrib_list[:]=[]
    sentence_break[:]=[]
    lemmas[:]=[]
    

def extract_text(fileName):
    #extracts text from XML data
    text_data=""
    language = ""
    tag_value = ""
    segmenter_value = ""
    dep_parser_value = ""
    
    with codecs.open(fileName,"r","utf-8") as f:
        data = f.read()      
        
        data = data.encode("utf-8","ignore")

        dom = parseString(data)
        text_nodes=dom.getElementsByTagName('Text')
        for text_node in text_nodes:
            
            language=text_node.getAttribute('language')
            tag_value=text_node.getAttribute('tagger')
            lemma_value=text_node.getAttribute('lemmatizer')
            seg_value=text_node.getAttribute('sent_segmenter')
            dep_parser_value=text_node.getAttribute('dep_parser')
            
            word_elements=text_node.getElementsByTagName('W')
            for element in word_elements:
                attrib_list={}
                keys=element.attributes.keys()
                
                keys.sort()
                for key in keys:
                    value=element.getAttribute(key)
                    key=key.encode("utf-8")
                    value=value.encode("utf-8")
                    attrib_list[key]=value
                original_attrib_list.append(attrib_list)
                wordValue= element.childNodes[0].nodeValue
                
                text_data+=wordValue+" "
                
        text_data=text_data.rstrip(" ").encode("utf-8")
       
    return list([text_data,language,tag_value,lemma_value,seg_value,dep_parser_value])

def reformat_text(text):
    # Separate most punctuation
    text = re.sub(r"([^\w\.\'\-\/,&])", r' \1 ', text)
    # Fix missing Unicode support in in re.sub Python <3.0
    text = re.sub(r"\s([\xaa-\xff])\s", r"\1" ,text)
    # Separate commas if they're followed by space.
    text = re.sub(r"(,\s)", r' \1', text)
    return text

def prepare_file_name(path):
    dir_file = os.path.split(path)
    dir_write = dir_file[0]+"/../Alignment_NLP/"+dir_file[1]
    return dir_write
    
def tokenize_sentence(text):
    #sentence tockenizer
    return sent_tokenize(text)
def tokenize_chinese_sentence(text):
    eol_char = u'\u3002'.encode("utf-8")
    temp_text = text.split(eol_char)
    return_text = []
    for text in temp_text:
        if(text!=""):
            text=text+eol_char
            return_text.append(text)
    return return_text

def pos_tag_english(sentence):
    #pos_tagger
    data = do_tagging_english(sentence)
    for info in data:
        token_list.append(info[0])
        tags.append(info[1])
        lemmas.append(info[2])
        
    sentence_break.append(str(len(token_list) - 1))  
    
def pos_tag_tree_tagger(sentence,language):
    data=do_tagging_treetagger(sentence, language, tree_tagger_path)
    for info in data:
        token_list.append(info[0])
        tags.append(info[1])
        lemmas.append(info[2])
        
    sentence_break.append(str(len(token_list)-1))


def write_back(xmlFile,language,tagger,lemmatizer,segmenter,dep_parser):
    doc = Document()
    
    root = doc.createElement("Text")
    root.setAttribute("language", language)
    if tagger != "":
        root.setAttribute("tagger", tagger)
    if lemmatizer != "":
        root.setAttribute("lemmatizer", lemmatizer)
    if segmenter != "":
        root.setAttribute("sent_segmenter", segmenter)
    if dep_parser != "":
        root.setAttribute("dep_parser", dep_parser)
    
    j=0 #for sentence break
    breaker_flag=0
    if (sentence_break!=None):
        breaker_flag=1
    
    for i in range(len(token_list)):
        #gets the original attributes and retains it
        
        attribs=original_attrib_list[i]
               
        attribs['pos']=tags[i]
        if(language!="zh"):
            attribs['lemma']=lemmas[i]
        
        
            
        if(breaker_flag==1):
            #Add sentence end info
            
            if(str(i)==sentence_break[j]):
                attribs['boundary']="sentence"
                j+=1
        attrib_keys = attribs.keys()
        attrib_keys.sort()
        W_node = doc.createElement("W")
        for attrib_key in attrib_keys:
            W_node.setAttribute(attrib_key, attribs[attrib_key])
        W_node.appendChild(doc.createTextNode(token_list[i]))
        root.appendChild(W_node)
    doc.appendChild(root)
            
    
    
    with codecs.open(xmlFile,"w") as f:
        ugly_XML = doc.toprettyxml(indent=" ",encoding="utf-8")
        text_re = re.compile('>\n\s+([^<>\s].*?)\n\s+</', re.DOTALL)    
        prettyXml = text_re.sub('>\g<1></', ugly_XML)
	prettyXml = prettyXml.replace("&amp;","&")
	prettyXml = prettyXml.replace("&quot;","\"")

        f.write(prettyXml)
        
    return True

'''''''''''''''''''''''''''''''''''''''
main program for english
'''''''''''''''''''''''''''''''''''''''

def for_english(text,outfile,language,tagger,lemmatizer,sent_tokenizer,dep_parser):
    
    sentences=tokenize_sentence(text)
    for sentence in sentences:
        pos_tag_english(sentence)
    write_back(outfile,language,tagger,lemmatizer,sent_tokenizer,dep_parser)
    

def for_tree_tagger(text,outfile,language,tagger,lemmatizer,sent_tokenizer,dep_parser):
    language = language.encode("utf-8") 
    if(language=="zh"):  
        sentences = tokenize_chinese_sentence(text)
    else:
        sentences = tokenize_sentence(text)
        
    for sentence in sentences:
        pos_tag_tree_tagger(sentence,language)
    
    write_back(outfile,language,tagger,lemmatizer,sent_tokenizer,dep_parser)
     

'''
Execution
'''

sys.stderr.write ("Start\n")
 
'''
Save functions inside a dictionary. for different taggers
'''
to_do = {"en":for_english,"tt":for_tree_tagger}

sys.stderr.write ("Getting pos tags and lemmas\n")

files = sys.argv

for i in range(1,len(files)):
    reset_data()
    path = files[i]
    info=extract_text(path)
    
    text = info[0]
    language = info[1]
    tagged=info[2]
    lemmatized=info[3]
    segmented = info[4]
    dep_parsed =info[5] 
    outpath = prepare_file_name(path)
    
    if (tagged == ""):
        #if file is already tagged
        if(language == "en"):
            #use nltk tagger
            tagged="nltk-pos-tagger"
            lemmatized = "nltk-wordnet-lemmatizer"
            segmented = "nltk_sent_tokenizer"           
            for_english(text,outpath,language,tagged,lemmatized,segmented,dep_parsed) 
            sys.stderr.write("FILE("+language+"): "+path+" was annotated and saved.\n")
            
        elif(language == "de" or language == "pt" or language == "es" or language == "zh" or language =="da" or language =="hi"):
            #use tree tagger
            if(tree_tagger_path==""):
                sys.stderr.write("Tree tagger module path not defined for language"+language+"\n")
                sys.stderr.write("Simply Copying files\n")
                shutil.copy(path, outpath)
                
            else:
                tagged="tree-tagger"
                lemmatized = "tree-tagger"
                segmented = "nltk_sent_tokenizer"
                if (language =="hi"):
                    tagged="TnT-tagger"
                    lemmatized = "Hindi-lemmatizer"
                    segmented = "nltk_sent_tokenizer"
                for_tree_tagger(text,outpath,language,tagged,lemmatized,segmented,dep_parsed)
                sys.stderr.write("FILE("+language+"): "+path+" was annotated and saved.\n")
       
        else:    
            #No taggers
            shutil.copy(path, outpath)
            sys.stderr.write("FILE: "+path+" contains language \""+language+"\" for which resources not available.\n")
             
    else:
        shutil.copy(path, outpath)
        sys.stderr.write("FILE: "+path+" is already annotated. Copying without making changes.\n")


