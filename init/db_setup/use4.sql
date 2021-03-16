/*
USE CASE 4

Parameter:
pMovieID : Movie ID which exists in Movies table

*/

USE `MovieLens`;
DROP procedure IF EXISTS `use4`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `use4` (
    IN pMovieID INT
    )

BEGIN
    DECLARE genres_string VARCHAR(255);
    DECLARE tags_string VARCHAR(255);
    DECLARE gCountUsersRatedSimilar INT;
    DECLARE tCountUsersRatedSimilar INT;
    DECLARE gWouldLike INT;
    DECLARE gWouldLikeDidLike INT;
    DECLARE gWouldLikeDidDislike INT;
    DECLARE gWouldDislike INT;
    DECLARE gWouldDislikeDidDislike INT;
    DECLARE gWouldDislikeDidLike INT;
    DECLARE tWouldLike INT;
    DECLARE tWouldLikeDidLike INT;
    DECLARE tWouldLikeDidDislike INT;
    DECLARE tWouldDislike INT;
    DECLARE tWouldDislikeDidDislike INT;
    DECLARE tWouldDislikeDidLike INT;

    DECLARE gHaveRated INT;
    DECLARE tHaveRated INT;
    DECLARE gHaveNotRated INT;
    DECLARE tHaveNotRated INT;

    SET SESSION group_concat_max_len = 1000000;
    -- Identifying categories by Ratings and Genre
    

    SET genres_string = (SELECT GROUP_CONCAT(DISTINCT Genre_Movie.genre_id) AS genres 
                            FROM Genre_Movie 
                            WHERE Genre_Movie.movie_id = pMovieID);
                                                
                                                
    DROP TEMPORARY TABLE IF EXISTS intermediate_genre_table;
    CREATE TEMPORARY TABLE intermediate_genre_table SELECT Ratings.user_id AS user_id,
                                                    AVG(Ratings.rating) AS similar_movie_rating
                                                    FROM Ratings LEFT JOIN Genre_Movie ON Ratings.movie_id = Genre_Movie.movie_id
                                                    WHERE FIND_IN_SET(Genre_Movie.genre_id, genres_string)
                                                    AND NOT Ratings.movie_id = pMovieID
                                                    GROUP BY Ratings.user_id
                                                    ORDER BY AVG(Ratings.rating) DESC;


    DROP TEMPORARY TABLE IF EXISTS users_already_rated;
    CREATE TEMPORARY TABLE users_already_rated Select DISTINCT intermediate_genre_table.user_id as user_id, similar_movie_rating, Ratings.rating as this_movie_rating
                                                FROM Ratings 
                                                LEFT JOIN intermediate_genre_table ON intermediate_genre_table.user_id = Ratings.user_id
                                                WHERE Ratings.movie_id = pMovieID;
                                                
	DROP TEMPORARY TABLE IF EXISTS similar_genre_ratings;
    CREATE TEMPORARY TABLE similar_genre_ratings SELECT intermediate_genre_table.user_id AS user_id,
                                                intermediate_genre_table.similar_movie_rating,
                                                users_already_rated.this_movie_rating as this_movie_rating
                                                FROM intermediate_genre_table
                                                LEFT JOIN users_already_rated ON users_already_rated.user_id = intermediate_genre_table.user_id;

    DROP TEMPORARY TABLE IF EXISTS users_not_rated;
    CREATE TEMPORARY TABLE users_not_rated Select similar_genre_ratings.user_id as user_id, similar_movie_rating
                                                FROM similar_genre_ratings 
                                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated);

    SET gCountUsersRatedSimilar = (SELECT COUNT(*) FROM similar_genre_ratings);    
                                        
    DROP TEMPORARY TABLE IF EXISTS like_genre_users;
    CREATE TEMPORARY TABLE like_genre_users SELECT * FROM similar_genre_ratings
                                        WHERE similar_movie_rating >= 3;

    DROP TEMPORARY TABLE IF EXISTS gWouldLikeTable;
    CREATE TEMPORARY TABLE gWouldLikeTable SELECT * FROM like_genre_users
                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated);
                                        
    SET gWouldLike = (SELECT COUNT(*) FROM gWouldLikeTable);

    DROP TEMPORARY TABLE IF EXISTS gWouldLikeDidLikeTable;
    CREATE TEMPORARY TABLE gWouldLikeDidLikeTable SELECT * FROM like_genre_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.this_movie_rating >= 3);

    SET gWouldLikeDidLike = (SELECT COUNT(*) FROM gWouldLikeDidLikeTable);


    DROP TEMPORARY TABLE IF EXISTS gWouldLikeDidDislikeTable;
    CREATE TEMPORARY TABLE gWouldLikeDidDislikeTable SELECT * FROM like_genre_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.this_movie_rating < 2.5);

    SET gWouldLikeDidDislike = (SELECT COUNT(*) FROM gWouldLikeDidDislikeTable);

    
    SET gHaveRated = (SELECT COUNT(user_id) 
                        FROM similar_genre_ratings 
                        WHERE user_id IN (SELECT users_already_rated.user_id 
                                            FROM users_already_rated ));    

    SET gHaveNotRated = (gCountUsersRatedSimilar - gHaveRated);

    DROP TEMPORARY TABLE IF EXISTS dislike_genre_users;
    CREATE TEMPORARY TABLE dislike_genre_users SELECT * FROM similar_genre_ratings
                                        WHERE similar_movie_rating < 2.5;
    
    DROP TEMPORARY TABLE IF EXISTS gWouldDislikeTable;
    CREATE TEMPORARY TABLE gWouldDislikeTable SELECT * FROM dislike_genre_users
                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated);

    SET gWouldDislike = (SELECT COUNT(*) FROM gWouldDislikeTable);

    DROP TEMPORARY TABLE IF EXISTS gWouldDislikeDidDislikeTable;
    CREATE TEMPORARY TABLE gWouldDislikeDidDislikeTable SELECT * FROM dislike_genre_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.this_movie_rating < 2.5);

    SET gWouldDislikeDidDislike = (SELECT COUNT(*) FROM gWouldDislikeDidDislikeTable);

    DROP TEMPORARY TABLE IF EXISTS gWouldDislikeDidLikeTable;
    CREATE TEMPORARY TABLE gWouldDislikeDidLikeTable SELECT * FROM dislike_genre_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.this_movie_rating >= 3);

    SET gWouldDislikeDidLike = (SELECT COUNT(*) FROM gWouldDislikeDidLikeTable);
                                                                    
    DROP TEMPORARY TABLE IF EXISTS tag_occurences;
    CREATE TEMPORARY TABLE tag_occurences SELECT common_tags.tag
                                    FROM (SELECT tag, COUNT(tag) AS tag_count
                                                    FROM Tags
                                                    GROUP BY tag
                                                    ORDER BY COUNT(tag) DESC)common_tags
                                    LEFT JOIN Tags ON Tags.tag = common_tags.tag
                                    WHERE Tags.movie_id = pMovieID
                                    GROUP BY movie_id, common_tags.tag
                                    LIMIT 3;

    SET tags_string = (SELECT GROUP_CONCAT(DISTINCT tag SEPARATOR ',') FROM tag_occurences);
                                                
    DROP TEMPORARY TABLE IF EXISTS similar_tag_ratings;
    CREATE TEMPORARY TABLE similar_tag_ratings SELECT Ratings.user_id AS user_id,
                                                    AVG(Ratings.rating) AS similar_movie_rating
                                                    FROM Ratings LEFT JOIN Tags ON Tags.movie_id = Ratings.movie_id
                                                    WHERE FIND_IN_SET(Tags.tag, tags_string)
                                                    AND NOT Ratings.movie_id = pMovieID
                                                    GROUP BY Ratings.user_id
                                                    ORDER BY AVG(Ratings.rating) DESC;

    SET tCountUsersRatedSimilar = (SELECT COUNT(*) FROM similar_tag_ratings);    

    SET tHaveRated = (SELECT COUNT(user_id) 
                        FROM similar_tag_ratings 
                        WHERE user_id IN (SELECT users_already_rated.user_id 
                                            FROM users_already_rated));
                                        
    SET tHaveNotRated = (tCountUsersRatedSimilar - tHaveRated);

    DROP TEMPORARY TABLE IF EXISTS like_tag_users;
    CREATE TEMPORARY TABLE like_tag_users SELECT user_id, similar_movie_rating FROM similar_tag_ratings
                                        WHERE similar_movie_rating >= 3;
                                        

    DROP TEMPORARY TABLE IF EXISTS tWouldLikeTable;
    CREATE TEMPORARY TABLE tWouldLikeTable SELECT * FROM like_tag_users
                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated);
                                
    SET tWouldLike = (SELECT COUNT(*) FROM tWouldLikeTable);


    DROP TEMPORARY TABLE IF EXISTS tWouldLikeDidLikeTable;
    CREATE TEMPORARY TABLE tWouldLikeDidLikeTable SELECT * FROM like_tag_users
                                                    WHERE user_id IN (SELECT users_already_rated.user_id 
                                                                FROM users_already_rated 
                                                                WHERE users_already_rated.this_movie_rating >= 3);

    SET tWouldLikeDidLike = (SELECT COUNT(*) FROM tWouldLikeDidLikeTable);

    DROP TEMPORARY TABLE IF EXISTS tWouldLikeDidDislikeTable;
    CREATE TEMPORARY TABLE tWouldLikeDidDislikeTable SELECT * FROM like_tag_users
                                                    WHERE user_id IN (SELECT users_already_rated.user_id 
                                                                FROM users_already_rated 
                                                                WHERE users_already_rated.this_movie_rating < 2.5);

    SET tWouldLikeDidDislike = (SELECT COUNT(*) FROM tWouldLikeDidDislikeTable);

    DROP TEMPORARY TABLE IF EXISTS dislike_tag_users;
    CREATE TEMPORARY TABLE dislike_tag_users SELECT user_id, similar_movie_rating FROM similar_tag_ratings
                                        WHERE similar_movie_rating < 2.5;

    DROP TEMPORARY TABLE IF EXISTS tWouldDislikeTable;
    CREATE TEMPORARY TABLE tWouldDislikeTable SELECT * FROM dislike_tag_users
                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated);
                                        
    SET tWouldDislike = (SELECT COUNT(*) FROM tWouldDislikeTable);

    DROP TEMPORARY TABLE IF EXISTS tWouldDislikeDidDislikeTable;
    CREATE TEMPORARY TABLE tWouldDislikeDidDislikeTable SELECT * FROM dislike_tag_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.this_movie_rating < 2.5);

    SET tWouldDislikeDidDislike = (SELECT COUNT(*) FROM tWouldDislikeDidDislikeTable);

    DROP TEMPORARY TABLE IF EXISTS tWouldDislikeDidLikeTable;
    CREATE TEMPORARY TABLE tWouldDislikeDidLikeTable SELECT * FROM dislike_tag_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.this_movie_rating >= 3);

    SET tWouldDislikeDidLike = (SELECT COUNT(*) FROM tWouldDislikeDidLikeTable);
                                                  
    SELECT gWouldLike, gWouldLikeDidLike, gWouldLikeDidDislike, gWouldDislike, gWouldDislikeDidDislike, 
    gWouldDislikeDidLike, tWouldLike, tWouldLikeDidLike, tWouldLikeDidDislike, tWouldDislike, tWouldDislikeDidDislike 
    , tWouldDislikeDidLike, gCountUsersRatedSimilar, tCountUsersRatedSimilar, gHaveRated, gHaveNotRated, tHaveRated, tHaveNotRated;

END$$

DELIMITER ;
