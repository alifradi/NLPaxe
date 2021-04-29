#  1.3 Functions  ----
#  1.3.1 Use Document-term matrix to model Semantic clusters ----
#______This function receives Document-term matrix and range of topic's number and returns all models, 
#    a plot of perplexity and the selected model via number of desirable topics to be allowed
LDA_optimal<-function(dtm, k_min, k_max, k_select=2, iter = 500, alpha = 0.5, seed = 1234, thin = 1){
  models <- list()
  
  for (k in k_min:k_max) {
    l= list()
    l$k<- k
    l$model           <-  mod <- topicmodels::LDA(x=dtm, method="Gibbs", k=k,
                                                  control=list(alpha=alpha, seed=seed, iter=iter, thin=thin))
    l$log_likelihood  <- logLik( l$model )
    l$perplexity      <- perplexity(object= l$model , newdata=dtm)
    models[[length(models)+1]] <- l
  }
  
  topics=c()
  log_likelihood = c()
  perplexity=c()
  for (k in models) {
    l = unlist(k)
    topics = c(topics, l$k)
    log_likelihood = c(log_likelihood, l$log_likelihood)
    perplexity = c(perplexity, l$perplexity)
    
  }
  
  Eval_mod    =    data.frame(
    topics,
    log_likelihood,
    perplexity
  ) %>% 
    dplyr::mutate(diff = c(NA, rev(diff(rev(perplexity)))))
  
  
  p <- plotly::ggplotly(
    ggplot2::ggplot(Eval_mod,aes(x=topics, perplexity)) +
      geom_point() +
      geom_line())
  min_perp <- unlist(models[which(Eval_mod$perplexity == min(Eval_mod$perplexity))])
  max_perp <- unlist(models[which(Eval_mod$perplexity == max(Eval_mod$perplexity))])
  selected_mod <- unlist(models[which(Eval_mod$diff == min(abs((Eval_mod$diff)), na.rm=TRUE))])
  stat_perp <- unlist(models[which(Eval_mod$topics == k_select)])
  
  res = list()
  res$Plot = p
  res$min_perp = unlist(min_perp)
  res$max_perp =  unlist(max_perp)
  res$selected_mod = unlist(selected_mod)
  res$stationary_prep = unlist(stat_perp)
  
  return(res)
}
#  1.3.2 Create Document-term matrix ----
#______This function receives a dataframe that contains document IDs and each token in a row line and a
#    dataframe containing stopwords in a column whose the name is "word" exclusively
df_to_matrix <- function(df, stopwords){
  df %>%
    purrr::set_names('id','word') %>%
    dplyr::anti_join(stopword) %>%
    dplyr::count(id, word) %>% 
    tidytext::cast_dtm(document=id, term=word, value=n)
}
#  1.3.3 Remove all entities from a text ----
#______This function takes a text paragraph and a vector of entities and removes them from the text
remove_NE_from_text <- function(raw_text, entities){
  if(length(entities)>0){
    text <- raw_text
    for (k in entities) {
      txt <- stringr::str_replace_all(text, stringr::fixed(as.character(k)), ' ')
      text <- txt
    }
  }else {
    txt <- raw_text
  }
  return(txt)
}
#  1.3.4 Get all tokens with their tags based on Spacy models ----
intelligent_tokenization <- function(raw_text){
  
  article = raw_text  %>%
    replace_contraction()
  
  entites = get_NE(article) 
  
  text_with_no_entities = remove_NE_from_text(article,entites[,"Named Entity"])
  
  tokens = c(text_with_no_entities %>%
               doc_spacy_tokenizer())
  
  tags = c(text_with_no_entities %>%
             doc_spacy_tagger())
  
  names(entites) <- c("Words", "Label")
  df = data.frame(
    Words = tokens,
    tag = tags
  ) %>%
    mutate(Label = ifelse(
      grepl("\\<[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\>", Words,
            ignore.case=TRUE),'E-mail adress', tag)) %>%
    select(-tag) %>%
    mutate_at('Words' ,trimws) %>%
    rbind(entites) %>% 
    filter(!Words %in% c('',NA,'\n'))
  return(df)
}
#  1.3.5 Tokenize naively a text  ----
tokenize_text <- function(text, id, stop_words){
  df <- intelligent_tokenization(as.character(text)) %>%
    set_names('word','Label') %>%
    mutate(word = textstem::lemmatize_words(word)) %>%
    mutate(word= tolower(word)) %>%
    anti_join(stop_words) %>%
    filter(!str_detect(word, "\\d"))%>%
    filter(nchar(word)>2)
  
  df <- df %>%
    mutate(id_doc = rep(id, nrow(df)))
  return(df)
}
#  1.3.6 Replace named entities with single term  ----
group_entitiesInText <- function(raw_text, entities, replacements){
  if(length(entities)>0){
    text <- raw_text
    for (k in 1:length(entities)) {
      txt <- stringr::str_replace_all(text, stringr::fixed(entities[k]), replacements[k])
      text <- txt
    }
  } else {
    txt <- raw_text
  }
  
  return(txt)
}
# ---- 2. Text segmentation and clustering  ----
#  2.1 Subset paragraph from a raw text  ----
SegmentizeText <- function(Corpus,text_column, pattern){
  Corpus  %>%
    rowid_to_column(var = "text_id") %>%
    mutate(paragraph_text = stringi::stri_split_fixed(as.character(Corpus[,text_column]), pattern = pattern)) %>%
    select(-text_column) %>%
    unnest(paragraph_text) %>%
    rowid_to_column(var = "paragraph_num") %>%
    mutate(NCHAR = nchar(paragraph_text))  %>%
    as.data.frame()
}
#  2.2 List Named Entities of each paragraph  ----
Extract_Named_Entities <- function(df){
  Q <- data.frame()
  for (k in 1:nrow(df)) {
    NE = get_NE(df$paragraph_text[k])
    if(nrow(NE)>0){
      Q <- Q %>%
        rbind(
          data.frame(paragraph_num = df[k,'paragraph_num'],get_NE(df$paragraph_text[k]))
        )
    }
  }
  Q <- Q %>%
    mutate(NamedEntity = str_replace(`Named.Entity`,"\\+\\-\\.\\;\\:",'')) %>%
    mutate(NamedEntity = str_remove_all(NamedEntity," ")) %>%
    # mutate(NamedEntity = str_remove_all(NamedEntity,"'s$")) %>%
    # mutate(NamedEntity = str_remove_all(NamedEntity,"^the"))%>%
    # mutate(NamedEntity = str_remove_all(NamedEntity,"^The"))%>%
    mutate(NamedEntity = str_trim(NamedEntity))
  return(Q %>% filter(!is.na(paragraph_num)))
}
#  2.3 Deal with Named entities  ----
NE_Cleansing <- function(df, text_id,text_column, group = FALSE, rm=TRUE, Extracted_Entities_table){
  NEWS <- df %>%
    mutate(TEXT = '-')
  if(rm==TRUE && group==FALSE){
    for (k in 1:nrow(NEWS)) {
      art_id = as.numeric(NEWS[k,text_id])
      NEWS$TEXT[k] <- remove_NE_from_text(NEWS[ ,text_column][NEWS[,text_id]==art_id]
                                          ,Extracted_Entities_table[Extracted_Entities_table[,text_id]==art_id,'Named.Entity'])
    }
  }else if(rm==FALSE && group==TRUE){
    for (k in 1:nrow(NEWS)) {
      art_id = as.numeric(NEWS[k,text_id])
      NEWS$TEXT[k] <- group_entitiesInText(NEWS[ ,text_column][NEWS[,text_id]==art_id]
                                           ,Extracted_Entities_table[Extracted_Entities_table[,text_id]==art_id,'Named.Entity']
                                           ,Extracted_Entities_table[Extracted_Entities_table[,text_id]==art_id,'NamedEntity'])
    }  
  }
  return(NEWS)
}
#  2.4 Clustering paragraphs into segments  ----
Clustering_doc_paragraphs <- function(doc_df,doc_id){
  df = doc_df  %>%
    set_names('id','text') %>%
    unnest_tokens(input=text, output=word) %>% 
    mutate(word_lemma = textstem::lemmatize_words(word)) %>%
    mutate(word_low= tolower(word_lemma)) %>%
    select(-word, -word_lemma) %>%
    set_names('id','word') %>%
    anti_join(tidytext::stop_words) %>%
    filter(!str_detect(word, "\\d"))%>%
    filter(nchar(word)>2) %>%
    count(id, word) %>%
    bind_tf_idf(word, id, n) %>%
    arrange(desc(tf_idf))
  quant = quantile(df$tf_idf)
  df = df %>% 
    filter(tf_idf >= quant[1])%>% 
    cast_dtm(document=id, term=word, value=n) 
  l = LDA_optimal(df,2,10)
  df2 = tidy(l$min_perp$model, "gamma") %>% 
    spread(topic, gamma) %>%
    as.data.frame()
  tot_withinss <- map_dbl(1:(nrow(df2)-1),  function(k){
    model <- kmeans(x = df, centers = k)
    model$tot.withinss
  })
  elbow_df <- data.frame(
    k = 1:(nrow(df2)-1),
    tot_withinss = tot_withinss
  ) %>% 
    dplyr::mutate(diff = c(NA, rev(diff(rev(tot_withinss))))) %>%
    filter(diff == max(diff,na.rm = TRUE)) %>%
    select(k) %>%
    as.numeric()
  model_km <- kmeans(x = df, centers = elbow_df)
  df2 <- mutate(df2, cluster = paste(paste("Seg-",doc_id,sep = ''), model_km$cluster, sep = '-'))
  
  return(df2  %>%select(document,cluster) %>% set_names("paragraph_num","cluster"))
}
#  2.5 segments
all_seg <- function(art_rm_NE, text_ID, par_num, text){
  Q <- data.frame()
  art_rm_NE <- art_rm_NE %>%
    select(text_ID,  par_num, text) %>%
    set_names('text_id','paragraph_num', 'TEXT')
  for (k in unique(art_rm_NE$text_id)) {
    Q <- Q %>% 
      rbind(
        Clustering_doc_paragraphs(
          art_rm_NE %>% 
            filter(text_id == k) %>%
            as.data.frame() %>%
            select(paragraph_num,TEXT),
          k)
      )
  }
  
  return(Q)
}



