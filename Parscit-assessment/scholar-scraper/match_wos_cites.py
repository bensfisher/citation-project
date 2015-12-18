import csv
import distance
import sys
import pandas as pd

reload(sys)  
sys.setdefaultencoding('utf8')

with open('clean_titles.txt') as f:
    reader = csv.reader(f)
    titles = list(reader)
f.close()

titles1 = []
for i in titles:
    for j in i:
        titles1.append(j)
titles1 = list(set(titles1))

df = pd.read_csv("wos_bib_frame.csv")
titles2 = df['title']
titles2 = list(set(titles2)) # remove duplicates
titles3 = []
for i in titles2:
    titles3.append(str(i).replace(',',''))
titles2 = titles3

ls_levs = []

# calculate distance scores for all combinations
for title1 in titles1:
    levs = []
    for title2 in titles2:
        try:
            levs.append(distance.levenshtein(str(title1), str(title2), normalized=True))
        except UnicodeDecodeError:
            levs.append(1)
    ls_levs.append(levs)

df_lev = pd.DataFrame(ls_levs)
df_lev.index = titles1
df_lev.columns = titles2
df_lev = df_lev.T

# get best match
ls_levs2 = []
for i in df_lev.columns:
    try:
        holder = {'gscholar':i, 'wos':df_lev[i].idxmin(), 'score':df_lev[i].min()}
    except ValueError:
        pass
    ls_levs2.append(holder)

df = pd.DataFrame(ls_levs2)

# filter based on .6 distance threshold
df = df[(df.score <= .6)]
matched = list(df['wos'])

with open('matched_wos_titles.txt', 'w') as f:
    f.write(','.join(matched))
f.close()