import csv
import re
import datetime
from shutil import copyfile

# Extract unique genres
uniqueGenres = []
with open('init/mysql_data/ml-latest-small/movies.csv', 'r') as file1:
    reader = csv.reader(file1)
    readingHeader = True
    for row in reader:
        if readingHeader:
            readingHeader = False
            continue
        genres = row[2].split("|")
        for genre in genres:
            if not (genre in uniqueGenres) and (genre != "(no genres listed)"):
                uniqueGenres.append(genre)

# write unique genres file
with open('init/mysql_data/final_data/genres.csv', 'w') as file:
    writer = csv.writer(file)
    for i in range(0, len(uniqueGenres)):
        writer.writerow([i+1, uniqueGenres[i]])

# make genre-movie csv file
with open('init/mysql_data/ml-latest-small/movies.csv', 'r') as file1:
    with open('init/mysql_data/final_data/genre-movie.csv', 'w') as file2:
        reader = csv.reader(file1)
        writer = csv.writer(file2)
        header = True
        for row in reader:
            if header:
                writer.writerow(["genre_id", "movie_id"])
                header = False
                continue
            genres = row[2].split("|")
            for genre in genres:
                if (genre != "(no genres listed)"):
                    writer.writerow([uniqueGenres.index(genre) + 1, row[0]])

# make final_movies csv
with open('init/mysql_data/ml-latest-small/movies.csv', 'r') as file1:
    with open('init/mysql_data/scraped_data/all_movie_scraped_data.csv', 'r') as file2:
        with open('init/mysql_data/final_data/movies.csv', 'w') as output:
            writer = csv.writer(output)
            list1 = [line.split(",") for line in file1]
            list2 = [line.split(",") for line in file2]
            for i in range(0, len(list1)):
                assert list1[i][0] == list2[i][0]
                list2[i][-1] = list2[i][-1].strip()
                newLine = list1[i][:2] + list2[i][1:]
                writer.writerow(newLine)

# convert ratings timestamp
with open('init/mysql_data/ml-latest-small/ratings.csv', 'r') as file1:
    with open('init/mysql_data/final_data/ratings.csv', 'w') as output:
        writer = csv.writer(output)
        reader = csv.reader(file1)
        header = True
        for row in reader:
            if header:
                writer.writerow(row)
                header = False
                continue
            newTimestamp = datetime.datetime.fromtimestamp(int(row[3]))
            row[3] = newTimestamp.strftime('%Y-%m-%d %H:%M:%S')
            writer.writerow(row)

# convert tags timestamp
with open('init/mysql_data/ml-latest-small/tags.csv', 'r') as file1:
    with open('init/mysql_data/final_data/tags.csv', 'w') as output:
        writer = csv.writer(output)
        reader = csv.reader(file1)
        header = True
        for row in reader:
            if header:
                writer.writerow(row)
                header = False
                continue
            newTimestamp = datetime.datetime.fromtimestamp(int(row[3]))
            row[3] = newTimestamp.strftime('%Y-%m-%d %H:%M:%S')
            writer.writerow(row)

# copy the stars and stars-movie files to final_data
copyfile("init/mysql_data/scraped_data/stars.csv", "init/mysql_data/final_data/stars.csv")
copyfile("init/mysql_data/scraped_data/star_movie.csv", "init/mysql_data/final_data/star_movie.csv")

with open('init/mysql_data/final_data/users.csv', 'w') as output:
    writer = csv.writer(output)
    writer.writerow(["userID"])
    for i in range(1, 611):
        writer.writerow([i])
