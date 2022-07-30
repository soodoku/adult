import urllib2
import requests
#import re
import BeautifulSoup
#import newspaper

# def remove_html_tags(data):
#      p = re.compile(r'<.*?>')
#      return p.sub('', data)

num = 0
with open("unique_urls_100k.txt") as f: #urls_10.txt
    for url in f:
    	if num == 6:
    		break
    	num = num + 1
    	url = url.strip("\"\r\n")
        #print(url)
        try:
        	page = requests.get('http://' + url, timeout=1)
        	page_content = page.text.encode("utf-8")
        	#page_content = remove_html_tags(page_content) # remove tags
        	# http://stackoverflow.com/questions/2977893/best-way-to-strip-out-everything-but-text-from-a-webpage
        	page_content = ''.join(BeautifulSoup.BeautifulSoup(page_content).findAll(text=lambda 
        		text: text.parent.name != "script" and 
        		text.parent.name != "style")).encode("utf-8")
        	with open('text/url'+str(num)+'.txt', 'w') as fid:
    			fid.write(page_content)
        except (urllib2.URLError, requests.exceptions.ConnectionError, requests.exceptions.ReadTimeout):
        	print "Bad URL (" + str(num) + "): " + url
        

## newspaper test

from newspaper import Article
article = Article('http://' + url, keep_article_html=True, fetch_images=False)

article.download()
article.parse()

article.html
article.text

from newspaper import fulltext

html = requests.get('http://' + url, timeout=1).text.encode("utf-8")
text = fulltext(html)

## using newspaper (1)

import urllib2
import requests
from newspaper import fulltext

num = 0
with open("unique_urls_100k.txt") as f: #urls_10.txt
    for url in f:
        if num == 50:
            break
        num = num + 1
        url = url.strip("\"\r\n")
        #print(url)
        try:
            page = requests.get('http://' + url, timeout=1)
            page_content = page.text.encode("utf-8")
            text = fulltext(page_content)
            with open('text/url'+str(num)+'.txt', 'w') as fid:
                fid.write(text)
        except: # (urllib2.URLError, requests.exceptions.ConnectionError, requests.exceptions.ReadTimeout): #, requests.exceptions.ReadTimeout
            print "Bad URL (" + str(num) + "): " + url
        
