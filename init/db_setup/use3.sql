USE `MovieLens`;
DROP procedure IF EXISTS `use3`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`%` PROCEDURE `use3`(
	IN requestType INT,
    IN pTimescale INT,
    IN pOffset INT,
    IN pLimit INT, 
    IN pGenre VARCHAR(100),
    OUT pCount INT)
BEGIN
    set @tableType = CASE requestType
                      when 1 then "Popular"
                      when 2 then "Polarising"
                      ELSE "Popular"
                      END;
    
	SET @tablename = CONCAT(@tableType, pTimescale);
    
	SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

	SET @genre_clause = CASE pGenre
										when "" then ""
										ELSE CONCAT(" LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
					Genre_Movie.movie_id = ",@tablename,".movie_id
										WHERE Genres.genre = '",pGenre, "' ")
										END;

	DROP TEMPORARY TABLE IF EXISTS result;
	SET @createtable = CONCAT(
				"CREATE TEMPORARY TABLE result 
					SELECT DISTINCT ",@tablename,".movie_id AS movie_id,
					",@tablename,".rating AS rating
					FROM ",@tablename,
											@genre_clause,
					" ORDER BY rating DESC;");
	PREPARE stmt FROM @createtable;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

  SET pCount = (SELECT COUNT(*) FROM result);
    
	SELECT result.movie_id as movie_id, 
	result.rating as rating,
	Movies.title AS title,
	Movies.movieURL AS movieURL,
 	GROUP_CONCAT(DISTINCT Genres.genre) AS genres
	FROM result
	LEFT JOIN Movies
	ON result.movie_id = Movies.movie_id
 	LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
 	Genre_Movie.movie_id = result.movie_id
	GROUP BY result.movie_id
	ORDER BY result.rating DESC, Movies.title ASC
	LIMIT pLimit
	OFFSET pOffset;
END$$

DELIMITER ;