# ----  Jenson Shaanon Distribution  ----

computeJSD <- function(DOC1, DOC2, DocVsTopic){
  library("philentropy")
  DF_TOPIC_DOC = as.data.frame(DocVsTopic)
  P <- as.matrix(DF_TOPIC_DOC[DF_TOPIC_DOC$document == DOC1, 2:ncol(DF_TOPIC_DOC)])
  Q <- as.matrix(DF_TOPIC_DOC[DF_TOPIC_DOC$document == DOC2, 2:ncol(DF_TOPIC_DOC)])
  x <- rbind(P,Q)
  x <- rbind(P,Q)
  return(JSD(x))
}
get_similarties <- function(DOC,DocVsTopic) {
  DF_TOPIC_DOC = as.data.frame(DocVsTopic) 
  Sim_Doc = c()
  names = c()
  for (k in 1:nrow(DF_TOPIC_DOC)) {
    if(DF_TOPIC_DOC$document[k]!=DOC){
      Sim_Doc[k] <- computeJSD(DOC,DF_TOPIC_DOC$document[k],DF_TOPIC_DOC)
      names[k] <- DF_TOPIC_DOC$document[k]
    }
  }
  
  ds= data.frame(names,Sim_Doc)
  names(ds) <- c(paste0("Similar to ",DOC,sep = ' '), "Similarity" )
  
  return(ds %>% arrange(desc(Similarity)))
}