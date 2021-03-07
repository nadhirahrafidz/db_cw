/*
USE CASE 5

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

USE `MovieLens`;
DROP procedure IF EXISTS `use5`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `use5` (
    -- No explicit inputs and outputs for now, will produce temporary tables
    IN pPanelSize INT,
    IN pReleaseSize INT
    )

BEGIN
    SET SESSION group_concat_max_len = 1000000;
    -- Due to scalability can't just order by random and then limit, need a fast way to do it increase DB increases substantially
    -- http://jan.kneschke.de/projects/mysql/order-by-rand/

    -- to limit the no. of tags
    DROP TEMPORARY TABLE IF EXISTS tag_occurences;
    CREATE TEMPORARY TABLE tag_occurences SELECT movie_id, tag, COUNT(tag) AS tag_occurence
                                       FROM Tags
                                       GROUP BY movie_id, tag
                                       ORDER BY movie_id ASC, tag_occurence DESC;


    -- get 10 most common tags
    DROP TEMPORARY TABLE IF EXISTS movie_common_tags;
    CREATE TEMPORARY TABLE movie_common_tags SELECT movie_id, 
                                             SUBSTRING_INDEX(GROUP_CONCAT(DISTINCT tag SEPARATOR ','), ',', 10) AS common_tags, 
                                             COUNT(tag) AS tag_count
                                            FROM tag_occurences
                                            GROUP BY movie_id
                                            ORDER BY movie_id;
                                                
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
                                               GROUP_CONCAT(DISTINCT Genre_Movie.genre_id) AS genre_string,
                                               COUNT(Genre_Movie.genre_id) AS genre_count,
                                               GROUP_CONCAT(DISTINCT Star_Movie.star_id) AS star_string,
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
    CREATE TEMPORARY TABLE preview_panel SELECT t1.user_id AS user
                                        FROM Users AS t1
                                        JOIN (SELECT user_id FROM Users ORDER BY RAND() LIMIT pPanelSize) AS t2 ON t1.user_id = t2.user_id;

    -- combine preview panel and their existing ratings + tags in db
    DROP TEMPORARY TABLE IF EXISTS users_all_ratings;
    CREATE TEMPORARY TABLE users_all_ratings SELECT preview_panel.user AS user, 
                                                    r.rating AS rating, 
                                                    m.movie_id AS movie_id, 
                                                    m.director AS director, 
                                                    m.runtime AS runtime,
                                                    gm.genre_id AS genre,
                                                    tag_occurences.tag AS tags,
                                                    s.star_id AS stars
                                            FROM preview_panel
                                            LEFT JOIN Ratings AS r ON r.user_id = preview_panel.user
                                            LEFT JOIN Movies AS m ON m.movie_id = r.movie_id
                                            LEFT JOIN Genre_Movie AS gm ON gm.movie_id = m.movie_id
                                            LEFT JOIN Star_Movie AS s ON s.movie_id = gm.movie_id
                                            LEFT JOIN movie_common_tags ON movie_common_tags.movie_id = s.movie_id
                                            LEFT JOIN tag_occurences ON FIND_IN_SET(tag_occurences.tag, movie_common_tags.common_tags)
                                            ORDER BY preview_panel.user;
    
    -- preview panel ratings based on genre
    DROP TEMPORARY TABLE IF EXISTS tb_genre_avg;
    CREATE TEMPORARY TABLE tb_genre_avg SELECT release_soon.movie_id, release_soon.genre_string, AVG(uar.rating) AS genre_avg_rating,
                                                SUM(CASE WHEN FIND_IN_SET(uar.genre, release_soon.genre_string) THEN 1 ELSE 0 END) AS users_counted
                                        FROM release_soon
                                        LEFT JOIN users_all_ratings AS uar ON FIND_IN_SET(uar.genre, release_soon.genre_string)
                                        GROUP BY release_soon.movie_id, release_soon.genre_string;

    -- based on director
    DROP TEMPORARY TABLE IF EXISTS tb_director_avg;
    CREATE TEMPORARY TABLE tb_director_avg SELECT release_soon.movie_id, release_soon.director, AVG(uar.rating) AS director_avg_rating,
                                                SUM(CASE WHEN uar.director = release_soon.director THEN 1 ELSE 0 END) AS users_counted
                                        FROM release_soon
                                        LEFT JOIN users_all_ratings AS uar ON uar.director = release_soon.director
                                        GROUP BY release_soon.movie_id, release_soon.director;

    -- based on runtime, assumption ratings based on the length of the movie (runtime - 30 <= movie_runtime <= runtime + 30)
    DROP TEMPORARY TABLE IF EXISTS tb_runtime_avg;
    CREATE TEMPORARY TABLE tb_runtime_avg SELECT release_soon.movie_id, release_soon.runtime, AVG(uar.rating) AS runtime_avg_rating,
                                            SUM(CASE WHEN uar.runtime >= (release_soon.runtime - 30) AND uar.runtime <= (release_soon.runtime + 30) THEN 1 ELSE 0 END) AS users_counted
                                        FROM release_soon
                                        LEFT JOIN users_all_ratings AS uar ON uar.runtime >= (release_soon.runtime - 30) AND uar.runtime <= (release_soon.runtime + 30)
                                        GROUP BY release_soon.movie_id, release_soon.runtime;

    -- based on tags
    DROP TEMPORARY TABLE IF EXISTS tb_tag_avg;
    CREATE TEMPORARY TABLE tb_tag_avg SELECT release_soon.movie_id, release_soon.tag_string, AVG(uar.rating) AS tag_avg_rating,
                                             SUM(CASE WHEN FIND_IN_SET(uar.tags, release_soon.tag_string) THEN 1 ELSE 0 END) AS users_counted
                                        FROM release_soon
                                        LEFT JOIN users_all_ratings AS uar ON FIND_IN_SET(uar.tags, release_soon.tag_string)
                                        GROUP BY release_soon.movie_id, release_soon.tag_string;

    -- based on stars
    DROP TEMPORARY TABLE IF EXISTS tb_star_avg;
    CREATE TEMPORARY TABLE tb_star_avg SELECT release_soon.movie_id, release_soon.star_string, AVG(uar.rating) AS star_avg_rating,
                                            SUM(CASE WHEN FIND_IN_SET(uar.stars, release_soon.star_string) THEN 1 ELSE 0 END) AS users_counted
                                        FROM release_soon
                                        LEFT JOIN users_all_ratings AS uar ON FIND_IN_SET(uar.stars, release_soon.star_string)
                                        GROUP BY release_soon.movie_id, release_soon.star_string;

    -- final table with predicted averages
    DROP TEMPORARY TABLE IF EXISTS tb_predicted_ratings;
    CREATE TEMPORARY TABLE tb_predicted_ratings SELECT rs.movie_id AS movie_id,
                                                    tb_genre_avg.genre_avg_rating AS genre_avg,
                                                    tb_director_avg.director_avg_rating AS director_avg,
                                                    tb_runtime_avg.runtime_avg_rating AS runtime_avg,
                                                    tb_tag_avg.tag_avg_rating AS tag_avg,
                                                    tb_star_avg.star_avg_rating AS star_avg,
                                                    ((
                                                        (tb_genre_avg.genre_avg_rating * (rs.genre_count / 10) * (tb_genre_avg.users_counted / 100)) + 
                                                        (tb_director_avg.director_avg_rating * (1 / 10) * (tb_director_avg.users_counted / 100)) +
                                                        (tb_runtime_avg.runtime_avg_rating * (1 / 10) * (tb_runtime_avg.users_counted / 100)) +
                                                        (tb_tag_avg.tag_avg_rating * (movie_common_tags.tag_count / 10) * (tb_tag_avg.users_counted / 100)) +
                                                        (tb_star_avg.star_avg_rating * (rs.star_count / 10) * (tb_star_avg.users_counted / 100))
                                                    ) / 5) AS movie_predicted_rating
                                                    FROM release_soon AS rs 
                                                    LEFT JOIN tb_genre_avg ON rs.movie_id = tb_genre_avg.movie_id
                                                    LEFT JOIN tb_director_avg ON tb_director_avg.movie_id = tb_genre_avg.movie_id
                                                    LEFT JOIN tb_runtime_avg ON tb_runtime_avg.movie_id = tb_director_avg.movie_id
                                                    LEFT JOIN tb_tag_avg ON tb_tag_avg.movie_id = tb_runtime_avg.movie_id
                                                    LEFT JOIN tb_star_avg ON tb_star_avg.movie_id = tb_tag_avg.movie_id
                                                    LEFT JOIN movie_common_tags ON movie_common_tags.movie_id = tb_star_avg.movie_id
                                                    ORDER BY rs.movie_id ASC;

END$$

DELIMITER ;
