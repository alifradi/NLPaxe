
Extract_Named_Entities <- function(df){
  Q <- data.frame()
  for (k in 1:nrow(df)) {
    NE = get_NE(df$paragraph_text[k])
    if(nrow(NE>0)){
      Q <- Q %>%
        rbind(
          data.frame(paragraph_num = df[k,'paragraph_num'],get_NE(df$paragraph_text[k]))
        )
    }
  }
  Q <- Q %>%
    mutate(NamedEntity = str_replace(`Named.Entity`,"\\+\\-\\.\\;\\:",'')) %>%
    mutate(NamedEntity = str_remove_all(NamedEntity," ")) %>%
    mutate(NamedEntity = str_remove_all(NamedEntity,"'s$")) %>%
    mutate(NamedEntity = str_remove_all(NamedEntity,"^the"))%>%
    mutate(NamedEntity = str_remove_all(NamedEntity,"^The"))%>%
    mutate(NamedEntity = str_trim(NamedEntity))
  return(Q %>% filter(!is.na(paragraph_num)))
}


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
