# NLP_summary

# 00- Collect data from guardian API in R
How to set an API R client to scrap articles from the Guardian.
# 00- Collecting data from web
Based on quality research results that Google news can afford topics that are likely to be interesting for financial audit, we suggested that we can determin a list of queries that select a bench of candidates nrws articles from which we learn topics and keywords of each topic.  

This glosssary was a good start to generate queries that we affinated and aggregated by topic so far:  

https://businessfraudprevention.org/glossary-of-fraud-terms/   

The list of final topics we selected at this level consists of: "suspecions activities", "terrorism", "financial crime" and "fraud"

### req_GOOG
Generates links of main Google news paginations in respect to a the input query  

Arguments:  

1- query a short text query as typed on Google bar, example = "extended confiscation"  

2- pages a 10-incremented list of pagination indexes , example = seq(from = 0, to = 190, by = 10)
### Articles_by_topic
Generates links of news articles found in main Google pagination indexes in respect to a the input query  
Arguments:  

1- query a short text query as typed on Google bar, example = "extended confiscation"  

2- pages a 10-incremented list of pagination indexes , example = seq(from = 0, to = 190, by = 10)
### get_news
Stores the scraped articles in main Google news pagination indexes in respect to the input query in a data frame with the following columns: 'query', 'source', 'titles', 'texts', 'keywords'.  

Paragraphs are separated by ' n' and time sleep has been set to avoid scrap restrictions.
Arguments:  

1- query a short text query as typed on Google bar, example = "extended confiscation"  

2- pages a 10-incremented list of pagination indexes , example = seq(from = 0, to = 190, by = 10)
BERTopic clustering.html
### Scrap chunk
Last chunk of code in this markdown shows a progress bar and lets the maximum of pagination to travel in Goole news resarch to be fixed.  

At this step, we loop over all topics and list of queries to extract news articles that Google news suggests, then saves them into an RDS compressed file under the name of specified topic, the date of scraping and places it under the file data of this repository.
# 01- Segment based document recommendation
This work is based on the article **A_segment-based_approach_to_clustering_multi-topic** available under/documentation of this repository.

**Grafe-TopicModelingInFinancialDocuments** is also avaluable article of same topic.

1 - import Reuters corpus, libraries and scripts available under /data of this repository.  

2 - preview of named entity extraction using spacy tools  
preview of removing named entities frpm texts  

preview of intelligent tokenization (adding linguistic nature of each token)  

preview of how to tokenize a text into a dataframe containing tokens, linguistic nature, and id of doc   

3 - Segmentize a dataframe ot texts into a dataframe of paragraph specifying column name containing the articles' bodies and patter of paragraph split  

output dataframe indexes the praragraph for possible job runs  

Eliminate docs with less than 2 paragraphs (for segmentation puposes)  

4 - Create dataframe of detected named entities with their labels and  praragraph numbers that were extracted from for later jobs  

5 - Preview of segments creation using one single documents  

6 - Generate all segments from all documents that have been processed  

7 - Perform clustering on segments and then on clusters of segment to get sets of segments form all corpus data that are in semantic harmony  

8 - Pick a random segment by id such as Seg-12-1 and get top matching documents.  
# 02- Unsupervised text-topics exploration using BERTopic

### Links to be saved

