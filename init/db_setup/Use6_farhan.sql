-- -- /*

-- -- Input: To-be-released (TBR) movie id
-- -- Output: A Float score (1-7) of the following personality trait metrics:
-- -- 1. Openness
-- -- 2. Agreeableness
-- -- 3. Conscientiousness
-- -- 4. Emotional Stability
-- -- 5. Extraversion

-- -- J score is the Jaccard index of two sets of movie tags. It measures how similar one set is to the other. The higher the J score, the 
-- -- higher the similarity. A J score of 1 means that the two sets are identical. 

-- -- Outline of the procedure: 
-- -- 1. Get set of tags from TBR movies (TBR tags)
-- -- 2. Get movie_id if movies with similar tags to TBR tags. 
-- -- 3. Calculate J_scores of similar movies (SHOULD there be a threshold?)
-- -- 4. Find users from Personality Table who have rated the similar movies > 4 
-- -- 5. Calculate weighted j_score for each movie                                    [movie_weighted_score table]
-- -- 6. Calculate the number of user ratings for each movie                          [ratings_count_movie]

-- -- Then for each trait:
-- -- 7. Count the frequency of each score for each movie                                                     [**_freq table]
-- -- 8. Calculate the probability of each trait score for each movie                                         [**_prob table]
-- -- 9. Multiply j_score weights with each trait score probability for each movie
-- -- 10. Get the expected trait result by summing the weighted trait for each movie (calculated in step 9)    [**_res table]    

-- -- */


USE `MovieLens`;
DROP procedure IF EXISTS `use6_farhan`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `use6_farhan`(IN pmovie_id INT)
BEGIN
    -- Result Vars
    DECLARE res_op FLOAT;
    DECLARE res_ag FLOAT;
    DECLARE res_es FLOAT;
    DECLARE res_ex FLOAT;
    DECLARE res_con FLOAT;
    
    -- J score and weight vars 
    DECLARE intersect_length INT; 
    DECLARE tags_tbr_len INT;
    DECLARE j FLOAT; 
    DECLARE j_sum FLOAT; 
    DECLARE total_weights INT; 
    
    
    SET @ave_op = (SELECT AVG(openness) FROM Personality); 
    SET @ave_ag = (SELECT AVG(agreeableness) FROM Personality); 
    SET @ave_es = (SELECT AVG(emotional_stability) FROM Personality); 
    SET @ave_ex = (SELECT AVG(extraversion) FROM Personality); 
    SET @ave_con = (SELECT AVG(conscientiousness) FROM Personality); 
    
    -- Get the tags of TBR movie
    DROP TEMPORARY TABLE IF EXISTS tags_tbr;
    CREATE TEMPORARY TABLE tags_tbr SELECT DISTINCT tag FROM Tags WHERE movie_id = pmovie_id; 
    
    SET tags_tbr_len = (SELECT COUNT(*) FROM tags_tbr); 
    
    
    -- Sub-tables for similar_movies: movie_similar_genre and movie_similar_tag
    BEGIN
    -- (1) Select Movies with similar genres
    DROP TEMPORARY TABLE IF EXISTS movie_similar_genre;
    CREATE TEMPORARY TABLE movie_similar_genre
    SELECT DISTINCT(movie_id) 
    FROM Genre_Movie 
    WHERE genre_id IN (SELECT DISTINCT(genre_id) FROM Genre_Movie WHERE movie_id = pmovie_id) 
    AND movie_id != pmovie_id; 
    
    -- (2) Select Movies with similar tags
    DROP TEMPORARY TABLE IF EXISTS movie_similar_tag;
    CREATE TEMPORARY TABLE movie_similar_tag
    SELECT DISTINCT(movie_id) 
    FROM Tags 
    WHERE tag IN (SELECT tag FROM Tags WHERE movie_id = pmovie_id) AND movie_id != pmovie_id; 
    END;
    
    DROP TEMPORARY TABLE IF EXISTS similar_movies;
    CREATE TEMPORARY TABLE similar_movies
    SELECT movie_similar_genre.movie_id 
    FROM movie_similar_genre 
    INNER JOIN movie_similar_tag
    ON movie_similar_genre.movie_id = movie_similar_tag.movie_id; 

    DROP TEMPORARY TABLE IF EXISTS relevant_users;
    CREATE TEMPORARY TABLE relevant_users 
    SELECT 
    Personality_Ratings.user_id AS user_id
    FROM similar_movies
    LEFT JOIN Personality_Ratings 
    ON (similar_movies.movie_id = Personality_Ratings.movie_id)
    GROUP BY user_id
    HAVING AVG(Personality_Ratings.rating) >= 4;

    DROP TEMPORARY TABLE IF EXISTS personality_traits;
    CREATE TEMPORARY TABLE personality_traits 
    SELECT 
    AVG(openness) AS openness, 
    AVG(agreeableness) AS agreeableness, 
    AVG(conscientiousness) AS conscientiousness, 
    AVG(emotional_stability) AS emotional_stability, 
    AVG(extraversion) AS extraversion
    FROM relevant_users
    LEFT JOIN Personality 
    ON (Personality.user_id = relevant_users.user_id);

    SELECT @ave_op AS average_openness, 
    @ave_ag AS average_agreeableness, 
    @ave_con AS average_conscientiousness, 
    @ave_ex AS average_extraversion, 
    @ave_es AS average_emotional_stability,
    * 
    FROM personality_traits;

    
END$$

DELIMITER ;

