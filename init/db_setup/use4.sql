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
    IN pMovieID VARCHAR(32),
    OUT pCountMostLikely INT,
    OUT pcountLikely INT,
    OUT pPercUsuallyLow INT,
    OUT pPercUsuallyHigh INT,
    )

BEGIN
    -- Segmentation by Genre and Ratings
    DROP TEMPORARY TABLE IF EXISTS top_genres;
    CREATE TEMPORARY TABLE top_genres SELECT genres.genre_id AS genre_id, AVG(ratings.rating) AS avg_rating
                                        FROM ratings
                                        LEFT JOIN genre-movie genres 
                                        ON ratings.movieId = genre-movie.movie_id AND ratings.movieId = pMovieID
                                        GROUP BY genres.genre_id
                                        ORDER BY avg_rating DESC
                                        LIMIT 2

    SET @genre_1 = (SELECT genre_id FROM top_genres WHERE ROWNUM = 1)
    SET @genre_2 = (SELECT genre_id FROM top_genres WHERE ROWNUM = 2)

    -- User most likely to enjoy movie based on giving other movies of genre_1 or genre_2 a high rating "above 4"
    DROP TEMPORARY TABLE IF EXISTS most_likely_genre;
    CREATE TEMPORARY TABLE most_likely_genre SELECT (DISTINCT ratings.userId) AS user,
                                        FROM ratings
                                        LEFT JOIN genre-movie genres ON ratings.movieId = genres.movie_id
                                        WHERE (genres.genre_id = genre_1 OR genres.genre_id = genre_2) 
                                            AND (ratings.rating >= 4)

    SET pcountMostLikely = (SELECT COUNT(*) FROM most_likely_genre)
    -- Segment: No. of users most likely to watch who previously gave low ratings

    SET pPercUsuallyLow = SELECT user_id,
                                 AVG(ratings.rating) AS avg_rating
                                 FROM most_likely_genre
                                 LEFT JOIN ratings ON most_likely_genre.user_id = ratings.userId
                                 GROUP BY user_id
                                 WHERE 

    -- Users likely to enjoy movie based on giving other movies of genre_1 or genre_2 good rating "3"
    DROP TEMPORARY TABLE IF EXISTS likely_genre;
    CREATE TEMPORARY TABLE likely_genre SELECT (DISTINCT ratings.userId) AS user
                                        FROM ratings
                                        LEFT JOIN genre-movie genres ON ratings.movieId = genre-movie.movie_id
                                        WHERE (genres.genre_id = genre_1 OR genres.genre_id = genre_2) 
                                            AND (ratings.rating >=3 AND ratings.rating < 4)

    SET pcountLikely = (SELECT COUNT(*) FROM likely_genre)

    -- Segmentation by Tags and Ratings
    