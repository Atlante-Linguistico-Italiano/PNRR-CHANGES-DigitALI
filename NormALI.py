import re
import os
import glob
import pandas as pd
import string as str
import csv
import numpy as np
from segments.tokenizer import Tokenizer # https://pypi.org/project/segments/

os.chdir("") # percorso di base

#tokenizzatore
t = Tokenizer("ALIorth.txt")

# forme generali caratteri
basesup = r"(%[1-4](\$[abdejlqy6z~?]|[a-zABD-GIJL-PR-TW-Z6?]'?|\$~))"
diasup = r"(%[0-4]\$?[\\/^{C_|\-:'@\.Q\"~&}=])"
basesub = r"(%[6-8](\$[abdejlqy6z~?]|[a-zABD-GIJL-PR-TW-Z6?]'?|\$~))"
diasub = r"(%[6-9]\$?[\\/^{C_|\-:'@\.Q\"~&}=])"
simbolo = r"(%4(\$[1-9;]|[KV]))"
numero = r"(%4[1-9])"

#espressioni regolari per normalizzazione
regexes = [
    # correzione intacco palatale
    (re.compile(r"[ !](%\d')"), r"\1"),
    # rimozione spazio da nota
    (re.compile(r"!( %4U)"), r"\1"),
    # rimozione spazio da rifo
    (re.compile(r"!(\$0)"), r" \1"),
    # rimozione spazi legende/simboli
    (re.compile(r"!?( %4(\$[1-9;]|[KV]))!?"), r"\1 "),
    # legende/simboli senza ! dopo
    (re.compile(r"( %4(\$[1-9;]|[KV]))(\w)"), r"\1 \3"),
    (re.compile(r"!? (%4[1-9])"), r"\1"),
    (re.compile(r"(\w)#cc "), r"\1 #cc"),
    (re.compile(r"#c "), r"#e "),
    (re.compile(r"#cc "), r"#cc"),
    (re.compile(r"# "), r"#e "),
    (re.compile(r" #e"), r"#e"),
    (re.compile(r" (%\dP)"), r"\1"),
    # ricodifica !%4:
    (re.compile(r"!%4:"), r"%4:"),
    # chiusura spazio prima di trattino verticale basso
    (re.compile(r" (%\d:)(?!%\d)"), r"\1"),
    # errore digitazione trattino verticale basso
    (re.compile(r"(?<!%\d)( )?(:)(%\d)"), r"\1 %4:%3"),
    (re.compile(r"(%4\*) "), r"\1"),
    (re.compile(r"((%4\*){,3})(#cc)"), r"\3\1"),
    (re.compile(r"(#cc(%4\*){,3}ai+|\$I{1,2}) "), r"\1#e #cc"),
    (re.compile(r" (((%4\*){,3}ai+|(\$?I){1,2})#e)"), r"#e #cc\1"),
    (re.compile(r"((\$[A-H,J-Z])(%4\d)?) "), r"\1#e #cc"),
    (re.compile(r'(\$?[<\[(]!?)(#cc)(?!corr)'), r"\2\1"),
    (re.compile(r'(?<!corr)(#e)(!?\$?[>\])])'), r"\2\1"),
    # riallineamento par. basse
    (re.compile(r"( ?%[67]\()(.*?)(%6.*?%[67]\))"), r"\2\1\3"), # tolto spazio dopo \1 --> tenere d'occhio
    # riallineamento par. alte
    (re.compile(r"( ?%[43]\(.*?)(%6.*?)( %[43]\))"), r"\1\3\2"),
    # inversione diacritici alti non ambigui
    (re.compile(r" ((%[2-4]\$?[\\/^{C_|\-:'@\.Q\"~&}=]){,3})(%[1-4](\$[abdejlqy6z~?]|[a-zABD-GIJL-PR-TW-Z6?]'?|\$~))"), r" \3\1"),
    # inversione diacritici bassi non ambigui
    (re.compile(r"(%[67]\$?[\\@/^{C_}|\-'.Q\"~&}:=]){1,2}(%[78][a-zA-Z])|(%[78]\$[?~])"), r"\2\1"),
    # ricodifica diacritici alti ambigui
    (re.compile(r" ((%[1-3]\$?[a-zA-Z@Q\\/\^\{\".C&~_\}\|-]){1,2})(%[2-4])([.Q\"~&}:])"), r" \1%0\4"),
    # ricodifica diacritici bassi ambigui
    (re.compile(r"((%[78]\$?[a-zA-Z@Q\\/\^\{\".C&~_\}\|-]){1,2})(%[67])([.Q\"~&}:])"), r"\1%9\4"),
    # rimozione spazio dopo par. aperta
    (re.compile(r" (%\d\()"), r"\1"),
    # rimozione spazio dopo par. chiusa
    (re.compile(r" (%\d\))"), r"\1"),
    # delimitazione gruppi alti
    (re.compile(' ?((' + basesup + diasup + '{,3})+)'), r"##a\1#a"),
    # delimitazione gruppi bassi
    (re.compile('(' + basesub + diasub + '{,3})'), r"##b\1#b"),
    # delimitazione parentesi alte
    (re.compile(r"(%[34]\(.*?%[34]\))"), r"##a\1#a"),
    # delimitazione parentesi basse
    (re.compile(r"(%[67]\(.*?%[67]\))"), r"##b\1#b"),
    # rimozione #a da parentesi alte
    (re.compile(r"(?<=%[43]\()##a|#a(?=%[43]\))"), r""),
    # rimozione #b da parentesi alte
    (re.compile(r"(?<=%[67]\()##b|#b(?=%[67]\))"), r"")
]

