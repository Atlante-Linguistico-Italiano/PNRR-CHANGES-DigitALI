# Funzione per la ristrutturazione dei dati ALI
# prende i file "norm_" come input e restituisce file "_tidy" in output
# Scritta da Stefano Fiori (s.fiori@unito.it)

library(dplyr)
library(tidyr)
library(stringi)
library(stringr)
library(qlcData)
library(tibble)
library(purrr)

#pattern risposte multiple
split_pattern <- regex(
  paste(
  #"(?= P)",
  "#cce#e "
  ,"(?=#cc\\$I\\$?I#e)"
  ," , +(?=#cc.+?#e)"
  ,"(?=\\$/ )" 
  ,"(?= ; )"
  ,sep="|")
  )

#sigle identificative degli informatori
sigle <- regex(paste(
  "#cc(%4\\*)*ai+#e",
  "#cc\\$I\\$?I?#e"
  ,"#cc[iu]mc#e"
  ,"^ ?; "
  ,sep="|")
  )

#pattern per la rimozione dei corsivi
clean_pattern <- regex(paste(
  "%4[UH]",
  "\\$0",
  "#cc(\\$[A-H,J-Z](%4\\d)?)+#e",
  "%4(\\$[1-9;]|[KV])",
  "#cc(%4\\*)*ai+#e",
  "#cc\\$I\\$?I?#e",
  "^ ?; ",
  "#cc[iu]mc#e",
  "\\$/",
  sep="|"
))

#estrazione corsivi
extract_collapse <- function(x, pattern) {
  str_extract_all(x, pattern) %>%
    vapply(paste, collapse = ",", FUN.VALUE = character(1))
}

#ordinali_dati <- function(test,name,path) {

ordinali_dati <- function(test,name,path) {

  temp <- test %>%
    mutate(risposta = normali) %>%
    # sep. risp. con sigle su righe diverse
    separate_longer_delim(risposta,split_pattern) %>%
    # sep. stringhe identificative
    mutate(sigla = map_chr(str_extract_all(risposta,sigle), ~paste(.x, collapse = ""))) %>%
    # sep. risposte doppie
    separate_longer_delim(risposta, delim=" , ") %>%
    # voci originali
    mutate(voce = map_chr(
      str_extract_all(risposta,
                      "rispost[ae] raccolt[ae] (?:rispettivamente )?all[ae] voc[ei] (\\d+)(?: e)? ?(\\d+)?"),
      ~paste(.x, collapse = ""))) %>%
    # separazione note CP
    separate(risposta, into = c("risposta","nota_cp"),sep= "(?<=\\S), #cc",fill = "right",remove = F) %>%
    # separazione colonne simboli
    mutate(bilingue = extract_collapse(risposta,"\\$/"),
           legenda = extract_collapse(risposta,"(?<=#cc)(\\$[A-H,J-Z](%4\\d)?)+(?=#e)"),
           simbolo = extract_collapse(risposta,"%4(\\$[1-9;]|[KV])"),
           nota = extract_collapse(risposta,"%4[UH]"),
           rifo = extract_collapse(risposta,"\\$0")
           ) %>%
    # rimozione corsivi
    mutate(risposta = str_replace_all(risposta,clean_pattern,"")) %>%
    # separazione #cc alla fine; problema in II 354, più pezzi
    mutate(tag = map_chr(str_extract_all(risposta,"#cc.*#e"), 
                         ~paste(.x, collapse = " "))) %>%
    # rimozione tag
    mutate(risposta = str_replace_all(risposta,"#cc.*#e|#cc.*#e|[<\\[]?!?#cccorr|sic]|nega(no)?:?#e!?[>\\]]?","")) %>%
    relocate(c(unicode,html),.after = last_col()) %>%
    mutate(across(c(5:14), ~gsub('(#(cc|e))','',.x))) #%>%
    mutate(across(c(5:14), ~na_if(.,""))) %>%
    # rimozione spazi
    mutate(across(c(5:14), ~str_trim(.x))) %>% # forse squish?
    # inversione parentesi e segno sollevate/abbassate
    mutate(risposta = gsub("(%\\d\\))(#[ab])","\\2\\1",risposta)) %>%
    # conversione unicode
    mutate(across(c(5:14), ~stri_unescape_unicode(
      tokenize(.x
               ,profile = prof
               ,transliterate = "UNICODE"
               ,sep = ""
               ,normalize="NFD")$strings$transliterated)
    )) %>%
    mutate(voce = case_when(
      is.na(voce) == T ~ tolower(name),
      .default = map_chr(str_extract_all(voce,'\\d+'), ~paste(.x, collapse = ","))))
  
    write.table(temp,file=paste0(path,"\\volume_",name,"_tidy.tsv")
               ,sep = "\t"
               ,na=""
               ,quote = F
               ,row.names = F)
  
  #return(temp)

}
