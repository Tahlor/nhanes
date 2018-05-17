import os
import time
import urllib
from urllib2 import urlopen
from urllib2 import Request

from pprint import pprint
from HTMLParser import HTMLParser
from os.path import basename
from urlparse import urlsplit
import re

# Globals
root_dir = r'D:\OneDrive\Documents\Graduate School\2017 Fall\CS 478\NHANES'
root_dir = r"D:\Data\NHANES\NHANES"
year_range = xrange(2017,2014,-2)

# NEW
#http://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Demographics&CycleBeginYear=2015
#http://wwwn.cdc.gov/Nchs/Nhanes/Search/DataPage.aspx?Component=Demographics&CycleBeginYear=2015
#http://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Laboratory&CycleBeginYear=2015


#Get Hyperlinks

def getLinks(website, prefix = "", keyword = ""):
    page=urlopen(website)
    text=page.read()
    hyperlink_list=[]
    sub_text = text 
    while sub_text.find('href=') > 0:
        sub_text = sub_text[sub_text.find('href=')+6:]
        hyperlink = sub_text[:sub_text.find(">")-1]
        #if hyperlink not in hyperlink_list:
            #print hyperlink
        #if hyperlink.rsplit('.', 1)[-1] == "pdf":
        if hyperlink.find(keyword)>-1 and prefix+hyperlink not in hyperlink_list:
            hyperlink_list.append(prefix+hyperlink)
    return hyperlink_list

#<th scope="row">Blood Pressure</th><td>


def url2name(url):
    return basename(urlsplit(url)[2])

def download(url, localFileName = None):
    localName = url2name(url)
    req = Request(url)
    r = urlopen(req)
    if r.info().has_key('Content-Disposition'):
        # If the response has Content-Disposition, we take file name from it
        localName = r.info()['Content-Disposition'].split('filename=')[1]
        if localName[0] == '"' or localName[0] == "'":
            localName = localName[1:-1]
    elif r.url != url: 
        # if we were redirected, the real file name we take from the final URL
        localName = url2name(r.url)
    if localFileName: 
        # we can force to save the file as specified name
        localName = localFileName
    f = open(localName, 'wb')
    f.write(r.read())
    f.close()

def download_data(hyperlink_list, full_path, full_path2 = ""):
    #for url in open('urls.txt'):
    for url in hyperlink_list:
        # Split on the rightmost / and take everything on the right side of that
        name = url.rsplit('/', 1)[-1]
        #format name
        #name = name.replace("smac-list-effective-", "")
        #for excludes in ["-includes", "-with"]:
        #    if name.find(excludes)> 0:
        #        name = name[:name.find(excludes)]
        #if name.find(extension) >= 0:
        filename, file_extension = os.path.splitext(name)
        if file_extension.lower() in extension_list or re.match(regex, name[-6:].lower()) :
            file_path_name = os.path.join(full_path2, name) if re.match(regex, name[-6:].lower()) else os.path.join(full_path, name)

            # Download if it doesn't exist
            if not os.path.isfile(file_path_name):
                try:

                    urllib.urlretrieve(url, file_path_name)
                except:
                    try:
                        urllib.urlretrieve(url_stub+url, file_path_name)
                    except:
                        print "Error downloading " + name
                        
                print name
                #download(url, filename)

def prep_directory(url, subfolder1 = "", subfolder2 = ""):   
    global url_stub
    print url
    #extension = raw_input("File extension? (include dot)")
    #url = raw_input("URL?")
    new_folder = url[url.find(".")+1:]
    new_folder = new_folder[:new_folder.find(".") ]
    print new_folder
    url_stub = url[:min(filter(lambda x: x > 0, [url.find(".com/"), url.find(".org/"),url.find(".gov/")]))+5]
    site_path = os.path.join(root_dir, new_folder)
    full_path = os.path.join(site_path, subfolder1) if subfolder1 <> "" else site_path
    full_path = os.path.join(full_path, subfolder2) if subfolder2 <> "" else full_path
    full_path2 = os.path.join(full_path, "Documentation")
    #full_path = os.path.join(site_path, (time.strftime("%m_%d_%Y")))
    print full_path
    if not os.path.exists(full_path2):
        os.makedirs(full_path2)
    hyperlink_list = getLinks(url)
    #print(hyperlink_list)
    print(url)

    #print hyperlink_list
    download_data(hyperlink_list, full_path, full_path2)

#hyperlink_list = getLinks('http://www.ilsmac.com/list', "http://www.ilsmac.com/", "files/smac-list-effective")
#url_list = {1:r"http://www.cdc.gov/nchs/nhanes/nh3data.htm"}
#extension = raw_input("File extension?")
#url = raw_input("URL?")

data_list = ["Demographics", "Non-Public", "Laboratory", "Questionnaire", "Examination", "Dietary"]
extension = ".dat, .xpt, .pdf, .txt, _c.htm".lower()
extension_list = extension.replace(" ", "").split(',')
#root_dir = r'C:\Users\tarchibald\Documents\Scripts\Python\General Tools\Downloader'
regex = re.compile('_.\.htm')

for year in year_range:
    url_list = []
    for data_name in data_list:
        prep_directory("https://wwwn.cdc.gov/Nchs/Nhanes/Search/DataPage.aspx?Component="+data_name+"&CycleBeginYear=" + str(year), str(year), data_name)
