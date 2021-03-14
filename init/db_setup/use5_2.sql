USE `MovieLens`;
DROP procedure IF EXISTS `use5_v4`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`%` PROCEDURE `use5_v4`(
                            IN psample_size INT, 
                            IN ptbrmovie_id INT)
BEGIN   
    -- Declaring Variables
    DECLARE tbr_tag_len INT; 
    DECLARE sum_jscore FLOAT; 
    DECLARE count_similar_movie_ratings INT; 
    -- J score and weight vars 
    DECLARE j_sum FLOAT; 
    DECLARE total_weights INT; 

            
    -- Note: Not selecting top 25 percentile of users who have the most number of ratings (MIN 20, MAX 2698) 
    -- Weakness: some people from preview panel may never have seen ANY movie from similar movies
    DROP TEMPORARY TABLE IF EXISTS preview_pan;
    CREATE TEMPORARY TABLE preview_pan
    SELECT user_id, rating FROM Ratings WHERE movie_id = ptbrmovie_id ORDER BY RAND() LIMIT psample_size;
    
    -- Select tables that make up similar_movies_w_ave (Tables: movie_similar_genre, movie_similar_tag, similar_movies)
    BEGIN
    -- (1) Select Movies with similar genres
    DROP TEMPORARY TABLE IF EXISTS movie_similar_genre;
    CREATE TEMPORARY TABLE movie_similar_genre
    SELECT DISTINCT(movie_id) 
    FROM Genre_Movie 
    WHERE genre_id IN (SELECT DISTINCT(genre_id) FROM Genre_Movie WHERE movie_id = ptbrmovie_id) 
    AND movie_id != ptbrmovie_id; 
    
    -- (2) Select Movies with similar tags
    DROP TEMPORARY TABLE IF EXISTS movie_similar_tag;
    CREATE TEMPORARY TABLE movie_similar_tag
    SELECT DISTINCT(movie_id) 
    FROM Tags 
    WHERE tag IN (SELECT tag FROM Tags WHERE movie_id = ptbrmovie_id) AND movie_id != ptbrmovie_id; 
    
    
    DROP TEMPORARY TABLE IF EXISTS similar_movies;
    CREATE TEMPORARY TABLE similar_movies
    SELECT movie_similar_genre.movie_id 
    FROM movie_similar_genre 
    INNER JOIN movie_similar_tag
    ON movie_similar_genre.movie_id = movie_similar_tag.movie_id; 
    END;
    
    DROP TEMPORARY TABLE IF EXISTS similar_movies_w_ave;
    CREATE TEMPORARY TABLE similar_movies_w_ave
    SELECT similar_movies.movie_id, AVG(Ratings.rating) AS ave_rating
    FROM similar_movies 
    INNER JOIN Ratings ON similar_movies.movie_id = Ratings.movie_id 
    GROUP BY movie_id; 
    
    -- Preview panel rating of similar movies
    BEGIN
    DROP TEMPORARY TABLE IF EXISTS prev_pan_sim_movies;
    CREATE TEMPORARY TABLE prev_pan_sim_movies
    SELECT preview_pan.user_id as user_id, Ratings.movie_id, Ratings.rating as rating
    FROM preview_pan 
    INNER JOIN Ratings 
    ON preview_pan.user_id = Ratings.user_id; 
    END;
    
    -- [1] Preview panel with deviations from typical rating 
    DROP TEMPORARY TABLE IF EXISTS prev_pan_dev;
    CREATE TEMPORARY TABLE prev_pan_dev
    SELECT prev_pan_sim_movies.user_id, similar_movies_w_ave.movie_id, 1 - ((prev_pan_sim_movies.rating - ave_rating) / ave_rating) AS deviation
    FROM similar_movies_w_ave 
    INNER JOIN prev_pan_sim_movies
    ON similar_movies_w_ave.movie_id = prev_pan_sim_movies.movie_id;  
    
    -- Tags of TBR movie
    DROP TEMPORARY TABLE IF EXISTS tags_tbr;
    CREATE TEMPORARY TABLE tags_tbr
    SELECT Tag FROM Tags WHERE Tags.movie_id = ptbrmovie_id;
    
    SET tbr_tag_len = (SELECT COUNT(*) FROM tags_tbr); 
    
    -- [2] J score calc  (Tables: tags_similar_movies, intersect, union_tags, J_score)
    BEGIN
    -- STEP 1: Find tags of similar movies
    DROP TEMPORARY TABLE IF EXISTS tags_similar_movies;
    CREATE TEMPORARY TABLE tags_similar_movies 
    SELECT movie_id, tag 
    FROM Tags 
    WHERE movie_id IN (SELECT movie_id FROM similar_movies); 
    
    -- STEP 2: Get set intersection length between tbr tags and similar movie tags
    -- Note: this is not 100% accurate.. 
        -- If TBR movie has tags (pixar, pixar) & similar movie has tags (pixar, pixar)  => Intersect length is 1 
        -- Cannot distinguish that these tags are unique bc they are made by different people.
    DROP TEMPORARY TABLE IF EXISTS intersect;
    CREATE TEMPORARY TABLE intersect 
    SELECT tags_similar_movies.movie_id, COUNT(DISTINCT tags_tbr.tag) AS intersect_len 
    FROM tags_similar_movies 
    INNER JOIN tags_tbr
    ON LOWER(tags_similar_movies.tag) = LOWER(tags_tbr.tag)
    GROUP BY tags_similar_movies.movie_id;
    
    -- STEP 3: Get set union length between tbr tags and similar movie tags (not 100% accurate since intersect length is not accurate) 
    DROP TEMPORARY TABLE IF EXISTS union_tags;
    CREATE TEMPORARY TABLE union_tags 
    SELECT intermediate.movie_id, (union_w_dupes - intersect.intersect_len) AS union_len
    FROM
        (SELECT tags_similar_movies.movie_id, COUNT(DISTINCT tags_similar_movies.tag) + tbr_tag_len AS union_w_dupes
        FROM tags_similar_movies
        GROUP BY tags_similar_movies.movie_id) AS intermediate
    INNER JOIN intersect
    ON intermediate.movie_id = intersect.movie_id ; 
    
    -- STEP4: j_score = intersect/union
    DROP TEMPORARY TABLE IF EXISTS J_score;
    CREATE TEMPORARY TABLE J_score 
    SELECT intersect.movie_id, intersect_len/union_len AS j_score
    FROM intersect
    INNER JOIN union_tags
    ON intersect.movie_id = union_tags.movie_id; 
    END;
    
    SET sum_jscore = (SELECT SUM(j_score) FROM J_score); 
    
    -- Note: Movie weights should add to ~1
    DROP TEMPORARY TABLE IF EXISTS weighted_J_score;
    CREATE TEMPORARY TABLE weighted_J_score 
    SELECT J_score.movie_id, j_score/sum_jscore AS weighted_j_score
    FROM J_score; 
    
    -- Preparing each user's weights 
    BEGIN
    -- user_id, SUM([1]*[2]) => [3]
    DROP TEMPORARY TABLE IF EXISTS numer;
    CREATE TEMPORARY TABLE numer 
    SELECT user_id, SUM(intermediate.mult_weights) as sum_mult_weights
    FROM
        (SELECT user_id, weighted_j_score * deviation AS mult_weights 
        FROM prev_pan_dev
        LEFT JOIN weighted_J_score 
        ON prev_pan_dev.movie_id = weighted_J_score.movie_id) AS intermediate
    GROUP BY user_id; 
    
    -- user_id, SUM([j_score]) => [4]
    DROP TEMPORARY TABLE IF EXISTS denom;
    CREATE TEMPORARY TABLE denom 
    SELECT prev_pan_dev.user_id, SUM(weighted_J_score.weighted_j_score) AS sum_j_score
    FROM prev_pan_dev
    INNER JOIN weighted_J_score 
    ON prev_pan_dev.movie_id = weighted_J_score.movie_id
    GROUP BY user_id; 
    
    -- user_id, [3]/[4]
    DROP TEMPORARY TABLE IF EXISTS user_weights;
    CREATE TEMPORARY TABLE user_weights 
    SELECT numer.user_id, sum_mult_weights/denom.sum_j_score as weight
    FROM numer
    INNER JOIN denom 
    ON numer.user_id = denom.user_id; 
    END;
    
    -- Weighted rating of TBR movie
    DROP TEMPORARY TABLE IF EXISTS weighted_ratings;
    CREATE TEMPORARY TABLE weighted_ratings 
    SELECT preview_pan.user_id, (preview_pan.rating * user_weights.weight) AS weighted_rating
    FROM preview_pan
    INNER JOIN user_weights
    ON preview_pan.user_id = user_weights.user_id; 
    
    -- Note: not all similar movies would be included -> Excluded: similar movies that have never been watched by anyone from preview panel
    SET count_similar_movie_ratings = (SELECT COUNT(*) FROM weighted_ratings); 
    
    -- Housekeeping
    BEGIN
    DROP TEMPORARY TABLE IF EXISTS similar_movies;
    DROP TEMPORARY TABLE IF EXISTS similar_movies_ave;
    DROP TEMPORARY TABLE IF EXISTS tags_similar_movies;
    DROP TEMPORARY TABLE IF EXISTS movie_similar_tag;
    DROP TEMPORARY TABLE IF EXISTS movie_similar_genre;
    DROP TEMPORARY TABLE IF EXISTS prev_pan_sim_movies;
    DROP TEMPORARY TABLE IF EXISTS prev_pan_dev;
    DROP TEMPORARY TABLE IF EXISTS intersect;
    DROP TEMPORARY TABLE IF EXISTS union_tags;
    DROP TEMPORARY TABLE IF EXISTS J_score;
    DROP TEMPORARY TABLE IF EXISTS weighted_J_score;
    DROP TEMPORARY TABLE IF EXISTS user_weights;
    DROP TEMPORARY TABLE IF EXISTS numer;
    DROP TEMPORARY TABLE IF EXISTS denom;
    END; 
    
    SELECT SUM(weighted_rating)/count_similar_movie_ratings FROM weighted_ratings; 
END$$

DELIMITER ;

