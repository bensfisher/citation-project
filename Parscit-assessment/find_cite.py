import distance
import urllib2
from bs4 import BeautifulSoup

def find_cite(cite, user, agent = "scraper/1.0"):
    """ get DOI for citation on citeulike
    Keyword arguments:
    user -- username and email for citelike (e.g. 'user/email')
    agent -- name of program used (default 'scraper/1.0)
    cite -- citation title
    """
    user_agent = "%s %s" % (user, agent)
    hdr = {'User-Agent':user_agent}
    title = cite.replace(' ', '+')
    url = "http://www.citeulike.org/search/all?q=%s" % title
    req = urllib2.Request(url, headers=hdr)
    page = urllib2.urlopen(req)
    text = page.read()
    soup = BeautifulSoup(text, 'html.parser')

    stop = 0
    for a in soup.find_all('a',{'class':'title'}):
        if stop == 0:
            title2 = a.get_text()[2:-1]
            print 'citation is: %s' % cite
            print 'best match is: %s' % title2
            stop += 1
    score = distance.levenshtein(cite, title2, normalized = True)
    stop = 0
    for a in soup.find_all('a'):
        if stop == 0:
            if str(a.string)[0:3] == 'doi':
                doi = a.string[4:-1]
                stop += 1
            else:
                doi = 'no match'
    if score <=.6:
        return doi
    else:
        return 'no match'
