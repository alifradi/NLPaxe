import spacy
import pandas as pd
nlp = spacy.load('en',parse=True,tag=True, entity=True)
def get_NE(text):
    doc = nlp(text)
    l1 = list()
    l2 = list()
    for k in doc.ents:
        l1.append(k.text)
        l2.append(k.label_)
    df = pd.DataFrame(list(zip(l1, l2)), columns =['Named Entity', 'Label'])
    return df
