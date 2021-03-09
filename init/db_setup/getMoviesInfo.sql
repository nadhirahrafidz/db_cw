USE `MovieLens`;
DROP procedure IF EXISTS `getMoviesInfo`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `getMoviesInfo` (
    IN movieIDs VARCHAR(255),
    IN order_by_paramater VARCHAR(255)
    )

BEGIN
set @order_by = CASE order_by_paramater
                      when 1 then "Movies.title ASC"
                      when 2 then "Movies.title DESC"
                      when 3 then "rating DESC"
                      WHEN 4 then "Movies.movie_id DESC"
                      ELSE "Movies.movie_id ASC"
                      END;

set @SQLstatement = CONCAT("SELECT 
  DISTINCT Movies.movie_id, 
  Movies.title, 
  Movies.movieURL,
  Movies.director,
  Movies.runtime,
  GROUP_CONCAT(DISTINCT Stars.star_name SEPARATOR', ') AS stars,
  GROUP_CONCAT(DISTINCT Genres.genre) AS genres,
  ROUND(AVG(Ratings.rating),1) AS rating,
  GROUP_CONCAT(DISTINCT Tags.tag SEPARATOR', ') AS tags
  FROM Movies
  LEFT JOIN (Star_Movie LEFT JOIN Stars ON Star_Movie.star_id = Stars.star_id) ON
  Star_Movie.movie_id = Movies.movie_id 
  LEFT JOIN (Genre_Movie LEFT JOIN Genres ON Genre_Movie.genre_id = Genres.genre_id) ON
  Genre_Movie.movie_id = Movies.movie_id
  LEFT JOIN Ratings ON
  Ratings.movie_id = Movies.movie_id 
  LEFT JOIN Tags ON
  Tags.movie_id = Movies.movie_id 
  WHERE find_in_set(Movies.movie_id, '", movieIDs, "')
  GROUP BY Movies.movie_id
  ORDER BY ", @order_by);
PREPARE stmt FROM @SQLStatement;
EXECUTE stmt;
END$$

DELIMITER ;
