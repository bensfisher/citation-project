<a href="https://flattr.com/submit/auto?user_id=venthur&url=http%3A%2F%2Fgithub.com%2Fventhur%2Fgscholar" target="_blank"><img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0"></a>


Requirements
============

 * Python
 * pdftotext (command line tool)


Note on Python2 and Python3
===========================

Gscholar is Python2 and Python3 compatible. No changes should be required to run
on either Python version.


Installing
==========

```bash
$ pip install gscholar
```

Using gscholar as a command line tool
=====================================

Put gscholar.py in your path (e.g. by putting it in your ~/bin/), to call it
from every directory.


Making a simple lookup:
-----------------------

    gscholar.py "some author or title"

will return the first resut from Google Scholar matching this query.


Getting more results:
---------------------

    gscholar.py --all "some author or title"

Same as above but returns up to 10 bibtex items. (Use with caution Google will
assume you're a bot an ban you're IP temporarily)


Querying using a pdf:
---------------------

    gscolar.py /path/to/pdf

Will read the pdf to generate a Google Scholar query. It uses this query to
show the first bibtex result as above.


Renaming a pdf:
---------------

    gscholar.py --rename /path/to/pdf

Will do the same as above but asks you if it should rename the file according
to the bibtex result. You have to answer with "y", default answer is no.


Getting help:
-------------

    gscholar.py --help



Using gscholar as a python library
==================================

Copy the package somewhere Python can find it.

    import gscholar

    gscholar.query("some author or title")

will return a list of bibtex items.



