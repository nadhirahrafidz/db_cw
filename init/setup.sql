-- GRANT SELECT,UPDATE,INSERT,DELETE
--     ON MovieLens.*
--     TO 'example'@'localhost'
--     IDENTIFIED BY 'ucl';

CREATE DATABASE MovieLens
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;
  
USE MovieLens;

CREATE TABLE Users (
    user_id INTEGER NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (user_id)
)
ENGINE = InnoDB;

-- From movies_complete
-- runtime should be an integer
CREATE TABLE Movies (
  movie_id INTEGER NOT NULL AUTO_INCREMENT,
  title VARCHAR(500),
  director VARCHAR(200),
  runtime INTEGER,
  releaseDate VARCHAR(200),
  PRIMARY KEY (movie_id)
)
ENGINE = InnoDB;

# user_id should not Auto_increment
# movie_id is a foreign key
CREATE TABLE Ratings (
  user_id INTEGER NOT NULL,
  movie_id INTEGER,
  rating FLOAT,
  rating_timestamp DATETIME,
  PRIMARY KEY (user_id, movie_id, rating_timestamp),
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON UPDATE CASCADE
)
ENGINE = InnoDB;


# user_id should not Auto_increment
CREATE TABLE Tags (
  user_id INTEGER NOT NULL,
  movie_id INTEGER,
  tag VARCHAR(200),
  tags_timestamp DATETIME,
  PRIMARY KEY (user_id, movie_id, tag, tags_timestamp),
  FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON UPDATE CASCADE
)
ENGINE = InnoDB;

CREATE TABLE Stars (
  star_id INTEGER NOT NULL AUTO_INCREMENT,
  star_name VARCHAR(200) NOT NULL,
  PRIMARY KEY (star_id)
)
ENGINE = InnoDB;

CREATE TABLE Star_Movie (
  star_id INTEGER NOT NULL,
  movie_id INTEGER NOT NULL,
  FOREIGN KEY (star_id) REFERENCES Stars(star_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  PRIMARY KEY (star_id, movie_id)
)
ENGINE = InnoDB;

CREATE TABLE Genres (
  genre_id INTEGER NOT NULL AUTO_INCREMENT,
  genre VARCHAR(200),
  PRIMARY KEY (genre_id)
)
ENGINE = InnoDB;

CREATE TABLE Genre_Movie (
  genre_id INTEGER NOT NULL,
  movie_id INTEGER NOT NULL,
  PRIMARY KEY (genre_id, movie_id),
  FOREIGN KEY (genre_id) REFERENCES Genres(genre_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES Movies(movie_id) ON UPDATE CASCADE
)
ENGINE = InnoDB;

-- -- LOADING DATA INTO TABLES
SHOW VARIABLES LIKE "secure_file_priv";

LOAD DATA INFILE '/init/data/final_data/users.csv'
INTO TABLE Users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- Populate Movies table with new values
LOAD DATA INFILE '/init/data/final_data/movies.csv'
INTO TABLE Movies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@movieId
, @title
, @Main_director
, @Duration
, @releaseYear
)
SET `movie_id` = @movieId
  , `title` = @title
  , `director` = @Main_director
  , `runtime` = @Duration
  , `releaseDate` = @releaseYear
;

LOAD DATA INFILE '/init/data/final_data/ratings.csv'
INTO TABLE Ratings
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/init/data/final_data/tags.csv'
INTO TABLE Tags
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/init/data/final_data/stars.csv'
INTO TABLE Stars
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/init/data/final_data/star_movie.csv'
INTO TABLE Star_Movie
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA INFILE '/init/data/final_data/genres.csv'
INTO TABLE Genres
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA INFILE '/init/data/final_data/genre-movie.csv'
INTO TABLE Genre_Movie
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


