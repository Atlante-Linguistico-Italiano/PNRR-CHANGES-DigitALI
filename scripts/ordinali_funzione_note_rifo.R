# library(dplyr)
# library(tidyr)
# library(stringi)
# library(stringr)
# library(qlcData)
# library(tibble)
# library(purrr)

# prof <- read.delim("utils\\ALIorth.txt",quote = "")
# 
# test <- read.delim("file_elaborati\\08\\DATI\\norm\\norm_VIII_ELAB_1446.tsv",quote = "") %>% 
#   mutate(unicode = stri_unescape_unicode(unicode))

ordinali_note <- function(test,name,type,path) {

  temp <- test %>%
    mutate(unicode = gsub('(#(cc|e))','',unicode),
           voce = tolower(name)) %>%
    { if(type == "nota") 
      mutate(.,nota = stri_unescape_unicode("\\u22A5")) 
      else mutate(.,rifo = stri_unescape_unicode("\\uD83C\\uDD35"))
    }
  
  write.table(temp,file=paste0(path,"\\VIII_",name,"_tidy.tsv")
              ,sep = "\t"
              ,na=""
              ,quote = F
              ,row.names = F)
  
  #return(temp)
  
}
