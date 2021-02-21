USE `MovieLens`;
DROP procedure IF EXISTS `getMoviesInfo`;

DELIMITER $$
USE `MovieLens`$$
CREATE PROCEDURE `getMoviesInfo` (
    IN movieIDs VARCHAR(255)
    )

BEGIN
  SELECT DISTINCT Movies.movie_id, Movies.title, Movies.movieURL,
  GROUP_CONCAT(DISTINCT Stars.star_name) AS stars, 
  GROUP_CONCAT(DISTINCT Genres.genre) AS genres,
  ROUND(AVG(Ratings.rating),1) AS rating
  FROM Movies, Stars, Star_Movie, Genres, Genre_Movie, Ratings
  WHERE find_in_set(Movies.movie_id, movieIDs)
  AND Movies.movie_id = Star_Movie.movie_id
  AND Star_Movie.star_id = Stars.star_id 
  AND Movies.movie_id = Genre_Movie.movie_id
  AND Genre_Movie.genre_id = Genres.genre_id
  AND Ratings.movie_id = Movies.movie_id
  GROUP BY Movies.movie_id;
END$$

DELIMITER ;
