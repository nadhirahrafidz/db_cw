USE `MovieLens`;
DROP procedure IF EXISTS `use3_polarizing`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`%` PROCEDURE `use3_polarizing`(
    IN pTimescale INT,
    IN pOffset INT,
    IN pLimit INT, 
    IN pGenre VARCHAR(100))
BEGIN
    DECLARE vGenre_id INT;
    DECLARE vStarting_date DATETIME; 
    DECLARE vCurr_date DATETIME; 
    DECLARE C INT;
    DECLARE m INT;
    
    # Polarizing formula reference: http://www.keldlundgaard.com/Polarizing_imdb_movies.html
    -- Get subset of movies
    IF  pGenre != "" THEN
        SET vGenre_id = (SELECT genre_id FROM Genres WHERE Genres.genre = pGenre);
        DROP TEMPORARY TABLE IF EXISTS subset_movies;
        CREATE TEMPORARY TABLE subset_movies SELECT DISTINCT Genre_Movie.movie_id
                                                FROM Genre_Movie
                                                WHERE genre_id = vGenre_id; 
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
    
    SELECT Movies.title AS title, 
    movie_count.movie_id AS movie_id, 
    ((movie_count.rating_count/ (movie_count.rating_count + m)) * movie_count.rating_std) + ((m / (movie_count.rating_count + m)) * C) AS weighted_rating_std
    FROM movie_count 
    INNER JOIN Movies
    ON movie_count.movie_id = Movies.movie_id
    ORDER BY weighted_rating_std DESC 
    LIMIT pLimit;
    
    DROP TEMPORARY TABLE IF EXISTS subset_rating_info;
    DROP TEMPORARY TABLE IF EXISTS subset_movies;
    DROP TEMPORARY TABLE IF EXISTS movie_count;
END$$

DELIMITER ;