#funzione trascrizione
def apply_regexes(text):
    for pattern, replacement in regexes:
        text = re.sub(pattern, replacement, text)
    return(text)   

#------ test singola stringa

text = r''
original_text = text

for i, (pattern, replacement) in enumerate(regexes):
    text = re.sub(pattern, replacement, text)
    print(f"step {i}: '{text}'")

#text2 = re.sub('- {8}-','',text)
norm = apply_regexes(text)
print(t(norm,column="HTML",separator=" &#x20; ").replace(" ",""))
print(t(norm,column="UNICODE",separator=" \\u0200 ").replace(" ",""))
print(norm)

#------ test singolo file

ali = pd.read_csv("file_ali\\volume\\dati\\nome_file.ali",sep='\t',quoting=3,header=None)
ali = pd.read_csv("file_ali\\volume\\dati\\nome_file.ali",sep='\t',quoting=3) # file 1, 2, 4 e da 8 in poi

ali.columns = ['col']
ali = ali.replace(np.nan, '')
ali = pd.DataFrame({'col': re.sub(r'-\n {8}-', '', '\n'.join(ali['col'])).split('\n')})
ali[['col','col2']] = ali['col'].str.split(r'(?<=^\d{4})',expand=True)
ali[['col2','col3']] = ali['col2'].str.split(r'(?<=^[a-z]{2}\d{3})',expand=True)
ali.columns = ['punto','codice','alicode'] # per le note, cambiare 'risposta' in 'testo'

#print(ali)

# normalizzazione
ali['normali'] = ali[r'alicode'].apply(apply_regexes)

# trascrizione
ali['unicode'] = ali[r'normali'].apply(t,column="UNICODE",separator=" \\u0020 ")
ali['html'] = ali[r'normali'].apply(t,column="HTML",separator=" &#x20; ")

ali['unicode'] = ali[r'unicode'].str.replace(" ","")
ali['html'] = ali[r'html'].str.replace(" ","")

# salvataggio
ali.to_csv('file_prova.tsv',sep='\t',index=False,quoting=3,encoding="utf-8")

#------ intero volume

directory_path = 'directory\\volume\\dati'
copy_path = 'directory\\volume\\dati\\norm'

for filename in os.listdir(directory_path):
    #if filename.endswith(".ALI"):  # cambiare estensione secondo necessità
    if filename.startswith("IX"): # cambiare numero volume secondo necessità
        file_path = os.path.join(directory_path, filename)
        
        # importazione file
        #df = pd.read_csv(file_path, sep='\t', encoding='utf-8',quoting=3,header=None) # volumi fino a 7
        df = pd.read_csv(file_path, sep='\t', encoding='utf-8',quoting=3) # da 8 in poi
        
        # separazione colonne
        df.columns = ['col']
        df = pd.DataFrame({'col': re.sub(r'-\n {8}-', '', '\n'.join(df['col'])).split('\n')})
        df[['col','col2']] = df['col'].str.split(r'(?<=^\d{4})',expand=True)
        df[['col2','col3']] = df['col2'].str.split(r'(?<=^[a-z]{2}\d{3})',expand=True)
        df.columns = ['punto','codice','alicode']
        
        # applicazione regexes
        df['alicode'] = df['alicode'].replace(np.nan, '')
        df['normali'] = df['alicode'].apply(apply_regexes)
        df['unicode'] = df['normali'].apply(t,column="UNICODE",separator=" \\u0020 ")
        df['html'] = df['norm'].apply(t,column="HTML",separator=" &#x20; ")
        df['unicode'] = df['unicode'].str.replace(" ","")
        df['html'] = df['html'].str.replace(" ","")

        # cambio estensione
        base_name, _ = os.path.splitext(filename)  # splits "data" and ".csv"
        new_filename = f"{base_name}.tsv"
        
        # salvataggio
        modified_file_path = os.path.join(copy_path, f"norm_{new_filename}")
        df.to_csv(modified_file_path, sep='\t', index=False, encoding='utf-8',quoting=csv.QUOTE_NONE)

        print(f"Normalizzato {filename}")