# Spacy & Text
import spacy
from spacy.lang.en import English
from spacy.lang.en.stop_words import STOP_WORDS
import string

# Data Manipulation
import numpy as np
import pandas as pd

#Sciket Learn
from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer
from sklearn.base import TransformerMixin
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression, LinearRegression
from sklearn import metrics
