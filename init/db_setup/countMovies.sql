USE `MovieLens`;
DROP procedure IF EXISTS `countMovieIDs`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `countMovieIDs` (
    IN genres_chosen VARCHAR(1000),
    IN search_value VARCHAR(255)
    )

BEGIN
IF search_value = "" and genres_chosen = "" THEN
    SELECT COUNT(DISTINCT Movies.movie_id)
    FROM Movies
    ;

ELSEIF search_value = "" THEN

	SELECT COUNT(DISTINCT Movies.movie_id)
    FROM Movies
    LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
    Genre_Movie.movie_id = Movies.movie_id
    WHERE find_in_set(Genres.genre, genres_chosen)
    ;

ELSEIF genres_chosen = "" THEN

	SELECT COUNT(DISTINCT Movies.movie_id)
    FROM Movies
    WHERE Movies.title LIKE search_value
    ;
    
ELSE    
    SELECT COUNT(DISTINCT Movies.movie_id)
    FROM Movies
    LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
    Genre_Movie.movie_id = Movies.movie_id
    WHERE Movies.movie_id = Genre_Movie.movie_id 
    AND Genre_Movie.genre_id = Genres.genre_id 
    AND find_in_set(Genres.genre, genres_chosen)
    AND Movies.title LIKE search_value
    ;
END IF;
END$$

DELIMITER ;
