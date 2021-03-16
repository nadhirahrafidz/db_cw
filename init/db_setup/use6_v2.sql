USE `MovieLens`;
DROP procedure IF EXISTS `use6_v2`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `use6_v2`(IN pmovie_id INT)
BEGIN
    -- Result Vars
    DECLARE res_op FLOAT;
    DECLARE res_ag FLOAT;
    DECLARE res_es FLOAT;
    DECLARE res_ex FLOAT;
    DECLARE res_con FLOAT;
    
    -- Whole table averages 
    /*
    DECLARE ave_op FLOAT;
    DECLARE ave_ag FLOAT;
    DECLARE ave_es FLOAT;
    DECLARE ave_ex FLOAT;
    DECLARE ave_con FLOAT;
    */
    
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
    
    DROP TEMPORARY TABLE IF EXISTS tags_similar_movies;
    CREATE TEMPORARY TABLE tags_similar_movies 
    SELECT DISTINCT movie_id, Tags.tag
    FROM Tags 
    INNER JOIN tags_tbr ON LOWER(Tags.tag) = LOWER(tags_tbr.tag)
    WHERE movie_id IN (SELECT movie_id FROM similar_movies); 
    
    DROP TEMPORARY TABLE IF EXISTS intersect;
    CREATE TEMPORARY TABLE intersect 
    SELECT tags_similar_movies.movie_id, COUNT(DISTINCT tags_tbr.tag) AS intersect_len 
    FROM tags_similar_movies 
    INNER JOIN tags_tbr
    ON LOWER(tags_similar_movies.tag) = LOWER(tags_tbr.tag)
    GROUP BY tags_similar_movies.movie_id;
    
    -- STEP4: j_score = intersect/union
    DROP TEMPORARY TABLE IF EXISTS J_score;
    CREATE TEMPORARY TABLE J_score 
    SELECT intersect.movie_id, intersect_len/tags_tbr_len AS j_score
    FROM intersect;
    
	DROP TEMPORARY TABLE IF EXISTS pers_rating_movies;
    CREATE TEMPORARY TABLE pers_rating_movies 
    SELECT 
    Personality_Ratings.user_id AS user_id, 
    J_score.movie_id AS movie_id,
    J_score.j_score AS score
    FROM J_score
    LEFT JOIN Personality_Ratings 
    ON (J_score.movie_id = Personality_Ratings.movie_id)
    WHERE Personality_Ratings.rating >=4;
    
    -- Find relevant users
    DROP TEMPORARY TABLE IF EXISTS users_high_rate;
    CREATE TEMPORARY TABLE users_high_rate 
    SELECT 
    pers_rating_movies.user_id, 
    pers_rating_movies.movie_id AS movie_id,
    pers_rating_movies.score AS score, 
    Personality.openness AS openness, 
    Personality.agreeableness AS agreeableness,
    Personality.emotional_stability AS emotional_stability,
    Personality.conscientiousness AS conscientiousness,
    Personality.extraversion AS extraversion
    FROM pers_rating_movies
    LEFT JOIN Personality
    ON (pers_rating_movies.user_id = Personality.user_id);
    
    SET j_sum = (SELECT SUM(score) FROM (SELECT DISTINCT movie_id, score FROM users_high_rate) AS aux_table);
    
    -- Calculate the weighted score for each movie 
    DROP TEMPORARY TABLE IF EXISTS movie_weighted_score;
    CREATE TEMPORARY TABLE movie_weighted_score
    SELECT DISTINCT movie_id, weighted_score
    FROM (SELECT movie_id, 
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
    -- OPENNESS
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
    SELECT movie_id, SUM(openness*probability) AS expectation
    FROM 
        (SELECT op_freq.movie_id,
        openness,
        c_openness/rating_count_movie.freq as probability
        FROM op_freq
        JOIN rating_count_movie
        ON op_freq.movie_id = rating_count_movie.movie_id) 
    AS intermediate_probability_table
    GROUP BY movie_id;
    
    -- Res OP
    SET res_op = 
    (SELECT SUM(final_expectation) 
    FROM
        (SELECT op_prob.movie_id, expectation * weighted_score as final_expectation
        FROM op_prob
        INNER JOIN movie_weighted_score
        ON op_prob.movie_id = movie_weighted_score.movie_id) 
    AS aux);
    
    -- AGREEABLENESS
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
    SELECT movie_id, SUM(agreeableness*probability) AS expectation
    FROM 
        (SELECT ag_freq.movie_id,
        agreeableness,
        c_agreeableness/rating_count_movie.freq as probability
        FROM ag_freq
        JOIN rating_count_movie
        ON ag_freq.movie_id = rating_count_movie.movie_id) 
    AS intermediate_probability_table
    GROUP BY movie_id;
    
    -- Res ag
    SET res_ag = 
    (SELECT SUM(final_expectation) 
    FROM
        (SELECT ag_prob.movie_id, expectation * weighted_score as final_expectation
        FROM ag_prob
        INNER JOIN movie_weighted_score
        ON ag_prob.movie_id = movie_weighted_score.movie_id) 
    AS aux);
    
    -- EMOTIONAL STABILITY
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
    SELECT movie_id, SUM(emotional_stability*probability) AS expectation
    FROM 
        (SELECT es_freq.movie_id,
        emotional_stability,
        c_emotional_stability/rating_count_movie.freq as probability
        FROM es_freq
        JOIN rating_count_movie
        ON es_freq.movie_id = rating_count_movie.movie_id) 
    AS intermediate_probability_table
    GROUP BY movie_id;
    
    -- Res es
    SET res_es = 
    (SELECT SUM(final_expectation) 
    FROM
        (SELECT es_prob.movie_id, expectation * weighted_score as final_expectation
        FROM es_prob
        INNER JOIN movie_weighted_score
        ON es_prob.movie_id = movie_weighted_score.movie_id) 
    AS aux);
    
    -- EXTRAVERSION
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
    SELECT movie_id, SUM(extraversion*probability) AS expectation
    FROM 
        (SELECT ex_freq.movie_id,
        extraversion,
        c_extraversion/rating_count_movie.freq as probability
        FROM ex_freq
        JOIN rating_count_movie
        ON ex_freq.movie_id = rating_count_movie.movie_id) 
    AS intermediate_probability_table
    GROUP BY movie_id;
    
    -- Res es
    SET res_ex = 
    (SELECT SUM(final_expectation) 
    FROM
        (SELECT ex_prob.movie_id, expectation * weighted_score as final_expectation
        FROM ex_prob
        INNER JOIN movie_weighted_score
        ON ex_prob.movie_id = movie_weighted_score.movie_id) 
    AS aux);
    
    -- CONSCIENTIOUSNESS
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
    SELECT movie_id, SUM(conscientiousness*probability) AS expectation
    FROM 
        (SELECT con_freq.movie_id,
        conscientiousness,
        c_conscientiousness/rating_count_movie.freq as probability
        FROM con_freq
        JOIN rating_count_movie
        ON con_freq.movie_id = rating_count_movie.movie_id) 
    AS intermediate_probability_table
    GROUP BY movie_id;
    
    -- Res con
    SET res_con = 
    (SELECT SUM(final_expectation) 
    FROM
        (SELECT con_prob.movie_id, expectation * weighted_score as final_expectation
        FROM con_prob
        INNER JOIN movie_weighted_score
        ON con_prob.movie_id = movie_weighted_score.movie_id) 
    AS aux);
    
    /*
    SELECT (res_op - ave_op) AS openn, 
    (res_ag - ave_ag) As agree, 
    (res_con - ave_con) AS con, 
    (res_ex - ave_ex) AS extra, 
    (res_es - ave_es) AS emo_stab;
    */
    
	-- SELECT res_op AS openn, 
    -- res_ag As agree, 
    -- res_con AS con, 
    -- res_ex AS extra, 
    -- res_es AS emo_stab;

    SELECT @ave_op AS average_openness, 
    @ave_ag AS average_agreeableness, 
    @ave_con AS average_conscientiousness, 
    @ave_ex AS average_extraversion, 
    @ave_es AS average_emotional_stability,
    (res_op) AS openness, 
    (res_ag) As agreeableness, 
    (res_con) AS conscientiousness, 
    (res_ex) AS extraversion, 
    (res_es) AS emotional_stability;
    
    -- Housekeeping
    DROP TEMPORARY TABLE IF EXISTS tags_tbr;
    DROP TEMPORARY TABLE IF EXISTS movie_similar_genre;
    DROP TEMPORARY TABLE IF EXISTS movie_similar_tag;
    DROP TEMPORARY TABLE IF EXISTS similar_movies;
    DROP TEMPORARY TABLE IF EXISTS intersection;
    DROP TEMPORARY TABLE IF EXISTS J_score;
    DROP TEMPORARY TABLE IF EXISTS weighted_J_score;
    DROP TEMPORARY TABLE IF EXISTS users_high_rate;
    
    DROP TEMPORARY TABLE IF EXISTS op_freq;
    DROP TEMPORARY TABLE IF EXISTS ex_freq;
    DROP TEMPORARY TABLE IF EXISTS es_freq;
    DROP TEMPORARY TABLE IF EXISTS ag_freq;
    DROP TEMPORARY TABLE IF EXISTS con_freq;
    DROP TEMPORARY TABLE IF EXISTS op_prob;
    DROP TEMPORARY TABLE IF EXISTS ex_prob;
    DROP TEMPORARY TABLE IF EXISTS es_prob;
    DROP TEMPORARY TABLE IF EXISTS ag_prob;
    DROP TEMPORARY TABLE IF EXISTS con_prob;
END$$

DELIMITER ;

