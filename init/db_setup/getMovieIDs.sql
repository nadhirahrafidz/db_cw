USE `MovieLens`;
DROP procedure IF EXISTS `getMoviesIDs`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `getMoviesIDs` (
    IN no_of_results INT,
    IN offset_required INT,
    IN genres_chosen VARCHAR(1000),
    IN search_value VARCHAR(255)
    )

BEGIN
IF search_value = "" and genres_chosen = "" THEN
    SELECT DISTINCT Movies.movie_id
    FROM Movies
    LIMIT no_of_results
    OFFSET offset_required
    ;

ELSEIF search_value = "" THEN

	SELECT DISTINCT Movies.movie_id
    FROM Movies, Genres, Genre_Movie 
    WHERE Movies.movie_id = Genre_Movie.movie_id 
    AND Genre_Movie.genre_id = Genres.genre_id 
    AND find_in_set(Genres.genre, genres_chosen)
    LIMIT no_of_results
    OFFSET offset_required
    ;

ELSEIF genres_chosen = "" THEN

	SELECT DISTINCT Movies.movie_id
    FROM Movies
    WHERE Movies.title LIKE search_value
    LIMIT no_of_results
    OFFSET offset_required
    ;
    
ELSE    
    SELECT DISTINCT Movies.movie_id
    FROM Movies, Genres, Genre_Movie 
    WHERE Movies.movie_id = Genre_Movie.movie_id 
    AND Genre_Movie.genre_id = Genres.genre_id 
    AND find_in_set(Genres.genre, genres_chosen)
    AND Movies.title LIKE search_value
    LIMIT no_of_results
    OFFSET offset_required
    ;
END IF;
END$$

DELIMITER ;
