import codecs
import os, sys
import xmldict
import pandas as pd
from fuzzywuzzy import fuzz

reload(sys)
sys.setdefaultencoding('utf-8')


rias = []
root = 'Parscit-assesment/test-RIAs'
for dirs, subdirs, files in os.walk(root):
    for name in files:
        if name.endswith('cites.txt'):
            rias.append(os.path.join(root, name))

pc = {}
processed = 0
# create dictionary with RIN as key and list of citation titles as value for Parscit output
for ria in rias:
    print "pulling titles from %s" % ria
    with open (ria) as f:
        text=f.read().replace('\n','')
    try:
        titles = []
        xml = xmldict.xml_to_dict(text)
        xmllist = xml.get('algorithms', {}).get('algorithm',{}).get('citationList',{}).get('citation')
        if isinstance(xmllist, list) is True:
            for item in xmllist:
                try:
                    titles.append(item['title'])
                except KeyError:
                    try:
                        titles.append(item['booktitle'])
                    except KeyError:
                        pass
        elif isinstance(xmllist, dict) is True:
            titles.append(xmllist['title'])
        else:
            pass
    except AttributeError,e:
        print e
    pc[ria[-19:-10]] = titles
    processed += 1


# create similar dictionary for manually coded data 
cites = pd.read_csv('Parscit-assesment/RIACitations.csv')
cites = cites[(cites.RIN != 'RIN1190-AA44') & (cites.RIN != 'RIN1190-AA46') & (cites.RIN != 'RIN1601-AA52')]
cites = cites[['RIN','Title']]
cites['rin'] = cites['RIN']
for i in range(len(cites['RIN'])):
    cites['rin'][i] = cites['RIN'][i][0:9]
rins = pd.unique(cites.rin.ravel()).tolist()

gt = {}
for rin in rins:
    ls = []
    for col1, col2 in zip(cites['rin'], cites['Title']):
        if rin == col1:
            ls.append(col2)
        else:
            pass
    gt[rin] = ls

# some RIAs weren't found when running Parscit apparently. Drop them from the
# ground truth dictionary if they're not in the Parscit dictionary.
gt2 = {}
for rin in gt:
    if rin in pc:
        gt2[rin] = gt[rin]

gt = gt2
del gt2

# create a list to hold all the ratios, then dictionary to store ratios by ria
all_ratios = []
ria_ratios = {}
passed = 0

reload(sys)  
sys.setdefaultencoding('utf8')

for a in gt:
    ls = []
    checked = 0
    for b in pc:
        if checked == 0:
            if a == b:
                for v1 in gt[a]:
                    for v2 in pc[b]:
                        try:
                            ratio = fuzz.partial_ratio(v1, v2)
                            all_ratios.append(ratio)
                            ls.append(ratio)
                        except UnicodeDecodeError:
                            passed += 1
                checked += 1
            else:
                pass
        else:
            pass
    ria_ratios[a] = ls



