import requests
import json
from bs4 import BeautifulSoup
import csv
import datetime
from collections import defaultdict

def scrape(imdbID):
    url = "http://www.imdb.com/title/tt"+imdbID+"/"
    page = requests.get(url)
    time = ""
    director = ""
    soup = BeautifulSoup(page.content, 'html.parser')
    try:
        time = soup.findAll("div", {"class":"subtext"})[0].find("time").text.strip()
    except IndexError:
        time = "n/a"
    except AttributeError:
        time = "n/a"
    try:
        director = soup.findAll("div", {"class":"credit_summary_item"})[0].find("a").text.strip()
    except IndexError:
        director = "n/a"
    except AttributeError:
        director = "n/a"
    return director, time


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

f_movies = open("movies.csv")
fout = open("movies_enhanced.csv", "a")
counter = 1
skip_amount = 667

for line in f_movies:
    if counter < skip_amount:
        counter+=1
        continue

    columns = line.strip().split(",")
    director, duration = scrape(mapping[columns[0]])
    fout.write(line.strip()+ "," + director + "," + duration + "\n")

    print(counter)
    counter+=1


f_movies.close()
fout.close()
scrape(mapping['1'])

