/*
USE CASE 5
*/

USE `MovieLens`;
DROP procedure IF EXISTS `use5`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `use5` (
    -- No explicit inputs and outputs for now, will produce temporary tables
    IN pPanelSize INT,
    IN pReleaseSize INT,
    OUT pGenreAvgRating INT,
    OUT pDirectorAvgRating INT,
    OUT pRuntimeAvgRating INT,
    OUT pTagsAvgRating INT,
    OUT pStarAvgRating INT
    )

BEGIN
    -- Due to scalability can't just order by random and then limit, need a fast way to do it increase DB increases substantially
    -- http://jan.kneschke.de/projects/mysql/order-by-rand/

    -- to limit the no. of tags
    DROP TEMPORARY TABLE IF EXISTS tag_occurences;
    CREATE TEMPORARY TABLE tag_occurences SELECT movie_id, tag, COUNT(tag) AS tag_occurence
                                       FROM Tags
                                       GROUP BY movie_id, tag
                                       ORDER BY movie_id ASC, tag_occurence DESC;
    DROP TEMPORARY TABLE IF EXISTS movie_common_tags;
    CREATE TEMPORARY TABLE movie_common_tags SELECT movie_id, GROUP_CONCAT(DISTINCT tag) AS common_tags, COUNT(DISTINCT tag) AS tag_count
                                                FROM tag_occurences
                                                GROUP BY movie_id
                                                LIMIT 10;

    -- Sample of 10 soon to be released movies
    DROP TEMPORARY TABLE IF EXISTS sample_movies;
    CREATE TEMPORARY TABLE sample_movies SELECT t1.movie_id, t1.title, t1.director, t1.runtime 
                                         FROM Movies AS t1 
                                         JOIN (SELECT movie_id FROM Movies ORDER BY RAND() LIMIT pReleaseSize) AS t2 ON t1.movie_id = t2.movie_id;

    -- do this separately because excessive joins and random generation may be very slow, but just the samples with tag, genre and star info added
    DROP TEMPORARY TABLE IF EXISTS release_soon;
    CREATE TEMPORARY TABLE release_soon SELECT sample_movies.movie_id, sample_movies.title, sample_movies.director, sample_movies.runtime,
                                               movie_common_tags.common_tags AS tag_string,
                                               movie_common_tags.tag_count AS tag_count,
                                               GROUP_CONCAT(Genre_Movie.genre_id) AS genre_string,
                                               COUNT(Genre_Movie.genre_id) AS genre_count,
                                               GROUP_CONCAT(Star_Movie.star_id) AS star_string,
                                               COUNT(Star_Movie.star_id) AS star_count
                                        FROM sample_movies
                                        LEFT JOIN Genre_Movie ON Genre_Movie.movie_id = sample_movies.movie_id
                                        LEFT JOIN Star_Movie ON Star_Movie.movie_id = Genre_Movie.movie_id
                                        LEFT JOIN movie_common_tags ON movie_common_tags.movie_id = Star_Movie.movie_id
                                        GROUP BY sample_movies.movie_id, sample_movies.title, sample_movies.director, sample_movies.runtime, 
                                                 movie_common_tags.common_tags, movie_common_tags.tag_count
                                        ORDER BY sample_movies.movie_id;

    -- Sample of 100 users for preview panel
    DROP TEMPORARY TABLE IF EXISTS preview_panel;
    CREATE TEMPORARY TABLE preview_panel SELECT t1.user_id
                                        FROM Users AS t1
                                        JOIN (SELECT user_id FROM Users ORDER BY RAND() LIMIT pPanelSize) AS t2 ON t1.user_id = t2.user_id;

    /*
    OUT pGenreAvgRating INT,
    OUT pDirectorAvgRating INT,
    OUT pRuntimeAvgRating INT,
    OUT pTagsAvgRating INT,
    OUT pStarAvgRating INT
    release_soon -> table of movies
    preview_panel -> table of users
    */

    -- Now predict the rating of each soon to be released movie

    /*
    movie_id | title | director | runtime | common_tags | tag_count |   genre_string     | genre_count |     star_string    | star_count
       4       thor     bobby      60      ear, pop         2         action, thriller        2           theodore, alvin       2

    e.g.
    100 Users in panel
    50 rate action + horror -> average 2 [2 categories]
    10 rate bobby movies -> average 5 [1 category]
    60 rate tagged -> average 1 [10 categories (max tags)]
    5 rate stars -> average 3.5 [3 stars (max stars)]

    So scale:

    Total[rating*(no. of categories/10)*(no. of users/100)]/5 -> predicted rating

    (2*(2/10)*(50/100)) + (5*(1/10)*(10/100)) + (1*(10/10)*(60/100)) + (3.5*(3/10)*(5/100)) / 5
    
    */
    
                            
END$$

DELIMITER ;
