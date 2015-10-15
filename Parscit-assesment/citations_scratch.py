import distance
import os, sys
import xmldict
import pandas as pd
from fuzzywuzzy import fuzz

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

for k in pc:
    if len(pc[k]) == 0:
        pc[k].append('NO PARSCIT CITATIONS')
    else:
        pass

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
            col2 = str(col2).replace('\r', ' ')
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


all_ratios = []
colnames = ['ria','cite','type','partial','partial_match','lev','lev_match','jac','jac_match','sor','sor_match']
df = pd.DataFrame(columns=colnames)
for a in gt:
    print "checking {}".format(a)
    ls_partials = []
    ls_levs = []
    ls_hams = []
    ls_jacs = []
    ls_sors = []
    checked = 0
    for b in pc:
        if checked == 0:
            if a == b:
                checked += 1
                for v1 in gt[a]:
                    partials = []
                    levs = []
                    jacs = []
                    sors = []
                    for v2 in pc[b]:
                        try:
                            partials.append((1-(fuzz.partial_ratio(v1, v2)/100.0)))
                            levs.append(distance.levenshtein(v1,v2, normalized=True))
                            jacs.append(distance.jaccard(v1, v2))
                            sors.append(distance.sorensen(v1, v2))
                        except UnicodeDecodeError:
                            partials.append(0)
                            levs.append(1)
                            jacs.append(1)
                            sors.append(1)
                    ls_partials.append(partials)
                    ls_levs.append(levs)
                    ls_jacs.append(jacs)
                    ls_sors.append(sors)
            else:
                pass
        else:
            pass
    df_partial = pd.DataFrame(ls_partials)
    df_partial.index = gt[a]
    df_partial.columns = pc[a]
    df_partial.to_csv("Parscit-assesment/results/{}-partial.txt".format(a),sep='\t')
    df_lev = pd.DataFrame(ls_levs)
    df_lev.index = gt[a]
    df_lev.columns = pc[a]
    df_lev.to_csv("Parscit-assesment/results/{}-lev.txt".format(a),sep='\t')
    df_jac = pd.DataFrame(ls_jacs)
    df_jac.index = gt[a]
    df_jac.columns = pc[a]
    df_jac.to_csv("Parscit-assesment/results/{}-jac.txt".format(a),sep='\t')
    df_sor = pd.DataFrame(ls_sors)
    df_sor.index = gt[a]
    df_sor.columns = pc[a]
    df_sor.to_csv("Parscit-assesment/results/{}-sor.txt".format(a),sep='\t')
    
    partial_list = []
    for i in df_partial.columns:
        print i
        holder = {'ria': a, 'cite': i, 'type': 'pc', 'partial_match':df_partial[i].idxmax(), 'partial':df_partial[i].max()}
        partial_list.append(holder)
    lev_list = []
    for i in df_lev.columns:
        holder = {'ria': a, 'cite': i, 'type': 'pc', 'lev_match':df_lev[i].idxmin(), 'lev':df_lev[i].min()}
        lev_list.append(holder)
    jac_list = []
    for i in df_jac.columns:
        holder = {'ria': a, 'cite': i, 'type': 'pc', 'jac_match':df_jac[i].idxmin(), 'jac':df_jac[i].min()}
        jac_list.append(holder)
    sor_list = []
    for i in df_sor.columns:
        holder = {'ria': a, 'cite': i, 'type': 'pc', 'sor_match':df_sor[i].idxmin(), 'sor':df_sor[i].min()}
        sor_list.append(holder)

    df_partial = df_partial.transpose()
    for i in df_partial.columns:
        holder = {'ria': a, 'cite': i, 'type': 'gt', 'partial_match':df_partial[i].idxmax(), 'partial':df_partial[i].max()}
        partial_list.append(holder)
    df_lev = df_lev.transpose()
    for i in df_lev.columns:
        holder = {'ria': a, 'cite': i, 'type': 'gt', 'lev_match':df_lev[i].idxmin(), 'lev':df_lev[i].min()}
        lev_list.append(holder)
    df_jac = df_jac.transpose()
    for i in df_jac.columns:
        holder = {'ria': a, 'cite': i, 'type': 'gt', 'jac_match':df_jac[i].idxmin(), 'jac':df_jac[i].min()}
        jac_list.append(holder)
    df_sor = df_sor.transpose()
    for i in df_sor.columns:
        holder = {'ria': a, 'cite': i, 'type': 'gt', 'sor_match':df_sor[i].idxmin(), 'sor':df_sor[i].min()}
        sor_list.append(holder)
    
    df_partial = pd.DataFrame(partial_list)
    df_lev = pd.DataFrame(lev_list)
    df_jac = pd.DataFrame(jac_list)
    df_sor = pd.DataFrame(sor_list)
    df_full = pd.merge(df_partial, df_lev, on = ('ria','cite','type'))
    df_full = pd.merge(df_full, df_jac, on = ('ria','cite','type'))
    df_full = pd.merge(df_full, df_sor, on = ('ria','cite','type'))
    df = df.append(df_full)
    print df

df.to_csv('Parscit-assesment/results/matches.txt', sep='\t', index=False)







