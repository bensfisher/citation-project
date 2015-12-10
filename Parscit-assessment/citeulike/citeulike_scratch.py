import distance
import urllib2
import os, sys
import time
import pandas as pd
from bs4 import BeautifulSoup
from find_cite import find_cite

start = time.time()

reload(sys)
sys.setdefaultencoding('utf8')

df = pd.read_table('results/matches.txt', sep=':', header=0)
df = df[(df.source == 'pc')]
df = df.reset_index(drop=True)
df['citeulike'] = ''

for i in xrange(0, len(df)):
    try:
        t = (df['cite'][i])
        df['citeulike'][i] = find_cite(t, 'bsf153/bsf153@psu.edu')
    except (UnboundLocalError, urllib2.HTTPError):
        df['citeulike'][i] = 'no match'
    print i
end = time.time()

print end - start


