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
                      when 1 then "Movies.title ASC"
                      when 2 then "Movies.title DESC"
                      when 3 then "rating DESC"
                      WHEN 4 then "Movies.movie_id DESC"
                      ELSE "Movies.movie_id ASC"
                      END;

set @select_params = CASE order_by_parameter
                      when 3 then ", AVG(Ratings.rating) as rating "
                      ELSE " "
                      END;

set @join_params = CASE order_by_parameter
                      when 3 then "LEFT JOIN Ratings ON Ratings.movie_id = Movies.movie_id "
                      ELSE " "
                      END;

IF search_value = "" and genres_chosen = "" THEN
set @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title", @select_params,
    "FROM Movies ", 
    @join_params,
	"GROUP BY Movies.movie_id
    ORDER BY ", @order_by, 
    " LIMIT ",  no_of_results,
    " OFFSET ", offset_required)
    ;

ELSEIF search_value = "" THEN
set @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title", @select_params,
    "FROM Movies ", 
    @join_params,
    "LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
    Genre_Movie.movie_id = Movies.movie_id
    WHERE find_in_set(Genres.genre,'",genres_chosen,"')
	GROUP BY Movies.movie_id
    ORDER BY ", @order_by, 
    " LIMIT ",  no_of_results,
    " OFFSET ", offset_required)
    ;

ELSEIF genres_chosen = "" THEN

set @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title", @select_params,
    "FROM Movies ", 
    @join_params,
    "WHERE Movies.title LIKE '", search_value,  "'
	GROUP BY Movies.movie_id
    ORDER BY ", @order_by, 
    " LIMIT ",  no_of_results,
    " OFFSET ", offset_required)
    ;

ELSE    

set @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title", @select_params,
    "FROM Movies ", 
    @join_params,
    "LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
    Genre_Movie.movie_id = Movies.movie_id
    WHERE find_in_set(Genres.genre,'",genres_chosen,"')
    AND Movies.title LIKE '", search_value, "'
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
