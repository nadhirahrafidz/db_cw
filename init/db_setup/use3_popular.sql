USE `MovieLens`;
DROP procedure IF EXISTS `use3_popular`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`%` PROCEDURE `use3_popular`(
    IN pTimescale INT,
    IN pOffset INT,
    IN pLimit INT, 
    IN pGenre VARCHAR(100),
    OUT pCount INT)
BEGIN

	SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
    
	set @tablename = CONCAT("Popular",pTimescale);

    DROP TEMPORARY TABLE IF EXISTS result;
    SET @createtable = CONCAT(
					"CREATE TEMPORARY TABLE result 
						SELECT DISTINCT ",@tablename,".movie_id AS movie_id,
						",@tablename,".rating AS rating,
						Movies.title AS title,
						Movies.movieURL AS movieURL,
						GROUP_CONCAT(DISTINCT Genres.genre) AS genres
						FROM ",@tablename,"
						LEFT JOIN Movies
						ON ",@tablename,".movie_id = Movies.movie_id
						LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
						Genre_Movie.movie_id = ",@tablename,".movie_id
						GROUP BY ",@tablename,".movie_id
						ORDER BY rating DESC, title ASC;");

    PREPARE stmt FROM @createtable;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;

    SET pCount = (SELECT COUNT(*) FROM result);

    SELECT * FROM result
    LIMIT pLimit
    OFFSET pOffset;
END$$

DELIMITER ;
