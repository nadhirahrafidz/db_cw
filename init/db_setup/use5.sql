/*
USE CASE 5
*/

USE `MovieLens`;
DROP procedure IF EXISTS `use5`;

DELIMITER $$
USE `MovieLens`$$

CREATE PROCEDURE `use5` (
    -- No explicit inputs and outputs for now, will produce temporary tables
    )
BEGIN
    -- Sample of 10 soon to be released movies
    DROP TEMPORARY TABLE IF EXISTS sample_movies;
    CREATE TEMPORARY TABLE sample_movies SELECT TOP 10 PERCENT movie_id, title, director, runtime
                                        FROM Movies
                                        WHERE movie_id IN (SELECT TOP 10 PERCENT movie_id FROM Movies ORDER BY newid());
                                        -- newid() gets a random movie_id each time, inner select to improve performance
                                        -- https://stackoverflow.com/questions/848872/select-n-random-rows-from-sql-server-table

    -- do this separately because excessive joins and random generation may be very slow, but just the samples with tag, genre and star info added
    DROP TEMPOROARY TABLE IS EXISTS release_soon;
    CREATE TEMPORARY TABLE release_soon SELECT Movies.movie_id, Movies.title, Movies.director, Movies.runtime,
                                               GROUP_CONCAT(Genre_Movie.genre_id), 
                                               GROUP_CONCAT(Star_Movie.star_id),
                                               GROUP_CONCAT(Tags.movie_id)
                                               FROM sample_movies
                                               LEFT JOIN Genre.Movie ON Genre_Movie.movie_id = sample_movies.movie_id
                                               LEFT JOIN Star_Movie ON Star_Movie.movie_id = Genre_Movie.movie_id
                                               LEFT JOIN Tags ON Tags.movie_id = Star_Movie.movie_id
                                               GROUP BY Movies.movie_id
                                               ORDER BY Movies.movie_id;

    -- Sample of 100 users for preview panel
    DROP TEMPORARY TABLE IF EXISTS sample_users;
    CREATE TEMPORARY TABLE sample_users SELECT TOP 100 PERCENT user_id 
                                        FROM Users 
                                        WHERE user_id IN (SELECT TOP 100 PERCENT user_id FROM Users ORDER BY newid());

    -- Preview Panel of 100 users, joined with rating, tag, genre and star info.
    DROP TEMPORARY TABLE IF EXISTS preview_panel;
    CREATE TEMPORARY TABLE preview_panel SELECT sample_users.user_id,
                                                Ratings.rating,
                                                Genre_Movie.movie_id, 
                                                GROUP_CONCAT(Genre_Movie.genre_id),
                                                GROUP_CONCAT(Tags.tag),
                                                GROUP_CONCAT(Star_Movie.star_id)
                                                FROM sample_users
                                                LEFT JOIN Ratings ON Ratings.user_id = sample_users.user_id
                                                LEFT JOIN Genre_Movie ON Genre_Movie.movie_id = Ratings.movie_id
                                                LEFT JOIN Tags ON Tags.movie_id = Genre_Movie.movie_id
                                                LEFT JOIN Star_Movie ON Star_Movie.movie_id = Tags.movie_id
                                                GROUP BY sample_users.user_id, Genre_Movie.movie_id
                                                ORDER BY movie_id;
                            
END$$

DELIMITER ;
