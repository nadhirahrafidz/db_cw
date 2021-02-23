USE `MovieLens`;
DROP procedure IF EXISTS `getMovieIDs`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `getMovieIDs` (
    IN no_of_results VARCHAR(32),
    IN offset_required VARCHAR(32),
    IN genres_chosen VARCHAR(1000),
    IN search_value VARCHAR(255),
    IN order_by_parameter INT
    )

BEGIN
set @order_by = CASE order_by_parameter
                      when 0 then "Movies.movie_id ASC"
                      when 1 then "Movies.title ASC"
                      when 2 then "Movies.title DESC"
                      when 3 then "rating DESC"
                      END;


IF search_value = "" and genres_chosen = "" THEN
set @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title, AVG(Ratings.rating) as rating
    FROM Movies, Ratings
	WHERE Movies.movie_id = Ratings.movie_id
	GROUP BY Movies.movie_id
    ORDER BY ", @order_by, 
    " LIMIT ",  no_of_results,
    " OFFSET ", offset_required)
    ;

ELSEIF search_value = "" THEN

set @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title, AVG(Ratings.rating) as rating
    FROM Movies, Genres, Genre_Movie, Ratings
    WHERE Movies.movie_id = Genre_Movie.movie_id 
    AND Genre_Movie.genre_id = Genres.genre_id 
    AND find_in_set(Genres.genre,'",genres_chosen,"')
	AND Movies.movie_id = Ratings.movie_id
	GROUP BY Movies.movie_id
    ORDER BY ", @order_by, 
    " LIMIT ",  no_of_results,
    " OFFSET ", offset_required)
    ;

ELSEIF genres_chosen = "" THEN

set @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title, AVG(Ratings.rating) as rating
    FROM Movies, Ratings
    WHERE Movies.title LIKE '", search_value,  "'
	AND Movies.movie_id = Ratings.movie_id
	GROUP BY Movies.movie_id
    ORDER BY ", @order_by, 
    " LIMIT ",  no_of_results,
    " OFFSET ", offset_required)
    ;

ELSE    

set @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title, AVG(Ratings.rating) as rating
    FROM Movies, Genres, Genre_Movie, Ratings
    WHERE Movies.movie_id = Genre_Movie.movie_id 
    AND Genre_Movie.genre_id = Genres.genre_id 
    AND find_in_set(Genres.genre,'",genres_chosen,"')
    AND Movies.title LIKE '", search_value, "'
	AND Movies.movie_id = Ratings.movie_id
	GROUP BY Movies.movie_id
    ORDER BY ", @order_by, 
    " LIMIT ",  no_of_results,
    " OFFSET ", offset_required)
    ;

END IF;

PREPARE stmt FROM @SQLStatement;
EXECUTE stmt;
END$$

DELIMITER ;
