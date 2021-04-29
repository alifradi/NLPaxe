import spacy
nlp = spacy.load('en_core_web_lg')

sim= lambda t1, t2: nlp(t1).similarity(nlp(t2))
