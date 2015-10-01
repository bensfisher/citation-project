import xmldict
import pandas as pd
from fuzzywuzzy import fuzz

rias = ['test_RIAs/RIN0910-AC34-citations.txt',
        'test_RIAs/RIN0910-AF18-citations.txt',
        'test_RIAs/RIN1210-AB10-citations.txt']

titles1 = []

for ria in rias:
    with open (ria) as f:
        text=f.read().replace('\n','')
    check = xmldict.xml_to_dict(text)
    check2 = check.get('algorithms', {}).get('algorithm',{}).get('citationList',{}).get('citation')
    titles = []
    for item in check2:
        try:
            titles.append(item['title'])
        except KeyError:
            try:
                titles.append(item['booktitle'])
            except KeyError:
                pass
    for item in titles:
        titles1.append(item)

cites = pd.read_csv('RIACitations_Justin.csv')
cites = cites[(cites.RIN=='0910-AC34') | (cites.RIN=='0910-AF18') | (cites.RIN=='1210-AB10')]
titles2 = cites['Title'].tolist()

matched = []

for a in titles1:
    for b in titles2:
        ratio = fuzz.partial_ratio(a,b)
        if ratio >= 90:
            matched.append(a)

len(matched)/float(len(titles2))
            