[GitHub BERTopic](https://github.com/MaartenGr/BERTopic) 

[Toward data science BERTopic](https://towardsdatascience.com/topic-modeling-with-bert-779f7db187e6) 



# 03- Topic Word Cloud modeling

1 - imports data (reuters corpus) and select an article  

2 - split article text to sentences   
    extract named entities  

3 - remove named entities from texts  

strip all words with no additional information  

add a frequency column to count words  

lemmatize  

cast to document2term matrix dtm  

4 - imports LDA_optimal as a function from Rfunctions  

perform LDA and plot its perplexity function in order to pick out the best number of topics to be extracted   
   
5 - plot the word cloud distinguished to topics by colours  

# 04- Sentiment analysis with phrasal bank
This markdown builds two different models

1- a linear model for sentiment intensity

2- a mulitnomial logistic regression to classify text segments into three possible sentiment levels

The problem turns to be supervised based on the work that have been done by 16 experts who picked up around 8 thounds of text segments and labeled them according to what they state as financial sentiment.

The markdown evaluate the performance of those models on Hallibuton quarterly result reporrted in the pdf document available in this repository.

The labeled dataset is known under **Financial PhraseBank**. See  [this documentation](https://www.researchgate.net/publication/251231364_FinancialPhraseBank-v10) for further information.

# 05- Guided topic modeling Seeds collection approach

This approach consists of guiding the Latent Direchlet Allocation (LDA) algorithm to better fit the modeled topics (via matrix factorization) to the topics we want to put stress on. The critical part here is the selection of seeds we want to force the LDA to consider when building a topic as a cluster of terms.

First thoughts were to use the genuis Google research engine for recommending news articles that are likely to report latest news related to a stated query.

A further level of difficulty  is about collecting queries to Google and topics to put a focus on. Topics can be overlapping when building disjoint topics under a single domain of activity such as financial audit. 

Thus a research has been done and based on available glossaries and on trendings of financial audit components. This effort juiced a list of queries labeled under topics we want to model.

The coming part describe, from a concept perspective, how articles are processed to give out seeds we feed to LDA model in order to give it biais and enable its posteriori to track topics existence under candidate test article:

### Read all texts

Script to scrap and read all articles from differents collected corpuses by topic and scrap date.

### SeedCreation

1 - import and merge text articles from different topics under one single corpus   

2 - clean special characters  
Replace of concatenations like "can't" -> can not  
    
3 - importcustomized stopwords  
tokenize titles/texts under each document in one/two grams  
filter words with less than 3 characters  
generate id, unigram/bigram term, frequency dataframe for each topic  
    
4 - Generate rank column based on frequency with topics  

5 - Append queries that triggered the research on google news for each document  

6 - Add a similarity column about queries/terms  

7 - Gather all results together  

Seeds are uni-grams/bi-grams that are frequent in topics we are trecking and that are likely to be similar to queries used to find the source article on Google news. Similarity between queries and seeds is defined in the sense of [spacy models](https://spacy.io/models/en).

Seed creation is automated under the imported functionalities.

### Tokenizing docs

1 - filter results of seedcreation thoughout several levels (similarity query-tem, rank ,...)  

2 - Intialize a matrix of (num_topics, num_terms) size   

3 - Set wieghts of each term for each topic to force LDA to adapt its distribution to the seeds we fed into it  
4 - Run LDA with seeds on training data  

5 - for each input doc we want to test the model on, we tokenize the title and the article's body the same way we did for the training data and we join the result  

with a right join to all vacobulary terms setting the non existing terms frequencies to 0   (it won't affect the model), by then we cast it to dtm matrix   

6 - use LDA posteriori to determin topics distributions  

7 - try it on one document to give a pie chart about the presence of each targeted topic in the testing article.  

# 06 - BERTology

[Transformers from scratch](http://nlp.seas.harvard.edu/2018/04/03/attention.html)

[A Visual Notebook to Using BERT for text classification](https://colab.research.google.com/github/jalammar/jalammar.github.io/blob/master/notebooks/bert/A_Visual_Notebook_to_Using_BERT_for_the_First_Time.ipynb#scrollTo=3rUMKuVgwzkY)

# 07 - Event Extraction (EE)

[ANN for Event Extraction](https://tel.archives-ouvertes.fr/tel-01943841/document)

[Event Extraction policy](https://www.almeta.io/en/blog/an-overview-of-the-event-extraction-task-in-nlp/)

[Using Document Level Cross-Event Inference to Improve Event Extraction](https://www.aclweb.org/anthology/P10-1081.pdf)


[Refining Event Extraction through Cross-document Inference](https://www.aclweb.org/anthology/P08-1030.pdf)

# 08 - NLP standards

[The Automatic Content Extraction (ACE) Program Tasks, Data, and Evaluation](http://www.lrec-conf.org/proceedings/lrec2004/pdf/5.pdf)




# BONUS: textProcess class

Under /Imports the textProcess class offers some great and simplified tools to process text with. a simple instance of the class and help hit over it will pop up some handy examples on how-to-use the bonus part.