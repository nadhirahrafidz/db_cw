USE `MovieLens`;
-- DROP procedure IF EXISTS `use3_polarising`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`%` 
PROCEDURE `use3_polarising`(
    IN pTimescale INT,
    IN pOffset INT,
    IN pLimit INT, 
    IN pGenre INT,
    OUT pCount INT)
BEGIN
    DECLARE vGenre_id INT;
    DECLARE vStarting_date DATETIME; 
    DECLARE vCurr_date DATETIME; 
    DECLARE C INT;
    DECLARE m INT;
    DECLARE overall_average_rating_count FLOAT;

    -- Polarising formula reference: http://www.keldlundgaard.com/Polarizing_imdb_movies.html
    -- Get subset of movies
    IF  pGenre != 0 THEN
        DROP TEMPORARY TABLE IF EXISTS subset_movies;
        CREATE TEMPORARY TABLE subset_movies SELECT DISTINCT Genre_Movie.movie_id
                                                FROM Genre_Movie
                                                WHERE genre_id = pGenre; 
    ELSE
            DROP TEMPORARY TABLE IF EXISTS subset_movies;
            CREATE TEMPORARY TABLE subset_movies SELECT DISTINCT movie_id FROM Movies; 
    END IF;

    -- Select time period
    IF pTimescale = 0 THEN 
        SET vStarting_date = (SELECT MIN(rating_timestamp) FROM Ratings); 
    ELSE
        SET vCurr_date = (SELECT MAX(rating_timestamp) FROM Ratings); 
        SET vStarting_date = (SELECT DATE_SUB(vCurr_date, INTERVAL pTimescale DAY));
    END IF; 

    -- Popularity ranking
    DROP TEMPORARY TABLE IF EXISTS subset_rating_info;
    CREATE TEMPORARY TABLE subset_rating_info SELECT Ratings.movie_id as movie_id,
                                    Ratings.rating as rating
                                    FROM Ratings 
                                    INNER JOIN subset_movies ON Ratings.movie_id = subset_movies.movie_id
                                    WHERE Ratings.rating_timestamp >= vStarting_date;

    DROP TEMPORARY TABLE IF EXISTS movie_count;
    CREATE TEMPORARY TABLE movie_count SELECT movie_id, 
                                    COUNT(rating) AS rating_count,
                                    STD(rating) AS rating_std
                                    FROM subset_rating_info 
                                    GROUP BY movie_id;

    SET C = (SELECT STD(subset_rating_info.rating) FROM subset_rating_info );
    SET m = (SELECT min(rating_count) FROM (SELECT * FROM movie_count LIMIT 250) AS top_250);
    SET overall_average_rating_count = (SELECT AVG(rating_count) FROM movie_count);


    SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

    DROP TEMPORARY TABLE IF EXISTS result;
    CREATE TEMPORARY TABLE result SELECT DISTINCT movie_count.movie_id AS movie_id,
                                    Movies.title AS title,
                                    Movies.movieURL AS movieURL,
                                    GROUP_CONCAT(DISTINCT Genres.genre) AS genres,
                                    ROUND(((movie_count.rating_count/ (movie_count.rating_count + m)) * movie_count.rating_std) + ((m / (movie_count.rating_count + m)) * C),1) AS rating
                                    FROM movie_count 
                                    INNER JOIN Movies
                                    ON movie_count.movie_id = Movies.movie_id
                                    LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
                                    Genre_Movie.movie_id = movie_count.movie_id
                                    WHERE movie_count.rating_count > overall_average_rating_count
                                    GROUP BY movie_count.movie_id
                                    ORDER BY rating DESC, title ASC;

    SET pCount = (SELECT COUNT(*) FROM result);

    SELECT * FROM result
    LIMIT pLimit
    OFFSET pOffset;


    DROP TEMPORARY TABLE IF EXISTS subset_rating_info;
    DROP TEMPORARY TABLE IF EXISTS subset_movies;
    DROP TEMPORARY TABLE IF EXISTS movie_count;
END$$

DELIMITER ;