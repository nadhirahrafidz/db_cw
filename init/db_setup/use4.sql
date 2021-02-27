/*
USE CASE 4

Parameter:
pMovieID : Movie ID which exists in Movies table

Returns:
top_genres: Table which holds the top 2 genres and average rating for pMovieID genres
most_likely_genre: Table which holds userIDs of users most likely to enjoy movie based on genres
pCountMostLikely: Count of most_likely_genre
likely_genre: Table which holds userIDs of users likely to enjoy movie based on genres
pCountLikely: Count of likely_genre

Example use in SQL:
    CALL use4(1); 

    SELECT * FROM most_likely_genre;
    SELECT @pCountMostLikely
    SELECT * FROM likely_genre;
    SELECT @pCountLikely
*/

USE `MovieLens`;
DROP procedure IF EXISTS `use4`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `use4` (
    IN pMovieID INT,
    OUT pCountMostLikely INT,
    OUT genre_1 INT,
    OUT genre_2 INT,
    OUT pCountLikely INT,
    OUT pCountLeastLikely INT,
    OUT pCountUsuallyHigh INT,
    OUT pCountUsuallyLow INT
    )

BEGIN

    -- Identifying categories by Ratings and Genre

    -- Segmentation by Genre and Ratings
    DROP TEMPORARY TABLE IF EXISTS top_genres;
    CREATE TEMPORARY TABLE top_genres SELECT Genre_Movie.genre_id AS genre_id, AVG(Ratings.rating) AS avg_rating
                                        FROM Ratings
                                        LEFT JOIN Genre_Movie 
                                        ON Ratings.movie_id = Genre_Movie.movie_id AND Ratings.movie_id = pMovieID
                                        GROUP BY Genre_Movie.genre_id
                                        ORDER BY avg_rating DESC
                                        LIMIT 2;

    SET genre_1 = (SELECT SUM(genre_id) FROM top_genres LIMIT 0,1);
    SET genre_2 = (SELECT SUM(genre_id) FROM top_genres LIMIT 1,1);

    -- User most likely to enjoy movie based on giving other movies of genre_1 or genre_2 a high rating "above 4"
    DROP TEMPORARY TABLE IF EXISTS most_likely_genre;
    CREATE TEMPORARY TABLE most_likely_genre SELECT Ratings.user_id AS user
                                        FROM Ratings
                                        LEFT JOIN Genre_Movie ON Ratings.movie_id = Genre_Movie.movie_id
                                        WHERE (Genre_Movie.genre_id = genre_1 OR Genre_Movie.genre_id = genre_2) 
                                            AND (Ratings.rating >= 4);

    SET pcountMostLikely = (SELECT COUNT(*) FROM most_likely_genre);

    -- Users likely to enjoy movie based on giving other movies of genre_1 or genre_2 good rating "3"
    DROP TEMPORARY TABLE IF EXISTS likely_genre;
    CREATE TEMPORARY TABLE likely_genre SELECT Ratings.user_id AS user
                                        FROM Ratings
                                        LEFT JOIN Genre_Movie ON Ratings.movie_id = Genre_Movie.movie_id
                                        WHERE (Genre_Movie.genre_id = genre_1 OR Genre_Movie.genre_id = genre_2) 
                                            AND (Ratings.rating >=3 AND Ratings.rating < 4);

    SET pCountLikely = (SELECT COUNT(*) FROM likely_genre);

    -- Users least likely to enjoy movie based on giving other movies of genre_1 or genre_2 low rating below 3
    DROP TEMPORARY TABLE IF EXISTS least_likely_genre;
    CREATE TEMPORARY TABLE least_likely_genre SELECT Ratings.user_id AS user
                                        FROM Ratings
                                        LEFT JOIN Genre_Movie ON Ratings.movie_id = Genre_Movie.movie_id
                                        WHERE (Genre_Movie.genre_id = genre_1 OR Genre_Movie.genre_id = genre_2) 
                                            AND (Ratings.rating < 3);

    SET pCountLeastLikely = (SELECT COUNT(*) FROM least_likely_genre);

    -- Further Segmentation, least likely to like who usually rate movies high
    DROP TEMPORARY TABLE IF EXISTS rated_low_usually_high;
    CREATE TEMPORARY TABLE rated_low_usually_high SELECT Ratings.user_id AS user,
                                                    AVG(Ratings.rating) AS usual_rating
                                                    FROM Ratings
                                                    JOIN least_likely_genre ON Ratings.user_id = least_likely_genre.user
                                                    GROUP BY Ratings.user_id
                                                    HAVING usual_rating >= 3;

    SET pCountUsuallyHigh = (SELECT COUNT(*) FROM rated_low_usually_high);

    DROP TEMPORARY TABLE IF EXISTS rated_high_usually_low;
    CREATE TEMPORARY TABLE rated_high_usually_low SELECT Ratings.user_id AS user,
                                                    AVG(Ratings.rating) AS usual_rating
                                                    FROM Ratings
                                                    JOIN most_likely_genre ON Ratings.user_id = most_likely_genre.user
                                                    GROUP BY Ratings.user_id
                                                    HAVING usual_rating < 3;

    SET pCountUsuallyLow = (SELECT COUNT(*) FROM rated_high_usually_low);

    -- Identifying categories by Tags, Python preprocessing

    -- Identify most common tag
END$$

DELIMITER ;
