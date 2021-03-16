USE `MovieLens`;
-- DROP procedure IF EXISTS `getMovieIDs`;

DELIMITER $$
USE `MovieLens`$$
CREATE DEFINER=`root`@`localhost`
PROCEDURE `getMovieIDs` (
    IN no_of_results INT,
    IN offset_required INT,
    IN genres_chosen INT,
    IN search_value VARCHAR(255),
    IN order_by_parameter INT
    )

BEGIN
SET @no_of_results = no_of_results;
SET @offset_required = offset_required;
SET @search_value = search_value; 
SET @genres_chosen = genres_chosen;

set @order_by = CASE order_by_parameter
                      when 1 then "Movies.title ASC"
                      when 2 then "Movies.title DESC"
                      when 3 then "rating DESC"
                      WHEN 4 then "Movies.movie_id DESC"
                      ELSE "Movies.movie_id ASC"
                      END;

set @select_params = CASE order_by_parameter
                      when 3 then ", AVG(Ratings.rating) as rating "
                      ELSE " "
                      END;

set @join_params = CASE order_by_parameter
                      when 3 then "LEFT JOIN Ratings ON Ratings.movie_id = Movies.movie_id "
                      ELSE " "
                      END;

IF search_value = "" and genres_chosen = 0 THEN
    BEGIN
        SET @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title ", @select_params, " 
            FROM Movies ", @join_params, " 
            GROUP BY Movies.movie_id
            ORDER BY ", @order_by, " 
            LIMIT ?
            OFFSET ?");

    PREPARE stmt FROM @SQLStatement;
    EXECUTE stmt USING @no_of_results, @offset_required;
    END;
    
ELSEIF search_value = "" THEN 
    BEGIN
        SET @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title ", @select_params, " 
            FROM Movies ", @join_params, " 
            LEFT JOIN Genre_Movie ON Genre_Movie.movie_id = Movies.movie_id
            WHERE Genre_Movie.genre_id = ?
            GROUP BY Movies.movie_id
            ORDER BY ", @order_by, " 
            LIMIT ?
            OFFSET ?");
            
            PREPARE stmt FROM @SQLStatement;
            EXECUTE stmt USING @genres_chosen, @no_of_results, @offset_required;
    END;

ELSEIF genres_chosen = 0 THEN
    BEGIN
        SET @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title ", @select_params, "
            FROM Movies ", @join_params, " 
            WHERE Movies.title LIKE ?
            GROUP BY Movies.movie_id
            ORDER BY ", @order_by, " 
            LIMIT ?
            OFFSET ?");

            PREPARE stmt FROM @SQLStatement;
            EXECUTE stmt USING @search_value, @no_of_results, @offset_required;
    END;

ELSE
    BEGIN
    SET @SQLstatement = CONCAT("SELECT DISTINCT Movies.movie_id, Movies.title ", @select_params, "
        FROM Movies ", @join_params, " 
        LEFT JOIN Genre_Movie ON Genre_Movie.movie_id = Movies.movie_id
		WHERE Genre_Movie.genre_id = ?
        AND Movies.title LIKE ?
        GROUP BY Movies.movie_id
        ORDER BY ", @order_by, " 
        LIMIT ?
        OFFSET ?");

        PREPARE stmt FROM @SQLStatement;
        EXECUTE stmt USING @genres_chosen, @search_value, @no_of_results, @offset_required;
    END;
END IF;

END$$
DELIMITER ;
