USE `MovieLens`;
DROP procedure IF EXISTS `createPolarisingTable`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `createPolarisingTable`(
    IN pTimescale INT
    )
BEGIN
    DECLARE vStarting_date DATETIME; 
    DECLARE vCurr_date DATETIME; 
    DECLARE C FLOAT;
    DECLARE m INT;
    DECLARE overall_average_rating_count FLOAT;
    DECLARE new_table_name VARCHAR(100);

	DROP TEMPORARY TABLE IF EXISTS subset_movies;
	CREATE TEMPORARY TABLE subset_movies SELECT DISTINCT movie_id FROM Movies; 
    
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
                                    WHERE Ratings.rating_timestamp >= vStarting_date;
          
    DROP TEMPORARY TABLE IF EXISTS movie_count;
    CREATE TEMPORARY TABLE movie_count SELECT movie_id, 
                                    COUNT(rating) AS rating_count,
                                    STD(rating) AS rating_std
                                    FROM subset_rating_info 
                                    GROUP BY movie_id
                                    ORDER BY rating_count DESC;
    
    SET C = (SELECT STD(subset_rating_info.rating) FROM subset_rating_info );
    SET m = (SELECT min(rating_count) FROM (SELECT * FROM movie_count LIMIT 250) AS top_250);
    SET overall_average_rating_count = (SELECT AVG(rating_count) FROM movie_count);
    
    
    SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
    
    SET new_table_name = CONCAT("Polarising", pTimescale);
    
    SET @droptable = CONCAT("DROP TABLE IF EXISTS ", new_table_name, ";");
    PREPARE stmt FROM @droptable;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

	SET @createtable = CONCAT(
					" CREATE TABLE ", new_table_name, 
					" SELECT DISTINCT movie_count.movie_id AS movie_id,
					ROUND(((movie_count.rating_count/ (movie_count.rating_count + ",m,")) * movie_count.rating_std) + ((",m," / (movie_count.rating_count + ",m,")) * ",C,"),1) AS rating
					FROM movie_count
					WHERE movie_count.rating_count > ",overall_average_rating_count,"
					GROUP BY movie_count.movie_id
					ORDER BY rating DESC;");

	PREPARE stmt FROM @createtable;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
    
  DROP TEMPORARY TABLE IF EXISTS subset_rating_info;
  DROP TEMPORARY TABLE IF EXISTS movie_count;
END$$

DELIMITER ;

