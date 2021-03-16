USE `MovieLens`;
DROP procedure IF EXISTS `use6`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `use6`(IN pmovie_id INT)
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
    
    -- Get the tags of TBR movie
    DROP TEMPORARY TABLE IF EXISTS tags_tbr;
    CREATE TEMPORARY TABLE tags_tbr SELECT DISTINCT tag FROM Tags WHERE movie_id = pmovie_id; 
    
    SET tags_tbr_len = (SELECT COUNT(*) FROM tags_tbr); 
    
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
    
    -- SET @sum_jscore = (SELECT SUM(j_score) FROM J_score); 

	/*
    DROP TEMPORARY TABLE IF EXISTS relevant_users;
    CREATE TEMPORARY TABLE relevant_users 
    SELECT 
    Personality_Ratings.user_id AS user_id,
    group_concat(t1.movie_id)
    FROM similar_movies LEFT JOIN Personality_Ratings 
    ON (similar_movies.movie_id = Personality_Ratings.movie_id)
    LEFT JOIN Personality_Ratings AS t1 
    ON (similar_movies.movie_id = t1.movie_id)
    GROUP BY user_id
    HAVING AVG(Personality_Ratings.rating) >= 4;
	*/
    
	DROP TEMPORARY TABLE IF EXISTS relevant_users;
    CREATE TEMPORARY TABLE relevant_users 
    SELECT 
    Personality_Ratings.user_id AS user_id
    FROM similar_movies
    LEFT JOIN Personality_Ratings 
    ON (similar_movies.movie_id = Personality_Ratings.movie_id)
    GROUP BY user_id
    HAVING AVG(Personality_Ratings.rating) >= 4;
    
    
    -- DROP TEMPORARY TABLE IF EXISTS relevant_users;
    -- CREATE TEMPORARY TABLE relevant_users 
    -- SELECT 
    -- Personality_Ratings.user_id AS user_id
    -- FROM similar_movies
    -- LEFT JOIN Personality_Ratings 
    -- ON (similar_movies.movie_id = Personality_Ratings.movie_id)
    -- GROUP BY user_id
    -- HAVING AVG(Personality_Ratings.rating) >= 4;
    
    DROP TEMPORARY TABLE IF EXISTS relevant_users_movies;
	CREATE TEMPORARY TABLE relevant_users_movies 
	SELECT 
	relevant_users.user_id AS user_id,
	similar_movies.movie_id AS movie_id,
	J_score.j_score
	FROM relevant_users
	LEFT JOIN (Personality_Ratings INNER JOIN (similar_movies, J_score)
				ON (Personality_Ratings.movie_id = similar_movies.movie_id
				AND similar_movies.movie_id = J_score.movie_id))
	ON relevant_users.user_id = Personality_Ratings.user_id;

	SET @j_score_sum = (SELECT SUM(j_score) FROM relevant_users_movies);

	DROP TEMPORARY TABLE IF EXISTS relevant_users_j_score;
	CREATE TEMPORARY TABLE relevant_users_j_score
	SELECT 
	relevant_users_movies.user_id AS user_id,
	SUM(j_score)/@j_score_sum AS weight
	FROM relevant_users_movies
	GROUP BY user_id;

	DROP TEMPORARY TABLE IF EXISTS personality_traits;
	CREATE TEMPORARY TABLE personality_traits
	SELECT 
	SUM(openness * weight) AS openness, 
	SUM(agreeableness * weight) AS agreeableness, 
	SUM(conscientiousness * weight) AS conscientiousness, 
	SUM(emotional_stability * weight) AS emotional_stability, 
	SUM(extraversion * weight) AS extraversion
	FROM relevant_users_j_score
	LEFT JOIN Personality 
	ON (Personality.user_id = relevant_users_j_score.user_id);

    SELECT * FROM personality_traits;

    
END$$

DELIMITER ;

