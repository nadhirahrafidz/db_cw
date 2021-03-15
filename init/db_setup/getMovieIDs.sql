USE `MovieLens`;
DROP procedure IF EXISTS `getMovieIDs`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `getMovieIDs` (
    IN no_of_results VARCHAR(32),
    IN offset_required VARCHAR(32),
    IN genres_chosen VARCHAR(1000),
    IN search_value VARCHAR(255),
    IN order_by_parameter INT
    )

BEGIN
SET @no_of_results = no_of_results;
SET @offset_required = offset_required;
SET @search_value = search_value; 

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

IF search_value = "" and genres_chosen = "" THEN
    BEGIN
        SET @SQLstatement = "SELECT DISTINCT Movies.movie_id, Movies.title ?
            FROM Movies 
            ?
            GROUP BY Movies.movie_id
            ORDER BY ?
            LIMIT ?
            OFFSET ?";

    PREPARE stmt FROM @SQLStatement;
    EXECUTE stmt USING @select_params, @join_params, @order_by, @no_of_results, @offset_required;
    END;
    
ELSEIF search_value = "" THEN 
    BEGIN
        SET @SQLstatement = "SELECT DISTINCT Movies.movie_id, Movies.title ?
            FROM Movies 
            ?
            LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) 
            ON Genre_Movie.movie_id = Movies.movie_id
            WHERE find_in_set(Genres.genre, ?)
            GROUP BY Movies.movie_id
            ORDER BY ?
            LIMIT ?
            OFFSET ?";
            
            PREPARE stmt FROM @SQLStatement;
            EXECUTE stmt USING @select_params, @join_params, @genres_chosen, @order_by, @no_of_results, @offset_required;
    END;

ELSEIF genres_chosen = "" THEN
    BEGIN
        set @SQLstatement = "SELECT DISTINCT Movies.movie_id, Movies.title ?
            FROM Movies 
            ?
            WHERE Movies.title LIKE ?
            GROUP BY Movies.movie_id
            ORDER BY ? 
            LIMIT ?
            OFFSET ?";

            PREPARE stmt FROM @SQLStatement;
            EXECUTE stmt USING @select_params, @join_params, @search_value, @order_by, @no_of_results, @offset_required;
    END;

ELSE
    BEGIN
    SET @SQLstatement = "SELECT DISTINCT Movies.movie_id, Movies.title ?
        FROM Movies 
        ?
        LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) 
        ON Genre_Movie.movie_id = Movies.movie_id
        WHERE find_in_set(Genres.genre, ?)
        AND Movies.title LIKE ?
        GROUP BY Movies.movie_id
        ORDER BY ?
        LIMIT ?
        OFFSET ?";

        PREPARE stmt FROM @SQLStatement;
        EXECUTE stmt USING @select_params, @join_params, @genres_chosen, @search_value, @order_by, @no_of_results, @offset_required;
    END;
END IF;

END$$
DELIMITER ;
