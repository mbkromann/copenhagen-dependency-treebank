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
            segmenter_value=text_node.getAttribute('segmenter')
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
       
    return list([text_data,language,tag_value,segmenter_value,dep_parser_value])

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
    
    
        
def pos_tag_german(sentence):
    #pos_tagger
    data=do_tagging_treetagger(sentence, "german", tree_tagger_path)
    for info in data:
        token_list.append(info[0])
        tags.append(info[1])
        lemmas.append(info[2])
        
    sentence_break.append(str(len(token_list)-1))  
    
    
def pos_tag_spanish(sentence):
    #pos_tagger
    data=do_tagging_treetagger(sentence, "spanish", tree_tagger_path)
    for info in data:
        token_list.append(info[0])
        tags.append(info[1])
        lemmas.append(info[2])
        
    sentence_break.append(str(len(token_list)-1))
     
    
def pos_tag_portuguese(sentence):
    #pos_tagger
    data=do_tagging_treetagger(sentence, "portuguese", tree_tagger_path)
    
    for info in data:
        
        token_list.append(info[0])
        tags.append(info[1])
        lemmas.append(info[2])
        
    sentence_break.append(str(len(token_list)-1))

def pos_tag_chinese(sentence):
    #pos_tagger
    data=do_tagging_treetagger(sentence, "chinese", tree_tagger_path)
    
    for info in data:
        token_list.append(info[0])
        tags.append(info[1])
        lemmas.append(info[2])
        
    sentence_break.append(str(len(token_list)-1))  


def write_back(xmlFile,language,tagger,lemmatizer,segmenter,dep_parser):
    doc = Document()
    
    root = doc.createElement("Text")
    root.setAttribute("language", language)
    root.setAttribute("tagger", tagger)
    root.setAttribute("lemmatizer", lemmatizer)
    root.setAttribute("sent_segmenter", segmenter)
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
                attribs['last']="sentence"
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
        f.write(prettyXml)
        
    return True

'''''''''''''''''''''''''''''''''''''''
main program for english
'''''''''''''''''''''''''''''''''''''''
def for_english(text,outfile):
    
    sentences=tokenize_sentence(text)
    for sentence in sentences:
        pos_tag_english(sentence)
    write_back(outfile,"en","nltk-pos-tagger","nltk-wordnet-lemmatizer","nltk_sent_tokenizer","None")
    reset_data()
    
'''''''''''''''''''''''''''''''''''''''
 program for Spanish
'''''''''''''''''''''''''''''''''''''''

def for_spanish(text,outfile):     
     
    sentences=tokenize_sentence(text)
    for sentence in sentences:
        pos_tag_spanish(sentence)
    write_back(outfile,"es","tree-tagger","tree-tagger","nltk_sent_tokenizer","None")
    reset_data()
    
'''''''''''''''''''''''''''''''''''''''
 program for German
'''''''''''''''''''''''''''''''''''''''  

def for_german(text,outfile):
    
    sentences=tokenize_sentence(text)
    for sentence in sentences:
        
        pos_tag_german(sentence)
    write_back(outfile,"de","tree-tagger","tree-tagger","nltk_sent_tokenizer","None")
    reset_data()
    
'''''''''''''''''''''''''''''''''''''''
 program for Portuguese
'''''''''''''''''''''''''''''''''''''''  
def for_portuguese(text,outfile):
    
    
    sentences=tokenize_sentence(text)
    for sentence in sentences:
        
        pos_tag_portuguese(sentence)
    write_back(outfile,"pt","tree-tagger","tree-tagger","nltk_sent_tokenizer","None")
    reset_data()
    
def for_chinese(text,outfile):

    sentences = tokenize_chinese_sentence(text)
    
    for sentence in sentences:
        
        pos_tag_chinese(sentence)
        write_back(outfile,"zh","tree-tagger","tree-tagger","nltk_sent_tokenizer","None")
    reset_data()

'''
Execution
'''

sys.stderr.write ("Start\n")
 
'''
Save functions inside a dictionary
'''
to_do = {"en":for_english,"de":for_german,"pt":for_portuguese,"es":for_spanish,"zh":for_chinese}

sys.stderr.write ("Getting pos tags and lemmas\n")

files = sys.argv

for i in range(1,len(files)):
    path = files[i]
    info=extract_text(path)
    
    text = info[0]
    language = info[1]
    tagger=info[2]
    
    outpath = prepare_file_name(path)
    
    if (tagger == ""):
        #if file is already tagged
        modify = to_do.get(language,"Not found")
        if(modify != "Not found"):
            if(language == "de" or language == "pt" or language == "es" or language == "zh"):
                #use tree tagger
                if(tree_tagger_path==""):
                    sys.stderr.write("Tree tagger module path not defined for language"+language+"\n")
                    sys.stderr.write("Simply Copying files\n")
                    shutil.copy(path, outpath)
                    
                else:
                    modify(text,outpath)
                    sys.stderr.write("FILE("+language+"): "+path+" was annotated and saved.\n")
            else:
                #other taggers
                modify(text,outpath) 
                sys.stderr.write("FILE("+language+"): "+path+" was annotated and saved.\n")
                
        else:
            shutil.copy(path, outpath)
            sys.stderr.write("FILE: "+path+" contains language for which resources not available.\n")
    else:
        shutil.copy(path, outpath)
        sys.stderr.write("FILE: "+path+" is already annotated. Copying without making changes.\n")


