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
DROP procedure IF EXISTS `use6_old`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `use6_old`(IN pmovie_id INT)
BEGIN
    -- Result Vars
    DECLARE res_op FLOAT;
    DECLARE res_ag FLOAT;
    DECLARE res_es FLOAT;
    DECLARE res_ex FLOAT;
    DECLARE res_con FLOAT;
    
    -- Whole table averages 
    DECLARE ave_op FLOAT;
    DECLARE ave_ag FLOAT;
    DECLARE ave_es FLOAT;
    DECLARE ave_ex FLOAT;
    DECLARE ave_con FLOAT;
    
    -- J score and weight vars 
    DECLARE done INTEGER DEFAULT 0;
    DECLARE intersect_length INT; 
    DECLARE union_length INT;
    DECLARE j FLOAT; 
    DECLARE j_sum FLOAT; 
    DECLARE cmovie_id INT;
    DECLARE total_weights INT; 
    DECLARE similar_movie_cursor CURSOR FOR
            SELECT DISTINCT movie_id
            FROM Tags 
            INNER JOIN tags_tbr ON LOWER(Tags.tag) = LOWER(tags_tbr.tag)
            WHERE movie_id != pmovie_id;
    
    SET ave_op = (SELECT AVG(openness) FROM Personality); 
    SET ave_ag = (SELECT AVG(agreeableness) FROM Personality); 
    SET ave_es = (SELECT AVG(emotional_stability) FROM Personality); 
    SET ave_ex = (SELECT AVG(extraversion) FROM Personality); 
    SET ave_con = (SELECT AVG(conscientiousness) FROM Personality); 
    
    DROP TABLE IF EXISTS J_score;
    CREATE TABLE J_score(similar_movie_id INT,
                        j_score FLOAT);                 
    
    -- Get the tags of TBR movie
    DROP TEMPORARY TABLE IF EXISTS tags_tbr;
    CREATE TEMPORARY TABLE tags_tbr SELECT DISTINCT tag FROM Tags WHERE movie_id = pmovie_id; 
    
    -- Calculate J-Score for movies with similar tags
    BEGIN
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN similar_movie_cursor; 
        calculate_J: LOOP
            FETCH similar_movie_cursor INTO cmovie_id;
            IF(done = 1) 
                THEN LEAVE calculate_J;
            END IF;
            DROP TEMPORARY TABLE IF EXISTS tags_B;
            CREATE TEMPORARY TABLE tags_B SELECT tag FROM Tags WHERE movie_id = cmovie_id;

            -- INTERSECTION
            SET intersect_length = (SELECT COUNT(DISTINCT tags_tbr.tag) FROM tags_tbr WHERE LOWER(tags_tbr.tag) IN (SELECT LOWER(tags_B.tag) FROM tags_B));
            -- UNION
            SET union_length = (SELECT COUNT(*) FROM ((SELECT LOWER(tag) FROM tags_tbr) UNION DISTINCT (SELECT LOWER(tag) FROM tags_B)) AS union_table);
            
            SET j = (SELECT intersect_length/union_length);         
            INSERT INTO J_score (similar_movie_id, j_score) VALUES (cmovie_id, j); 
        END LOOP; 
        DROP TEMPORARY TABLE IF EXISTS tags_B;
    END;
    CLOSE similar_movie_cursor; 
    
    -- Find relevant users
    DROP TEMPORARY TABLE IF EXISTS users_high_rate;
    CREATE TEMPORARY TABLE users_high_rate 
    SELECT 
    Personality.user_id, 
    J_score.similar_movie_id AS movie_id,
    J_score.j_score AS score, 
    Personality.openness AS openness, 
    Personality.agreeableness AS agreeableness,
    Personality.emotional_stability AS emotional_stability,
    Personality.conscientiousness AS conscientiousness,
    Personality.extraversion AS extraversion
    FROM J_score
    LEFT JOIN Personality 
    ON (J_score.similar_movie_id = Personality.movie_1) OR (J_score.similar_movie_id = Personality.movie_2)
    OR (J_score.similar_movie_id = Personality.movie_3) OR (J_score.similar_movie_id = Personality.movie_4)
    OR (J_score.similar_movie_id = Personality.movie_5) OR (J_score.similar_movie_id = Personality.movie_6)
    OR (J_score.similar_movie_id = Personality.movie_7) OR (J_score.similar_movie_id = Personality.movie_8)
    OR (J_score.similar_movie_id = Personality.movie_9) OR (J_score.similar_movie_id = Personality.movie_10)
    OR (J_score.similar_movie_id = Personality.movie_11) OR (J_score.similar_movie_id = Personality.movie_12)
    WHERE 
    enjoy_watching >= 4 AND 
    (predicted_rating_1 >= 4 OR predicted_rating_2 >= 4 OR predicted_rating_3 >= 4 OR predicted_rating_4 >= 4 OR
    predicted_rating_5 >= 4 OR predicted_rating_6 >= 4 OR predicted_rating_7 >= 4 OR predicted_rating_8 >= 4 OR
    predicted_rating_9 >= 4 OR predicted_rating_10 >= 4 OR predicted_rating_11 >= 4 OR predicted_rating_12 >= 4);
    
    SET j_sum = (SELECT SUM(score) FROM (SELECT DISTINCT movie_id, score FROM users_high_rate) AS aux_table);
    
    -- Calculate the weighted score for each movie 
    DROP TEMPORARY TABLE IF EXISTS movie_weighted_score;
    CREATE TEMPORARY TABLE movie_weighted_score
    SELECT DISTINCT movie_id, weighted_score
    FROM(SELECT movie_id, 
    score/j_sum as weighted_score
    FROM users_high_rate) AS temp; 
    
    -- Count ratings per movie 
    DROP TEMPORARY TABLE IF EXISTS rating_count_movie;
    CREATE TEMPORARY TABLE rating_count_movie
    SELECT movie_id, 
    COUNT(user_id) AS freq
    FROM users_high_rate
    GROUP BY movie_id; 
    
    -- Count Frequencies of each trait score per movie
    -- OP
    DROP TEMPORARY TABLE IF EXISTS op_freq;
    CREATE TEMPORARY TABLE op_freq
    SELECT movie_id, 
    openness,
    COUNT(openness) as c_openness
    FROM users_high_rate
    GROUP BY movie_id, openness; 
    
    -- Probability of trait for each movie
    DROP TEMPORARY TABLE IF EXISTS op_prob;
    CREATE TEMPORARY TABLE op_prob
    SELECT movie_id, SUM(openness*probability) AS ex
    FROM 
        (SELECT op_freq.movie_id,
        openness,
        c_openness/rating_count_movie.freq as probability
        FROM op_freq
        JOIN rating_count_movie
        ON op_freq.movie_id = rating_count_movie.movie_id) 
    AS inter
    GROUP BY movie_id;
    
    -- Res OP
    SET res_op = 
    (SELECT SUM(expectation) FROM
    (SELECT op_prob.movie_id, ex * weighted_score as expectation
    FROM op_prob
    INNER JOIN movie_weighted_score
    ON op_prob.movie_id = movie_weighted_score.movie_id) AS aux);
    
    -- AG
    DROP TEMPORARY TABLE IF EXISTS ag_freq;
    CREATE TEMPORARY TABLE ag_freq
    SELECT movie_id, 
    agreeableness,
    COUNT(agreeableness) as c_agreeableness
    FROM users_high_rate
    GROUP BY movie_id, agreeableness; 
    
    -- Probability of trait for each movie
    DROP TEMPORARY TABLE IF EXISTS ag_prob;
    CREATE TEMPORARY TABLE ag_prob
    SELECT movie_id, SUM(agreeableness*probability) AS ex
    FROM 
    (SELECT ag_freq.movie_id,
    agreeableness,
    c_agreeableness/rating_count_movie.freq as probability
    FROM ag_freq
    JOIN rating_count_movie
    ON ag_freq.movie_id = rating_count_movie.movie_id) AS inter
    GROUP BY movie_id;
    
    -- Res ag
    SET res_ag = 
    (SELECT SUM(expectation) FROM
    (SELECT ag_prob.movie_id, ex * weighted_score as expectation
    FROM ag_prob
    INNER JOIN movie_weighted_score
    ON ag_prob.movie_id = movie_weighted_score.movie_id) AS aux);
    
    -- ES
    DROP TEMPORARY TABLE IF EXISTS es_freq;
    CREATE TEMPORARY TABLE es_freq
    SELECT movie_id, 
    emotional_stability,
    COUNT(emotional_stability) as c_emotional_stability
    FROM users_high_rate
    GROUP BY movie_id, emotional_stability; 
    
    -- Probability of trait for each movie
    DROP TEMPORARY TABLE IF EXISTS es_prob;
    CREATE TEMPORARY TABLE es_prob
    SELECT movie_id, SUM(emotional_stability*probability) AS ex
    FROM 
    (SELECT es_freq.movie_id,
    emotional_stability,
    c_emotional_stability/rating_count_movie.freq as probability
    FROM es_freq
    JOIN rating_count_movie
    ON es_freq.movie_id = rating_count_movie.movie_id) AS inter
    GROUP BY movie_id;
    
    -- Res es
    SET res_es = 
    (SELECT SUM(expectation) FROM
    (SELECT es_prob.movie_id, ex * weighted_score as expectation
    FROM es_prob
    INNER JOIN movie_weighted_score
    ON es_prob.movie_id = movie_weighted_score.movie_id) AS aux);
    
    -- EX
    DROP TEMPORARY TABLE IF EXISTS ex_freq;
    CREATE TEMPORARY TABLE ex_freq
    SELECT movie_id, 
    extraversion,
    COUNT(extraversion) as c_extraversion
    FROM users_high_rate
    GROUP BY movie_id, extraversion; 
    
    -- Probability of trait for each movie
    DROP TEMPORARY TABLE IF EXISTS ex_prob;
    CREATE TEMPORARY TABLE ex_prob
    SELECT movie_id, SUM(extraversion*probability) AS ex
    FROM 
    (SELECT ex_freq.movie_id,
    extraversion,
    c_extraversion/rating_count_movie.freq as probability
    FROM ex_freq
    JOIN rating_count_movie
    ON ex_freq.movie_id = rating_count_movie.movie_id) AS inter
    GROUP BY movie_id;
    
    -- Res es
    SET res_ex = 
    (SELECT SUM(expectation) FROM
    (SELECT ex_prob.movie_id, ex * weighted_score as expectation
    FROM ex_prob
    INNER JOIN movie_weighted_score
    ON ex_prob.movie_id = movie_weighted_score.movie_id) AS aux);
    
    -- CON
    DROP TEMPORARY TABLE IF EXISTS con_freq;
    CREATE TEMPORARY TABLE con_freq
    SELECT movie_id, 
    conscientiousness,
    COUNT(conscientiousness) as c_conscientiousness
    FROM users_high_rate
    GROUP BY movie_id, conscientiousness; 
        
    -- Probability of trait for each movie
    DROP TEMPORARY TABLE IF EXISTS con_prob;
    CREATE TEMPORARY TABLE con_prob
    SELECT movie_id, SUM(conscientiousness*probability) AS ex
    FROM 
    (SELECT con_freq.movie_id,
    conscientiousness,
    c_conscientiousness/rating_count_movie.freq as probability
    FROM con_freq
    JOIN rating_count_movie
    ON con_freq.movie_id = rating_count_movie.movie_id) AS inter
    GROUP BY movie_id;
    
    -- Res con
    SET res_con = 
    (SELECT SUM(expectation) FROM
    (SELECT con_prob.movie_id, ex * weighted_score as expectation
    FROM con_prob
    INNER JOIN movie_weighted_score
    ON con_prob.movie_id = movie_weighted_score.movie_id) AS aux);
    
    SELECT (res_op - ave_op) AS openness, 
    (res_ag - ave_ag) As agree, 
    (res_con - ave_con) AS con, 
    (res_ex - ave_ex) AS extraver, 
    (res_es - ave_es) AS emotional_stab;
    
    DROP TABLE IF EXISTS J_score;
END$$

DELIMITER ;