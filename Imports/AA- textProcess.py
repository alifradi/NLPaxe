class ProcessText:
    "This class regroups text processing tools"
    def __init__(self, text):
        import spacy
        import pandas as pd
        from spacy.lang.en.stop_words import STOP_WORDS
        from spacy.lang.en import English
        import string
        self.text        = text
        self.nlp         = spacy.load('en',parse=True,tag=True, entity=True)
        from spacy.lang.en import English
        self.parser      = English()
        import string
        self.punctuations = string.punctuation
        self.stop_words   = spacy.lang.en.stop_words.STOP_WORDS
    def get_NE(self):
      """
      t = ProcessText("Bill Gates is a great inspiration") 
      t.spacy_tokenizer()
      ### Result: {'entities': ['Bill Gates'], 'labels': ['PERSON']}
      """
      doc = self.nlp(self.text)
      entity            = list()
      label             = list()
      for k in doc.ents:
        entity.append(k.text)
        label.append(k.label_)
      return {'entities':entity, 'labels':label}
    def spacy_tokenizer(self):
      """
      t = ProcessText("Bill Gates is a great inspiration") 
      t.spacy_tokenizer()
      ### Result: [Bill, Gates, is, a, great, inspiration]
      """
      mytokens = self.parser(self.text)
      mytokens = [ word for word in mytokens ]
      return mytokens 
    def doc_spacy_tagger(self):
      """
      t = ProcessText("Bill Gates is a great inspiration") 
      t.doc_spacy_tagger()
      ### Result: ['PROPN', 'PROPN', 'VERB', 'DET', 'ADJ', 'NOUN']
      """
      doc = self.nlp(self.text)
      l=list()
      for token in doc:
        l.append(token.pos_)
      return l
    def tokenize(self, remove_stopWords = True):
      """
      t = ProcessText("Bill Gates is a great inspiration") 
      t.tokenize()
      ### Result: ['bill', 'gates', 'great', 'inspiration']
      t.tokenize(False)
      ### Result: ['bill', 'gates', 'be', 'a', 'great', 'inspiration']
      """
      if remove_stopWords == True:
        mytokens = self.parser(self.text)
        # Lemmatizing each token and converting each token into lowercase
        mytokens = [ word.lemma_.lower().strip() if word.lemma_ != "-PRON-" else word.lower_ for word in mytokens]
        # Removing stop words
        mytokens = [ word for word in mytokens if word not in self.stop_words and word not in self.punctuations ]
        # return preprocessed list of tokens
        return mytokens
      elif remove_stopWords == False:
        doc = self.nlp(self.text)
        l=list()
        for token in doc:
          if token.lemma_ != "-PRON-" and token.text not in self.punctuations:
            l.append(token.lemma_)
        return l
    def get_compound_pairs(self, verbose=False):
      """
      Return tuples of (multi-noun word, adjective or verb) for document.
      Try 'The company's customer service was terrible.'
      will give you '[(customer service, terrible)]'
      """
      doc = self.nlp(self.text)
      compounds = [tok for tok in doc if tok.dep_ == 'compound'] # Get list of compounds in doc
      compounds = [c for c in compounds if c.i == 0 or doc[c.i - 1].dep_ != 'compound'] # Remove middle parts of compound nouns, but avoid index errors
      tuple_list = []
      if compounds:
        for tok in compounds:
          pair_item_1, pair_item_2 = (False, False) # initialize false variables
          noun = doc[tok.i: tok.head.i + 1]
          pair_item_1 = noun
          # If noun is in the subject, we may be looking for adjective in predicate
          # In simple cases, this would mean that the noun shares a head with the adjective
          if noun.root.dep_ == 'nsubj':
            adj_list = [r for r in noun.root.head.rights if r.pos_ == 'ADJ']
            if adj_list:
              pair_item_2 = adj_list[0] 
            if verbose == True: # For trying different dependency tree parsing rules
               print("Noun: ", noun)
               print("Noun root: ", noun.root)
               print("Noun root head: ", noun.root.head)
               print("Noun root head rights: ", [r for r in noun.root.head.rights if r.pos_ == 'ADJ'])
          if noun.root.dep_ == 'dobj':
            verb_ancestor_list = [a for a in noun.root.ancestors if a.pos_ == 'VERB']
            if verb_ancestor_list:
              pair_item_2 = verb_ancestor_list[0]
            if verbose == True: # For trying different dependency tree parsing rules
               print("Noun: ", noun)
               print("Noun root: ", noun.root)
               print("Noun root head: ", noun.root.head)
               print("Noun root head verb ancestors: ", [a for a in noun.root.ancestors if a.pos_ == 'VERB'])
          if pair_item_1 and pair_item_2:
            tuple_list.append((pair_item_1, pair_item_2))
      return tuple_list
        
        
        


  
