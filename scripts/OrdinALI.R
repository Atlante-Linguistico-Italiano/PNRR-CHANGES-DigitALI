# Script per la ristrutturazione dei dati ALI
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
source("ordinali_funzione_dati.R")
source("ordinali_funzione_note_rifo.R")

#### DATI ####

path <- ""

dati_norm <- list.files(paste0(path,"path\\to\\files"),pattern = "norm_",full.names = F)
lista_dati <- lapply(paste0(path,dati_norm), read.delim,quote="")
names(lista_dati) <- sub(pattern = ".*?0?(\\d{1,4}[a-zA-Z]*)\\.tsv"
                         ,replacement = "\\1"
                         ,x = dati_norm
                         ,perl=T)

map2(lista_dati,names(lista_dati),ordinali,.progress = T)

#### unione file ####

dati_tidy <- list.files(path = "path\\to\\tidy\\files",pattern = "_tidy",full.names = F)

tables <- lapply(paste0("file_elaborati\\08\\dati\\tidy\\",dati_tidy), read.delim,quote="",sep="\t")

comb_dati <- do.call(rbind,tables) %>%
  mutate(nota = gsub(stri_unescape_unicode("\\u22A2"),
                     stri_unescape_unicode("\\u22A5"),nota),
         vol = '8') #cambiare secondo necessità

readr::write_tsv(comb_dati,"path\\to\\volume.tsv",na="")

#### NOTE/RIFO ####

path = ""

note_norm <- list.files("path\\to\\norm\\files",pattern = "^norm",full.names = F)
lista_note <- lapply(paste0(path,"NOTE\\norm\\",note_norm), read.delim,quote="")
names(lista_note) <- sub(pattern = ".*?0?(\\d{1,4}[a-zA-Z]*)N_[XIV]+\\.tsv" #cambiare N/F
                        ,replacement = "\\1"
                        ,x = note_norm
                        ,perl=T) 

map2(lista_note,names(lista_note),ordinali_note,.progress = T)

#### unione file ####

note_tidy <- list.files(path = "path\\to\\tidy\\files",pattern = "_TIDY_",full.names = F)

tables <- lapply(paste0("path\\to\\tidy\\files",note_tidy),read.delim,sep="\t",quote="")

comb_note <- do.call(rbind,tables) %>%
  rename(note_unicode = unicode,
         note_html = html) %>%
  mutate(vol=8) #cambiare secondo necessità
comb_rifo <- do.call(rbind,tables) %>%
  rename(rifo_unicode = unicode,
         rifo_html = html) %>%
  mutate(vol=8) #cambiare secondo necessità

readr::write_tsv(comb_note,paste0("path\\to\\volume.tsv"),na="")
