/*
USE CASE 4

Parameter:
pMovieID : Movie ID which exists in Movies table

Returns:

concatenated_genres: Table holds all movies and genres as a comma separated strin
genres_string: Single string with genres for pMovieID

most_likely_genre: Table holding users who will most likely enjoy the movie based on rating movies of the same genre above 4
pCountMostLikely: Count of most_likely_genre

likely_genre: Table holding users who will likely enjoy the movie based on rating movies of the same genre between 3 and 4
pCountLikely: Count of likely_genre

least_likely_genre: Table holding users least likely to enjoy the movie based on rating movies of the same genre below 3
pCountLeastLikely: Count of least_likely_genre

rated_low_usually_high: Table holding users who rated pMovieID low (below 3) but usually rate movies of the same genre above 3
pCountUsuallyHigh: Count of rated_low_usually_high

rated_high_usually_low: Table holding users who rated pMovieID highly (above 3) but usually rate movies of the same genre below 3
pCountUsuallyLow: Count of rated_high_usually_low

tag_occurences: Table holding movies with associated tags and the number of times tag was used throughout the DB (will contain duplicates of tags due to movie_id grouping)
movie_common_tags: Table holding movies associated with *up to* 3 most commont tags used for that movie
tags_string: String holding up to 3 most common tags for pMovieID

most_likely_tags: Table holding users most likely to enjoy movie due to rating movies with the same tags above 3
pTagsMostLikely: Count of most_likely_tags

least_likely_tags:  Table holding users most likely to enjoy movie due to rating movies with the same tags below 3
pTagsLeastLikely: Count of least_likely_tags

Example use in SQL:
    CALL use4(1); 

    SELECT * least_likely_genre;
    SELECT @pCountLeastLikely;

*/

USE `MovieLens`;
DROP procedure IF EXISTS `use4`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `use4` (
    IN pMovieID INT,
    OUT genres_string VARCHAR(255),
    OUT tags_string VARCHAR(255),
    OUT pCountMostLikely INT,
    OUT pCountLikely INT,
    OUT pCountLeastLikely INT,
    OUT pCountUsuallyHigh INT,
    OUT pCountUsuallyLow INT,
    OUT pTagsMostLikely INT,
    OUT pTagsLeastLikely INT
    )

