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
    DECLARE gCountUsersRated INT;
    DECLARE tCountUsersRated INT;
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

    DECLARE gPercWouldlike INT;
    DECLARE gPercWouldLikeDidLike INT;
    DECLARE gPercWouldLikeDidDislike INT;
    DECLARE gPercWouldDislike INT;
    DECLARE gPercWouldDislikeDidDislike INT;
    DECLARE gPercWouldDislikeDidLike INT;
    DECLARE tPercWouldLike INT;
    DECLARE tPercWouldLikeDidLike INT;
    DECLARE tPercWouldLikeDidDislike INT;
    DECLARE tPercWouldDislike INT;
    DECLARE tPercWouldDislikeDidDislike INT;
    DECLARE tPercWouldDislikeDidLike INT;

    SET SESSION group_concat_max_len = 1000000;
    -- Identifying categories by Ratings and Genre
    

    SET genres_string = (SELECT GROUP_CONCAT(DISTINCT Genre_Movie.genre_id) AS genres 
                            FROM Genre_Movie 
                            WHERE Genre_Movie.movie_id = pMovieID);
                        

                        
    DROP TEMPORARY TABLE IF EXISTS users_already_rated;
    CREATE TEMPORARY TABLE users_already_rated Select Ratings.user_id as user_id, Ratings.rating as rating
                                                FROM Ratings 
                                                WHERE Ratings.movie_id = pMovieID;
                                                
                                                
    DROP TEMPORARY TABLE IF EXISTS similar_genre_ratings;
    CREATE TEMPORARY TABLE similar_genre_ratings SELECT Ratings.user_id AS user_id,
                                                    AVG(Ratings.rating) AS genre_rating
                                                    FROM Ratings LEFT JOIN Genre_Movie ON Ratings.movie_id = Genre_Movie.movie_id
                                                    WHERE FIND_IN_SET(Genre_Movie.genre_id, genres_string)
                                                    AND NOT Ratings.movie_id = pMovieID
                                                    GROUP BY Ratings.user_id
                                                    ORDER BY AVG(Ratings.rating) DESC;

    SET gCountUsersRated = (SELECT COUNT(*) FROM similar_genre_ratings);    
                                        
    DROP TEMPORARY TABLE IF EXISTS like_genre_users;
    CREATE TEMPORARY TABLE like_genre_users SELECT user_id, genre_rating FROM similar_genre_ratings
                                        WHERE genre_rating >= 3;
                                        
    SET gWouldLike = (SELECT COUNT(*) FROM like_genre_users
                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated));

    SET gWouldLikeDidLike = (SELECT COUNT(*) FROM like_genre_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.rating >= 3));

    SET gWouldLikeDidDislike = (SELECT COUNT(*) FROM like_genre_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.rating < 2.5));

    
    SET gPercWouldlike = (IF (gCountUsersRated = 0 OR gCountUsersRated IS NULL, 0, ((IF(gWouldLike IS NULL, 0,gWouldLike))  / gCountUsersRated ) * 100));

    SET gPercWouldLikeDidLike = (IF (gCountUsersRated = 0 OR gCountUsersRated IS NULL, 0, ((IF(gWouldLikeDidLike IS NULL, 0, gWouldLikeDidLike)) / gCountUsersRated) * 100));
                                        
    SET gPercWouldLikeDidDislike = (IF (gCountUsersRated = 0 OR gCountUsersRated IS NULL, 0, ((IF(gWouldLikeDidDislike IS NULL, 0, gWouldLikeDidDislike)) / gCountUsersRated) * 100));

    DROP TEMPORARY TABLE IF EXISTS dislike_genre_users;
    CREATE TEMPORARY TABLE dislike_genre_users SELECT user_id, genre_rating FROM similar_genre_ratings
                                        WHERE genre_rating < 2.5;
                                        
    SET gWouldDislike = (SELECT COUNT(*) FROM dislike_genre_users
                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated));

    SET gWouldDislikeDidDislike = (SELECT COUNT(*) FROM dislike_genre_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.rating < 2.5));

    SET gWouldDislikeDidLike = (SELECT COUNT(*) FROM dislike_genre_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.rating >= 3));

    SET gPercWouldDislike = (IF (gCountUsersRated = 0 OR gCountUsersRated IS NULL, 0, ((IF(gWouldDislike IS NULL, 0, gWouldDislike)) / gCountUsersRated ) * 100));

    SET gPercWouldDislikeDidDislike = (IF (gCountUsersRated = 0 OR gCountUsersRated IS NULL, 0, ((IF(gWouldDislikeDidDislike IS NULL, 0, gWouldDislikeDidDislike))  / gCountUsersRated ) * 100));
                                        
    SET gPercWouldDislikeDidLike = (IF (gCountUsersRated = 0 OR gCountUsersRated IS NULL, 0, ((IF(gWouldDislikeDidLike IS NULL, 0, gWouldDislikeDidLike)) / gCountUsersRated ) * 100));
                                                                    
    DROP TEMPORARY TABLE IF EXISTS tag_occurences;
    CREATE TEMPORARY TABLE tag_occurences SELECT Common_Tags.tag
                                    FROM Common_Tags
                                    LEFT JOIN Tags ON Tags.tag = Common_Tags.tag
                                    WHERE Tags.movie_id = pMovieID
                                    GROUP BY movie_id, Common_Tags.tag
                                    LIMIT 3;

    SET tags_string = (SELECT GROUP_CONCAT(DISTINCT tag SEPARATOR ',') FROM tag_occurences);

                                                
    DROP TEMPORARY TABLE IF EXISTS similar_tag_ratings;
    CREATE TEMPORARY TABLE similar_tag_ratings SELECT Ratings.user_id AS user_id,
                                                    AVG(Ratings.rating) AS tag_rating
                                                    FROM Ratings LEFT JOIN Tags ON Tags.movie_id = Ratings.movie_id
                                                    WHERE FIND_IN_SET(Tags.tag, tags_string)
                                                    AND NOT Ratings.movie_id = pMovieID
                                                    GROUP BY Ratings.user_id
                                                    ORDER BY AVG(Ratings.rating) DESC;

    SET tCountUsersRated = (SELECT COUNT(*) FROM similar_tag_ratings);    
                                        
    DROP TEMPORARY TABLE IF EXISTS like_tag_users;
    CREATE TEMPORARY TABLE like_tag_users SELECT user_id, tag_rating FROM similar_tag_ratings
                                        WHERE tag_rating >= 3;
                                        
    SET tWouldLike = (SELECT COUNT(*) FROM like_tag_users
                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated));

    SET tWouldLikeDidLike = (SELECT COUNT(*) FROM like_tag_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.rating >= 3));

    SET tWouldLikeDidDislike = (SELECT COUNT(*) FROM like_tag_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.rating < 2.5));

    SET tPercWouldlike = (IF (tCountUsersRated = 0 OR tCountUsersRated IS NULL, 0, ((IF(tWouldLike IS NULL, 0, tWouldLike)) / tCountUsersRated ) * 100));

    SET tPercWouldLikeDidLike = (IF (tCountUsersRated = 0 OR tCountUsersRated IS NULL, 0, ((IF(tWouldLikeDidLike IS NULL, 0, tWouldLikeDidLike)) / tCountUsersRated) * 100));
                                        
    SET tPercWouldLikeDidDislike = (IF (tCountUsersRated = 0 OR tCountUsersRated IS NULL, 0, ((IF(tWouldLikeDidDislike IS NULL, 0, tWouldLikeDidDislike)) / tCountUsersRated) * 100));
                                        

    DROP TEMPORARY TABLE IF EXISTS dislike_tag_users;
    CREATE TEMPORARY TABLE dislike_tag_users SELECT user_id, tag_rating FROM similar_tag_ratings
                                        WHERE tag_rating < 2.5;
                                        
    SET tWouldDislike = (SELECT COUNT(*) FROM dislike_tag_users
                                WHERE user_id NOT IN (SELECT user_id FROM users_already_rated));

    SET tWouldDislikeDidDislike = (SELECT COUNT(*) FROM dislike_tag_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.rating < 2.5));

    SET tWouldDislikeDidLike = (SELECT COUNT(*) FROM dislike_tag_users
                                WHERE user_id IN (SELECT users_already_rated.user_id 
                                                    FROM users_already_rated 
                                                    WHERE users_already_rated.rating >= 3));

    SET tPercWouldDislike = (IF (tCountUsersRated = 0 OR tCountUsersRated IS NULL, 0, ((IF(tWouldDislike IS NULL, 0,tWouldDislike)) / tCountUsersRated ) * 100));

    SET tPercWouldDislikeDidDislike = (IF (tCountUsersRated = 0 OR tCountUsersRated IS NULL, 0, ((IF(tWouldDislikeDidDislike IS NULL, 0, tWouldDislikeDidDislike)) / tCountUsersRated ) * 100));
                                        
    SET tPercWouldDislikeDidLike = (IF (tCountUsersRated = 0 OR tCountUsersRated IS NULL, 0, ((IF(tWouldDislikeDidLike IS NULL, 0, tWouldDislikeDidLike)) / tCountUsersRated ) * 100));
                                                  
    SELECT gWouldLike, gWouldLikeDidLike, gWouldLikeDidDislike, gWouldDislike, gWouldDislikeDidDislike, 
    gWouldDislikeDidLike, tWouldLike, tWouldLikeDidLike, tWouldLikeDidDislike, tWouldDislike, tWouldDislikeDidDislike 
    , tWouldDislikeDidLike, gCountUsersRated, tCountUsersRated, gPercWouldLike, gPercWouldLikeDidLike, gPercWouldLikeDidDislike, 
    gPercWouldDislike, gPercWouldDislikeDidDislike, gPercWouldDislikeDidLike, tPercWouldLike, tPercWouldLikeDidLike, tPercWouldDislike,
    tPercWouldDislikeDidDislike, tPercWouldDislikeDidLike;

END$$

DELIMITER ;
