# ----------  STOPWORDS  ----------

STOPWORDS<-tidytext::get_stopwords()

# ----------  1-gram vectorization -- 

Vectorization_1gram <- function(corpus){
  
  title_1gram <- corpus %>%
    tidytext::unnest_tokens(
      input = titles,
      output = word,
      token = "ngrams",
      n = 1,
      to_lower = TRUE
    )   %>%
    mutate(word = stringi::stri_trim(word)) %>%
    filter(!str_detect(word, "\\d")) %>%
    filter(nchar(word) > 3) %>%
    mutate(word = textstem::lemmatize_words(word)) %>%
    mutate(word = gsub("'s$", '', word)) %>%
    dplyr::anti_join(STOPWORDS)%>%
    select("doc_id","word", "Topic")
  
  
  text_1gram <- corpus %>%
    tidytext::unnest_tokens(
      input = texts,
      output = word,
      token = "ngrams",
      n=1,
      to_lower = TRUE
    )   %>%
    mutate(word = stringi::stri_trim(word)) %>%
    filter(!str_detect(word, "\\d")) %>%
    mutate(word = textstem::lemmatize_words(word)) %>%
    mutate(word = gsub("'s$", '', word)) %>%
    dplyr::anti_join(STOPWORDS) %>%
    group_by(doc_id,word,Topic) %>%
    select("doc_id","word", "Topic") %>%
    as.data.frame()
  
  
  
  unigrams_data <- rbind(title_1gram, text_1gram) %>%
    group_by(doc_id,word,Topic) %>% 
    mutate(n = n()) %>%
    bind_tf_idf(doc_id, word, n)%>%
    filter(tf_idf >= 0.004866832) %>% #quantile(unigrams_data$tf_idf)[2]
    filter(tf_idf <= 0.08439338) %>%
    select(doc_id,word,Topic,n)%>%
    as.data.frame()
  
  return(unigrams_data)
  
}



# ----------  2-gram vectorization  ----------


Vectorization_2gram <- function(corpus){
  title_2gram <- corpus %>%
    tidytext::unnest_tokens(
      input = titles,
      output = word,
      token = "ngrams",
      n = 2,
      to_lower = TRUE
    )     %>%
    mutate(word = stringi::stri_trim(word)) %>%
    separate(word, into = c("word1", "word2"), sep = " ")  %>%
    filter(!str_detect(word1, "\\d")) %>%
    filter(!str_detect(word2, "\\d"))  %>%
    filter(nchar(word1) > 3) %>%
    filter(nchar(word2) > 3) %>%
    mutate(word1 = textstem::lemmatize_words(word1)) %>%
    mutate(word1 = gsub("'s$", '', word1)) %>%
    mutate(word2 = textstem::lemmatize_words(word2)) %>%
    mutate(word2 = gsub("'s$", '', word2)) %>%
    filter(!word1 %in% STOPWORDS$word) %>%
    filter(!word2 %in% STOPWORDS$word) %>%
    unite("word", c(word1, word2)) %>%
    select(doc_id, word,Topic)%>%
    as.data.frame()
  
  
  text_2gram <- corpus %>%
    tidytext::unnest_tokens(
      input = texts,
      output = word,
      token = "ngrams",
      n = 2,
      to_lower = TRUE
    )   %>%
    mutate(word = stringi::stri_trim(word)) %>%
    separate(word, into = c("word1", "word2"), sep = " ")  %>%
    filter(!str_detect(word1, "\\d")) %>%
    filter(!str_detect(word2, "\\d"))  %>%
    mutate(word1 = textstem::lemmatize_words(word1)) %>%
    mutate(word1 = gsub("'s$", '', word1)) %>%
    mutate(word2 = textstem::lemmatize_words(word2)) %>%
    mutate(word2 = gsub("'s$", '', word2)) %>%
    filter(!word1 %in% STOPWORDS$word) %>%
    filter(!word2 %in% STOPWORDS$word) %>%
    unite("word", c(word1, word2), sep=" ") %>%
    group_by(doc_id,word,Topic)%>%
    select("doc_id","word", "Topic") %>%
    as.data.frame()
  
  
  bigrams_data <- rbind(title_2gram, text_2gram) %>%
    group_by(doc_id,word,Topic) %>% 
    mutate(n = n()) %>%
    bind_tf_idf(doc_id, word, n)%>%
    filter(tf_idf >= 0.004866832) %>% #quantile(unigrams_data$tf_idf)[2]
    filter(tf_idf <= 0.08439338) %>%
    select(doc_id,word,Topic,n)%>%
    unique()%>%
    as.data.frame()
  
  
  # return(unique(bigrams_data, by = c("word", "Topic"))  )
  return(bigrams_data)
}


# ----------  3- frequency BOW creation  ----------



box_creation <- function(text_vect_1, text_vect_2) {
  vectorized_corpus <-
    data.table::as.data.table(rbind(text_vect_1, text_vect_2))
  
  vectorized_corpus <-   merge(
    vectorized_corpus,
    financial_corpus[, c("seed", "topic")],
    by.x = c("word", "topic"),
    by.y = c("seed", "topic"),
    all.y = T
  )
  vectorized_corpus[is.na(vectorized_corpus)] = 0
  
  vectorized_corpus <- data.table::dcast(
    vectorized_corpus,
    doc_id + topic ~ word,
    value.var = "n",
    fun.aggregate = sum
  ) # or min or max or...
  
  return(vectorized_corpus)
  
}









# ----------  test: 1-gram vectorizaion  ----------


