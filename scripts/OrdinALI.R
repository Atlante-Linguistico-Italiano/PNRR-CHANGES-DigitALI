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

#ortografia
prof <- read.delim("ALIorth.txt",quote = "")

#script ristrutturazione
source("ordinali_funzione.R")
source("ordinali_funzione_note_rifo.R")

#### DATI ####

path <- ("file_elaborati\\02")

dati_norm <- list.files(paste0(path,"\\DATI\\norm"),pattern = "norm_",full.names = F)
lista_dati <- lapply(paste0(path,dati_norm), read.delim,quote="")
names(lista_dati) <- sub(pattern = ".*?0?(\\d{1,4}[a-zA-Z]*)\\.tsv"
                  ,replacement = "\\1"
                  ,x = dati_norm
                  ,perl=T)

#### ristrutturazione ####

# controllare NOME VOCE

for (f in names(ldf)) {

# test <- read.delim(paste0("file_elaborati\\08\\DATI\\norm\\",f),quote = "",sep="\t") %>%
#   mutate(unicode = stri_unescape_unicode(unicode))
  test <- ldf[[f]]
  
  temp <- ordinali(test,f)
  
  write.table(temp,file=paste0("file_elaborati\\08\\DATI\\tidy\\VIII_",name,"_tidy.tsv")
              ,sep = "\t"
              ,na=""
              ,quote = F
              ,row.names = F)
  
  print(paste0("Sistemato ", f))

}

map2(lista_dati,names(lista_dati),ordinali,.progress = T)

#### cucire insieme ####

dati_tidy <- list.files(path = "file_elaborati\\08\\dati\\tidy",pattern = "_tidy",full.names = F)

tables <- lapply(paste0("file_elaborati\\08\\dati\\tidy\\",dati_tidy), read.delim,quote="",sep="\t")

comb_dati <- do.call(rbind,tables) %>%
  mutate(nota = gsub(stri_unescape_unicode("\\u22A2"),
                     stri_unescape_unicode("\\u22A5"),nota),
         vol = 8)

readr::write_tsv(comb_dati,"file_elaborati\\08\\ALI_08_DATI.tsv",na="")

#### NOTE/RIFO ####

path = "file_elaborati\\02\\NOTE"

test <- read.delim(paste0(path,"\\norm\\norm_II_NOTE_0292.tsv"),sep="\t",
                        quote = "") %>%
  mutate(unicode = stri_unescape_unicode(unicode))

note_norm <- list.files("file_elaborati\\03\\NOTE\\norm",pattern = "^norm",full.names = F)
lista_note <- lapply(paste0(path,"NOTE\\norm\\",note_norm), read.delim,quote="")
names(lista_note) <- sub(pattern = ".*?0?(\\d{1,4}[a-zA-Z]*)N_[XIV]+\\.tsv"
                  ,replacement = "\\1"
                  ,x = note_norm
                  ,perl=T) #cambiare N/F

map2(lista_note,names(lista_note),ordinali_note,.progress = T)

for (f in note_norm) {
  
  test <- read.delim(paste0("file_elaborati\\03\\NOTE\\norm\\",f),sep="\t",quote = "") %>%
    mutate(unicode = stri_unescape_unicode(unicode))

  name <- sub(pattern = ".*?0?(\\d{1,4}[a-zA-Z]*)N_[XIV]+\\.tsv",
              replacement = "\\1",
              x = f,perl=T)
  
  temp <- test %>%
    mutate(unicode = gsub('(#(cc|e))','',unicode),
           nota = "\\u22A5",
           #rifo = "\\uD83C\\uDD35",
           #voce = tolower(name)
           voce = tolower(name)) %>%
    mutate(nota = stri_unescape_unicode(nota))
    #mutate(rifo = stri_unescape_unicode(rifo))
  
  # cambiare note/rifo
  readr::write_tsv(temp,file = paste0("file_elaborati\\03\\NOTE\\tidy\\III_TIDY_",name,".tsv"),na="",escape="none")
  # write.table(temp,file = paste0("file_elaborati\\05\\NOTE\\tidy\\V_",name,"_note_tidy.tsv"),
  #             sep="\t",quote = F,na="")
  #readr::write_tsv(temp,file = paste0("tidy\\II_292_note_tidy.tsv"),na="",escape="none")

  print(paste0("Sistemato ", f)) # occhio al nome
  
}

# cambio nome

# path = "C:\\Users\\bluew\\Desktop\\stefano\\qlc\\ALI_07\\RIFO"
# 
# setwd(path)
# 
# files <- list.files(path = "C:\\Users\\bluew\\Desktop\\qlc\\ALI_06\\RIFO",
#                     full.names = F)
# 
# new_names <- sub(pattern = "\\.ALI", 
#                  replacement = "", 
#                  x = files,perl = T)
# 
# file.rename(from = files, to = new_names)

# cucitura (cambiare sempre note/rifo e volume)

note_tidy <- list.files(path = "file_elaborati\\03\\NOTE\\tidy",pattern = "_TIDY_",full.names = F)

tables <- lapply(paste0("file_elaborati\\03\\NOTE\\tidy\\",note_tidy),read.delim,sep="\t",quote="")

comb_note <- do.call(rbind,tables) %>%
  rename(note_unicode = unicode,
         note_html = html) %>%
  mutate(vol=3)
comb_rifo <- do.call(rbind,tables) %>%
  rename(rifo_unicode = unicode,
         rifo_html = html) %>%
  mutate(vol=5)

#names(comb) <- c("punto","codice","risposta","str","tag","risposta2","q")
readr::write_tsv(comb_note,paste0("file_elaborati\\03\\ALI_03_NOTE.tsv"),na="")
readr::write_tsv(comb_rifo,paste0(digitali,"\\file_elaborati\\05\\ALI_05_RIFO.tsv"),na="",escape = "none")

#### DATABASE COMPLETO ####

#occhio a tipi colonne

j <- comb_dati %>%
  left_join(select(comb_note,punto,codice,note_unicode,note_html,voce,nota),
            by=c("punto","codice","nota","voce")) %>%
  #mutate(rifo_unicode = NA,rifo_html=NA) %>% # per quando non ci sono rifo
  left_join(select(comb_rifo,punto,codice,voce,rifo,rifo_unicode,rifo_html),
            by=c("punto","codice","rifo","voce")) %>%
  mutate(vol = "09") #%>% # CAMBIARE
  select(-c(testo,unicode))

readr::write_tsv(j,"file_elaborati\\09\\ALI_09_comp.tsv",
                 quote = "none",na="",escape = "none")
