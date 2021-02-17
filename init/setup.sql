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

CREATE TABLE Personality (
  user_id VARCHAR(50) NOT NULL,
  openness INTEGER NOT NULL,
  agreeableness INTEGER NOT NULL,
  emotional_stability INTEGER NOT NULL,
  conscientiousness INTEGER NOT NULL,
  extraversion INTEGER NOT NULL,
  assigned_metric VARCHAR(20) NOT NULL CHECK(assigned_metric IN ('serendipity', 'all', 'popularity', 'diversity')),
  assigned_condition VARCHAR(20) NOT NULL CHECK(assigned_condition IN ('high', 'default', 'medium', 'low')),
  movie_1 INTEGER NOT NULL,
  predicted_rating_1 FLOAT NOT NULL,
  movie_2 INTEGER NOT NULL,
  predicted_rating_2 FLOAT NOT NULL,
  movie_3 INTEGER NOT NULL,
  predicted_rating_3 FLOAT NOT NULL,
  movie_4 INTEGER NOT NULL,
  predicted_rating_4 FLOAT NOT NULL,
  movie_5 INTEGER NOT NULL,
  predicted_rating_5 FLOAT NOT NULL,
  movie_6 INTEGER NOT NULL,
  predicted_rating_6 FLOAT NOT NULL,
  movie_7 INTEGER NOT NULL,
  predicted_rating_7 FLOAT NOT NULL,
  movie_8 INTEGER NOT NULL,
  predicted_rating_8 FLOAT NOT NULL,
  movie_9 INTEGER NOT NULL,
  predicted_rating_9 FLOAT NOT NULL,
  movie_10 INTEGER NOT NULL,
  predicted_rating_10 FLOAT NOT NULL,
  movie_11 INTEGER NOT NULL,
  predicted_rating_11 FLOAT NOT NULL,
  movie_12 INTEGER NOT NULL,
  predicted_rating_12 FLOAT NOT NULL,
  is_personalized INTEGER NOT NULL,
  enjoy_watching INTEGER NOT NULL,
  PRIMARY KEY (user_id), 
  FOREIGN KEY (movie_1) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_2) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_3) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_4) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_5) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_6) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_7) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_8) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_9) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_10) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_11) REFERENCES Movies(movie_id) ON UPDATE CASCADE,
  FOREIGN KEY (movie_12) REFERENCES Movies(movie_id) ON UPDATE CASCADE
)
ENGINE = InnoDB;

-- -- LOADING DATA INTO TABLES

LOAD DATA INFILE '/init/data/final_data/users.csv'
INTO TABLE Users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


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

LOAD DATA INFILE '/init/data/final_data/personality.csv'
INTO TABLE Personality
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


-- -- CREATING NEW USERS
-- SELECT user, host FROM mysql.user;

-- CREATE USER 'dev'@'%' IDENTIFIED BY 'team11';
-- GRANT ALL PRIVILEGES ON MovieLens.* TO 'dev'@'%';
-- FLUSH PRIVILEGES;