Vectorization_1gram_test <- function(corpus){
  title_1gram <- corpus %>%
    tidytext::unnest_tokens(
      input = texts,
      output = word,
      token = "ngrams",
      n = 1,
      to_lower = TRUE
    )    %>%
    mutate(word = stringi::stri_trim(word)) %>%
    filter(!str_detect(word, "\\d")) %>%
    filter(nchar(word) > 3) %>% 
    mutate(word = textstem::lemmatize_words(word)) %>%
    mutate(word = gsub("'s$", '', word)) %>%
    dplyr::anti_join(STOPWORDS) %>%
    group_by(doc_id, word) %>% 
    mutate(n = n()) %>%
    as.data.frame()
  # %>%
  #   bind_tf_idf(doc_id, word, n) %>%
  #   select(doc_id, word, tf_idf)
  
  return(title_1gram)
  
}




# ----------  test: 2-gram vectorizaion  ----------


Vectorization_2gram_test <- function(corp) {
  
  text_vect_2 <- corp %>%
    tidytext::unnest_tokens(
      input = texts,
      output = word,
      token = "ngrams",
      n = 2,
      to_lower = TRUE
    )   %>%
    mutate(word = stringi::stri_trim(word)) %>%
    separate(word, into = c("word1", "word2"), sep = " ")  %>%
    filter(!str_detect(word1, "\\d")) %>%
    filter(!str_detect(word2, "\\d"))  %>%
    filter(nchar(word1) > 3) %>%
    filter(nchar(word2) > 3) %>%
    mutate(word1 = textstem::lemmatize_words(word1)) %>%
    mutate(word1 = gsub("'s$", '', word1)) %>%
    mutate(word2 = textstem::lemmatize_words(word2)) %>%
    mutate(word2 = gsub("'s$", '', word2)) %>%
    filter(!word1 %in% STOPWORDS$word) %>%
    filter(!word2 %in% STOPWORDS$word) %>%
    unite("word", c(word1, word2)) %>%
    select(word, doc_id) %>%
    group_by(doc_id, word) %>%
    mutate(n = n())%>%
    as.data.frame()
  
  
  return(text_vect_2)
}




# ----------  3- test: frequencyBOW creation ----------



box_creation_test <- function(text_vect_1, text_vect_2) {
  vectorized_corpus <-
    data.table::as.data.table(rbind(text_vect_1, text_vect_2))
  
  vectorized_corpus <-   merge(
    vectorized_corpus,
    financial_corpus[, c("seed")],
    by.x = c("word"),
    by.y = c("seed"),
    all.y = T
  )
  vectorized_corpus[is.na(vectorized_corpus)] = 0
  
  vectorized_corpus <- data.table::dcast(
    vectorized_corpus,
    doc_id ~ word,
    value.var = "n",
    fun.aggregate = sum
  ) 
  vectorized_corpus=vectorized_corpus[doc_id> 0,]
  
  return(vectorized_corpus)
  
}



# ----------  Topic classification visualization  ----------

get_topic <- function(data){
  g<-data %>%
    mutate(
      topic_classification = case_when(
        topic_classification == 1 ~ "Employee Dismissal",
        topic_classification == 2 ~ "Money Laundering",
        topic_classification == 3 ~ "Company Crisis",
        topic_classification == 4 ~ "Financial Crime",
        topic_classification == 5 ~ "Financing Terrorism",
        topic_classification == 6 ~ "Fraud",
        topic_classification == 7 ~ "Suspicious Activity",
        
      ) %>% factor(
        levels = c(
          "Employee Dismissal",
          "Money Laundering",
          "Company Crisis",
          "Financial Crime",
          "Financing Terrorism",
          "Fraud",
          "Suspicious Activity"
        )
      )
    ) %>%
    ggplot(aes(topic_classification, topic_regression, color = topic_regression)) +
    geom_point(aes(text = label, size = abs(topic_regression))) +
    scale_color_viridis_c() +
    theme_tq() +
    coord_flip()
  ggplotly(g, tooltip = "text")
  
}



###---- the plot thing

visualize_topic<- function(data,mod,id){
  
  topic_name=c("HR_Managment", "International_Footprint","Financial_Performance")
  art_1gram<-Vectorization_1gram_test(art)
  art_2gram<-Vectorization_2gram_test(art)
  total_seed_art<-rbind(art_1gram,art_2gram)
  
  
  test_table <- total_seed_art %>% 
    count(doc_id, word) %>%
    right_join(total_seed %>% as.data.frame() %>% select(word), by=c("word"="word")) %>%
    distinct()
  
  
  # Prepare a document-term matrix
  test_dtm <- test_table %>%
    arrange(desc(doc_id)) %>%
    mutate(doc_id = ifelse(is.na(doc_id), first(doc_id), doc_id),
           n = ifelse(is.na(n), 0, n)) %>%
    as.data.table()
  
  test_dtm=dcast(test_dtm,
                 doc_id~word,
                 value.var = "n"
  )
  test_dtm[is.na(test_dtm)]<-0
  
  test_dtm<-test_dtm[doc_id %in% c(1:4),]
  # Obtain posterior probabilities for test documents
  results <- posterior(object=mod, newdata=test_dtm)
  doc2top = as.data.frame(results$topics)
  
  doc_id = id
  
  data = data.frame(
    app = as.numeric(doc2top[nrow(doc2top)-doc_id+1,]), # switch to article to analyze
    leg = append(topic_name,"other")
  ) %>%
    mutate(ymax = cumsum(app)) %>%
    mutate(ymin = c(0, head(ymax, n=-1)))
  fig <- plot_ly(data, labels = ~leg, values = ~app , type = 'pie')
  
  return(fig)
}
