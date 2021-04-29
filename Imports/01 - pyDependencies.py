# Spacy & Text
import spacy
from spacy.lang.en import English
from spacy.lang.en.stop_words import STOP_WORDS
import string

# Data Manipulation
import numpy as np
import pandas as pd


punctuations = string.punctuation
nlp = spacy.load('en',parse=True,tag=True, entity=True)
# Load English tokenizer, tagger, parser, NER and word vectors
parser = English()
# Create our list of punctuation marks
punctuations = string.punctuation
# Create our list of stopwords
stop_words = spacy.lang.en.stop_words.STOP_WORDS
