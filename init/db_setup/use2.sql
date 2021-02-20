USE `MovieLens`;
DROP procedure IF EXISTS `use2`;

DELIMITER $$
USE `MovieLens`$$
-- https://www.mysqltutorial.org/mysql-stored-procedures-return-multiple-values/
CREATE PROCEDURE `use2` (
    IN pMovieID INT, 
    OUT pratings_count INT, 
    OUT paverage_score INT)
BEGIN
    SET pratings_count = (SELECT COUNT(rating) FROM Ratings WHERE Ratings.movie_id = pMovieID);
    SET paverage_score = (SELECT AVG(rating) FROM Ratings WHERE Ratings.movie_id = pMovieID);
    CREATE TEMPORARY TABLE results SELECT ROUND(rating,0) as rating_idx, COUNT(ROUND(rating, 0)) AS rating_count FROM Ratings WHERE Ratings.movie_id = 1 GROUP BY ROUND(rating, 0);
END$$

DELIMITER ;
