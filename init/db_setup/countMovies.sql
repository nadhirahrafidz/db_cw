USE `MovieLens`;
-- DROP procedure IF EXISTS `countMovieIDs`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`localhost`
PROCEDURE `countMovieIDs` (
    IN genres_chosen INT,
    IN search_value VARCHAR(255)
    )

BEGIN

SET @search_value = search_value; 
SET @genres_chosen = genres_chosen;

IF search_value = "" and genres_chosen = 0 THEN
    SELECT COUNT(DISTINCT Movies.movie_id)
    FROM Movies
    ;

ELSEIF search_value = "" THEN

	SELECT COUNT(DISTINCT Movies.movie_id)
    FROM Movies
    LEFT JOIN Genre_Movie ON
    Genre_Movie.movie_id = Movies.movie_id
    WHERE Genre_Movie.genre_id = genres_chosen
    ;

ELSEIF genres_chosen = 0 THEN
	SET @SQLstatement = "SELECT COUNT(DISTINCT Movies.movie_id)
								FROM Movies
								WHERE Movies.title LIKE ?";

    PREPARE stmt FROM @SQLStatement;
    EXECUTE stmt USING @search_value;
    
ELSE    
	SET @SQLstatement = "SELECT COUNT(DISTINCT Movies.movie_id)
								FROM Movies
								LEFT JOIN Genre_Movie ON
								Genre_Movie.movie_id = Movies.movie_id
								WHERE Genre_Movie.genre_id = ?
								AND Movies.title LIKE ?";

    PREPARE stmt FROM @SQLStatement;
    EXECUTE stmt USING @genres_chosen, @search_value;
    
END IF;
END$$

DELIMITER ;
