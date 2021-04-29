def get_NE(text):
    doc = nlp(text)
    l1 = list()
    l2 = list()
    for k in doc.ents:
        l1.append(k.text)
        l2.append(k.label_)
    df = pd.DataFrame(list(zip(l1, l2)), columns =['Named Entity', 'Label'])
    return df
# Creating our tokenizer function
def spacy_tokenizer(sentence):
    # Creating our token object, which is used to create documents with linguistic annotations.
    mytokens = parser(sentence)
    # Lemmatizing each token and converting each token into lowercase
    mytokens = [ word.lemma_.lower().strip() if word.lemma_ != "-PRON-" else word.lower_ for word in mytokens]
    # Removing stop words
    mytokens = [ word for word in mytokens if word not in stop_words and word not in punctuations ]
    # return preprocessed list of tokens
    return mytokens  
# Creating our tokenizer function
def doc_spacy_tokenizer(sentence):
    doc1 = nlp(sentence)
    l=list()
    for token in doc1:
        if token.lemma_ != "-PRON-" and token.text not in punctuations:
           l.append(token.lemma_)
    return l
def doc_spacy_tagger(sentence):
    doc1 = nlp(sentence)
    l=list()
    for token in doc1:
        if token.lemma_ != "-PRON-" and token.text not in punctuations:
           l.append(token.pos_)
    return l