BEGIN
    -- Identifying categories by Ratings and Genre

    -- Get Movie and it's genre as string e.g. Toy Story | (1,2,3)
    DROP TEMPORARY TABLE IF EXISTS concatenated_genres;
    CREATE TEMPORARY TABLE concatenated_genres SELECT Genre_Movie.movie_id As movie_id, GROUP_CONCAT(DISTINCT Genre_Movie.genre_id) AS genres
                                               FROM Genre_Movie
                                               WHERE Genre_Movie.movie_id = pMovieID -- stop qury having to unecessary group all movies and their genres
                                               GROUP BY movie_id;

    SET genres_string = (SELECT genres FROM concatenated_genres WHERE movie_id = pMovieID);

    -- User most likely to enjoy movie based on given other movies of same genres as pMovieID rating above 4
    DROP TEMPORARY TABLE IF EXISTS most_likely_genre;
    CREATE TEMPORARY TABLE most_likely_genre SELECT Ratings.user_id AS user,
                                             AVG(Ratings.rating) AS genre_rating
                                             FROM Ratings LEFT JOIN Genre_Movie ON Ratings.movie_id = Genre_Movie.movie_id
                                             WHERE FIND_IN_SET(Genre_Movie.genre_id, genres_string)
                                             GROUP BY Ratings.user_id
                                             HAVING AVG(Ratings.rating) >= 4
                                             ORDER BY AVG(Ratings.rating) DESC;

    SET pCountMostLikely = (SELECT COUNT(*) FROM most_likely_genre);

    -- Users likely to enjoy movie based on given other movies of same genres as pMovieID between 3 and 4
    DROP TEMPORARY TABLE IF EXISTS likely_genre;
    CREATE TEMPORARY TABLE likely_genre SELECT Ratings.user_id AS user,
                                             AVG(Ratings.rating) AS genre_rating
                                             FROM Ratings LEFT JOIN Genre_Movie ON Ratings.movie_id = Genre_Movie.movie_id
                                             WHERE FIND_IN_SET(Genre_Movie.genre_id, genres_string)
                                             GROUP BY Ratings.user_id
                                             HAVING AVG(Ratings.rating) >= 3 AND AVG(Ratings.rating) < 4
                                             ORDER BY AVG(Ratings.rating) DESC;

    SET pCountLikely = (SELECT COUNT(*) FROM likely_genre);

    -- Users least likely to enjoy movie based on given other movies of same genres as pMovieID rating below 3
    DROP TEMPORARY TABLE IF EXISTS least_likely_genre; -- change where to CASE statements
    CREATE TEMPORARY TABLE least_likely_genre SELECT Ratings.user_id AS user,
                                                AVG(Ratings.rating) AS genre_rating
                                                FROM Ratings LEFT JOIN Genre_Movie ON Ratings.movie_id = Genre_Movie.movie_id
                                                WHERE FIND_IN_SET(Genre_Movie.genre_id, genres_string)
                                                GROUP BY Ratings.user_id
                                                HAVING AVG(Ratings.rating) < 3
                                                ORDER BY AVG(Ratings.rating);

    SET pCountLeastLikely = (SELECT COUNT(*) FROM least_likely_genre);

    -- Change so its for specific user given rating to the movie -> above average of 3.5, below 2.5 for this movie
    -- Further Segmentation, least likely to like who usually rate movies high
    DROP TEMPORARY TABLE IF EXISTS movie_rating_avg_ratings;
    CREATE TEMPORARY TABLE movie_rating_avg_ratings SELECT CASE WHEN Ratings.movie_id = pMovieID AND Ratings.rating <= 2.5 THEN 'low'
                                                              WHEN Ratings.movie_id = pMovieID AND Ratings.rating >= 3.5 THEN 'high'
                                                              ELSE 'not watched' END AS movie_rating,
                                                              AVG(Ratings.rating) AS avg_rating,
                                                              Ratings.user_id AS user
                                                              FROM Ratings
                                                              GROUP BY user, movie_rating;

    SET pCountUsuallyHigh = (SELECT COUNT(*) FROM movie_rating_avg_ratings WHERE movie_rating = 'low');
    SET pCountUsuallyLow = (SELECT COUNT(*) FROM movie_rating_avg_ratings WHERE movie_rating = 'high');

    -- Identifying categories by Tags
    DROP TEMPORARY TABLE IF EXISTS tag_occurences;
    CREATE TEMPORARY TABLE tag_occurences SELECT movie_id, tag, COUNT(tag) AS tag_occurence
                                       FROM Tags
                                       GROUP BY movie_id, tag
                                       ORDER BY movie_id ASC, tag_occurence DESC;

    -- Get top 3 tags for specific movie, use subquery
    DROP TEMPORARY TABLE IF EXISTS movie_common_tags;
    CREATE TEMPORARY TABLE movie_common_tags SELECT movie_id, GROUP_CONCAT(SELECT tag_occurences.tag FROM tag_occurences LIMIT 3) AS common_tags
                                                FROM tag_occurences
                                                GROUP BY movie_id;

    SET tags_string = (SELECT common_tags FROM movie_common_tags WHERE movie_id = pMovieID);

    -- Users most likely to enjoy movie based on tags and given movie with corresponding tags high ratings
    DROP TEMPORARY TABLE IF EXISTS most_likely_tags;
    CREATE TEMPORARY TABLE most_likely_tags SELECT Ratings.user_id AS user,
                                             AVG(Ratings.rating) AS tag_rating
                                             FROM Ratings LEFT JOIN Tags ON Tags.movie_id = Ratings.movie_id
                                             WHERE FIND_IN_SET(Tags.tag, tags_string)
                                             GROUP BY Ratings.user_id
                                             HAVING AVG(Ratings.rating) >= 3
                                             ORDER BY AVG(Ratings.rating) DESC;

    SET pTagsMostLikely = (SELECT COUNT(*) FROM most_likely_tags);

    -- Users least likely to enjoy movie based on tags and given movie with corresponding tags low ratings
    DROP TEMPORARY TABLE IF EXISTS least_likely_tags;
    CREATE TEMPORARY TABLE least_likely_tags SELECT Ratings.user_id AS user,
                                             AVG(Ratings.rating) AS tag_rating
                                             FROM Ratings LEFT JOIN Tags ON Tags.movie_id = Ratings.movie_id
                                             WHERE FIND_IN_SET(Tags.tag, tags_string)
                                             GROUP BY Ratings.user_id
                                             HAVING AVG(Ratings.rating) < 3
                                             ORDER BY AVG(Ratings.rating);

    SET pTagsLeastLikely = (SELECT COUNT(*) FROM least_likely_tags);

END$$

DELIMITER ;
