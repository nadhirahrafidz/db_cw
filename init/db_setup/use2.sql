/*
USE CASE 2 

Parameter:
pMovieID : Movie ID which exists in Movies table
pratings_count: INT variable which will hold the number of ratings for pMovieID
paverage_score: INT variable which will hold the average rating for pMovieID

Returns:
@pratings_count: INT variable which will hold the number of ratings for pMovieID
@paverage_score: INT variable which will hold the average rating for pMovieID
rating_breakdown: Table which holds the rating (0 to 5) and respective counts 

Example use in SQL:
    CALL use2(23, @pratings_count, @paverage_score); 

    SELECT @pratings_count; 
    SELECT @paverage_score;
    SELECT * FROM rating_breakdown;
*/

USE `MovieLens`;
-- DROP procedure IF EXISTS `use2`;

DELIMITER $$
USE `MovieLens`$$
-- https://www.mysqltutorial.org/mysql-stored-procedures-return-multiple-values/
CREATE DEFINER=`root`@`localhost`
PROCEDURE `use2` (
    IN pMovieID INT, 
    OUT pratings_count INT, 
    OUT paverage_score FLOAT)
BEGIN
    SET pratings_count = (SELECT COUNT(rating) FROM Ratings WHERE Ratings.movie_id = pMovieID);
    SET paverage_score = (SELECT AVG(rating) FROM Ratings WHERE Ratings.movie_id = pMovieID);

    DROP TEMPORARY TABLE IF EXISTS rating_breakdown;
    CREATE TEMPORARY TABLE rating_breakdown SELECT CEILING(rating) as rating_idx, COUNT(CEILING(rating)) AS rating_count 
                                    FROM Ratings 
                                    WHERE Ratings.movie_id = pMovieID
                                    GROUP BY rating_idx
                                    ORDER BY rating_idx;
END$$

DELIMITER ;
