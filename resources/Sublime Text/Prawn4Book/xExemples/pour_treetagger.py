'''
Created on 08.12.2014

@author: Andreas
'''
from settings import *
import psycopg2
from lib.treetagger import TreeTagger
from nltk.tokenize.punkt import PunktWordTokenizer, PunktParameters, PunktSentenceTokenizer

class POS_Tagger():
    def __init__(self, 
                 path_to_home=TREETAGGER_PATH_TO_HOME, 
                 path_to_model=TREETAGGER_PATH_MODEL):
        
        self.tagger = TreeTagger(path_to_home, parameters=[r'-lemma', r'-token', path_to_model])
        
    def tag(self, tokens):
        return self.tagger.tag(tokens)
        
        
class Sent_Tokenizer():
    def __init__(self):
        with open(TREETAGGER_ABBREVIATIONLIST, mode='r', encoding='utf-8') as f:
            abbr = set([l.strip('.\n') for l in f.readlines()])
        
        punkt_param = PunktParameters()
        punkt_param.abbrev_types = abbr 
        self.tokenizer = PunktSentenceTokenizer(punkt_param)
    
    def tokenize(self, text):
        return self.tokenizer.tokenize(text)

class Word_Tokenizer():
    def __init__(self):
        self.tokenizer = PunktWordTokenizer()
    
    def tokenize(self, sentence):
        return self.tokenizer.tokenize(sentence)
