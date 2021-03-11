import requests
import json
from bs4 import BeautifulSoup
import csv
import datetime
from collections import defaultdict

def scrape(imdbID):
    url = "http://www.imdb.com/title/tt"+imdbID+"/"
    page = requests.get(url)
    image_url = ""
    soup = BeautifulSoup(page.content, 'html.parser')
    try:
        image_url = soup.find("div", {"class": "poster"}).find("img").get('src')
        #print(image_url)
    except IndexError:
        image_url = "n/a"
    except AttributeError:
        image_url = "n/a"
    return image_url


f_imdb_mapping = open("links.csv")
mapping = dict()
skip = True
for line in f_imdb_mapping:
    if skip:
        skip = False
        continue
    lines = line.strip().split(",")
    mapping[lines[0]] = lines[1]
f_imdb_mapping.close()

print(mapping['2'])
skip = True

#LINE TO CHANGE
f_movies = open("movies_enhanced.csv")
fout = open("movies_enhanced2.csv", "w")

counter = 0
skip_amount = 1

for line in f_movies:
    if counter < skip_amount:
        counter+=1
        fout.write(line.strip() + ",movieURL \n")
        continue

    columns = line.strip().split(",")
    url = scrape(mapping[columns[0]])
    fout.write(line.strip()+ "," + url + "\n")

    print(counter)
    counter+=1

f_movies.close()
fout.close()