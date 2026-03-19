# Funzione per la ristrutturazione dei dati ALI (note e riferimenti fotografici)
# prende i file "norm_" come input e restituisce file "_tidy" in output
# Scritta da Stefano Fiori (s.fiori@unito.it)

# library(dplyr)
# library(tidyr)
# library(stringi)
# library(stringr)
# library(qlcData)
# library(tibble)
# library(purrr)

ordinali_note <- function(test,name,type,path) {

  temp <- test %>%
    mutate(unicode = gsub('(#(cc|e))','',unicode),
           voce = tolower(name)) %>%
    { if(type == "nota") 
      mutate(.,nota = stri_unescape_unicode("\\u22A5")) 
      else mutate(.,rifo = stri_unescape_unicode("\\uD83C\\uDD35"))
    }
  
  write.table(temp,file=paste0(path,"\\volume_",name,"_tidy.tsv")
              ,sep = "\t"
              ,na=""
              ,quote = F
              ,row.names = F)
  
  #return(temp)
  
}
