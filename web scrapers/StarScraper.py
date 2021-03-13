import requests
import json
from bs4 import BeautifulSoup
import csv
import datetime
from collections import defaultdict

#function that writes the titles for the respective files. If run in batches, comment out the call
def writeTitles(f_stars, f_star_movie):
    f_stars.write("StarID,Name")
    f_star_movie.write("StarID,movieID")


#function that does the scraping
def scrape(imdbID):
    url = "http://www.imdb.com/title/tt"+imdbID+"/"
    page = requests.get(url)
    soup = BeautifulSoup(page.content, 'html.parser')
    try:
        summary = soup.find("div", {"class":"plot_summary"})
        star_list_section = summary.findAll("div", {"class":"credit_summary_item"})[2]
        star_list = star_list_section.findAll("a")
        names = []
        for index in range(0, len(star_list)-1): #change to index based cause we dont want the last one (see full cast + crew)
            names.append(star_list[index].text.strip())
        return names
    except (IndexError, AttributeError) as e:
        return []

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

f_stars = open("stars.csv", "a")
f_star_movie = open("star_movie.csv", "a")
f_movies = open("movies.csv")

#uncomment out the line if you are running this for the first time
#writeTitles(f_stars, f_star_movie)

starID = 1
name_id_mapping = dict()

counter = 0
for line in f_movies:
    if counter == 0:
        counter = 1
        continue

    columns = line.strip().split(",")
    names = scrape(mapping[columns[0]])
    
    for name in names:
        if not name in name_id_mapping:
            name_id_mapping[name] = starID
            starID += 1
        
        name_id = name_id_mapping[name]
        f_star_movie.write(str(name_id_mapping[name]) + "," + str(columns[0]) + "\n")
    
    counter += 1
    print(counter)


for name in name_id_mapping:
    f_stars.write(str(name_id_mapping[name])  + "," + name + "\n")


f_stars.close()
f_star_movie.close()